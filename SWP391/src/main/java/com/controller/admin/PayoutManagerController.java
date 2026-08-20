package com.controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.DAO.WalletDAO;
import com.entity.Account;
import com.entity.PayoutRequest;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "PayoutManagerController", urlPatterns = {"/admin/payouts"})
public class PayoutManagerController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final WalletDAO walletDAO = new WalletDAO();

    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 1) { // 1 = Admin
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null && !pageRaw.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageRaw.trim());
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {
                page = 1;
            }
        }

        int totalRecords = walletDAO.countAllPayoutRequests(keyword, status);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<PayoutRequest> payoutList = walletDAO.getAllPayoutRequests(keyword, status, page, PAGE_SIZE);

        // Tính toán thống kê nhanh
        BigDecimal pendingTotal = BigDecimal.ZERO;
        BigDecimal completedTotal = BigDecimal.ZERO;
        int totalRequests = 0;

        List<PayoutRequest> allList = walletDAO.getAllPayoutRequests(null, null);
        if (allList != null) {
            totalRequests = allList.size();
            for (PayoutRequest p : allList) {
                if ("pending".equalsIgnoreCase(p.getStatus())) {
                    pendingTotal = pendingTotal.add(p.getAmount());
                } else if ("completed".equalsIgnoreCase(p.getStatus()) || "approved".equalsIgnoreCase(p.getStatus())) {
                    completedTotal = completedTotal.add(p.getAmount());
                }
            }
        }

        // Xử lý thông báo flash từ session (sau khi approve/reject redirect)
        String flashMessage = (String) session.getAttribute("message");
        String flashMessageType = (String) session.getAttribute("messageType");
        if (flashMessage != null) {
            request.setAttribute("flashMessage", flashMessage);
            request.setAttribute("flashType", flashMessageType);
            session.removeAttribute("message");
            session.removeAttribute("messageType");
        }

        request.setAttribute("payoutList", payoutList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("pendingTotal", pendingTotal);
        request.setAttribute("completedTotal", completedTotal);
        request.setAttribute("totalRequests", totalRequests);

        // Pass contentPage name for admin_layout.jsp
        request.setAttribute("contentPage", "payouts.jsp");

        // Forward to admin layout
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String payoutIdStr = request.getParameter("payoutId");

        try {
            int payoutId = Integer.parseInt(payoutIdStr);

            if ("approve".equals(action)) {
                String transactionCode = request.getParameter("transactionCode");
                boolean ok = walletDAO.approvePayout(payoutId, transactionCode != null ? transactionCode.trim() : "");
                if (ok) {
                    session.setAttribute("message", "Đã duyệt đơn rút #" + payoutId + " và xác nhận chuyển tiền thành công!");
                    session.setAttribute("messageType", "success");
                } else {
                    session.setAttribute("message", "Không thể duyệt đơn rút #" + payoutId + ". Vui lòng thử lại!");
                    session.setAttribute("messageType", "error");
                }

            } else if ("reject".equals(action)) {
                String adminNote = request.getParameter("adminNote");
                boolean ok = walletDAO.rejectPayout(payoutId, adminNote != null ? adminNote.trim() : "");
                if (ok) {
                    session.setAttribute("message", "Đã từ chối đơn rút #" + payoutId + " và hoàn trả tiền về ví giảng viên!");
                    session.setAttribute("messageType", "warning");
                } else {
                    session.setAttribute("message", "Không thể từ chối đơn rút #" + payoutId + ". Vui lòng thử lại!");
                    session.setAttribute("messageType", "error");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Lỗi xử lý đơn rút tiền!");
            session.setAttribute("messageType", "error");
        }

        response.sendRedirect(request.getContextPath() + "/admin/payouts");
    }
}
