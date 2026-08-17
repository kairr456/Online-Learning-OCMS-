package com.DAO;

import com.entity.Course;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO riêng cho trang "Quản lý khóa học" (admin). - Tách khỏi CourseDAO vì
 * CourseDAO đã dài và còn phục vụ trang public (home/cart/lesson). - LƯU Ý QUAN
 * TRỌNG: mỗi lần gọi phải dùng instance riêng vì closeResources() sẽ đóng luôn
 * connection -> ví dụ: new CourseAdminDAO().searchCourses(...) - Nghiệp vụ
 * admin (list + search + soft delete) chỉ nằm ở đây, không nhồi thêm vào
 * CourseDAO.
 */
public class CourseAdminDAO extends DBContext {

    /**
     * Lấy danh sách khóa học cho bảng admin. JOIN account (tên giảng viên) +
     * category (tên danh mục) để hiển thị tên thay vì số ID. WHERE động theo
     * keyword / status / categoryId, phân trang bằng LIMIT ? OFFSET ?.
     *
     * LƯU Ý: Điều kiện WHERE phải khớp 100% với countCourses() để phân trang
     * không bị lệch.
     */
    public List<Course> searchCourses(String keyword, String status, Integer categoryId, int page, int pageSize) {
        List<Course> courses = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.*, a.full_name AS teacher_name, cat.name AS category_name "
                + "FROM course c "
                + "JOIN account a ON c.created_by = a.id "
                + "JOIN category cat ON c.category_id = cat.id WHERE 1=1");
        List<Object> params = new ArrayList<>();

        // Tìm theo từ khóa: khớp tên hoặc mô tả khóa học
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.name LIKE ? OR c.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        // Lọc theo trạng thái (active / inactive / draft)
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND c.status = ?");
            params.add(status.trim());
        }
        // Lọc theo danh mục
        if (categoryId != null) {
            sql.append(" AND c.category_id = ?");
            params.add(categoryId);
        }
        // Phân trang
        sql.append(" ORDER BY c.id LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    statement.setInt(i + 1, (Integer) params.get(i));
                } else {
                    statement.setString(i + 1, (String) params.get(i));
                }
            }
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                // Dùng lại mapper chung của CourseDAO (đã đổi thành static)
                Course course = mapCourse( resultSet);
                course.setCategoryName(resultSet.getString("category_name"));
                course.setTeacherName(resultSet.getString("teacher_name"));
                courses.add(course);
            }
        } catch (SQLException ex) {
            System.out.println("Error searching courses: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return courses;
    }

    /**
     * Đếm tổng số khóa học theo filter — dùng để tính tổng số trang
     * (controller). LƯU Ý: WHERE phải GIỐNG HỆT searchCourses() để số trang
     * không bị lệch.
     */
    public int countCourses(String keyword, String status, Integer categoryId) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) AS total FROM course c "
                + "JOIN account a ON c.created_by = a.id "
                + "JOIN category cat ON c.category_id = cat.id WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (c.name LIKE ? OR c.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND c.status = ?");
            params.add(status.trim());
        }
        if (categoryId != null) {
            sql.append(" AND c.category_id = ?");
            params.add(categoryId);
        }

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    statement.setInt(i + 1, (Integer) params.get(i));
                } else {
                    statement.setString(i + 1, (String) params.get(i));
                }
            }
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("total");
            }
        } catch (SQLException ex) {
            System.out.println("Error counting courses: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    /**
     * Soft delete: đổi trạng thái khóa học về 'inactive'. KHÔNG dùng DELETE
     * thật vì course bị FK tham chiếu từ cart_item/registration -> nếu có bản
     * ghi trỏ tới thì DELETE sẽ lỗi.
     */
    public boolean deactivateCourse(int id) {
        String sql = "UPDATE course SET status = 'inactive' WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error deactivating course: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    private Course mapCourse(ResultSet rs) throws SQLException {
        java.sql.Timestamp cDate = rs.getTimestamp("created_date");
        java.sql.Timestamp mDate = rs.getTimestamp("modified_date");
        Course course = new Course();
        course.setId(rs.getInt("id"));
        course.setName(rs.getString("name"));
        course.setDescription(rs.getString("description"));
        course.setThumbnail(rs.getString("thumbnail"));
        course.setRating(rs.getInt("rating"));
        course.setPrice(rs.getFloat("price"));
        course.setStatus(rs.getString("status"));
        course.setCreatedDate(cDate != null ? cDate.toLocalDateTime() : null);
        course.setModifiedDate(mDate != null ? mDate.toLocalDateTime() : null);
        course.setCreatedBy(rs.getInt("created_by"));
        course.setCategoryId(rs.getInt("category_id"));
        return course;
    }
}
