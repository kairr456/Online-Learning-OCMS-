package com.controller.admin;

import com.DAO.AccountDAO;
import com.entity.Account;
import com.utils.PasswordUtil;
import com.validator.adminValidator;
import com.validator.registerValidator;
import com.validator.registrationValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AccountManagerController", urlPatterns = {"/admin/accounts"})
public class AccountManagerController extends HttpServlet {

    private static final int PAGE_SIZE = 5;
    // ---------- GET: list + delete ----------
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
        String keyword = registrationValidator.keywordFor(request.getParameter("keyword"));
        String roleId = request.getParameter("roleId");
        String status = request.getParameter("status");
        
        //Phân trang
        int page = registrationValidator.pageFor(request.getParameter("page"));
        
        // Đếm tổng số record TRƯỚC (instance riêng) → tính tổng số trang → clamp page
        int totalRecords = new AccountDAO().countAccounts(keyword, roleId, status);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
        if (page > totalPages) page = totalPages;

        // Lấy danh sách account (instance riêng — connection bị đóng sau mỗi lần gọi)
        List<Account> userList = new AccountDAO().searchAccounts(keyword, roleId, status, page, PAGE_SIZE);
        
        // Đưa danh sách account và thông tin filter sang JSP
        request.setAttribute("userList", userList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        
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
                new AccountDAO().deactivateAccount(id);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // Quay lại danh sách
        response.sendRedirect(request.getContextPath() + "/admin/accounts");
    }
    
    // ---------- POST: add + edit (từ modal, trả JSON) ----------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");   // "add" hoặc "edit"
        if ("add".equals(action))  handleAdd(request, response);
        else if ("edit".equals(action)) handleEdit(request, response);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = adminValidator.trim(request.getParameter("username"));
        String email    = adminValidator.trim(request.getParameter("email"));
        String phone    = adminValidator.trim(request.getParameter("phone"));
        String fullName = adminValidator.trim(request.getParameter("fullName"));

        if (new AccountDAO().isUsernameExists(username)) { writeJson(response, false, "Username already exists."); return; }
        if (!registerValidator.isValidEmail(email))       { writeJson(response, false, "Invalid email address.");    return; }
        if (new AccountDAO().isEmailExists(email))        { writeJson(response, false, "Email already exists.");    return; }

        Account account = new Account();
        account.setUsername(username);
        account.setPassword(PasswordUtil.md5(request.getParameter("password"))); // hash, không lưu thô
        account.setEmail(email);
        account.setPhone(phone);
        account.setFullName(fullName);
        account.setGender(registerValidator.genderValueFor(request.getParameter("gender")));
        account.setAvatar("");
        account.setActive(true);   // mặc định Active
        account.setRoleId(adminValidator.parseInt(request.getParameter("roleId"), 3));

        // Register() ĐÃ INSERT đủ 9 cột → Add account dùng chung, không cần SQL mới
        boolean ok = new AccountDAO().register(account);
        writeJson(response, ok, ok ? null : "Insert failed.");
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = adminValidator.parseInt(request.getParameter("id"), -1);
        if (id <= 0) { writeJson(response, false, "Invalid account id."); return; }
        Account account = new AccountDAO().getAccountById(id);
        if (account == null) { writeJson(response, false, "Account not found."); return; }

        account.setEmail(adminValidator.trim(request.getParameter("email")));
        account.setPhone(adminValidator.trim(request.getParameter("phone")));
        account.setFullName(adminValidator.trim(request.getParameter("fullName")));
        account.setGender(registerValidator.genderValueFor(request.getParameter("gender")));
        account.setActive(adminValidator.activeFlagFor(request.getParameter("isActive")));
        account.setRoleId(adminValidator.parseInt(request.getParameter("roleId"), account.getRoleId()));
        // username + password giữ nguyên (password để trống = giữ mật khẩu cũ)

        boolean ok = new AccountDAO().updateAccount(account);
        writeJson(response, ok, ok ? null : "Update failed.");
    }

    // Trả JSON thủ công (không cần thư viện)
    private void writeJson(HttpServletResponse response, boolean success, String error) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().print(
            "{\"success\": " + success + ", \"error\": \"" + (error == null ? "" : error) + "\"}");
    }
}
