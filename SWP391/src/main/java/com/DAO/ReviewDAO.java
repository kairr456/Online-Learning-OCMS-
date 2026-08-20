package com.DAO;

import com.entity.Review;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ReviewDAO extends DBContext {

    public ReviewDAO() {
        // Tự động đồng bộ số sao trung bình của tất cả khóa học từ bảng review vào bảng course
        syncAllCourseRatings();
    }

    /**
     * Đồng bộ lại cột rating trong bảng course cho tất cả các khóa học
     */
    public void syncAllCourseRatings() {
        String restoreSeedSql = "UPDATE course SET rating = CASE "
                + "WHEN id IN (2,5,9,11,13,17,19,22,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57) THEN 5 "
                + "WHEN id IN (1,4,6,8,10,12,14,16,18,20,23,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56) THEN 4 "
                + "WHEN id IN (3,7,15,21) THEN 3 "
                + "ELSE rating END "
                + "WHERE id <= 57";

        String syncReviewsSql = "UPDATE course c "
                + "JOIN (SELECT course_id, ROUND(AVG(rating)) AS avg_rate FROM review GROUP BY course_id) r "
                + "ON c.id = r.course_id "
                + "SET c.rating = r.avg_rate";

        DBContext db = new DBContext();
        try {
            if (db.connection != null) {
                Statement stmt = db.connection.createStatement();
                stmt.executeUpdate(restoreSeedSql);
                stmt.executeUpdate(syncReviewsSql);
                stmt.close();
            }
        } catch (SQLException ex) {
            Logger.getLogger(ReviewDAO.class.getName()).log(Level.SEVERE, "Lỗi đồng bộ ratings khóa học: " + ex.getMessage(), ex);
        } finally {
            db.closeResources();
        }
    }

    /**
     * Cập nhật điểm đánh giá trung bình cho 1 khóa học cụ thể
     */
    public void updateCourseRating(int courseId) {
        String sql = "UPDATE course c "
                   + "SET c.rating = COALESCE((SELECT ROUND(AVG(r.rating)) FROM review r WHERE r.course_id = ?), c.rating) "
                   + "WHERE c.id = ?";
        DBContext db = new DBContext();
        try {
            if (db.connection != null) {
                PreparedStatement ps = db.connection.prepareStatement(sql);
                ps.setInt(1, courseId);
                ps.setInt(2, courseId);
                ps.executeUpdate();
                ps.close();
            }
        } catch (SQLException ex) {
            Logger.getLogger(ReviewDAO.class.getName()).log(Level.SEVERE, "Lỗi cập nhật rating courseId=" + courseId, ex);
        } finally {
            db.closeResources();
        }
    }

    public boolean insert(Review review) {
        String sql = "INSERT INTO `review` (`course_id`, `account_id`, `rating`, `comment`) VALUES (?, ?, ?, ?)";
        boolean success = false;
        try {
            statement = connection.prepareStatement(sql);
            statement.setInt(1, review.getCourseId());
            statement.setInt(2, review.getAccountId());
            statement.setInt(3, review.getRating());
            statement.setString(4, review.getComment());

            int rowsAffected = statement.executeUpdate();
            success = rowsAffected > 0;
        } catch (SQLException ex) {
            Logger.getLogger(ReviewDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        } finally {
            closeResources();
        }

        if (success) {
            updateCourseRating(review.getCourseId());
        }
        return success;
    }

    public List<Review> getReviewsByCourseId(int courseId) {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT * FROM `review` WHERE `course_id` = ? ORDER BY `created_date` DESC";
        try {
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                Review review = new Review();
                review.setId(resultSet.getInt("id"));
                review.setCourseId(resultSet.getInt("course_id"));
                review.setAccountId(resultSet.getInt("account_id"));
                review.setRating(resultSet.getInt("rating"));
                review.setComment(resultSet.getString("comment"));
                review.setCreatedDate(resultSet.getTimestamp("created_date"));
                
                reviews.add(review);
            }
        } catch (SQLException ex) {
            Logger.getLogger(ReviewDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeResources();
        }
        return reviews;
    }

    /**
     * Lấy điểm rating trung bình dạng thập phân (ví dụ: 4.5)
     */
    public double getAverageRating(int courseId) {
        String sql = "SELECT AVG(rating) as avg_rating FROM review WHERE course_id = ?";
        DBContext db = new DBContext();
        try {
            if (db.connection != null) {
                PreparedStatement ps = db.connection.prepareStatement(sql);
                ps.setInt(1, courseId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    double avg = rs.getDouble("avg_rating");
                    rs.close();
                    ps.close();
                    return Math.round(avg * 10.0) / 10.0;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            db.closeResources();
        }
        return 0.0;
    }

    /**
     * Lấy phân bố số lượng đánh giá theo từng mức sao (1 - 5 sao)
     */
    public Map<Integer, Integer> getRatingDistribution(int courseId) {
        Map<Integer, Integer> distribution = new HashMap<>();
        for (int i = 1; i <= 5; i++) {
            distribution.put(i, 0);
        }
        String sql = "SELECT rating, COUNT(*) as cnt FROM review WHERE course_id = ? GROUP BY rating";
        DBContext db = new DBContext();
        try {
            if (db.connection != null) {
                PreparedStatement ps = db.connection.prepareStatement(sql);
                ps.setInt(1, courseId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    distribution.put(rs.getInt("rating"), rs.getInt("cnt"));
                }
                rs.close();
                ps.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            db.closeResources();
        }
        return distribution;
    }
}
