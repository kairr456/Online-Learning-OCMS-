package com.controller.admin;

import com.DAO.SupportedBankDAO;
import com.entity.Account;
import com.entity.SupportedBank;
import com.validator.adminValidator;
import com.validator.registrationValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller Quản lý Ngân hàng nhận tiền (Role: Admin)
 * URL: /admin/banks
 * - GET : Hiển thị bảng danh sách ngân hàng, tìm kiếm, phân trang, xóa ngân hàng.
 * - POST: Thêm mới (action=add) / Cập nhật (action=edit) ngân hàng từ Modal (trả JSON).
 */
@WebServlet(name = "BankController", urlPatterns = {"/admin/banks"})
public class BankController extends HttpServlet {

    private static final int PAGE_SIZE = 8;
    private final SupportedBankDAO bankDAO = new SupportedBankDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra quyền Admin (Role = 1)
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Xử lý xóa nếu action = delete
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
            return;
        }

        // 3. Đọc từ khóa tìm kiếm & phân trang
        String keyword = registrationValidator.keywordFor(request.getParameter("keyword"));
        int page = registrationValidator.pageFor(request.getParameter("page"));

        int totalRecords = bankDAO.countBanks(keyword);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<SupportedBank> bankList = bankDAO.searchBanks(keyword, page, PAGE_SIZE);

        // 4. Gửi dữ liệu sang View
        request.setAttribute("bankList", bankList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("keyword", keyword);

        // Đặt nội dung hiển thị trong admin_layout.jsp
        request.setAttribute("contentPage", "banks.jsp");

        // Forward sang admin layout
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp").forward(request, response);
    }

    /**
     * Xử lý xóa ngân hàng nhận tiền
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idRaw = request.getParameter("id");
        int id = adminValidator.parseInt(idRaw, -1);

        if (id > 0) {
            int inUseCount = bankDAO.countAccountsUsingBank(id);
            if (inUseCount > 0) {
                response.sendRedirect(request.getContextPath() + "/admin/banks?error=in_use&count=" + inUseCount);
                return;
            }

            boolean ok = bankDAO.deleteBank(id);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/banks?msg=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/banks?error=delete_failed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/banks?error=invalid_id");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền Admin
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 1) {
            writeJson(response, false, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            handleAdd(request, response);
        } else if ("edit".equals(action)) {
            handleEdit(request, response);
        } else {
            writeJson(response, false, "Thao tác không hợp lệ.");
        }
    }

    /**
     * Xử lý thêm mới ngân hàng
     */
    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String bankCodeRaw = request.getParameter("bankCode");
        String bankCode = bankCodeRaw != null ? bankCodeRaw.replaceAll("\\s+", "").toUpperCase() : "";
        String bankName = adminValidator.trim(request.getParameter("bankName"));
        String shortName = adminValidator.trim(request.getParameter("shortName"));
        String status = adminValidator.trim(request.getParameter("status"));

        if (bankCode.isEmpty()) {
            writeJson(response, false, "Mã ngân hàng (Bank Code) không được để trống hoặc chỉ chứa dấu cách.");
            return;
        }
        if (bankCode.length() > 50) {
            writeJson(response, false, "Mã ngân hàng không được vượt quá 50 ký tự.");
            return;
        }

        if (bankCode.matches(".*\\d.*")) {
            writeJson(response, false, "Mã ngân hàng không được ghi số vào (chỉ được chứa chữ cái A-Z).");
            return;
        }

        if (bankName == null || bankName.trim().isEmpty()) {
            writeJson(response, false, "Tên ngân hàng đầy đủ không được để trống hoặc chỉ chứa dấu cách.");
            return;
        }
        if (bankName.length() > 255) {
            writeJson(response, false, "Tên ngân hàng không được vượt quá 255 ký tự.");
            return;
        }
        if (bankName.matches(".*\\d.*")) {
            writeJson(response, false, "Tên đầy đủ ngân hàng không được ghi số vào (chỉ được chứa chữ cái).");
            return;
        }

        if (shortName == null || shortName.trim().isEmpty()) {
            writeJson(response, false, "Tên hiển thị (Short Name) không được để trống hoặc chỉ chứa dấu cách.");
            return;
        }
        if (shortName.length() > 255) {
            writeJson(response, false, "Tên hiển thị không được vượt quá 255 ký tự.");
            return;
        }
        if (shortName.matches(".*\\d.*")) {
            writeJson(response, false, "Tên hiển thị rút gọn không được ghi số vào (chỉ được chứa chữ cái).");
            return;
        }

        if (status == null || (!"active".equalsIgnoreCase(status) && !"inactive".equalsIgnoreCase(status))) {
            status = "active";
        }

        if (bankDAO.isBankCodeExists(bankCode, -1)) {
            writeJson(response, false, "Mã ngân hàng '" + bankCode.toUpperCase() + "' đã tồn tại trên hệ thống.");
            return;
        }

        SupportedBank bank = new SupportedBank(bankCode.toUpperCase(), bankName, shortName, status.toLowerCase());
        boolean ok = bankDAO.insertBank(bank);
        writeJson(response, ok, ok ? null : "Thêm mới ngân hàng thất bại. Vui lòng thử lại!");
    }

    /**
     * Xử lý chỉnh sửa ngân hàng
     */
    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = adminValidator.parseInt(request.getParameter("id"), -1);
        String bankCodeRaw = request.getParameter("bankCode");
        String bankCode = bankCodeRaw != null ? bankCodeRaw.replaceAll("\\s+", "").toUpperCase() : "";
        String bankName = adminValidator.trim(request.getParameter("bankName"));
        String shortName = adminValidator.trim(request.getParameter("shortName"));
        String status = adminValidator.trim(request.getParameter("status"));

        if (id <= 0) {
            writeJson(response, false, "ID ngân hàng không hợp lệ.");
            return;
        }

        if (bankCode.isEmpty()) {
            writeJson(response, false, "Mã ngân hàng (Bank Code) không được để trống hoặc chỉ chứa dấu cách.");
            return;
        }
        if (bankCode.length() > 50) {
            writeJson(response, false, "Mã ngân hàng không được vượt quá 50 ký tự.");
            return;
        }

        if (bankCode.matches(".*\\d.*")) {
            writeJson(response, false, "Mã ngân hàng không được ghi số vào (chỉ được chứa chữ cái A-Z).");
            return;
        }

        if (bankName == null || bankName.trim().isEmpty()) {
            writeJson(response, false, "Tên ngân hàng đầy đủ không được để trống hoặc chỉ chứa dấu cách.");
            return;
        }
        if (bankName.length() > 255) {
            writeJson(response, false, "Tên ngân hàng không được vượt quá 255 ký tự.");
            return;
        }
        if (bankName.matches(".*\\d.*")) {
            writeJson(response, false, "Tên đầy đủ ngân hàng không được ghi số vào (chỉ được chứa chữ cái).");
            return;
        }

        if (shortName == null || shortName.trim().isEmpty()) {
            writeJson(response, false, "Tên hiển thị (Short Name) không được để trống hoặc chỉ chứa dấu cách.");
            return;
        }
        if (shortName.length() > 255) {
            writeJson(response, false, "Tên hiển thị không được vượt quá 255 ký tự.");
            return;
        }
        if (shortName.matches(".*\\d.*")) {
            writeJson(response, false, "Tên hiển thị rút gọn không được ghi số vào (chỉ được chứa chữ cái).");
            return;
        }

        if (status == null || (!"active".equalsIgnoreCase(status) && !"inactive".equalsIgnoreCase(status))) {
            status = "active";
        }

        SupportedBank existing = bankDAO.getBankById(id);
        if (existing == null) {
            writeJson(response, false, "Không tìm thấy thông tin ngân hàng.");
            return;
        }

        if (bankDAO.isBankCodeExists(bankCode, id)) {
            writeJson(response, false, "Mã ngân hàng '" + bankCode.toUpperCase() + "' đã tồn tại trên hệ thống.");
            return;
        }

        existing.setBankCode(bankCode.toUpperCase());
        existing.setBankName(bankName);
        existing.setShortName(shortName);
        existing.setStatus(status.toLowerCase());

        boolean ok = bankDAO.updateBank(existing);
        writeJson(response, ok, ok ? null : "Cập nhật ngân hàng thất bại. Vui lòng thử lại!");
    }

    /**
     * Trả kết quả JSON về cho client fetch API
     */
    private void writeJson(HttpServletResponse response, boolean success, String error) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String json = String.format("{\"success\": %b, \"error\": \"%s\"}",
                success,
                error == null ? "" : error.replace("\"", "\\\""));
        response.getWriter().print(json);
    }
}
