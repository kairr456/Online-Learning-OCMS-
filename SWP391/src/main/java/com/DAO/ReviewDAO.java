package com.DAO;

import com.entity.Review;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ReviewDAO extends DBContext {

    public boolean insert(Review review) {
        String sql = "INSERT INTO `review` (`course_id`, `account_id`, `rating`, `comment`) VALUES (?, ?, ?, ?)";
        try {
            statement = connection.prepareStatement(sql);
            statement.setInt(1, review.getCourseId());
            statement.setInt(2, review.getAccountId());
            statement.setInt(3, review.getRating());
            statement.setString(4, review.getComment());

            int rowsAffected = statement.executeUpdate();
            
            if (rowsAffected > 0) {
                updateCourseAverageRating(review.getCourseId());
            }
            return rowsAffected > 0;
        } catch (SQLException ex) {
            Logger.getLogger(ReviewDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        } finally {
            closeResources();
        }
    }

    private void updateCourseAverageRating(int courseId) {
        String sql = "UPDATE course SET rating = (SELECT ROUND(AVG(rating), 1) FROM review WHERE course_id = ?) WHERE id = ?";
        try {
            java.sql.PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, courseId);
            ps.setInt(2, courseId);
            ps.executeUpdate();
            ps.close();
        } catch (SQLException ex) {
            Logger.getLogger(ReviewDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
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
}
