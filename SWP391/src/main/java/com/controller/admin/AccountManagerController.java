package com.controller.admin;

import com.DAO.AccountDAO;
import com.entity.Account;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AccountManagerController", urlPatterns = {"/admin/accounts"})
public class AccountManagerController extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra xem có yêu cầu action gì không (vd: action=delete)
        String action = request.getParameter("action");
        if (action != null && action.equals("delete")) {
            handleDelete(request, response);
            return; // Dừng lại sau khi xóa để thực hiện redirect
        }

        // 2. Nếu không phải action xóa, xử lý hiển thị danh sách (Search/Filter)
        String keyword = request.getParameter("keyword");
        String roleId = request.getParameter("roleId");
        String status = request.getParameter("status");

        List<Account> userList = accountDAO.searchAccounts(keyword, roleId, status);

        request.setAttribute("userList", userList);
        request.setAttribute("contentPage", "accounts.jsp");
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp").forward(request, response);
    }

    // Hàm phụ trách xử lý xóa
    private void handleDelete(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String idRaw = request.getParameter("id");
        if (idRaw != null && !idRaw.isEmpty()) {
            try {
                int id = Integer.parseInt(idRaw);
                accountDAO.deleteAccount(id);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        // Xóa xong chuyển hướng lại về trang danh sách account
        response.sendRedirect(request.getContextPath() + "/admin/accounts");
    }
}


