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

public class ArchivedCourseDAO extends DBContext {

    public boolean add(int accountId, int courseId) {
        String sql = "INSERT IGNORE INTO archived_course (account_id, course_id) VALUES (?, ?)";
        try (Connection conn = new DBContext().connection;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, courseId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("[ArchivedCourseDAO] add error: " + e.getMessage());
        }
        return false;
    }

    public boolean remove(int accountId, int courseId) {
        String sql = "DELETE FROM archived_course WHERE account_id = ? AND course_id = ?";
        try (Connection conn = new DBContext().connection;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, courseId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("[ArchivedCourseDAO] remove error: " + e.getMessage());
        }
        return false;
    }

    public List<Course> getCoursesByAccountId(int accountId) {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT c.id, c.name, c.thumbnail, c.price, c.category_id " +
                     "FROM archived_course ac JOIN course c ON ac.course_id = c.id " +
                     "WHERE ac.account_id = ? ORDER BY ac.created_date DESC";
        try (Connection conn = new DBContext().connection;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course course = new Course();
                    course.setId(rs.getInt("id"));
                    course.setName(rs.getString("name"));
                    course.setThumbnail(rs.getString("thumbnail"));
                    course.setPrice(rs.getFloat("price"));
                    course.setCategoryId(rs.getInt("category_id"));
                    courses.add(course);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ArchivedCourseDAO] getCoursesByAccountId error: " + e.getMessage());
        }
        return courses;
    }

    public Set<Integer> getCourseIdsByAccountId(int accountId) {
        Set<Integer> courseIds = new HashSet<>();
        String sql = "SELECT course_id FROM archived_course WHERE account_id = ?";
        try (Connection conn = new DBContext().connection;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courseIds.add(rs.getInt("course_id"));
                }
            }
        } catch (SQLException e) {
            System.err.println("[ArchivedCourseDAO] getCourseIdsByAccountId error: " + e.getMessage());
        }
        return courseIds;
    }

    public boolean isArchived(int accountId, int courseId) {
        String sql = "SELECT COUNT(*) FROM archived_course WHERE account_id = ? AND course_id = ?";
        try (Connection conn = new DBContext().connection;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ArchivedCourseDAO] isArchived error: " + e.getMessage());
        }
        return false;
    }
}