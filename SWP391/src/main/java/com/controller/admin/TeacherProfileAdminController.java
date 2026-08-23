package com.controller.admin;

import com.DAO.AccountDAO;
import com.DAO.TeacherProfileDAO;
import com.DAO.WalletDAO;
import com.entity.Account;
import com.entity.TeacherProfile;
import com.utils.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

@WebServlet(urlPatterns = { "/admin/teacher-approvals" })
public class TeacherProfileAdminController extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("detail".equals(action)) {
            handleDetail(request, response);
        } else {
            // Default: list
            handleList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("approve".equals(action)) {
            handleApprove(request, response);
        } else if ("reject".equals(action)) {
            handleReject(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals");
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null)
            return false;
        Account account = (Account) session.getAttribute("account");
        return account != null && account.getRoleId() == 1;
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pageStr = request.getParameter("page");
        String keyword = request.getParameter("keyword");

        int page = 1;
        try {
            if (pageStr != null)
                page = Integer.parseInt(pageStr);
        } catch (NumberFormatException ignored) {
        }

        if (page < 1)
            page = 1;

        List<TeacherProfile> profiles = new TeacherProfileDAO().findPending(page, PAGE_SIZE, keyword);
        int total = new TeacherProfileDAO().countPending(keyword);
        profiles.forEach(profile -> profile.setCvUrl(normalizeCvUrl(request, profile.getCvUrl())));
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        request.setAttribute("profiles", profiles);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("total", total);

        request.setAttribute("contentPage", "teacher_approval_list.jsp");

        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp")
                .forward(request, response);
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals");
            return;
        }

        int profileId;
        try {
            profileId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals");
            return;
        }

        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        TeacherProfile profile = profileDAO.findById(profileId);

        if (profile == null) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals");
            return;
        }
        profile.setCvUrl(normalizeCvUrl(request, profile.getCvUrl()));

        AccountDAO accountDAO = new AccountDAO();
        Account account = accountDAO.getAccountById(profile.getAccountId());

        request.setAttribute("profile", profile);
        request.setAttribute("account", account);
        request.setAttribute("contentPage", "teacher_approval_detail.jsp");

        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp")
                .forward(request, response);
    }

    private void handleApprove(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            sendJsonError(response, "Missing id parameter");
            return;
        }

        int profileId;
        try {
            profileId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            sendJsonError(response, "Invalid profile ID");
            return;
        }

        HttpSession session = request.getSession();
        Account admin = (Account) session.getAttribute("account");

        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        TeacherProfile profile = profileDAO.findById(profileId);

        if (profile == null || !"PENDING".equals(profile.getApprovalStatus())) {
            sendJsonError(response, "Profile not found or not pending");
            return;
        }

        AccountDAO accountDAO = new AccountDAO();
        Account account = accountDAO.getAccountById(profile.getAccountId());
        if (account == null) {
            sendJsonError(response, "Teacher account not found");
            return;
        }

        // Update profile status
        profile.setApprovalStatus("APPROVED");
        profile.setRejectedReason(null);
        if (!new TeacherProfileDAO().update(profile)) {
            sendJsonError(response, "Could not approve teacher profile");
            return;
        }

        // Activate account
        if (!new AccountDAO().activateAccount(account.getId())) {
            sendJsonError(response, "Could not activate teacher account");
            return;
        }

        // Auto-create wallet for teacher
        WalletDAO walletDAO = new WalletDAO();
        walletDAO.getOrCreateWallet(profile.getAccountId());

        // Send approval email
        sendApprovalEmail(account.getEmail(), account.getFullName(), true, null, request);

        // Check if AJAX request (from preview modal)
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))
                || "true".equals(request.getParameter("ajax"))) {
            sendJsonSuccess(response, "Approved successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals?approved=1");
        }
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String rejectedReason = request.getParameter("rejectedReason");

        if (idStr == null) {
            sendJsonError(response, "Missing id parameter");
            return;
        }

        int profileId;
        try {
            profileId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            sendJsonError(response, "Invalid profile ID");
            return;
        }

        HttpSession session = request.getSession();
        Account admin = (Account) session.getAttribute("account");

        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        TeacherProfile profile = profileDAO.findById(profileId);

        if (profile == null || !"PENDING".equals(profile.getApprovalStatus())) {
            sendJsonError(response, "Profile not found or not pending");
            return;
        }

        // Update profile status
        if (!new TeacherProfileDAO().updateStatus(profileId, "REJECTED", rejectedReason)) {
            sendJsonError(response, "Could not reject teacher profile");
            return;
        }

        // Delete account (as requested)
        AccountDAO accountDAO = new AccountDAO();
        Account account = accountDAO.getAccountById(profile.getAccountId());
        if (account != null) {
            sendApprovalEmail(account.getEmail(), account.getFullName(), false, rejectedReason, request);
            new AccountDAO().deleteAccount(profile.getAccountId());
        }

        // Check if AJAX request
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))
                || "true".equals(request.getParameter("ajax"))) {
            sendJsonSuccess(response, "Rejected successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals?rejected=1");
        }
    }

    private void sendJsonSuccess(HttpServletResponse response, String message) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().print("{\"success\": true, \"message\": \"" + escapeJson(message) + "\"}");
    }

    private void sendJsonError(HttpServletResponse response, String error) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.getWriter().print("{\"success\": false, \"error\": \"" + escapeJson(error) + "\"}");
    }

    private void sendApprovalEmail(String toEmail, String fullName, boolean approved, String rejectedReason,
            HttpServletRequest request) {
        try {
            String subject = approved
                    ? "OCMS - Tài khoản giảng viên đã được duyệt"
                    : "OCMS - Tài khoản giảng viên bị từ chối";

            String body = approved
                    ? String.format(
                            "Chào %s,\n\n" +
                                    "Tài khoản giảng viên của bạn đã được duyệt thành công.\n" +
                                    "Bây giờ bạn có thể đăng nhập vào OCMS và bắt đầu tạo khóa học.\n\n" +
                                    "Trân trọng,\nBan quản trị OCMS",
                            fullName)
                    : String.format(
                            "Chào %s,\n\n" +
                                    "Rất tiếc, tài khoản giảng viên của bạn đã bị từ chối.\n" +
                                    "Lý do: %s\n\n" +
                                    "Bạn có thể đăng ký lại với thông tin chính xác hơn.\n\n" +
                                    "Trân trọng,\nBan quản trị OCMS",
                            fullName, (rejectedReason != null ? rejectedReason : "Không có ghi chú"));

            EmailService.sendEmail(toEmail, subject, body);
        } catch (Exception e) {
            // Log but don't fail the request
            e.printStackTrace();
        }
    }

    private String normalizeCvUrl(HttpServletRequest request, String cvUrl) {
        if (cvUrl == null || cvUrl.isBlank()) {
            return cvUrl;
        }

        String legacyPath = "/uploads/teacher-cv/";
        String currentPath = "/assets/css/uploads/teacher-cv/";
        int legacyIndex = cvUrl.indexOf(legacyPath);
        if (legacyIndex >= 0) {
            return request.getContextPath() + currentPath
                    + cvUrl.substring(legacyIndex + legacyPath.length());
        }
        return cvUrl;
    }

    private String escapeJson(String str) {
        if (str == null)
            return "";
        StringBuilder sb = new StringBuilder();
        for (char c : str.toCharArray()) {
            switch (c) {
                case '"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\b':
                    sb.append("\\b");
                    break;
                case '\f':
                    sb.append("\\f");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                default:
                    if (c < ' ') {
                        String t = "000" + Integer.toHexString(c);
                        sb.append("\\u").append(t.substring(t.length() - 4));
                    } else {
                        sb.append(c);
                    }
                    break;
            }
        }
        return sb.toString();
    }
}