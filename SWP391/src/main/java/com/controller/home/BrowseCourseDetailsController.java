/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.controller.home;

import com.entity.Course;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author cuong
 */
@WebServlet(name = "BrowseCourseDetailsController", urlPatterns = {"/browse-course"})
public class BrowseCourseDetailsController extends HttpServlet {
    private static final String BROWSE_COURSE_PAGE = "view/common/browse-course.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Tạm thời chưa dùng database theo yêu cầu
            List<Course> courses = new ArrayList<>();
            
            // Send course list to JSP
            request.setAttribute("courses", courses);
            
            // Forward to browse-course.jsp
            request.getRequestDispatcher(BROWSE_COURSE_PAGE).forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("404.jsp");
        }
    }
}
