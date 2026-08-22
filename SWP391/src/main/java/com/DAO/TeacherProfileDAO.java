package com.DAO;

import com.entity.TeacherProfile;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TeacherProfileDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(TeacherProfileDAO.class.getName());

    public boolean insert(TeacherProfile profile) {
        String sql = "INSERT INTO teacher_profile "
                + "(teacher_id, headline, bio, years_experience, education, certifications, "
                + "linkedin_url, website_url, avatar_url, cv_file_path, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, profile.getTeacherId());
            ps.setString(2, profile.getHeadline());
            ps.setString(3, profile.getBio());
            ps.setInt(4, profile.getYearsExperience());
            ps.setString(5, profile.getEducation());
            ps.setString(6, profile.getCertifications());
            ps.setString(7, profile.getLinkedinUrl());
            ps.setString(8, profile.getWebsiteUrl());
            ps.setString(9, profile.getAvatarUrl());
            ps.setString(10, profile.getCvFilePath());
            ps.setString(11, profile.getStatus());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        profile.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Insert teacher_profile failed", ex);
        }
        return false;
    }

    public TeacherProfile findByTeacherId(int teacherId) {
        String sql = "SELECT * FROM teacher_profile WHERE teacher_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Find teacher_profile by teacherId failed", ex);
        }
        return null;
    }

    public TeacherProfile findById(int id) {
        String sql = "SELECT * FROM teacher_profile WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Find teacher_profile by id failed", ex);
        }
        return null;
    }

    public boolean update(TeacherProfile profile) {
        String sql = "UPDATE teacher_profile SET "
                + "headline = ?, bio = ?, years_experience = ?, education = ?, certifications = ?, "
                + "linkedin_url = ?, website_url = ?, avatar_url = ?, cv_file_path = ?, "
                + "status = ?, admin_note = ?, reviewed_by = ?, reviewed_at = ?, updated_at = NOW() "
                + "WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, profile.getHeadline());
            ps.setString(2, profile.getBio());
            ps.setInt(3, profile.getYearsExperience());
            ps.setString(4, profile.getEducation());
            ps.setString(5, profile.getCertifications());
            ps.setString(6, profile.getLinkedinUrl());
            ps.setString(7, profile.getWebsiteUrl());
            ps.setString(8, profile.getAvatarUrl());
            ps.setString(9, profile.getCvFilePath());
            ps.setString(10, profile.getStatus());
            ps.setString(11, profile.getAdminNote());
            ps.setObject(12, profile.getReviewedBy());
            ps.setObject(13, profile.getReviewedAt());
            ps.setInt(14, profile.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Update teacher_profile failed", ex);
        }
        return false;
    }

    public boolean updateStatus(int profileId, String status, Integer reviewedBy, String adminNote) {
        String sql = "UPDATE teacher_profile SET status = ?, reviewed_by = ?, reviewed_at = NOW(), "
                + "admin_note = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setObject(2, reviewedBy);
            ps.setString(3, adminNote);
            ps.setInt(4, profileId);

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Update teacher_profile status failed", ex);
        }
        return false;
    }

    public List<TeacherProfile> findPending(int page, int pageSize, String keyword) {
        List<TeacherProfile> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT tp.*, a.username, a.email, a.full_name "
                + "FROM teacher_profile tp "
                + "JOIN account a ON tp.teacher_id = a.id "
                + "WHERE tp.status = 'pending' ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (a.username LIKE ? OR a.email LIKE ? OR a.full_name LIKE ? OR tp.headline LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY tp.created_at ASC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeacherProfile tp = mapRow(rs);
                    tp.setUsername(rs.getString("username"));
                    tp.setEmail(rs.getString("email"));
                    tp.setFullName(rs.getString("full_name"));
                    list.add(tp);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Find pending teacher_profiles failed", ex);
        }
        return list;
    }

    public int countPending(String keyword) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM teacher_profile tp "
                + "JOIN account a ON tp.teacher_id = a.id "
                + "WHERE tp.status = 'pending' ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (a.username LIKE ? OR a.email LIKE ? OR a.full_name LIKE ? OR tp.headline LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Count pending teacher_profiles failed", ex);
        }
        return 0;
    }

    public boolean deleteByTeacherId(int teacherId) {
        String sql = "DELETE FROM teacher_profile WHERE teacher_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, teacherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Delete teacher_profile by teacherId failed", ex);
        }
        return false;
    }

    private TeacherProfile mapRow(ResultSet rs) throws SQLException {
        TeacherProfile tp = new TeacherProfile();
        tp.setId(rs.getInt("id"));
        tp.setTeacherId(rs.getInt("teacher_id"));
        tp.setHeadline(rs.getString("headline"));
        tp.setBio(rs.getString("bio"));
        tp.setYearsExperience(rs.getInt("years_experience"));
        tp.setEducation(rs.getString("education"));
        tp.setCertifications(rs.getString("certifications"));
        tp.setLinkedinUrl(rs.getString("linkedin_url"));
        tp.setWebsiteUrl(rs.getString("website_url"));
        tp.setAvatarUrl(rs.getString("avatar_url"));
        tp.setCvFilePath(rs.getString("cv_file_path"));
        tp.setStatus(rs.getString("status"));
        tp.setAdminNote(rs.getString("admin_note"));
        tp.setReviewedBy((Integer) rs.getObject("reviewed_by"));
        tp.setReviewedAt(rs.getTimestamp("reviewed_at"));
        tp.setCreatedAt(rs.getTimestamp("created_at"));
        tp.setUpdatedAt(rs.getTimestamp("updated_at"));
        // Extra fields from JOIN (if present)
        try {
            tp.setUsername(rs.getString("username"));
        } catch (SQLException ignored) {}
        try {
            tp.setEmail(rs.getString("email"));
        } catch (SQLException ignored) {}
        try {
            tp.setFullName(rs.getString("full_name"));
        } catch (SQLException ignored) {}
        return tp;
    }
}