package com.validator;

import java.util.regex.Pattern;

/**
 * Validator cho form Checkout (Thanh toán)
 * Kiểm tra các trường bắt buộc, định dạng họ tên, số thẻ 16 số, ngày hết hạn và mã CVC.
 */
public class checkoutValidator {

    // Regex kiểm tra định dạng email: ^[^\s@]+@[^\s@]+$
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");

    // Regex kiểm tra chỉ chứa chữ cái (bao gồm tiếng Việt có dấu), khoảng trắng, dấu gạch nối/dấu nháy
    private static final Pattern NAME_PATTERN =
            Pattern.compile("^[\\p{L}\\s'-]+$");

    // Regex kiểm tra số thẻ 12 đến 20 chữ số
    private static final Pattern CARD_NUMBER_PATTERN =
            Pattern.compile("^\\d{12,20}$");

    // Regex kiểm tra ngày hết hạn MM/YY
    private static final Pattern EXPIRY_PATTERN =
            Pattern.compile("^(0[1-9]|1[0-2])\\/?([0-9]{2})$");

    // Regex kiểm tra CVC/CVV gồm đúng 3 chữ số
    private static final Pattern CVC_PATTERN =
            Pattern.compile("^\\d{3}$");

    private checkoutValidator() {
    }

    /**
     * Kiểm tra dữ liệu thanh toán.
     * 
     * @param fullName       Họ và tên người mua
     * @param email          Email liên hệ
     * @param address        Địa chỉ giao hàng/hóa đơn
     * @param country        Quốc gia/khu vực
     * @param paymentMethod  Phương thức thanh toán ("Card" hoặc "QR_CODE")
     * @param cardNumber     Số thẻ (nếu là Card)
     * @param expiry         Ngày hết hạn MM/YY (nếu là Card)
     * @param cvc            Mã CVC/CVV (nếu là Card)
     * @param cardName       Tên in trên thẻ (nếu là Card)
     * @return Thông báo lỗi đầu tiên nếu không hợp lệ, hoặc null nếu toàn bộ dữ liệu hợp lệ.
     */
    public static String validate(String fullName, String email, String address, String country,
                                  String paymentMethod, String cardNumber, String expiry,
                                  String cvc, String cardName) {

        // 1. Kiểm tra các trường thông tin người mua không được để trống
        if (isBlank(country)) {
            country = "Vietnam";
        }

        if (isBlank(fullName)) {
            return "Thiếu trường chưa điền: Vui lòng nhập Họ và tên.";
        }

        if (isBlank(email)) {
            return "Thiếu trường chưa điền: Vui lòng nhập Email liên hệ.";
        }

        if (isBlank(address)) {
            return "Thiếu trường chưa điền: Vui lòng nhập Địa chỉ.";
        }
        if (address.trim().length() > 255) {
            return "Địa chỉ không được vượt quá 255 ký tự.";
        }

        // 2. Validate Họ và tên (phải là chữ, không được chứa số)
        String trimmedFullName = fullName.trim();
        if (trimmedFullName.matches(".*\\d.*")) {
            return "Họ và tên chỉ được chứa chữ cái, không được chứa số.";
        }
        if (!NAME_PATTERN.matcher(trimmedFullName).matches()) {
            return "Họ và tên không hợp lệ (chỉ được chứa chữ cái và khoảng trắng).";
        }
        if (trimmedFullName.length() < 2) {
            return "Họ và tên phải có ít nhất 2 ký tự.";
        }
        if (trimmedFullName.length() > 100) {
            return "Họ và tên không được vượt quá 100 ký tự.";
        }

        // 3. Validate Email
        if (email.trim().length() > 255) {
            return "Email liên hệ không được vượt quá 255 ký tự.";
        }
        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            return "Email liên hệ không đúng định dạng vd:user01@gmai.com";
        }

        // 4. Validate thông tin thanh toán theo phương thức
        String method = (paymentMethod != null) ? paymentMethod.trim() : "Card";
        if ("Card".equalsIgnoreCase(method) || "Cards".equalsIgnoreCase(method)) {
            // Kiểm tra trường thẻ không được để trống
            if (isBlank(cardNumber)) {
                return "Thiếu trường chưa điền: Vui lòng nhập Số thẻ.";
            }
            if (isBlank(expiry)) {
                return "Thiếu trường chưa điền: Vui lòng nhập Ngày hết hạn thẻ (MM/YY).";
            }
            if (isBlank(cvc)) {
                return "Thiếu trường chưa điền: Vui lòng nhập Mã CVC / CVV.";
            }
            if (isBlank(cardName)) {
                return "Thiếu trường chưa điền: Vui lòng nhập Tên in trên thẻ.";
            }

            // Validate Số thẻ: từ 12 đến 20 chữ số sau khi bỏ khoảng trắng
            String cleanCardNumber = cardNumber.replaceAll("\\s+", "");
            if (!cleanCardNumber.matches("\\d+")) {
                return "Số thẻ chỉ được chứa các chữ số.";
            }
            if (cleanCardNumber.length() < 12 || cleanCardNumber.length() > 20 || !CARD_NUMBER_PATTERN.matcher(cleanCardNumber).matches()) {
                return "Số thẻ phải gồm từ 12 đến 20 chữ số.";
            }

            // Validate Ngày hết hạn (MM/YY)
            String trimmedExpiry = expiry.trim();
            if (!EXPIRY_PATTERN.matcher(trimmedExpiry).matches()) {
                return "Ngày hết hạn thẻ không hợp lệ (định dạng đúng là MM/YY, ví dụ: 12/28).";
            }

            // Validate CVC (đúng 3 số)
            String trimmedCvc = cvc.trim();
            if (!CVC_PATTERN.matcher(trimmedCvc).matches()) {
                return "Mã CVC / CVV phải gồm đúng 3 chữ số.";
            }

            // Validate Tên in trên thẻ (chữ, không được chứa số)
            String trimmedCardName = cardName.trim();
            if (trimmedCardName.matches(".*\\d.*")) {
                return "Tên in trên thẻ chỉ được chứa chữ cái, không được chứa số.";
            }
            if (!NAME_PATTERN.matcher(trimmedCardName).matches()) {
                return "Tên in trên thẻ không hợp lệ (chỉ được chứa chữ cái và khoảng trắng).";
            }
            if (trimmedCardName.length() > 100) {
                return "Tên in trên thẻ không được vượt quá 100 ký tự.";
            }
        }

        return null; // Toàn bộ dữ liệu hợp lệ
    }

    /**
     * Chuẩn hóa số thẻ (loại bỏ toàn bộ khoảng trắng)
     */
    public static String cleanCardNumber(String cardNumber) {
        if (cardNumber == null) {
            return "";
        }
        return cardNumber.replaceAll("\\s+", "");
    }

    /**
     * Kiểm tra chuỗi có rỗng hoặc chỉ chứa khoảng trắng hay không
     */
    public static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
