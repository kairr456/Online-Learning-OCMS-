/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.controller.home;

import com.entity.Course;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller to view course details
 */
@WebServlet(name = "BrowseCourseDetailsController", urlPatterns = {"/course-details"})
public class BrowseCourseDetailsController extends HttpServlet {
    private static final String COURSE_DETAILS_PAGE = "view/homepage/course_details.jsp"; // Or any specific view you have

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get course ID from request parameter
            String courseIdStr = request.getParameter("id");
            if (courseIdStr != null && !courseIdStr.isEmpty()) {
                int courseId = Integer.parseInt(courseIdStr);
                
                // Mock fetching course by ID since CourseDAO is not fully implemented yet
                Course course = new Course();
                course.setId(courseId);
                course.setName("Mock Course " + courseId);
                course.setDescription("Mock description for course " + courseId);
                course.setPrice(49.99f);
                course.setRating(5);
                course.setThumbnail("https://via.placeholder.com/600x400.png?text=Course+" + courseId);
                course.setCreatedBy(1);
                
                if (course != null) {
                    request.setAttribute("course", course);
                    request.getRequestDispatcher(COURSE_DETAILS_PAGE).forward(request, response);
                } else {
                    // Handle course not found
                    response.sendRedirect("404.jsp");
                }
            } else {
                // Handle missing course ID
                response.sendRedirect("404.jsp");
            }
        } catch (NumberFormatException e) {
            // Handle invalid course ID format
            response.sendRedirect("404.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("view/homepage/home.jsp").forward(request, response);
    }
}
