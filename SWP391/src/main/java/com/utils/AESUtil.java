package com.utils;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

/**
 * Tiện ích mã hóa và giải mã dữ liệu bảo mật (AES-128 2 chiều).
 * Sử dụng để mã hóa các trường nhạy cảm như Số tài khoản ngân hàng (account_number) trong Database.
 */
public class AESUtil {

    // Khóa bí mật 128-bit (16 ký tự)
    private static final String SECRET_KEY = "Ocms@SecretKey16";
    private static final String ALGORITHM = "AES";

    private AESUtil() {
    }

    /**
     * Mã hóa một chuỗi văn bản thuần sang chuỗi Base64 đã mã hóa AES
     */
    public static String encrypt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return value;
        }
        // Nếu đã được mã hóa trước đó rồi thì không mã hóa lặp lại
        if (isEncrypted(value)) {
            return value;
        }
        try {
            SecretKeySpec key = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, key);
            byte[] encryptedBytes = cipher.doFinal(value.trim().getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(encryptedBytes);
        } catch (Exception e) {
            System.err.println("[AESUtil] Lỗi khi mã hóa: " + e.getMessage());
            return value; // fallback trả về nguyên bản nếu lỗi
        }
    }

    /**
     * Giải mã từ chuỗi Base64 đã mã hóa AES ra dữ liệu gốc
     */
    public static String decrypt(String encryptedValue) {
        if (encryptedValue == null || encryptedValue.trim().isEmpty()) {
            return encryptedValue;
        }
        try {
            SecretKeySpec key = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, key);
            byte[] decodedBytes = Base64.getDecoder().decode(encryptedValue.trim());
            byte[] decryptedBytes = cipher.doFinal(decodedBytes);
            return new String(decryptedBytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            // Trường hợp dữ liệu cũ trong database chưa mã hóa hoặc không phải Base64 hợp lệ, trả về nguyên bản
            return encryptedValue;
        }
    }

    /**
     * Kiểm tra xem một chuỗi có phải là chuỗi đã được mã hóa bởi AESUtil hay không
     */
    public static boolean isEncrypted(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        try {
            SecretKeySpec key = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, key);
            byte[] decodedBytes = Base64.getDecoder().decode(value.trim());
            byte[] decrypted = cipher.doFinal(decodedBytes);
            return decrypted != null && decrypted.length > 0;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Che bớt số tài khoản khi hiển thị cho mục đích an toàn (ví dụ: *******1234)
     */
    public static String maskAccountNumber(String accountNumber) {
        if (accountNumber == null || accountNumber.length() < 4) {
            return accountNumber;
        }
        int len = accountNumber.length();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < len - 4; i++) {
            sb.append("*");
        }
        sb.append(accountNumber.substring(len - 4));
        return sb.toString();
    }
}
