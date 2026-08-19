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

        // Tự động archive những khóa học đã hoàn thành 100% (xử lý cả dữ liệu cũ)
        ArchivedCourseDAO archiveDAO = new ArchivedCourseDAO();
        Set<Integer> archivedCourseIds = archiveDAO.getCourseIdsByAccountId(account.getId());
        for (Course c : myCourses) {
            if (c.getProgress() >= 100 && !archivedCourseIds.contains(c.getId())) {
                archiveDAO.add(account.getId(), c.getId());
                archivedCourseIds.add(c.getId());
            }
        }

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
                if (days == null || days.trim().isEmpty()) {
                    out.print("{\"status\":\"error\", \"message\":\"Please select at least one day.\"}");
                    return;
                }
                String reminderTime = request.getParameter("reminderTime");
                if (reminderTime == null || reminderTime.trim().isEmpty()) {
                    reminderTime = "20:00";
                }
                boolean enabled = "true".equalsIgnoreCase(request.getParameter("enabled"))
                        || "on".equalsIgnoreCase(request.getParameter("enabled"))
                        || "1".equals(request.getParameter("enabled"));
                isSuccess = new ReminderDAO().upsert(account.getId(), days, reminderTime, enabled);

            } else if ("testReminder".equals(action)) {
                StringBuilder body = new StringBuilder();
                body.append("Hi ").append(account.getFullName() != null ? account.getFullName() : account.getUsername()).append(",\n\n");
                body.append("This is a test reminder from OCMS. Here is what you are currently learning:\n\n");
                List<Course> enrolled = new CourseRegistrationDAO().getCoursesByAccountId(account.getId());
                if (enrolled.isEmpty()) {
                    body.append("- You have not enrolled in any course yet.\n");
                } else {
                    for (Course c : enrolled) {
                        body.append("- ").append(c.getName()).append("\n");
                    }
                }
                body.append("\nKeep up the good work!\nOCMS");
                EmailService.sendEmail("ducduy8000pro@gmail.com", "OCMS - Learning Reminder (Test)", body.toString());
                out.print("{\"status\":\"success\",\"message\":\"Test reminder email sent\"}");
                return;

            } else if ("create".equals(action)) {
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                int newListId = listDAO.createList(account.getId(), title, description);
                if (newListId > 0) {
                    isSuccess = true;
                    String courseId = request.getParameter("courseId");
                    if (courseId != null && !courseId.trim().isEmpty()) {
                        isSuccess = new UserLearningListDAO().addCourseToList(newListId, Integer.parseInt(courseId));
                    }
                }

            } else if ("update".equals(action)) {
                int listId = Integer.parseInt(request.getParameter("listId"));
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                isSuccess = listDAO.updateList(listId, account.getId(), title, description);

            } else if ("delete".equals(action)) {
                int listId = Integer.parseInt(request.getParameter("listId"));
                isSuccess = listDAO.deleteList(listId, account.getId());

            } else if ("addCourse".equals(action)) {
                int listId = Integer.parseInt(request.getParameter("listId"));
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                isSuccess = listDAO.addCourseToList(listId, courseId);

            } else if ("removeCourse".equals(action)) {
                int listId = Integer.parseInt(request.getParameter("listId"));
                int courseId = Integer.parseInt(request.getParameter("courseId"));
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