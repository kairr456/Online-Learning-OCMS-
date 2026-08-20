package com.DAO;

import com.entity.Course;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class WishlistDAO extends DBContext {

    public Set<Integer> getCourseIdsByAccountId(int userId) {
        Set<Integer> courseIds = new HashSet<>();
        String sql = "SELECT course_id FROM wishlist WHERE account_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courseIds.add(rs.getInt("course_id"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] getCourseIdsByAccountId error: " + e.getMessage());
        }
        return courseIds;
    }

    public List<Course> getCoursesByAccountId(int userId) {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT c.id, c.name, c.description, c.thumbnail, c.price, c.category_id " +
                     "FROM wishlist w JOIN course c ON w.course_id = c.id " +
                     "WHERE w.account_id = ? ORDER BY w.created_date DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course course = new Course();
                    course.setId(rs.getInt("id"));
                    course.setName(rs.getString("name"));
                    course.setDescription(rs.getString("description"));
                    course.setThumbnail(rs.getString("thumbnail"));
                    course.setPrice(rs.getFloat("price"));
                    course.setCategoryId(rs.getInt("category_id"));
                    courses.add(course);
                }
            }
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] getCoursesByAccountId error: " + e.getMessage());
        }
        return courses;
    }

    public boolean add(int userId, int courseId) {
        String sql = "INSERT IGNORE INTO wishlist (account_id, course_id) VALUES (?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] add error: " + e.getMessage());
        }
        return false;
    }

    public boolean remove(int userId, int courseId) {
        String sql = "DELETE FROM wishlist WHERE account_id = ? AND course_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] remove error: " + e.getMessage());
        }
        return false;
    }

    public boolean toggle(int userId, int courseId) {
        String checkSql = "SELECT COUNT(*) FROM wishlist WHERE account_id = ? AND course_id = ?";
        try (Connection conn = getConnection()) {
            boolean exists;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    exists = rs.getInt(1) > 0;
                }
            }
            String sql = exists
                    ? "DELETE FROM wishlist WHERE account_id = ? AND course_id = ?"
                    : "INSERT IGNORE INTO wishlist (account_id, course_id) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, courseId);
                return ps.executeUpdate() >= 0;
            }
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] toggle error: " + e.getMessage());
            return false;
        }
    }

    public boolean isWishlisted(int userId, int courseId) {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE account_id = ? AND course_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[WishlistDAO] isWishlisted error: " + e.getMessage());
        }
        return false;
    }
}