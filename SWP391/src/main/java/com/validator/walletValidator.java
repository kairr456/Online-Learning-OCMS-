package com.validator;

import java.math.BigDecimal;
import java.util.regex.Pattern;

/**
 * Validator cho các nghiệp vụ Ví và Tài khoản Ngân hàng (Wallet & Payout)
 * Kiểm tra tính hợp lệ của Số tài khoản, Tên chủ tài khoản, Mã số thuế và Số tiền rút.
 */
public class walletValidator {

    // Regex kiểm tra số tài khoản ngân hàng: chỉ chứa từ 6 đến 20 chữ số
    private static final Pattern ACCOUNT_NUMBER_PATTERN = Pattern.compile("^\\d{6,20}$");

    // Regex kiểm tra tên chủ tài khoản: chỉ chứa chữ cái và khoảng trắng (tối thiểu 2 từ, 3 ký tự)
    private static final Pattern ACCOUNT_HOLDER_PATTERN = Pattern.compile("^[a-zA-Z\\s]{3,100}$");

    // Regex kiểm tra mã số thuế Việt Nam: 10 chữ số hoặc 13 chữ số (VD: 8401234567 hoặc 8401234567-001)
    private static final Pattern TAX_CODE_PATTERN = Pattern.compile("^\\d{10}(-\\d{3}|\\d{3})?$");

    private walletValidator() {
    }

    /**
     * Kiểm tra thông tin tài khoản ngân hàng của Giảng viên.
     *
     * @param bankCode      Mã ngân hàng (VCB, MB, TCB, ...)
     * @param bankName      Tên ngân hàng
     * @param accountNumber Số tài khoản ngân hàng
     * @param accountHolder Tên chủ tài khoản (in hoa không dấu)
     * @param taxCode       Mã số thuế cá nhân (tùy chọn)
     * @return Thông báo lỗi đầu tiên nếu không hợp lệ, hoặc null nếu hợp lệ.
     */
    public static String validateBankAccount(String bankCode, String bankName, 
                                             String accountNumber, String accountHolder, 
                                             String taxCode) {

        // 1. Kiểm tra Ngân hàng
        if (isBlank(bankCode) || isBlank(bankName)) {
            return "Vui lòng chọn ngân hàng nhận tiền từ danh sách.";
        }

        // 2. Kiểm tra Số tài khoản (STK)
        if (isBlank(accountNumber)) {
            return "Vui lòng nhập Số tài khoản ngân hàng (STK).";
        }
        
        String cleanAccNumber = accountNumber.trim().replaceAll("\\s+", "");
        if (!cleanAccNumber.matches("\\d+")) {
            return "Số tài khoản ngân hàng chỉ được chứa các chữ số (0-9), không được chứa chữ cái hoặc ký tự đặc biệt.";
        }
        if (cleanAccNumber.length() < 6 || cleanAccNumber.length() > 20) {
            return "Số tài khoản ngân hàng phải có độ dài từ 6 đến 20 chữ số.";
        }
        if (!ACCOUNT_NUMBER_PATTERN.matcher(cleanAccNumber).matches()) {
            return "Số tài khoản ngân hàng không hợp lệ.";
        }

        // 3. Kiểm tra Tên chủ tài khoản
        if (isBlank(accountHolder)) {
            return "Vui lòng nhập Tên chủ tài khoản ngân hàng.";
        }
        
        String trimmedHolder = accountHolder.trim().replaceAll("\\s+", " ");
        if (trimmedHolder.matches(".*\\d.*")) {
            return "Tên chủ tài khoản không được chứa số.";
        }
        if (trimmedHolder.length() < 3) {
            return "Tên chủ tài khoản phải có ít nhất 3 ký tự.";
        }
        // Kiểm tra chỉ chứa chữ cái tiếng Anh/không dấu
        if (!trimmedHolder.matches("^[a-zA-Z\\s]+$")) {
            return "Tên chủ tài khoản phải viết hoa không dấu (ví dụ: NGUYEN VAN A).";
        }

        // 4. Kiểm tra Mã số thuế (nếu có nhập)
        if (!isBlank(taxCode)) {
            String cleanTaxCode = taxCode.trim();
            if (!TAX_CODE_PATTERN.matcher(cleanTaxCode).matches()) {
                return "Mã số thuế cá nhân không hợp lệ (Mã số thuế chuẩn gồm 10 hoặc 13 chữ số).";
            }
        }

        return null; // Dữ liệu hợp lệ
    }

    /**
     * Kiểm tra số tiền và điều kiện yêu cầu rút tiền.
     *
     * @param amountStr      Số tiền muốn rút (dạng chuỗi)
     * @param currentBalance Số dư khả dụng hiện tại trong ví
     * @return Thông báo lỗi đầu tiên nếu không hợp lệ, hoặc null nếu hợp lệ.
     */
    public static String validateWithdrawAmount(String amountStr, BigDecimal currentBalance) {
        if (isBlank(amountStr)) {
            return "Vui lòng nhập số tiền muốn rút.";
        }

        BigDecimal amount;
        try {
            amount = new BigDecimal(amountStr.trim());
        } catch (NumberFormatException e) {
            return "Số tiền rút không hợp lệ.";
        }

        // Hạn mức rút tối thiểu 100.000 VNĐ
        BigDecimal minWithdraw = new BigDecimal("100000");
        if (amount.compareTo(minWithdraw) < 0) {
            return "Số tiền rút tối thiểu cho mỗi lần là 100.000 ₫.";
        }

        // Phải là bội số của 10.000 VNĐ
        BigDecimal tenThousand = new BigDecimal("10000");
        if (amount.remainder(tenThousand).compareTo(BigDecimal.ZERO) != 0) {
            return "Số tiền rút phải là bội số của 10.000 ₫ (ví dụ: 100.000, 150.000, 500.000,...).";
        }

        // Không được vượt quá số dư khả dụng
        if (currentBalance == null || amount.compareTo(currentBalance) > 0) {
            return "Số tiền muốn rút vượt quá số dư khả dụng hiện có trong ví.";
        }

        return null; // Hợp lệ
    }

    /**
     * Đếm số từ trong chuỗi văn bản.
     *
     * @param text Chuỗi cần đếm từ
     * @return Số từ
     */
    public static int countWords(String text) {
        if (isBlank(text)) {
            return 0;
        }
        String[] words = text.trim().split("\\s+");
        return words.length;
    }

    /**
     * Kiểm tra tính hợp lệ của ghi chú rút tiền (tối đa 50 ký tự).
     *
     * @param note Ghi chú của giảng viên khi gửi yêu cầu rút tiền
     * @return Thông báo lỗi nếu vượt quá 50 ký tự, hoặc null nếu hợp lệ.
     */
    public static String validateWithdrawNote(String note) {
        if (isBlank(note)) {
            return null; // Ghi chú là tùy chọn
        }
        String trimmed = note.trim();
        if (trimmed.length() > 50) {
            return "Ghi chú không được vượt quá 50 ký tự (hiện tại: " + trimmed.length() + " ký tự).";
        }
        return null;
    }

    /**
     * Kiểm tra chuỗi rỗng
     */
    public static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
