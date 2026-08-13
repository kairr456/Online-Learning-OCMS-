package com.DAO;

import com.entity.CartItem;
import com.entity.Registration;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;

public class CheckoutDAO extends DBContext {

    /**
     * Checkout toàn bộ cart.
     *
     * Transaction:
     * 1. Insert registration cho từng course
     * 2. Delete cart
     * 3. Commit
     *
     * Nếu có lỗi -> Rollback
     */
    public boolean checkout(int accountId, String email,
                            int cartId, List<CartItem> cartItems) {

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

            /*
             * Thời gian bắt đầu khóa học
             */
            Timestamp validFrom =
                    new Timestamp(System.currentTimeMillis());

            /*
             * Khóa học có hiệu lực 1 năm
             */
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(System.currentTimeMillis());
            calendar.add(Calendar.YEAR, 1);

            Timestamp validTo =
                    new Timestamp(calendar.getTimeInMillis());

            /*
             * INSERT registration cho từng course
             */
            try (PreparedStatement ps =
                         connection.prepareStatement(insertRegistrationSQL)) {

                for (CartItem item : cartItems) {

                    ps.setString(1, email);
                    ps.setInt(2, accountId);
                    ps.setInt(3, item.getCourseId());

                    // Database enum: Basic, Standard, Premium
                    ps.setString(4, "Standard");

                    ps.setBigDecimal(5, item.getPrice());

                    /*
                     * DB của bạn chỉ có:
                     * Pending / Approved
                     *
                     * Vì đây là checkout thành công:
                     * Approved
                     */
                    ps.setString(6, "Approved");

                    ps.setTimestamp(7, validFrom);
                    ps.setTimestamp(8, validTo);

                    ps.setInt(9, accountId);

                    ps.addBatch();
                }

                ps.executeBatch();
            }

            /*
             * Xóa cart.
             *
             * DB của bạn có:
             *
             * cart_item.cart_id
             * ON DELETE CASCADE
             *
             * nên DELETE cart sẽ tự động DELETE cart_item.
             */
            try (PreparedStatement ps =
                         connection.prepareStatement(deleteCartSQL)) {

                ps.setInt(1, cartId);
                ps.setInt(2, accountId);

                int affectedRows = ps.executeUpdate();

                if (affectedRows == 0) {
                    connection.rollback();
                    return false;
                }
            }

            /*
             * Mọi thứ thành công
             */
            connection.commit();

            return true;

        } catch (SQLException e) {

            System.out.println(
                    "Checkout error: " + e.getMessage()
            );

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