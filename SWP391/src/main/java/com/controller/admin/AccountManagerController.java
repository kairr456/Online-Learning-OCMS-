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

        // Kiểm tra action
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            handleDelete(request, response);
            return;
        }

        // Lấy thông tin filter & search
        String keyword = request.getParameter("keyword");
        String roleId = request.getParameter("roleId");
        String status = request.getParameter("status");

        // Lấy danh sách account
        List<Account> userList = accountDAO.searchAccounts(keyword, roleId, status);

        // Đưa danh sách account và thông tin filter sang JSP
        request.setAttribute("userList", userList);

        // Main content cần render
        request.setAttribute("contentPage", "accounts.jsp");

        // Render Admin Layout
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp")
                .forward(request, response);
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idRaw = request.getParameter("id");

        if (idRaw != null && !idRaw.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idRaw);
                accountDAO.deactivateAccount(id);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // Quay lại danh sách
        response.sendRedirect(request.getContextPath() + "/admin/accounts");
    }
}
