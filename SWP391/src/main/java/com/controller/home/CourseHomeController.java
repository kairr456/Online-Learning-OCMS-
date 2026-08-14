/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.controller.home;

import com.DAO.AccountDAO;
import com.DAO.CategoryDAO;
import com.DAO.CourseDAO;
import com.entity.Category;
import com.entity.Course;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author cuong
 */
@WebServlet(name = "CourseHomeController", urlPatterns = {"/courses"})
public class CourseHomeController extends HttpServlet {
    private static final String COURSE_LIST_PAGE = "view/common/home/browse-course.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Load categories from DB for sidebar
            CategoryDAO categoryDAO = new CategoryDAO();
            List<Category> allCategories = categoryDAO.findAll();
            request.setAttribute("allCategories", allCategories);

            // 1. Get Parameters
            String[] categoryParams = request.getParameterValues("category");
            String[] ratingParams = request.getParameterValues("rating");
            String teacherName = request.getParameter("teacherName");
            String courseName = request.getParameter("courseName");
            String sort = request.getParameter("sort");
            String pageParam = request.getParameter("page");

            // 2. Parse Parameters
            List<Integer> categoryIds = new ArrayList<>();
            if (categoryParams != null) {
                for (String c : categoryParams) {
                    try { categoryIds.add(Integer.parseInt(c)); } catch (NumberFormatException ignored) {}
                }
            }

            List<Integer> ratings = new ArrayList<>();
            if (ratingParams != null) {
                for (String r : ratingParams) {
                    try { ratings.add(Integer.parseInt(r)); } catch (NumberFormatException ignored) {}
                }
            }

            int currentPage = 1;
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    currentPage = Integer.parseInt(pageParam);
                } catch (NumberFormatException ignored) {}
            }
            int pageSize = 9; // 9 items per page

            // 3. Query Database
            CourseDAO courseDAO = new CourseDAO();
            List<Course> courses = courseDAO.findWithFilters(categoryIds, ratings, teacherName, courseName, sort, currentPage, pageSize);
            int totalRecords = courseDAO.getTotalFilteredRecords(categoryIds, ratings, teacherName, courseName);
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

            // 4. Load Author Names
            AccountDAO accountDAO = new AccountDAO();
            Map<Integer, String> authorNames = accountDAO.getAuthorNames();
            
            // 5. Set Attributes
            request.setAttribute("courses", courses);
            request.setAttribute("authorNames", authorNames);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", currentPage);
            
            // Keep selected filter state in UI
            request.setAttribute("selectedCategories", categoryIds);
            request.setAttribute("selectedRatings", ratings);
            request.setAttribute("teacherName", teacherName);
            request.setAttribute("courseName", courseName);
            request.setAttribute("sort", sort);

            // Forward to browse-course.jsp
            request.getRequestDispatcher(COURSE_LIST_PAGE).forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("404.jsp");
        }
    }
}
