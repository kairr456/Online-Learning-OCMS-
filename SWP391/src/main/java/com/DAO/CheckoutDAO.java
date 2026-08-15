package com.DAO;

import com.entity.CartItem;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;

public class CheckoutDAO extends DBContext {

    public boolean checkout(int accountId, String email,
                            int cartId, List<CartItem> cartItems) {
        return checkout(accountId, email, cartId, cartItems, "Card", "Done");
    }

    /**
     * Checkout toàn bộ cart với phương thức thanh toán và status (Pending / Done / Approved).
     */
    public boolean checkout(int accountId, String email,
                            int cartId, List<CartItem> cartItems,
                            String paymentMethod, String status) {

        // Mặc định status nếu null
        if (status == null || status.trim().isEmpty()) {
            status = "Card".equalsIgnoreCase(paymentMethod) ? "Done" : "Pending";
        }

        String insertRegistrationSQL =
                "INSERT INTO registration " +
                "(email, account_id, registration_time, course_id, package, " +
                "total_cost, status, valid_from, valid_to, last_updated_by) " +
                "VALUES (?, ?, CURDATE(), ?, ?, ?, ?, ?, ?, ?)";

        String deleteCartSQL =
                "DELETE FROM cart WHERE id = ? AND account_id = ?";

        try {
            connection = getConnection();

            if (connection == null) {
                return false;
            }

            // Bắt đầu transaction
            connection.setAutoCommit(false);

            Timestamp validFrom = new Timestamp(System.currentTimeMillis());
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            calendar.add(Calendar.YEAR, 1);
            Timestamp validTo = new Timestamp(calendar.getTimeInMillis());

            // INSERT registration cho từng course
            try (PreparedStatement ps = connection.prepareStatement(insertRegistrationSQL)) {
                for (CartItem item : cartItems) {
                    ps.setString(1, email);
                    ps.setInt(2, accountId);
                    ps.setInt(3, item.getCourseId());
                    ps.setString(4, "Standard");
                    ps.setBigDecimal(5, item.getPrice());
                    ps.setString(6, status);
                    ps.setTimestamp(7, validFrom);
                    ps.setTimestamp(8, validTo);
                    ps.setInt(9, accountId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // Xóa cart sau khi checkout thành công
            try (PreparedStatement ps = connection.prepareStatement(deleteCartSQL)) {
                ps.setInt(1, cartId);
                ps.setInt(2, accountId);
                ps.executeUpdate();
            }

            connection.commit();
            return true;

        } catch (SQLException e) {
            System.out.println("Checkout error: " + e.getMessage());
            e.printStackTrace();

            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (SQLException rollbackException) {
                rollbackException.printStackTrace();
            }
            return false;

        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            closeResources();
        }
    }
}