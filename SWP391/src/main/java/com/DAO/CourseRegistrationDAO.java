package com.DAO;

import com.entity.Registration;
import com.entity.Course;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CourseRegistrationDAO extends DBContext implements I_DAO<Registration> {
    // Chèn hàm này vào bên trong class RegistrationDAO
    public List<Course> getCoursesByAccountId(int accountId) {
        List<Course> courses = new ArrayList<>();
        // Truy vấn lấy thông tin khóa học mà tài khoản đã đăng ký (trạng thái Active/Approved)
        String sql = "SELECT c.* FROM course c " +
                    "JOIN registration r ON c.id = r.course_id " +
                    "WHERE r.account_id = ? AND r.status IN ('Active', 'Approved', 'Success')";

        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, accountId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course course = new Course();
                    course.setId(rs.getInt("id"));
                    course.setName(rs.getString("name"));
                    course.setDescription(rs.getString("description"));
                    course.setPrice(rs.getFloat("price"));
                    course.setThumbnail(rs.getString("thumbnail"));
                    course.setCategoryId(rs.getInt("category_id"));
                    courses.add(course);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error fetching courses by account ID: " + e.getMessage());
            e.printStackTrace();
        }
        return courses;
    }
    @Override
    public List<Registration> findAll() {
        List<Registration> registrations = new ArrayList<>();
        String sql = "SELECT * FROM registration";

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                registrations.add(getFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return registrations;
    }

    @Override
    public boolean update(Registration registration) {
        String sql = "UPDATE registration SET email = ?, account_id = ?, registration_time = ?, course_id = ?, " +
                "package = ?, total_cost = ?, status = ?, valid_from = ?, valid_to = ?, last_updated_by = ? WHERE id = ?";

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, registration.getEmail());
            ps.setInt(2, registration.getAccountId());
            ps.setTimestamp(3, registration.getRegistrationTime());
            ps.setInt(4, registration.getCourseId());
            ps.setString(5, registration.getPackages());
            ps.setObject(6, registration.getTotalCost());
            ps.setString(7, registration.getStatus());
            ps.setTimestamp(8, registration.getValidFrom());
            ps.setTimestamp(9, registration.getValidTo());
            ps.setInt(10, registration.getLastUpdateByPerson());
            ps.setInt(11, registration.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean delete(Registration registration) {
        String sql = "DELETE FROM registration WHERE id = ?";

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, registration.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public int insert(Registration registration) {
        String sql = "INSERT INTO registration (email, account_id, registration_time, course_id, package, " +
                "total_cost, status, valid_from, valid_to, last_updated_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, registration.getEmail());
            ps.setInt(2, registration.getAccountId());
            ps.setTimestamp(3, registration.getRegistrationTime());
            ps.setInt(4, registration.getCourseId());
            ps.setString(5, registration.getPackages());
            ps.setBigDecimal(6, registration.getTotalCost());
            ps.setString(7, registration.getStatus());
            ps.setTimestamp(8, registration.getValidFrom());
            ps.setTimestamp(9, registration.getValidTo());
            ps.setInt(10, registration.getLastUpdateByPerson());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public Registration getFromResultSet(ResultSet resultSet) throws SQLException {
        Registration registration = new Registration();
        registration.setId(resultSet.getInt("id"));
        registration.setEmail(resultSet.getString("email"));
        registration.setAccountId(resultSet.getInt("account_id"));
        registration.setRegistrationTime(resultSet.getTimestamp("registration_time"));
        registration.setCourseId(resultSet.getInt("course_id"));
        registration.setPackages(resultSet.getString("package"));
        registration.setTotalCost(resultSet.getBigDecimal("total_cost"));
        registration.setStatus(resultSet.getString("status"));
        registration.setValidFrom(resultSet.getTimestamp("valid_from"));
        registration.setValidTo(resultSet.getTimestamp("valid_to"));
        registration.setLastUpdateByPerson(resultSet.getInt("last_updated_by"));
        return registration;
    }

     public static void main(String[] args) {
            // Tạo đối tượng RegistrationDAO để thao tác với cơ sở dữ liệu
            CourseRegistrationDAO registrationDAO = new CourseRegistrationDAO();

            // 1. Thêm mới một bản ghi (Insert)
            Registration newRegistration = new Registration();
            newRegistration.setEmail("john.doe@example.com");
            newRegistration.setAccountId(1);
            newRegistration.setRegistrationTime(new Timestamp(System.currentTimeMillis()));
            newRegistration.setCourseId(2);
            newRegistration.setPackages("Standard");
            newRegistration.setTotalCost(new BigDecimal("199.99"));
            newRegistration.setStatus("Pending");
            newRegistration.setValidFrom(new Timestamp(System.currentTimeMillis()));
            newRegistration.setValidTo(new Timestamp(System.currentTimeMillis() + 10000000));  // Một khoảng thời gian giả
            newRegistration.setLastUpdateByPerson(1);

            int insertedId = registrationDAO.insert(newRegistration);
            System.out.println("Inserted new registration with ID: " + insertedId);

            // 2. Lấy tất cả bản ghi (Find All)
            List<Registration> registrations = registrationDAO.findAll();
            System.out.println("All registrations: ");
            for (Registration reg : registrations) {
                System.out.println(reg);
            }

            // 3. Cập nhật một bản ghi (Update)
            if (!registrations.isEmpty()) {
                Registration regToUpdate = registrations.get(0); // Lấy bản ghi đầu tiên để cập nhật
                regToUpdate.setEmail("new.email@example.com");
                regToUpdate.setTotalCost(new BigDecimal("299.99"));

                boolean isUpdated = registrationDAO.update(regToUpdate);
                if (isUpdated) {
                    System.out.println("Updated registration with ID: " + regToUpdate.getId());
                } else {
                    System.out.println("Update failed for registration with ID: " + regToUpdate.getId());
                }
            }

            // 4. Xóa một bản ghi (Delete)
            if (!registrations.isEmpty()) {
                Registration regToDelete = registrations.get(0); // Lấy bản ghi đầu tiên để xóa
                boolean isDeleted = registrationDAO.delete(regToDelete);
                if (isDeleted) {
                    System.out.println("Deleted registration with ID: " + regToDelete.getId());
                } else {
                    System.out.println("Delete failed for registration with ID: " + regToDelete.getId());
                }
            }
        }

    public List<Registration> getRegistrationsByFilter(String search, String category, 
            String status, String fromDate, String toDate, int page, int pageSize, int studentId) {
        List<Registration> registrations = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.* FROM registration r " +
            "LEFT JOIN account a ON r.account_id = a.id " +
            "WHERE r.account_id = ?"
        );
        
        List<Object> parameters = new ArrayList<>();
        parameters.add(studentId);

        // Add search condition
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (a.full_name LIKE ? OR a.email LIKE ?)");
            parameters.add("%" + search + "%");
            parameters.add("%" + search + "%");
        }

        // Add category condition
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND r.course_id = ?");
            parameters.add(Integer.parseInt(category));
        }

        // Add status condition
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND r.status = ?");
            parameters.add(status);
        }

        // Add date range conditions
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND r.valid_from >= ?");
            parameters.add(fromDate + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND r.valid_to <= ?");
            parameters.add(toDate + " 23:59:59");
        }

        // Add pagination
        sql.append(" ORDER BY r.registration_time DESC LIMIT ? OFFSET ?");
        parameters.add(pageSize);
        parameters.add((page - 1) * pageSize);

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    registrations.add(getFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.println("Error executing query: " + e.getMessage());
            e.printStackTrace();
        }
        return registrations;
    }

    // Helper methods to get related information
    

    public int getTotalRegistrationsByFilter(String search, String category, String status, String fromDate,
            String toDate, int studentId) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM registration r " +
            "LEFT JOIN account a ON r.account_id = a.id " +
            "WHERE r.account_id = ?"
        );
        
        List<Object> parameters = new ArrayList<>();
        parameters.add(studentId);

        // Add search condition
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (a.full_name LIKE ? OR a.email LIKE ?)");
            parameters.add("%" + search + "%");
            parameters.add("%" + search + "%");
        }

        // Add category condition
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND r.course_id = ?");
            parameters.add(Integer.parseInt(category));
        }

        // Add status condition
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND r.status = ?");
            parameters.add(status);
        }

        // Add date range conditions
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND r.valid_from >= ?");
            parameters.add(fromDate + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND r.valid_to <= ?");
            parameters.add(toDate + " 23:59:59");
        }

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Find a registration by its ID
     * @param id The ID of the registration to find
     * @return The Registration object if found, null otherwise
     */
    public Registration findById(int id) {
        String sql = "SELECT * FROM registration WHERE id = ?";
        
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return getFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error finding registration by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Find all registrations for a specific student
     * @param studentId The ID of the student
     * @return List of Registration objects
     */
    public List<Registration> findByStudentId(int studentId) {
        List<Registration> registrations = new ArrayList<>();
        String sql = "SELECT * FROM registration WHERE account_id = ?";
        
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    registrations.add(getFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.println("Error finding registrations by student ID: " + e.getMessage());
            e.printStackTrace();
        }
        return registrations;
    }

    /**
     * Check if a student has already registered for a specific course
     * @param studentId The ID of the student
     * @param courseId The ID of the course
     * @return true if the student has an active or pending registration for the course, false otherwise
     */
    public boolean isAlreadyRegistered(int studentId, int courseId) {
        String sql = "SELECT COUNT(*) FROM registration WHERE account_id = ? AND course_id = ? AND status IN ('Active', 'Pending')";
        
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("Error checking if course is already registered: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ============================================================
    // Hỗ trợ hiển thị GIAO DỊCH (Student & Teacher)
    // ------------------------------------------------------------
    // Student: /my-purchases + dropdown header -> lịch sử mua khóa.
    // Teacher: /teacher-transactions + dropdown header -> số lượt khóa được mua.
    // Tất cả truy vấn trên bảng registration cũ (JOIN course), KHÔNG cần bảng mới.
    // ============================================================

    /**
     * Lấy danh sách giao dịch mua khóa của học viên (kèm tên khóa học).
     *
     * @param accountId id tài khoản học viên
     * @param limit     số bản ghi tối đa (dropdown dùng 3); truyền 0 hoặc âm để lấy hết
     * @return List<Registration> mới nhất trước, có courseName
     */
    public List<Registration> getPurchasesByAccountId(int accountId, int limit) {
        List<Registration> purchases = new ArrayList<>();
        String sql = "SELECT r.*, c.name AS course_name " +
                     "FROM registration r " +
                     "JOIN course c ON r.course_id = c.id " +
                     "WHERE r.account_id = ? " +
                     "ORDER BY r.registration_time DESC" +
                     (limit > 0 ? " LIMIT ?" : "");

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            if (limit > 0) {
                ps.setInt(2, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Registration reg = getFromResultSet(rs);
                    reg.setCourseName(rs.getString("course_name"));
                    purchases.add(reg);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error fetching purchases by account: " + e.getMessage());
            e.printStackTrace();
        }
        return purchases;
    }

    /**
     * Tóm tắt mua hàng của học viên: tổng số khóa + tổng tiền đã chi.
     */
    public Map<String, Object> getPurchaseSummary(int accountId) {
        Map<String, Object> summary = new HashMap<>();
        String sql = "SELECT COUNT(*) AS total_count, COALESCE(SUM(total_cost), 0) AS total_spent " +
                     "FROM registration WHERE account_id = ?";
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.put("totalCount", rs.getInt("total_count"));
                    summary.put("totalSpent", rs.getBigDecimal("total_spent"));
                }
            }
        } catch (SQLException e) {
            System.out.println("Error fetching purchase summary: " + e.getMessage());
            e.printStackTrace();
        }
        return summary;
    }

    /**
     * Thống kê doanh thu bán khóa của giáo viên (theo từng khóa).
     * Chỉ đếm giao dịch thành công (Active/Approved/Success); LEFT JOIN để
     * khóa chưa bán vẫn xuất hiện với count = 0.
     *
     * @param teacherId id giáo viên (course.created_by)
     * @return List<Map> mỗi phần tử: courseName, totalSales, totalRevenue
     */
    public List<Map<String, Object>> countSalesByTeacher(int teacherId) {
        List<Map<String, Object>> sales = new ArrayList<>();
        String sql = "SELECT c.name AS course_name, " +
                     "COUNT(r.id) AS total_sales, " +
                     "COALESCE(SUM(r.total_cost), 0) AS total_revenue " +
                     "FROM course c " +
                     "LEFT JOIN registration r ON r.course_id = c.id " +
                     " AND r.status IN ('Active', 'Approved', 'Success') " +
                     "WHERE c.created_by = ? " +
                     "GROUP BY c.id, c.name " +
                     "ORDER BY total_sales DESC, c.name";

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("courseName", rs.getString("course_name"));
                    row.put("totalSales", rs.getInt("total_sales"));
                    row.put("totalRevenue", rs.getBigDecimal("total_revenue"));
                    sales.add(row);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error counting sales by teacher: " + e.getMessage());
            e.printStackTrace();
        }
        return sales;
    }

    /**
     * Tóm tắt doanh thu của giáo viên: tổng lượt mua + tổng doanh thu.
     */
    public Map<String, Object> getSalesSummary(int teacherId) {
        Map<String, Object> summary = new HashMap<>();
        String sql = "SELECT COUNT(r.id) AS total_sales_count, " +
                     "COALESCE(SUM(r.total_cost), 0) AS total_revenue " +
                     "FROM course c " +
                     "LEFT JOIN registration r ON r.course_id = c.id " +
                     " AND r.status IN ('Active', 'Approved', 'Success') " +
                     "WHERE c.created_by = ?";
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.put("totalSalesCount", rs.getInt("total_sales_count"));
                    summary.put("totalRevenue", rs.getBigDecimal("total_revenue"));
                }
            }
        } catch (SQLException e) {
            System.out.println("Error fetching sales summary: " + e.getMessage());
            e.printStackTrace();
        }
        return summary;
    }

    // ============================================================
    // Backward compatibility methods — dùng cho ADMIN
    // (trang "Quản lý đăng ký khóa học" /admin/registrations).
    // Lấy tất cả registration (không lọc theo studentId), kèm tên học viên
    // (account.full_name) và tên khóa học (course.name). Các method này
    // KHÔNG được controller phía student sử dụng nên an toàn khi sửa.
    // ============================================================

    /**
     * Lấy danh sách đăng ký cho admin với tìm kiếm / lọc / phân trang.
     *
     * @param search   từ khóa tìm theo tên học viên, email hoặc tên khóa học
     * @param category id khóa học (lọc theo khóa) — truyền null để bỏ qua
     * @param status   trạng thái đăng ký (Approved/Active/Pending/...) — null để lấy hết
     * @param fromDate lọc valid_from >= ngày bắt đầu (yyyy-MM-dd) — null để bỏ qua
     * @param toDate   lọc valid_to <= ngày kết thúc (yyyy-MM-dd) — null để bỏ qua
     * @param page     trang hiện tại (bắt đầu từ 1)
     * @param pageSize số bản ghi mỗi trang
     * @return danh sách Registration (đã kèm studentName & courseName), mới nhất lên đầu
     */
    public List<Registration> getRegistrationsByFilter(String search, String category,
            String status, String fromDate, String toDate, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(
            "SELECT r.*, a.full_name AS student_name, c.name AS course_name " +
            "FROM registration r " +
            "LEFT JOIN account a ON r.account_id = a.id " +
            "LEFT JOIN course c ON r.course_id = c.id " +
            "WHERE 1=1"
        );

        List<Object> parameters = new ArrayList<>();

        // Tìm kiếm theo tên học viên / email / tên khóa học
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (a.full_name LIKE ? OR a.email LIKE ? OR c.name LIKE ?)");
            parameters.add("%" + search + "%");
            parameters.add("%" + search + "%");
            parameters.add("%" + search + "%");
        }

        // Lọc theo khóa học (course_id)
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND r.course_id = ?");
            parameters.add(Integer.parseInt(category));
        }

        // Lọc theo trạng thái đăng ký
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND r.status = ?");
            parameters.add(status);
        }

        // Lọc theo khoảng ngày hiệu lực
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND r.valid_from >= ?");
            parameters.add(fromDate + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND r.valid_to <= ?");
            parameters.add(toDate + " 23:59:59");
        }

        // Phân trang: mới nhất lên đầu
        sql.append(" ORDER BY r.registration_time DESC LIMIT ? OFFSET ?");
        parameters.add(pageSize);
        parameters.add((page - 1) * pageSize);

        List<Registration> registrations = new ArrayList<>();
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Registration reg = getFromResultSet(rs);
                    // Map thêm 2 cột JOIN (không nằm trong getFromResultSet để
                    // các query SELECT * khác không bị lỗi thiếu cột)
                    reg.setStudentName(rs.getString("student_name"));
                    reg.setCourseName(rs.getString("course_name"));
                    registrations.add(reg);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error executing query: " + e.getMessage());
            e.printStackTrace();
        }
        return registrations;
    }

    /**
     * Đếm tổng số đăng ký khớp filter (dùng để tính tổng số trang cho admin).
     * JOIN course để count đúng khi search theo tên khóa học.
     */
    public int getTotalRegistrationsByFilter(String search, String category, String status, String fromDate,
            String toDate) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM registration r " +
            "LEFT JOIN account a ON r.account_id = a.id " +
            "LEFT JOIN course c ON r.course_id = c.id " +
            "WHERE 1=1"
        );

        List<Object> parameters = new ArrayList<>();

        // Tìm kiếm theo tên học viên / email / tên khóa học
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (a.full_name LIKE ? OR a.email LIKE ? OR c.name LIKE ?)");
            parameters.add("%" + search + "%");
            parameters.add("%" + search + "%");
            parameters.add("%" + search + "%");
        }

        // Lọc theo khóa học (course_id)
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND r.course_id = ?");
            parameters.add(Integer.parseInt(category));
        }

        // Lọc theo trạng thái đăng ký
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND r.status = ?");
            parameters.add(status);
        }

        // Lọc theo khoảng ngày hiệu lực
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND r.valid_from >= ?");
            parameters.add(fromDate + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND r.valid_to <= ?");
            parameters.add(toDate + " 23:59:59");
        }

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

}