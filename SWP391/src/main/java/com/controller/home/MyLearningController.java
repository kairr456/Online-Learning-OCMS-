package com.controller.home;

import com.DAO.CourseRegistrationDAO;
import com.DAO.LearningDAO;
import com.DAO.UserLearningListDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.UserLearningList;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MyLearningController", urlPatterns = {"/all-courses", "/my-list", "/wishlist", "/archived", "/learning-tools", "/my-learning"})
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

        Map<Integer, Integer> courseProgress = new LearningDAO().getCourseProgressMap(account.getId());
        for (Course c : myCourses) {
            Integer p = courseProgress.get(c.getId());
            c.setProgress(p != null ? p : 0);
        }

        UserLearningListDAO listDAO = new UserLearningListDAO();
        List<UserLearningList> myLists = listDAO.getListsByAccountId(account.getId());

        request.setAttribute("myCourses", myCourses);
        request.setAttribute("myLists", myLists);

        // /my-learning is kept as an alias for /all-courses so old links still work.
        String view;
        switch (request.getServletPath()) {
            case "/my-list":
                view = "/view/course_learning/my_list.jsp";
                break;
            case "/wishlist":
                view = "/view/course_learning/wishlist.jsp";
                break;
            case "/archived":
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
            if ("create".equals(action)) {
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