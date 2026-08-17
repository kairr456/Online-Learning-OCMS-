package com.DAO;

import com.entity.Course;
import com.entity.UserLearningList;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserLearningListDAO extends DBContext {

    // 1. Tạo danh sách mới (Đã sửa account_id -> user_id, UserLearningList -> user_learning_list)
    public int createList(int accountId, String title, String description) {
        String sql = "INSERT INTO user_learning_list (user_id, title, description) VALUES (?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, accountId);
            ps.setString(2, title);
            ps.setString(3, description);
            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // 2. Cập nhật thông tin danh sách
    public boolean updateList(int listId, int accountId, String title, String description) {
        String sql = "UPDATE user_learning_list SET title = ?, description = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setInt(3, listId);
            ps.setInt(4, accountId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Xóa danh sách
    public boolean deleteList(int listId, int accountId) {
        String deleteCoursesSql = "DELETE FROM user_learning_list_course WHERE list_id = ?";
        String deleteListSql = "DELETE FROM user_learning_list WHERE id = ? AND user_id = ?";
        
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement ps1 = conn.prepareStatement(deleteCoursesSql);
                 PreparedStatement ps2 = conn.prepareStatement(deleteListSql)) {
                
                ps1.setInt(1, listId);
                ps1.executeUpdate();

                ps2.setInt(1, listId);
                ps2.setInt(2, accountId);
                int affected = ps2.executeUpdate();

                conn.commit();
                return affected > 0;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Thêm khóa học vào danh sách
    public boolean addCourseToList(int listId, int courseId) {
        String sql = "INSERT INTO user_learning_list_course (list_id, course_id) VALUES (?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, listId);
            ps.setInt(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5. Xóa khóa học khỏi danh sách
    public boolean removeCourseFromList(int listId, int courseId) {
        String sql = "DELETE FROM user_learning_list_course WHERE list_id = ? AND course_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, listId);
            ps.setInt(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<UserLearningList> getListsByAccountId(int accountId) {
        List<UserLearningList> list = new ArrayList<>();
        String sql = "SELECT * FROM user_learning_list WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserLearningList item = new UserLearningList(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getString("title"),
                        rs.getString("description")
                    );
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // Dùng DAO riêng (connection riêng) để lấy courses sau khi đã đọc hết
        // danh sách, tránh làm đóng ResultSet của câu query cha.
        for (UserLearningList item : list) {
            item.setCourses(new UserLearningListDAO().getCoursesByListId(item.getId()));
        }
        return list;
    }

    public List<Course> getCoursesByListId(int listId) {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT c.* FROM course c JOIN user_learning_list_course lc ON c.id = lc.course_id WHERE lc.list_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, listId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Course c = new Course();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                courses.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return courses;
    }
}