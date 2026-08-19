package com.controller.home;

import com.DAO.WishlistDAO;
import com.DAO.CategoryDAO;
import com.entity.Account;
import com.entity.Course;
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

@WebServlet(name = "WishlistController", urlPatterns = {"/wishlist"})
public class WishlistController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
            return;
        }

        WishlistDAO wishlistDAO = new WishlistDAO();
        List<Course> wishlistCourses = wishlistDAO.getCoursesByAccountId(account.getId());

        Set<Integer> categoryIds = new HashSet<>();
        for (Course c : wishlistCourses) {
            categoryIds.add(c.getCategoryId());
        }
        Map<Integer, String> categoryNames = new CategoryDAO().findNames(categoryIds);
        for (Course c : wishlistCourses) {
            c.setCategoryName(categoryNames.get(c.getCategoryId()));
        }

        request.setAttribute("wishlistCourses", wishlistCourses);
        request.getRequestDispatcher("/view/course_learning/wishlist.jsp").forward(request, response);
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

        if (account == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"error\", \"message\":\"Unauthorized: Please log in first.\"}");
            return;
        }

        String action = request.getParameter("action");
        String courseIdParam = request.getParameter("courseId");
        WishlistDAO wishlistDAO = new WishlistDAO();
        boolean isSuccess = false;

        try {
            String idError = MyLearningValidator.validateCourseId(courseIdParam);
            if (idError != null) {
                out.print("{\"status\":\"error\", \"message\":\"" + idError + "\"}");
                return;
            }
            int courseId = Integer.parseInt(courseIdParam);
            int userId = account.getId();

            if ("add".equals(action)) {
                isSuccess = wishlistDAO.add(userId, courseId);
            } else if ("remove".equals(action)) {
                isSuccess = wishlistDAO.remove(userId, courseId);
            } else if ("toggle".equals(action)) {
                isSuccess = wishlistDAO.toggle(userId, courseId);
            }

            if (isSuccess) {
                out.print("{\"status\":\"success\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\":\"Operation failed in database.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}