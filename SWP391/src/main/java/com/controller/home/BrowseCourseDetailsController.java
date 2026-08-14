/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.controller.home;

import com.DAO.AccountDAO;
import com.DAO.CourseDAO;
import com.DAO.ReviewDAO;
import com.entity.Course;
import com.entity.Review;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller to view course details
 */
@WebServlet(name = "BrowseCourseDetailsController", urlPatterns = {"/course"})
public class BrowseCourseDetailsController extends HttpServlet {
    private static final String COURSE_DETAILS_PAGE = "view/common/home/course-details.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                int courseId = Integer.parseInt(idParam);
                
                CourseDAO courseDAO = new CourseDAO();
                Course course = courseDAO.findById(courseId);
                
                if (course != null) {
                    AccountDAO accountDAO = new AccountDAO();
                    Map<Integer, String> authorNames = accountDAO.getAuthorNames();
                    
                    ReviewDAO reviewDAO = new ReviewDAO();
                    List<Review> reviews = reviewDAO.getReviewsByCourseId(courseId);
                    
                    request.setAttribute("course", course);
                    request.setAttribute("authorName", authorNames.get(course.getCreatedBy()));
                    request.setAttribute("reviews", reviews);
                    // Also pass authorNames so we can lookup reviewer names in the JSP
                    request.setAttribute("accountNames", authorNames);
                } else {
                    response.sendRedirect("404.jsp");
                    return;
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            // Forward to course-details.jsp
            request.getRequestDispatcher(COURSE_DETAILS_PAGE).forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("404.jsp");
        }
    }
}

