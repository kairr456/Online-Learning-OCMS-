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
@WebServlet(name = "CourseHomeController", urlPatterns = {"/course-list"})
public class CourseHomeController extends HttpServlet {
    private static final String COURSE_LIST_PAGE = "view/common/browse-course.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Tạm thời tạo dữ liệu ảo (mock data) để xây dựng UI cho giống mẫu
            
            // Mock Danh sách Categories (allCategories)
            List<java.util.Map<String, Object>> allCategories = new java.util.ArrayList<>();
            String[] catNames = {"c#", "java", ".net", "c+", "c++", "html"};
            for (int i = 0; i < catNames.length; i++) {
                java.util.Map<String, Object> cat = new java.util.HashMap<>();
                cat.put("id", i + 1);
                cat.put("name", catNames[i]);
                allCategories.add(cat);
            }
            
            // Mock Author Names (authorNames)
            java.util.Map<Integer, String> authorNames = new java.util.HashMap<>();
            authorNames.put(1, "Nguyen Van A");
            authorNames.put(2, "Tran Thi B");
            
            // Mock Category Names (categoryNames)
            java.util.Map<Integer, String> categoryNames = new java.util.HashMap<>();
            for (int i = 0; i < catNames.length; i++) {
                categoryNames.put(i + 1, catNames[i]);
            }
            
            // Mock Danh sách Khóa học (courses)
            List<Course> courses = new ArrayList<>();
            for (int i = 1; i <= 9; i++) {
                Course c = new Course();
                c.setId(i);
                c.setName("Lập trình " + catNames[i % catNames.length]);
                c.setDescription("Description for course " + i);
                c.setThumbnail("https://via.placeholder.com/300x180.png?text=Course+" + i);
                c.setRating((i % 5) + 1);
                c.setPrice(49.99f + i);
                c.setCategoryId((i % catNames.length) + 1);
                c.setCreatedBy((i % 2) + 1);
                courses.add(c);
            }
            
            // Pagination info (Mocked as if we have multiple pages to demonstrate)
            int currentPage = 1;
            int totalRecords = 57;
            int totalPages = 7; 
            
            // Send attributes to JSP
            request.setAttribute("courses", courses);
            request.setAttribute("allCategories", allCategories);
            request.setAttribute("authorNames", authorNames);
            request.setAttribute("categoryNames", categoryNames);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRecords", totalRecords);
            
            // Forward to browse-course.jsp
            request.getRequestDispatcher(COURSE_LIST_PAGE).forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("404.jsp");
        }
    }
}
