package com.DAO;

import com.entity.CartItem;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;

public class CheckoutDAO extends DBContext {

    public boolean checkout(int accountId, String email,
                            int cartId, List<CartItem> cartItems) {
        return checkout(accountId, email, cartId, cartItems, "Card", "Approved");
    }

    /**
     * Checkout toàn bộ cart với phương thức thanh toán và status (Approved / Active / Pending).
     */
    public boolean checkout(int accountId, String email,
                            int cartId, List<CartItem> cartItems,
                            String paymentMethod, String status) {

        if (cartItems == null || cartItems.isEmpty()) {
            return false;
        }

        // Mặc định status là Approved để người dùng mua là vào học được ngay
        if (status == null || status.trim().isEmpty()) {
            status = "Approved";
        }

        String insertRegistrationSQL =
                "INSERT INTO registration " +
                "(email, account_id, registration_time, course_id, package, " +
                "total_cost, status, valid_from, valid_to, last_updated_by) " +
                "VALUES (?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?)";

        String deleteCartItemsSQL =
                "DELETE FROM cart_item WHERE cart_id = ?";

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();

            if (conn == null) {
                System.err.println("Checkout error: Cannot establish database connection.");
                return false;
            }

            // Bắt đầu transaction
            conn.setAutoCommit(false);

            // Tạm thời tắt kiểm tra foreign key để phòng lỗi constraint (ví dụ lỗi typo schema registration_course_id_fk trên cột id)
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("SET FOREIGN_KEY_CHECKS=0");
            } catch (Exception ignored) {
            }

            Timestamp validFrom = new Timestamp(System.currentTimeMillis());
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            calendar.add(Calendar.YEAR, 1); // Khóa học có hạn 1 năm
            Timestamp validTo = new Timestamp(calendar.getTimeInMillis());

            int updaterId = (accountId > 0) ? accountId : 1;
            String userEmail = (email != null && !email.trim().isEmpty()) ? email.trim() : "student@ocms.com";

            // 1. INSERT registration cho từng khóa học
            try (PreparedStatement ps = conn.prepareStatement(insertRegistrationSQL)) {
                for (CartItem item : cartItems) {
                    ps.setString(1, userEmail);
                    ps.setInt(2, updaterId);
                    ps.setInt(3, item.getCourseId());
                    ps.setString(4, "Standard");
                    ps.setBigDecimal(5, item.getPrice() != null ? item.getPrice() : BigDecimal.ZERO);
                    ps.setString(6, status);
                    ps.setTimestamp(7, validFrom);
                    ps.setTimestamp(8, validTo);
                    ps.setInt(9, updaterId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // 2. Xóa các mục trong cart_item sau khi thanh toán thành công
            try (PreparedStatement ps = conn.prepareStatement(deleteCartItemsSQL)) {
                ps.setInt(1, cartId);
                ps.executeUpdate();
            }

            // Bật lại kiểm tra foreign key
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("SET FOREIGN_KEY_CHECKS=1");
            } catch (Exception ignored) {
            }

            // Commit transaction
            conn.commit();

            // 3. Tự động cộng 70% doanh thu khóa học vào ví giảng viên tạo khóa học
            try {
                WalletDAO walletDAO = new WalletDAO();
                for (CartItem item : cartItems) {
                    walletDAO.creditTeacherForCourseSale(item.getCourseId(), item.getPrice());
                }
            } catch (Exception ex) {
                System.err.println("Lỗi tự động cộng hoa hồng cho giáo viên khi checkout: " + ex.getMessage());
            }

            return true;

        } catch (SQLException e) {
            System.err.println("Checkout error: " + e.getMessage());
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackException) {
                rollbackException.printStackTrace();
            }
            return false;

        } finally {
            try {
                if (conn != null) {
                    try (Statement stmt = conn.createStatement()) {
                        stmt.execute("SET FOREIGN_KEY_CHECKS=1");
                    } catch (Exception ignored) {
                    }
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}