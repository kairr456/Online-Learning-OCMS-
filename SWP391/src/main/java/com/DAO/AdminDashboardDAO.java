package com.DAO;

import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AdminDashboardDAO extends DBContext {

    // Đếm số lượng User thông qua bảng account
    public int getTotalUsers() {
        // Câu lệnh Query
        String sql = "SELECT COUNT(*) FROM Account";
        try {
            // Biên dịch câu lệnh SQL
            statement = connection.prepareStatement(sql);
            // Thực thi (chạy) câu SQL trên Database và trả về tập kết quả chứa trong biến
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                // Trả về con số đầu tiền trong bảng
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet(); // CHỈ đóng Statement và ResultSet!
        }
        return 0;
    }

    public int getTotalCourses() {
        // Câu lệnh Query
        String sql = "SELECT COUNT(*) FROM Course";
        try {
            // Biên dịch câu lệnh SQL
            statement = connection.prepareStatement(sql);
            // Thực thi (chạy) câu SQL trên Database và trả về tập kết quả chứa trong biến
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                // Trả về con số đầu tiền trong bảng
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet(); // CHỈ đóng Statement và ResultSet!
        }
        return 0;
    }

    // "D:\Các kỳ học\SUM2026\SWP391\DB_Old.txt"
    public int getTotalRegistrations() {
        // Câu lệnh Query
        String sql = "SELECT COUNT(*) FROM Registration";
        try {
            // Biên dịch câu lệnh SQL
            statement = connection.prepareStatement(sql);
            // Thực thi (chạy) câu SQL trên Database và trả về tập kết quả chứa trong biến
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                // Trả về con số đầu tiền trong bảng
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet(); // CHỈ đóng Statement và ResultSet!
        }
        return 0;
    }

    // Doanh thu = tổng total_cost của registration Approved (không có bảng payment)
    public double getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(total_cost), 0) FROM registration WHERE status = 'Approved'";
        try {
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getDouble(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return 0;
    }

    public double getRevenueBetween(LocalDate from, LocalDate to) {
        String sql = "SELECT COALESCE(SUM(total_cost), 0) FROM registration "
                + "WHERE status = 'Approved' AND registration_time >= ? AND registration_time < ?";
        try {
            statement = connection.prepareStatement(sql);
            statement.setDate(1, Date.valueOf(from));
            statement.setDate(2, Date.valueOf(to));
            resultSet = statement.executeQuery();
            if (resultSet.next())
                return resultSet.getDouble(1);
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return 0;
    }

    // Số user theo role — đếm được bao nhiêu role hiện bấy nhiêu
    public Map<String, Integer> getUserCountByRole() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT r.name, COUNT(a.id) AS c FROM account a "
                + "JOIN role r ON a.role_id = r.id GROUP BY r.id, r.name ORDER BY r.id";
        try {
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                map.put(resultSet.getString(1), resultSet.getInt(2));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return map;
    }

    // Số course theo status — đếm được status nào hiện status đó
    public Map<String, Integer> getCourseCountByStatus() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS c FROM course GROUP BY status";
        try {
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                map.put(resultSet.getString(1), resultSet.getInt(2));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return map;
    }

    // 12 tháng gần nhất (tháng không có registration = 0)
    public Map<String, Integer> getRegistrationsByMonth() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT MONTH(registration_time) AS m, YEAR(registration_time) AS y, COUNT(*) AS c "
                + "FROM registration GROUP BY YEAR(registration_time), MONTH(registration_time) ORDER BY y, m";
        try {
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                map.put(resultSet.getInt("m") + "/" + resultSet.getInt("y"), resultSet.getInt("c"));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return map;
    }

    public Map<String, Integer> getRegistrationsByMonth(LocalDate from, LocalDate to) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT MONTH(registration_time) AS m, YEAR(registration_time) AS y, COUNT(*) AS c "
                + "FROM registration WHERE registration_time >= ? AND registration_time < ? "
                + "GROUP BY YEAR(registration_time), MONTH(registration_time) ORDER BY y, m";
        try {
            statement = connection.prepareStatement(sql);
            statement.setDate(1, Date.valueOf(from));
            statement.setDate(2, Date.valueOf(to));
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                map.put(resultSet.getInt("m") + "/" + resultSet.getInt("y"), resultSet.getInt("c"));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return map;
    }

    public List<Map<String, Object>> getMonthlyTrend(LocalDate from, LocalDate to) {
        return getTrend(from, to, false);
    }

    public List<Map<String, Object>> getTrend(LocalDate from, LocalDate to, boolean daily) {
        List<Map<String, Object>> trend = new ArrayList<>();
        String grouping = daily ? "DATE_FORMAT(registration_time, '%Y-%m-%d')"
                : "DATE_FORMAT(registration_time, '%Y-%m')";
        String sql = "SELECT " + grouping + " AS period, "
                + "COUNT(*) AS registrations, "
                + "COALESCE(SUM(CASE WHEN status = 'Approved' THEN total_cost ELSE 0 END), 0) AS revenue "
                + "FROM registration WHERE registration_time >= ? AND registration_time < ? GROUP BY "
                + grouping + " ORDER BY period";
        try {
            statement = connection.prepareStatement(sql);
            statement.setDate(1, Date.valueOf(from));
            statement.setDate(2, Date.valueOf(to));
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Map<String, Object> point = new LinkedHashMap<>();
                point.put("period", resultSet.getString("period"));
                point.put("registrations", resultSet.getInt("registrations"));
                point.put("revenue", resultSet.getDouble("revenue"));
                trend.add(point);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return trend;
    }

    public List<Map<String, Object>> getTopSellingCourses(LocalDate from, LocalDate to) {
        List<Map<String, Object>> courses = new ArrayList<>();
        String sql = "SELECT c.id, c.name, COUNT(r.id) AS sales, COALESCE(SUM(r.total_cost), 0) AS revenue "
                + "FROM course c JOIN registration r ON r.course_id = c.id "
                + "WHERE r.status = 'Approved' AND r.registration_time >= ? AND r.registration_time < ? "
                + "GROUP BY c.id, c.name ORDER BY sales DESC, revenue DESC LIMIT 5";
        try {
            statement = connection.prepareStatement(sql);
            statement.setDate(1, Date.valueOf(from));
            statement.setDate(2, Date.valueOf(to));
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Map<String, Object> course = new LinkedHashMap<>();
                course.put("id", resultSet.getInt("id"));
                course.put("name", resultSet.getString("name"));
                course.put("sales", resultSet.getInt("sales"));
                course.put("revenue", resultSet.getDouble("revenue"));
                courses.add(course);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return courses;
    }

    public int getPendingTeacherApprovals() {
        return getCount("SELECT COUNT(*) FROM teacher_profiles WHERE approval_status = 'PENDING'");
    }

    public int getPendingCourseApprovals() {
        return getCount("SELECT COUNT(*) FROM course WHERE LOWER(status) = 'pending'");
    }

    // Tỷ lệ đỗ quiz = passed / tổng quiz_attempt
    public int getQuizPassRate() {
        int passed = 0, total = 0;
        try {
            statement = connection.prepareStatement("SELECT COUNT(*) FROM quiz_attempt WHERE passed = 1");
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                passed = resultSet.getInt(1);
            }
            resultSet.close();
            statement = connection.prepareStatement("SELECT COUNT(*) FROM quiz_attempt");
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                total = resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return total == 0 ? 0 : (int) Math.round((double) passed / total * 100);
    }

    // Số registration theo status — dùng cho ô "Registrations by Status" trên
    // dashboard
    public Map<String, Integer> getRegistrationCountByStatus() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS c FROM registration GROUP BY status ORDER BY status";
        try {
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                map.put(resultSet.getString(1), resultSet.getInt(2));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return map;
    }

    // Tỷ lệ hoàn thành bài học trên các lesson thuộc khóa học đã đăng ký.
    public int getLessonCompletionRate() {
        int completed = 0, total = 0;
        try {
            statement = connection.prepareStatement(
                    "SELECT COUNT(DISTINCT lp.account_id, lp.lesson_id) "
                            + "FROM lesson_progress lp JOIN lesson l ON l.id = lp.lesson_id "
                            + "JOIN registration r ON r.account_id = lp.account_id AND r.course_id = l.course_id "
                            + "WHERE lp.completed = 1 AND r.status = 'Approved'");
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                completed = resultSet.getInt(1);
            }
            resultSet.close();
            statement = connection.prepareStatement(
                    "SELECT COUNT(DISTINCT r.account_id, l.id) FROM registration r "
                            + "JOIN lesson l ON l.course_id = r.course_id WHERE r.status = 'Approved'");
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                total = resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return total == 0 ? 0 : (int) Math.round((double) completed / total * 100);
    }

    private int getCount(String sql) {
        try {
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next())
                return resultSet.getInt(1);
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return 0;
    }

    // Hàm phụ trợ đóng Statement và ResultSet an toàn
    private void closeStatementAndResultSet() {
        try {
            if (resultSet != null && !resultSet.isClosed()) {
                resultSet.close();
            }
            if (statement != null && !statement.isClosed()) {
                statement.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

}
