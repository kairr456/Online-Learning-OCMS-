package com.DAO;

import com.entity.CourseApprovalLog;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO luồng duyệt khóa học (approve/reject) + lưu vết course_approval_log.
 * LƯU Ý: mỗi lần gọi dùng instance riêng vì closeResources() đóng connection.
 */
public class CourseApprovalDAO extends DBContext {

    /** Ghi 1 dòng log (dùng khi instructor SUBMIT và khi admin duyệt/từ chối). */
    public boolean insertLog(int courseId, String action, String oldStatus, String newStatus,
            int actorId, String note, String ipAddress) {
        String sql = "INSERT INTO course_approval_log (course_id, action, old_status, new_status, actor_id, note, ip_address) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            statement.setString(2, action);
            statement.setString(3, oldStatus);
            statement.setString(4, newStatus);
            statement.setInt(5, actorId);
            statement.setString(6, note);
            statement.setString(7, ipAddress);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error insert approval log: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    /** Duyệt khóa: pending -> active + ghi log APPROVE (chỉ khi đang pending). */
    public boolean approveCourse(int courseId, int actorId, String ipAddress) {
        String updateSql = "UPDATE course SET status = 'active', modified_date = NOW() "
                + "WHERE id = ? AND status = 'pending'";
        String logSql = "INSERT INTO course_approval_log (course_id, action, old_status, new_status, actor_id, note, ip_address) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(updateSql);
            statement.setInt(1, courseId);
            boolean ok = statement.executeUpdate() > 0;
            if (ok) {
                statement = connection.prepareStatement(logSql);
                statement.setInt(1, courseId);
                statement.setString(2, "APPROVE");
                statement.setString(3, "pending");
                statement.setString(4, "active");
                statement.setInt(5, actorId);
                statement.setString(6, "");
                statement.setString(7, ipAddress);
                statement.executeUpdate();
            }
            return ok;
        } catch (SQLException ex) {
            System.out.println("Error approving course: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    /** Từ chối: pending -> cancelled + ghi log REJECT kèm lý do (chỉ khi đang pending). */
    public boolean rejectCourse(int courseId, int actorId, String note, String ipAddress) {
        String updateSql = "UPDATE course SET status = 'cancelled', modified_date = NOW() "
                + "WHERE id = ? AND status = 'pending'";
        String logSql = "INSERT INTO course_approval_log (course_id, action, old_status, new_status, actor_id, note, ip_address) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(updateSql);
            statement.setInt(1, courseId);
            boolean ok = statement.executeUpdate() > 0;
            if (ok) {
                statement = connection.prepareStatement(logSql);
                statement.setInt(1, courseId);
                statement.setString(2, "REJECT");
                statement.setString(3, "pending");
                statement.setString(4, "cancelled");
                statement.setInt(5, actorId);
                statement.setString(6, note == null ? "" : note);
                statement.setString(7, ipAddress);
                statement.executeUpdate();
            }
            return ok;
        } catch (SQLException ex) {
            System.out.println("Error rejecting course: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    /** Lấy toàn bộ lịch sử duyệt của 1 khóa (JOIN account lấy tên người thực hiện). */
    public List<CourseApprovalLog> getLogsByCourseId(int courseId) {
        List<CourseApprovalLog> logs = new ArrayList<>();
        String sql = "SELECT h.*, a.full_name AS actor_name, c.name AS course_name "
                + "FROM course_approval_log h "
                + "JOIN account a ON h.actor_id = a.id "
                + "JOIN course c ON h.course_id = c.id "
                + "WHERE h.course_id = ? ORDER BY h.created_date DESC, h.id DESC";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                logs.add(mapLog(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error loading approval logs: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return logs;
    }

    /** Lấy N dòng log gần nhất (dùng cho bảng "Course Change Log" dưới list). */
    public List<CourseApprovalLog> getRecentLogs(int limit) {
        List<CourseApprovalLog> logs = new ArrayList<>();
        String sql = "SELECT h.*, a.full_name AS actor_name, c.name AS course_name "
                + "FROM course_approval_log h "
                + "JOIN account a ON h.actor_id = a.id "
                + "JOIN course c ON h.course_id = c.id "
                + "ORDER BY h.created_date DESC, h.id DESC LIMIT ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, limit);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                logs.add(mapLog(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error loading recent approval logs: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return logs;
    }

    private CourseApprovalLog mapLog(java.sql.ResultSet rs) throws SQLException {
        CourseApprovalLog log = new CourseApprovalLog();
        log.setId(rs.getInt("id"));
        log.setCourseId(rs.getInt("course_id"));
        log.setCourseName(rs.getString("course_name"));
        log.setAction(rs.getString("action"));
        log.setOldStatus(rs.getString("old_status"));
        log.setNewStatus(rs.getString("new_status"));
        log.setActorId(rs.getInt("actor_id"));
        log.setActorName(rs.getString("actor_name"));
        log.setNote(rs.getString("note"));
        log.setIpAddress(rs.getString("ip_address"));
        java.sql.Timestamp ts = rs.getTimestamp("created_date");
        log.setCreatedDate(ts != null ? ts.toLocalDateTime() : null);
        return log;
    }
}