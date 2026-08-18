package com.controller.courseCRUD;

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
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CourseDashboardController", urlPatterns = {"/course-dashboard"})
public class CourseDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        CourseDAO courseDAO = new CourseDAO();
        CategoryDAO categoryDAO = new CategoryDAO();

        int pageSize = 8;
        int pageNumber = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                pageNumber = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                pageNumber = 1;
            }
        }

        String courseName = request.getParameter("courseName");
        String sort = request.getParameter("sort");
        String categoryParam = request.getParameter("category");

        List<Integer> categoryIds = new ArrayList<>();
        if (categoryParam != null && !categoryParam.isEmpty()) {
            try {
                categoryIds.add(Integer.parseInt(categoryParam));
            } catch (NumberFormatException ignored) {}
        }

        // We don't filter by ratings on the new dashboard design
        List<Integer> ratings = new ArrayList<>();

        List<Course> courses = courseDAO.findCreatorCoursesWithFilters(account.getId(), categoryIds, ratings, courseName, sort, pageNumber, pageSize);
        int totalRecords = courseDAO.getTotalCreatorFilteredRecords(account.getId(), categoryIds, ratings, courseName);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        List<Category> allCategories = categoryDAO.findAll();

        request.setAttribute("courses", courses);
        request.setAttribute("allCategories", allCategories);
        request.setAttribute("currentPage", pageNumber);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("selectedCategory", categoryIds.isEmpty() ? null : categoryIds.get(0));
        request.setAttribute("courseName", courseName);
        request.setAttribute("sort", sort);
        
        request.getRequestDispatcher("/view/courseCRUD/course-dashboard.jsp").forward(request, response);
    }
}
