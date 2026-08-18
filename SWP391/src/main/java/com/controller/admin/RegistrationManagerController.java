package com.controller.admin;

import com.DAO.CourseRegistrationDAO;
import com.entity.Registration;
import com.validator.registrationValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "RegistrationManagerController", urlPatterns = {"/admin/registrations"})
public class RegistrationManagerController extends HttpServlet {

    // Số bản ghi hiển thị trên mỗi trang
    private static final int PAGE_SIZE = 5;

    // ---------- GET: danh sách đăng ký với tìm kiếm / lọc / phân trang ----------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // Chuẩn hóa tham số qua registrationValidator (không tin raw từ client)
        String keyword = registrationValidator.keywordFor(request.getParameter("keyword"));
        String status  = registrationValidator.statusFor(request.getParameter("status"));
        int page       = registrationValidator.pageFor(request.getParameter("page"));

        // Đếm tổng số record TRƯỚC → tính tổng số trang → clamp page
        int totalRecords = new CourseRegistrationDAO()
                .getTotalRegistrationsByFilter(keyword, null, status, null, null);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
        if (page > totalPages) page = totalPages;

        // Lấy danh sách đăng ký theo filter (instance riêng — connection đóng sau mỗi lần gọi)
        List<Registration> registrationList = new CourseRegistrationDAO()
                .getRegistrationsByFilter(keyword, null, status, null, null, page, PAGE_SIZE);

        // Đưa dữ liệu + thông tin phân trang sang JSP
        request.setAttribute("registrationList", registrationList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        // Main content cần render
        request.setAttribute("contentPage", "registrations.jsp");

        // Render Admin Layout
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp")
                .forward(request, response);
    }
}