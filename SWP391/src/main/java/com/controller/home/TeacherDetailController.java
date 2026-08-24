package com.controller.home;

import com.DAO.AccountDAO;
import com.DAO.CategoryDAO;
import com.DAO.CourseDAO;
import com.entity.Account;
import com.entity.Category;
import com.entity.Course;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "TeacherDetailController", urlPatterns = {"/teacher-detail", "/instructor"})
public class TeacherDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            idParam = request.getParameter("teacherId");
        }

        int teacherId = 0;
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                teacherId = Integer.parseInt(idParam.trim());
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }
        } else {
            // Fallback: If logged-in user is a teacher and no ID is supplied, show own profile
            Account sessionAccount = (Account) request.getSession().getAttribute("account");
            if (sessionAccount != null && sessionAccount.getRoleId() == 2) {
                teacherId = sessionAccount.getId();
            } else {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }
        }

        AccountDAO accountDAO = new AccountDAO();
        Account teacher = accountDAO.getAccountById(teacherId);

        if (teacher == null) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        // Fetch courses created by this teacher
        CourseDAO courseDAO = new CourseDAO();
        List<Course> courses = courseDAO.findByCreator(teacherId);

        // Fetch categories map for display
        CategoryDAO categoryDAO = new CategoryDAO();
        List<Category> allCategories = categoryDAO.findAll();
        Map<Integer, String> categoryMap = new HashMap<>();
        if (allCategories != null) {
            for (Category cat : allCategories) {
                categoryMap.put(cat.getId(), cat.getName());
            }
        }

        int totalCourses = (courses != null) ? courses.size() : 0;

        request.setAttribute("teacher", teacher);
        request.setAttribute("courses", courses);
        request.setAttribute("totalCourses", totalCourses);
        request.setAttribute("categoryMap", categoryMap);

        request.getRequestDispatcher("/view/home/teacher-detail.jsp").forward(request, response);
    }
}
