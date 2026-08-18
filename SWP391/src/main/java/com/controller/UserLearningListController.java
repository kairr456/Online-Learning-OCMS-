package com.controller;

import com.DAO.UserLearningListDAO;
import com.entity.Account;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "UserLearningListController", urlPatterns = {"/user-learning-list"})
public class UserLearningListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Tự động chuyển hướng về trang My Learning nếu người dùng truy cập trực tiếp bằng phương thức GET
        response.sendRedirect(request.getContextPath() + "/all-courses");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Thiết lập cấu hình Encoding tiếng Việt và định dạng phản hồi JSON
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        PrintWriter out = response.getWriter();

        // 1. Kiểm tra trạng thái đăng nhập của người dùng
        if (account == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"error\", \"message\":\"Unauthorized: Please log in first.\"}");
            return;
        }

        String action = request.getParameter("action");
        UserLearningListDAO listDAO = new UserLearningListDAO();
        boolean isSuccess = false;

        try {
            // 2. Phân loại và xử lý các hành động AJAX từ Front-end
            if ("create".equals(action)) {
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                int newListId = listDAO.createList(account.getId(), title, description);
                if (newListId > 0) {
                    isSuccess = true;
                    String courseId = request.getParameter("courseId");
                    if (courseId != null && !courseId.trim().isEmpty()) {
                        isSuccess = new UserLearningListDAO().addCourseToList(newListId, Integer.parseInt(courseId));
                    }
                }

            } else if ("update".equals(action)) {
                int listId = Integer.parseInt(request.getParameter("listId"));
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                isSuccess = listDAO.updateList(listId, account.getId(), title, description);

            } else if ("delete".equals(action)) {
                int listId = Integer.parseInt(request.getParameter("listId"));
                isSuccess = listDAO.deleteList(listId, account.getId());

            } else if ("addCourse".equals(action)) {
                int listId = Integer.parseInt(request.getParameter("listId"));
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                isSuccess = listDAO.addCourseToList(listId, courseId);

            } else if ("removeCourse".equals(action)) {
                int listId = Integer.parseInt(request.getParameter("listId"));
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                isSuccess = listDAO.removeCourseFromList(listId, courseId);
            }

            // 3. Trả về kết quả JSON cho AJAX client
            if (isSuccess) {
                out.print("{\"status\":\"success\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\":\"Operation failed in database.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}