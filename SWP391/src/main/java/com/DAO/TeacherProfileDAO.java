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
        String sql = "INSERT INTO teacher_profiles "
                + "(account_id, bio, specialization, experience_years, cv_url, portfolio_url, approval_status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, profile.getAccountId());
            ps.setString(2, profile.getBio());
            ps.setString(3, profile.getSpecialization());
            ps.setInt(4, profile.getExperienceYears());
            ps.setString(5, profile.getCvUrl());
            ps.setString(6, profile.getPortfolioUrl());
            ps.setString(7, profile.getApprovalStatus());

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
            LOGGER.log(Level.SEVERE, "Insert teacher_profiles failed", ex);
        }
        return false;
    }

    public TeacherProfile findByAccountId(int accountId) {
        String sql = "SELECT * FROM teacher_profiles WHERE account_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Find teacher_profiles by accountId failed", ex);
        }
        return null;
    }

    public TeacherProfile findById(int id) {
        String sql = "SELECT * FROM teacher_profiles WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Find teacher_profiles by id failed", ex);
        }
        return null;
    }

    public boolean update(TeacherProfile profile) {
        String sql = "UPDATE teacher_profiles SET "
                + "bio = ?, specialization = ?, experience_years = ?, cv_url = ?, portfolio_url = ?, "
                + "approval_status = ?, rejected_reason = ?, updated_at = NOW() "
                + "WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, profile.getBio());
            ps.setString(2, profile.getSpecialization());
            ps.setInt(3, profile.getExperienceYears());
            ps.setString(4, profile.getCvUrl());
            ps.setString(5, profile.getPortfolioUrl());
            ps.setString(6, profile.getApprovalStatus());
            ps.setString(7, profile.getRejectedReason());
            ps.setInt(8, profile.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Update teacher_profiles failed", ex);
        }
        return false;
    }

    public boolean updateStatus(int profileId, String approvalStatus, String rejectedReason) {
        String sql = "UPDATE teacher_profiles SET approval_status = ?, rejected_reason = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, approvalStatus);
            ps.setString(2, rejectedReason);
            ps.setInt(3, profileId);

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Update teacher_profiles status failed", ex);
        }
        return false;
    }

    public List<TeacherProfile> findPending(int page, int pageSize, String keyword) {
        List<TeacherProfile> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT tp.*, a.username, a.email, a.full_name "
                + "FROM teacher_profiles tp "
                + "JOIN account a ON tp.account_id = a.id "
                + "WHERE tp.approval_status = 'PENDING' ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (a.username LIKE ? OR a.email LIKE ? OR a.full_name LIKE ? OR tp.specialization LIKE ?) ");
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
                "SELECT COUNT(*) FROM teacher_profiles tp "
                + "JOIN account a ON tp.account_id = a.id "
                + "WHERE tp.approval_status = 'PENDING' ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (a.username LIKE ? OR a.email LIKE ? OR a.full_name LIKE ? OR tp.specialization LIKE ?) ");
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

    public boolean deleteByAccountId(int accountId) {
        String sql = "DELETE FROM teacher_profiles WHERE account_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Delete teacher_profiles by accountId failed", ex);
        }
        return false;
    }

    private TeacherProfile mapRow(ResultSet rs) throws SQLException {
        TeacherProfile tp = new TeacherProfile();
        tp.setId(rs.getInt("id"));
        tp.setAccountId(rs.getInt("account_id"));
        tp.setSpecialization(rs.getString("specialization"));
        tp.setBio(rs.getString("bio"));
        tp.setExperienceYears(rs.getInt("experience_years"));
        tp.setCvUrl(rs.getString("cv_url"));
        tp.setPortfolioUrl(rs.getString("portfolio_url"));
        tp.setApprovalStatus(rs.getString("approval_status"));
        tp.setRejectedReason(rs.getString("rejected_reason"));
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