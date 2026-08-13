package com.controller.admin;

import com.DAO.AdminDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

        // Lấy dữ liệu từ DAO
        int totalUsers = dashboardDAO.getTotalUsers();
        int totalCourses = dashboardDAO.getTotalCourses();
        int totalRegistrations = dashboardDAO.getTotalRegistrations();

        // Gửi dữ liệu sang JSP
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalCourses", totalCourses);
        request.setAttribute("totalRegistrations", totalRegistrations);

        // Trong AdminDashboardController.java
        request.setAttribute("contentPage", "dashboard.jsp");

        // Forward nội bộ từ Servlet vào WEB-INF
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
