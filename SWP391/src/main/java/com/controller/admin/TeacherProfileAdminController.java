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

@WebServlet("/admin/teacher-approvals/*")
public class TeacherProfileAdminController extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/list")) {
            handleList(request, response);
        } else if (pathInfo.equals("/detail")) {
            handleDetail(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if ("/approve".equals(pathInfo)) {
            handleApprove(request, response);
        } else if ("/reject".equals(pathInfo)) {
            handleReject(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Account account = (Account) session.getAttribute("account");
        return account != null && account.getRoleId() == 1;
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pageStr = request.getParameter("page");
        String keyword = request.getParameter("keyword");

        int page = 1;
        try {
            if (pageStr != null) page = Integer.parseInt(pageStr);
        } catch (NumberFormatException ignored) {}

        if (page < 1) page = 1;

        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        List<TeacherProfile> profiles = profileDAO.findPending(page, PAGE_SIZE, keyword);
        int total = profileDAO.countPending(keyword);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        request.setAttribute("profiles", profiles);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("total", total);

        request.getRequestDispatcher("/view/admin/teacherApprovalList.jsp")
                .forward(request, response);
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        int profileId;
        try {
            profileId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        TeacherProfile profile = profileDAO.findById(profileId);

        if (profile == null) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        AccountDAO accountDAO = new AccountDAO();
        Account account = accountDAO.getAccountById(profile.getTeacherId());

        request.setAttribute("profile", profile);
        request.setAttribute("account", account);

        request.getRequestDispatcher("/view/admin/teacherApprovalDetail.jsp")
                .forward(request, response);
    }

    private void handleApprove(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        int profileId;
        try {
            profileId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        HttpSession session = request.getSession();
        Account admin = (Account) session.getAttribute("account");

        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        TeacherProfile profile = profileDAO.findById(profileId);

        if (profile == null || !"pending".equals(profile.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        // Update profile status
        profile.setStatus("approved");
        profile.setReviewedBy(admin.getId());
        profile.setReviewedAt(new Timestamp(System.currentTimeMillis()));
        profileDAO.update(profile);

        // Activate account
        AccountDAO accountDAO = new AccountDAO();
        Account account = accountDAO.getAccountById(profile.getTeacherId());
        if (account != null) {
            account.setActive(true);
            accountDAO.updateAccount(account);
        }

        // Auto-create wallet for teacher
        WalletDAO walletDAO = new WalletDAO();
        walletDAO.getOrCreateWallet(profile.getTeacherId());

        // Send approval email
        sendApprovalEmail(account.getEmail(), account.getFullName(), true, null, request);

        response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list?approved=1");
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String adminNote = request.getParameter("adminNote");

        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        int profileId;
        try {
            profileId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        HttpSession session = request.getSession();
        Account admin = (Account) session.getAttribute("account");

        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        TeacherProfile profile = profileDAO.findById(profileId);

        if (profile == null || !"pending".equals(profile.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list");
            return;
        }

        // Update profile status
        profileDAO.updateStatus(profileId, "rejected", admin.getId(), adminNote);

        // Delete account (as requested)
        AccountDAO accountDAO = new AccountDAO();
        // Note: We don't have a delete method, so we'll keep it inactive
        // Could add deleteAccount method to AccountDAO if needed

        // Send rejection email & delete account
        Account account = accountDAO.getAccountById(profile.getTeacherId());
        if (account != null) {
            sendApprovalEmail(account.getEmail(), account.getFullName(), false, adminNote, request);
            accountDAO.deleteAccount(profile.getTeacherId());
        }

        response.sendRedirect(request.getContextPath() + "/admin/teacher-approvals/list?rejected=1");
    }

    private void sendApprovalEmail(String toEmail, String fullName, boolean approved, String adminNote, HttpServletRequest request) {
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
                    fullName
            )
                    : String.format(
                    "Chào %s,\n\n" +
                    "Rất tiếc, tài khoản giảng viên của bạn đã bị từ chối.\n" +
                    "Lý do: %s\n\n" +
                    "Bạn có thể đăng ký lại với thông tin chính xác hơn.\n\n" +
                    "Trân trọng,\nBan quản trị OCMS",
                    fullName, (adminNote != null ? adminNote : "Không có ghi chú")
            );

            EmailService.sendEmail(toEmail, subject, body);
        } catch (Exception e) {
            // Log but don't fail the request
            e.printStackTrace();
        }
    }
}