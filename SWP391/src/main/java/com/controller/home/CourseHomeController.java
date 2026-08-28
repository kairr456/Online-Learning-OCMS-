/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.controller.home;

import com.DAO.AccountDAO;
import com.DAO.CategoryDAO;
import com.DAO.CourseDAO;
import com.DAO.CourseRegistrationDAO;
import com.DAO.WishlistDAO;
import com.entity.Account;
import com.entity.Category;
import com.entity.Course;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
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
<<<<<<< Updated upstream
            if (teacherName != null) {
                teacherName = teacherName.trim();
                if (teacherName.isEmpty()) teacherName = null;
            }
            String courseName = request.getParameter("courseName");
            if (courseName != null) {
                courseName = courseName.trim();
                if (courseName.isEmpty()) courseName = null;
            }
=======
            if (teacherName != null) teacherName = teacherName.trim().replaceAll("\\s+", " ");
            String courseName = request.getParameter("courseName");
            if (courseName != null) courseName = courseName.trim().replaceAll("\\s+", " ");
>>>>>>> Stashed changes
            String sort = request.getParameter("sort");
//            if (sort == null || sort.isEmpty()) {
//            sort = "Latest"; // Mặc định sắp xếp mới nhất
//             }
            String pageParam = request.getParameter("page");

            // 2. Parse Parameters
            List<Integer> categoryIds = new ArrayList<>();
            List<String> selectedCategoriesStr = new ArrayList<>();
            if (categoryParams != null) {
                for (String c : categoryParams) {
                    if (c != null && !c.trim().isEmpty()) {
                        selectedCategoriesStr.add(c.trim());
                        try { categoryIds.add(Integer.parseInt(c.trim())); } catch (NumberFormatException ignored) {}
                    }
                }
            }

            List<Integer> ratings = new ArrayList<>();
            List<String> selectedRatingsStr = new ArrayList<>();
            if (ratingParams != null) {
                for (String r : ratingParams) {
                    if (r != null && !r.trim().isEmpty()) {
                        selectedRatingsStr.add(r.trim());
                        try { ratings.add(Integer.parseInt(r.trim())); } catch (NumberFormatException ignored) {}
                    }
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
//            if (courses.size()>3){
//                courses=courses.subList(0, 3);
//            }
            int totalRecords = courseDAO.getTotalFilteredRecords(categoryIds, ratings, teacherName, courseName);   
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

            // 4. Load Author Names
            AccountDAO accountDAO = new AccountDAO();
            Map<Integer, String> authorNames = accountDAO.getAuthorNames();
            
            // 4.5. Load Enrolled Courses
            Set<Integer> enrolledCourseIds = new HashSet<>();
            Set<Integer> wishlistCourseIds = new HashSet<>();
            Account account = (Account) request.getSession().getAttribute("account");
            if (account != null) {
                CourseRegistrationDAO regDAO = new CourseRegistrationDAO();
                enrolledCourseIds.addAll(regDAO.getEnrolledCourseIds(account.getId()));
                
                // ALSO add courses created by the user (so they are free for the creator)
                List<Course> createdCourses = courseDAO.findByCreator(account.getId());
                for (Course c : createdCourses) {
                    enrolledCourseIds.add(c.getId());
                }

                // Load wishlist course ids (to pre-fill heart icons)
                wishlistCourseIds = new WishlistDAO().getCourseIdsByAccountId(account.getId());
            }
            
            // 5. Set Attributes
            request.setAttribute("courses", courses);
            request.setAttribute("authorNames", authorNames);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("enrolledCourseIds", enrolledCourseIds);
            request.setAttribute("wishlistCourseIds", wishlistCourseIds);
            
            // Keep selected filter state in UI
            request.setAttribute("selectedCategories", categoryIds);
            request.setAttribute("selectedRatings", ratings);
            request.setAttribute("selectedCategoriesStr", selectedCategoriesStr);
            request.setAttribute("selectedRatingsStr", selectedRatingsStr);
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
