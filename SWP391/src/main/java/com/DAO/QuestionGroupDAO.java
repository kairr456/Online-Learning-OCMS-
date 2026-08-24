package com.DAO;

import com.entity.QuestionGroup;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class QuestionGroupDAO extends DBContext {

    public List<QuestionGroup> getGroupsByCourseId(int courseId) {
        List<QuestionGroup> list = new ArrayList<>();
        String sql = "SELECT qg.*, (SELECT COUNT(*) FROM question_bank qb WHERE qb.group_id = qg.id) AS q_count FROM question_group qg WHERE qg.course_id = ? ORDER BY qg.id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuestionGroup g = new QuestionGroup(
                        rs.getInt("id"),
                        rs.getInt("course_id"),
                        rs.getString("name"),
                        rs.getTimestamp("created_date")
                    );
                    g.setQuestionCount(rs.getInt("q_count"));
                    list.add(g);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int createGroup(int courseId, String name) {
        String sql = "INSERT INTO question_group (course_id, name) VALUES (?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, courseId);
            ps.setString(2, name);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void deleteGroup(int id) {
        String sql = "DELETE FROM question_group WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean checkGroupNameExists(int courseId, String name) {
        String sql = "SELECT COUNT(*) FROM question_group WHERE course_id = ? AND LOWER(TRIM(name)) = LOWER(TRIM(?))";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setString(2, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

