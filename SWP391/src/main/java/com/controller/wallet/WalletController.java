package com.controller.wallet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.DAO.SupportedBankDAO;
import com.DAO.WalletDAO;
import com.entity.Account;
import com.entity.PayoutRequest;
import com.entity.SupportedBank;
import com.entity.TeacherBankAccount;
import com.entity.TeacherWallet;
import com.entity.WalletTransaction;
import com.validator.walletValidator;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "WalletController", urlPatterns = {"/wallet"})
public class WalletController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String WALLET_JSP = "/view/wallet/wallet.jsp";
    private final WalletDAO walletDAO = new WalletDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Chỉ giáo viên (role_id = 2) mới có quyền truy cập ví
        if (account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        int teacherId = account.getId();
        System.out.println("[WALLET_CONTROLLER] Truy cập /wallet bởi Account ID=" + teacherId + ", Username=" + account.getUsername() + ", RoleId=" + account.getRoleId());

        // 0. Tự động đồng bộ doanh thu từ các đơn mua khóa học trong bảng registration vào ví
        walletDAO.syncWalletWithRegistrations(teacherId);

        // 1. Lấy thông tin ví (Tự khởi tạo số dư 0đ nếu là GV mới)
        TeacherWallet wallet = walletDAO.getOrCreateWallet(teacherId);
        
        // 2. Lấy thông tin tài khoản ngân hàng
        TeacherBankAccount bankAccount = walletDAO.getBankAccountByTeacherId(teacherId);

        // 3. Lấy tổng số tiền rút đang chờ duyệt
        BigDecimal pendingAmount = walletDAO.getPendingPayoutAmount(teacherId);

        // Lấy tham số sắp xếp theo thời gian (mới nhất / lâu nhất)
        String sort = request.getParameter("sort");
        if (sort == null || (!sort.equalsIgnoreCase("oldest") && !sort.equalsIgnoreCase("newest"))) {
            sort = "newest";
        }

        // 4. Lấy lịch sử biến động số dư
        List<WalletTransaction> transactions = null;
        if (wallet != null) {
            transactions = walletDAO.getTransactionsByWalletId(wallet.getId(), sort);
        }

        // 5. Lấy danh sách yêu cầu rút tiền
        List<PayoutRequest> payoutRequests = walletDAO.getPayoutRequestsByTeacherId(teacherId, sort);

        // 6. Xử lý thông báo flash từ session (sau khi redirect) và xóa khỏi session
        String flashMessage = (String) session.getAttribute("message");
        String flashMessageType = (String) session.getAttribute("messageType");
        if (flashMessage != null) {
            request.setAttribute("flashMessage", flashMessage);
            request.setAttribute("flashType", flashMessageType);
            session.removeAttribute("message");
            session.removeAttribute("messageType");
        }

        // 7. Lấy danh sách ngân hàng nhận tiền đang hoạt động (do Admin quản lý)
        List<SupportedBank> supportedBanks = new SupportedBankDAO().getActiveBanks();

        // Đẩy dữ liệu sang JSP
        request.setAttribute("wallet", wallet);
        request.setAttribute("bankAccount", bankAccount);
        request.setAttribute("supportedBanks", supportedBanks);
        request.setAttribute("pendingAmount", pendingAmount);
        request.setAttribute("transactions", transactions);
        request.setAttribute("payoutRequests", payoutRequests);
        request.setAttribute("sort", sort);

        request.getRequestDispatcher(WALLET_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int teacherId = account.getId();
        String action = request.getParameter("action");

        if ("update_bank".equals(action)) {
            String bankCode = request.getParameter("bankCode");
            String bankName = request.getParameter("bankName");
            String accountNumber = request.getParameter("accountNumber");
            String accountHolder = request.getParameter("accountHolder");
            String taxCode = request.getParameter("taxCode");

            // Server-side validation
            String error = walletValidator.validateBankAccount(bankCode, bankName, accountNumber, accountHolder, taxCode);
            if (error != null) {
                session.setAttribute("message", error);
                session.setAttribute("messageType", "error");
            } else {
                TeacherBankAccount bank = new TeacherBankAccount();
                bank.setTeacherId(teacherId);
                bank.setBankCode(bankCode.trim());
                bank.setBankName(bankName.trim());
                bank.setAccountNumber(accountNumber.trim());
                bank.setAccountHolder(accountHolder.trim().toUpperCase());
                bank.setTaxCode(taxCode != null ? taxCode.trim() : null);

                boolean success = walletDAO.saveOrUpdateBankAccount(bank);
                if (success) {
                    session.setAttribute("message", "Cập nhật thông tin tài khoản ngân hàng thành công!");
                    session.setAttribute("messageType", "success");
                } else {
                    session.setAttribute("message", "Không thể lưu thông tin ngân hàng. Vui lòng thử lại!");
                    session.setAttribute("messageType", "error");
                }
            }

        } else if ("request_payout".equals(action)) {
            String amountStr = request.getParameter("amount");
            String note = request.getParameter("note");

            TeacherWallet currentWallet = walletDAO.getOrCreateWallet(teacherId);
            TeacherBankAccount bank = walletDAO.getBankAccountByTeacherId(teacherId);

            if (bank == null) {
                session.setAttribute("message", "Vui lòng cài đặt tài khoản ngân hàng trước khi thực hiện rút tiền!");
                session.setAttribute("messageType", "error");
            } else {
                // Server-side validation
                BigDecimal balanceToCheck = (currentWallet != null && currentWallet.getBalance() != null) ? currentWallet.getBalance() : BigDecimal.ZERO;
                String error = walletValidator.validateWithdrawAmount(amountStr, balanceToCheck);
                if (error == null) {
                    error = walletValidator.validateWithdrawNote(note);
                }
                if (error != null) {
                    session.setAttribute("message", error);
                    session.setAttribute("messageType", "error");
                } else {
                    BigDecimal amount = new BigDecimal(amountStr.trim());
                    boolean success = walletDAO.requestPayout(teacherId, amount, note);
                    if (success) {
                        session.setAttribute("message", "Đã gửi yêu cầu rút " + NumberFormat(amountStr) + " ₫ thành công! Vui lòng chờ Admin duyệt.");
                        session.setAttribute("messageType", "success");
                    } else {
                        String err = walletDAO.getLastError();
                        session.setAttribute("message", err != null ? err : "Gửi yêu cầu rút tiền thất bại! Vui lòng kiểm tra lại số dư.");
                        session.setAttribute("messageType", "error");
                    }
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/wallet");
    }

    private String NumberFormat(String str) {
        try {
            long val = Long.parseLong(str.trim());
            return String.format("%,d", val).replace(',', '.');
        } catch (Exception e) {
            return str;
        }
    }
}
