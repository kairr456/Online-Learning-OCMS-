package com.controller.home;

import com.DAO.ArchivedCourseDAO;
import com.DAO.CourseRegistrationDAO;
import com.DAO.CategoryDAO;
import com.DAO.LearningDAO;
import com.DAO.ReminderDAO;
import com.DAO.UserLearningListDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.LearningReminder;
import com.entity.UserLearningList;
import com.utils.EmailService;
import com.validator.MyLearningValidator;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MyLearningController", urlPatterns = {"/all-courses", "/my-list", "/archived", "/learning-tools", "/my-learning"})
public class MyLearningController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
            return;
        }

        CourseRegistrationDAO registrationDAO = new CourseRegistrationDAO();
        List<Course> myCourses = registrationDAO.getCoursesByAccountId(account.getId());

        // Tự động kiểm tra và cấp chứng chỉ còn thiếu cho các khóa học đã hoàn thành 100%
        com.DAO.CertificateDAO certDAO = new com.DAO.CertificateDAO();
        certDAO.autoIssuePendingCertificatesForStudent(account.getId());
        request.setAttribute("certTemplateIds", certDAO.getTemplateCourseIds());
        request.setAttribute("certCodeMap", certDAO.getCertificateCodeMapByAccount(account.getId()));
        
        // Also add courses that the user created
        com.DAO.CourseDAO courseDAO = new com.DAO.CourseDAO();
        List<Course> createdCourses = courseDAO.findByCreator(account.getId());
        for (Course c : createdCourses) {
            boolean exists = false;
            for (Course m : myCourses) {
                if (m.getId() == c.getId()) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                myCourses.add(c);
            }
        }

        Map<Integer, Integer> courseProgress = new LearningDAO().getCourseProgressMap(account.getId());
        for (Course c : myCourses) {
            Integer p = courseProgress.get(c.getId());
            c.setProgress(p != null ? p : 0);
        }

        ArchivedCourseDAO archiveDAO = new ArchivedCourseDAO();
        Set<Integer> archivedCourseIds = archiveDAO.getCourseIdsByAccountId(account.getId());

        // Khóa học đã archived không còn hiển thị ở All Courses
        myCourses.removeIf(c -> archivedCourseIds.contains(c.getId()));

        Set<Integer> categoryIds = new HashSet<>();
        for (Course c : myCourses) {
            categoryIds.add(c.getCategoryId());
        }
        Map<Integer, String> categoryNames = new CategoryDAO().findNames(categoryIds);
        for (Course c : myCourses) {
            c.setCategoryName(categoryNames.get(c.getCategoryId()));
        }

        UserLearningListDAO listDAO = new UserLearningListDAO();
        List<UserLearningList> myLists = listDAO.getListsByAccountId(account.getId());

        LearningReminder reminder = new ReminderDAO().getByAccountId(account.getId());

        request.setAttribute("myCourses", myCourses);
        request.setAttribute("myLists", myLists);
        request.setAttribute("reminder", reminder);

        // /my-learning is kept as an alias for /all-courses so old links still work.
        String view;
        switch (request.getServletPath()) {
            case "/my-list":
                view = "/view/course_learning/my_list.jsp";
                break;
            case "/archived":
                request.setAttribute("archivedCourses", archiveDAO.getCoursesByAccountId(account.getId()));
                view = "/view/course_learning/archived.jsp";
                break;
            case "/learning-tools":
                view = "/view/course_learning/learning_tools.jsp";
                break;
            case "/all-courses":
            case "/my-learning":
            default:
                view = "/view/course_learning/all_courses.jsp";
                break;
        }

        request.getRequestDispatcher(view).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        PrintWriter out = response.getWriter();

        // Kiểm tra đăng nhập
        if (account == null) {
            out.print("{\"status\":\"error\", \"message\":\"Unauthorized\"}");
            return;
        }

        String action = request.getParameter("action");
        UserLearningListDAO listDAO = new UserLearningListDAO();
        boolean isSuccess = false;

        try {
            if ("saveReminder".equals(action)) {
                String days = request.getParameter("days");
                String daysError = MyLearningValidator.validateReminderDays(days);
                if (daysError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + daysError + "\"}");
                    return;
                }
                String reminderTime = request.getParameter("reminderTime");
                String timeError = MyLearningValidator.validateReminderTime(reminderTime);
                if (timeError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + timeError + "\"}");
                    return;
                }
                if (MyLearningValidator.isBlank(reminderTime)) {
                    reminderTime = "20:00";
                } else {
                    reminderTime = reminderTime.trim();
                    if (reminderTime.length() == 4) {
                        reminderTime = "0" + reminderTime;
                    }
                    if (reminderTime.length() > 5) {
                        reminderTime = reminderTime.substring(0, 5);
                    }
                }
                boolean enabled = "true".equalsIgnoreCase(request.getParameter("enabled"))
                        || "on".equalsIgnoreCase(request.getParameter("enabled"))
                        || "1".equals(request.getParameter("enabled"));
                isSuccess = new ReminderDAO().upsert(account.getId(), days, reminderTime, enabled);

            } else if ("testReminder".equals(action)) {
                Account currentAccount = new com.DAO.AccountDAO().getAccountById(account.getId());
                if (currentAccount == null) {
                    currentAccount = account;
                } else {
                    session.setAttribute("account", currentAccount);
                }

                String recipientEmail = currentAccount.getEmail();
                if (MyLearningValidator.isBlank(recipientEmail)) {
                    out.print("{\"status\":\"error\", \"message\":\"No email address found for your account.\"}");
                    return;
                }

                StringBuilder body = new StringBuilder();
                body.append("Hi ").append(currentAccount.getFullName() != null && !currentAccount.getFullName().trim().isEmpty() ? currentAccount.getFullName() : currentAccount.getUsername()).append(",\n\n");
                body.append("This is a test reminder from OCMS. Here is what you are currently learning:\n\n");
                List<Course> enrolled = new CourseRegistrationDAO().getCoursesByAccountId(currentAccount.getId());
                if (enrolled.isEmpty()) {
                    body.append("- You have not enrolled in any course yet.\n");
                } else {
                    for (Course c : enrolled) {
                        body.append("- ").append(c.getName()).append("\n");
                    }
                }
                body.append("\nKeep up the good work!\nOCMS");
                try {
                    String userEmail = account.getEmail();
                    if (userEmail == null || userEmail.trim().isEmpty()) {
                        out.print("{\"status\":\"error\", \"message\":\"Tài khoản hiện tại chưa có email!\"}");
                        return;
                    }
                    EmailService.sendEmail(userEmail, "OCMS - Learning Reminder (Test)", body.toString());
                } catch (Exception e) {
                    e.printStackTrace();
                    out.print("{\"status\":\"error\", \"message\":\"Failed to send email: " + e.getMessage() + "\"}");
                    return;
                }
                out.print("{\"status\":\"success\",\"message\":\"Test reminder email sent to " + recipientEmail + "\"}");
                return;

            } else if ("create".equals(action)) {
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String titleError = MyLearningValidator.validateListTitle(title);
                if (titleError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + titleError + "\"}");
                    return;
                }
                int newListId = listDAO.createList(account.getId(), title, description);
                if (newListId > 0) {
                    isSuccess = true;
                    String courseId = request.getParameter("courseId");
                    if (!MyLearningValidator.isBlank(courseId)) {
                        String courseError = MyLearningValidator.validateCourseId(courseId);
                        if (courseError != null) {
                            out.print("{\"status\":\"error\", \"message\":\"" + courseError + "\"}");
                            return;
                        }
                        isSuccess = new UserLearningListDAO().addCourseToList(newListId, Integer.parseInt(courseId));
                    }
                }

            } else if ("update".equals(action)) {
                String listIdParam = request.getParameter("listId");
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String updateError = MyLearningValidator.validateListId(listIdParam);
                if (updateError == null) {
                    updateError = MyLearningValidator.validateListTitle(title);
                }
                if (updateError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + updateError + "\"}");
                    return;
                }
                int listId = Integer.parseInt(listIdParam);
                isSuccess = listDAO.updateList(listId, account.getId(), title, description);

            } else if ("delete".equals(action)) {
                String listIdParam = request.getParameter("listId");
                String idError = MyLearningValidator.validateListId(listIdParam);
                if (idError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + idError + "\"}");
                    return;
                }
                int listId = Integer.parseInt(listIdParam);
                isSuccess = listDAO.deleteList(listId, account.getId());

            } else if ("addCourse".equals(action)) {
                String listIdParam = request.getParameter("listId");
                String courseIdParam = request.getParameter("courseId");
                String addError = MyLearningValidator.validateListId(listIdParam);
                if (addError == null) {
                    addError = MyLearningValidator.validateCourseId(courseIdParam);
                }
                if (addError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + addError + "\"}");
                    return;
                }
                int listId = Integer.parseInt(listIdParam);
                int courseId = Integer.parseInt(courseIdParam);
                isSuccess = listDAO.addCourseToList(listId, courseId);

            } else if ("removeCourse".equals(action)) {
                String listIdParam = request.getParameter("listId");
                String courseIdParam = request.getParameter("courseId");
                String removeError = MyLearningValidator.validateListId(listIdParam);
                if (removeError == null) {
                    removeError = MyLearningValidator.validateCourseId(courseIdParam);
                }
                if (removeError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + removeError + "\"}");
                    return;
                }
                int listId = Integer.parseInt(listIdParam);
                int courseId = Integer.parseInt(courseIdParam);
                isSuccess = listDAO.removeCourseFromList(listId, courseId);
            }

            if (isSuccess) {
                out.print("{\"status\":\"success\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\":\"Operation failed\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage() + "\"}");
        }
    }
}