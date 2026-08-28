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

    // Tỷ lệ học viên đỗ quiz:
    // Đánh giá theo từng cặp (account_id, quiz_id) cho các khóa học đã được đăng ký hợp lệ:
    // - Nhiều lần làm, đỗ ít nhất 1 lần -> Tính 1 ĐỖ.
    // - Nhiều lần làm, tất cả trượt -> Tính 1 TRƯỢT.
    // - 1 lần làm, đỗ -> Tính 1 ĐỖ.
    // Tỷ lệ = (Số cặp đỗ ít nhất 1 lần / Tổng số cặp đã thực hiện bài làm) * 100
    public int getQuizPassRate() {
        int passedCount = 0, totalCount = 0;
        try {
            // 1. Đếm số cặp (account_id, quiz_id) đã đỗ ít nhất 1 lần đối với các khóa học được đăng ký/mua
            String sqlPassed = "SELECT COUNT(*) FROM (" +
                    "SELECT qa.account_id, qa.quiz_id " +
                    "FROM quiz_attempt qa " +
                    "JOIN lesson_quiz lq ON lq.id = qa.quiz_id " +
                    "JOIN lesson l ON l.id = lq.lesson_id " +
                    "JOIN section s ON s.id = l.section_id " +
                    "JOIN registration r ON r.course_id = s.course_id AND r.account_id = qa.account_id " +
                    "WHERE qa.passed = 1 AND LOWER(r.status) IN ('approved', 'success', 'active') " +
                    "GROUP BY qa.account_id, qa.quiz_id" +
                    ") AS passed_pairs";

            statement = connection.prepareStatement(sqlPassed);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                passedCount = resultSet.getInt(1);
            }
            resultSet.close();

            // 2. Đếm tổng số cặp (account_id, quiz_id) đã thực hiện bài làm đối với các khóa học được đăng ký/mua
            String sqlTotal = "SELECT COUNT(*) FROM (" +
                    "SELECT qa.account_id, qa.quiz_id " +
                    "FROM quiz_attempt qa " +
                    "JOIN lesson_quiz lq ON lq.id = qa.quiz_id " +
                    "JOIN lesson l ON l.id = lq.lesson_id " +
                    "JOIN section s ON s.id = l.section_id " +
                    "JOIN registration r ON r.course_id = s.course_id AND r.account_id = qa.account_id " +
                    "WHERE LOWER(r.status) IN ('approved', 'success', 'active') " +
                    "GROUP BY qa.account_id, qa.quiz_id" +
                    ") AS total_pairs";

            statement = connection.prepareStatement(sqlTotal);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                totalCount = resultSet.getInt(1);
            }
            resultSet.close();

            // Fallback nếu không có lượt đăng ký chính thức tương ứng
            if (totalCount == 0) {
                String fallbackPassed = "SELECT COUNT(*) FROM (" +
                        "SELECT account_id, quiz_id FROM quiz_attempt WHERE passed = 1 GROUP BY account_id, quiz_id" +
                        ") AS p";
                statement = connection.prepareStatement(fallbackPassed);
                resultSet = statement.executeQuery();
                if (resultSet.next()) passedCount = resultSet.getInt(1);
                resultSet.close();

                String fallbackTotal = "SELECT COUNT(*) FROM (" +
                        "SELECT account_id, quiz_id FROM quiz_attempt GROUP BY account_id, quiz_id" +
                        ") AS t";
                statement = connection.prepareStatement(fallbackTotal);
                resultSet = statement.executeQuery();
                if (resultSet.next()) totalCount = resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return totalCount == 0 ? 0 : (int) Math.round((double) passedCount / totalCount * 100);
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

    // Tỷ lệ hoàn thành khóa học:
    // Tính dựa trên tổng số lượt mua/đăng ký khóa học (registration) đã hoàn thành 100% tất cả bài học (lesson_progress.completed = 1).
    // Tỷ lệ = (Số khóa học hoàn thành 100% / Tổng số lượt mua khóa học) * 100
    public int getLessonCompletionRate() {
        int completedCourses = 0, totalPurchasedCourses = 0;
        try {
            String sql = "SELECT " +
                    "  COUNT(CASE WHEN course_lessons.total_lessons > 0 AND course_lessons.completed_lessons >= course_lessons.total_lessons THEN 1 END) AS completed_courses, " +
                    "  COUNT(*) AS total_purchased_courses " +
                    "FROM (" +
                    "  SELECT " +
                    "    r.account_id, " +
                    "    r.course_id, " +
                    "    ( " +
                    "      SELECT COUNT(DISTINCT l.id) " +
                    "      FROM section s " +
                    "      JOIN lesson l ON l.section_id = s.id " +
                    "      WHERE s.course_id = r.course_id " +
                    "    ) AS total_lessons, " +
                    "    ( " +
                    "      SELECT COUNT(DISTINCT lp.lesson_id) " +
                    "      FROM lesson_progress lp " +
                    "      JOIN lesson l ON l.id = lp.lesson_id " +
                    "      JOIN section s ON s.id = l.section_id " +
                    "      WHERE lp.account_id = r.account_id " +
                    "        AND lp.completed = 1 " +
                    "        AND s.course_id = r.course_id " +
                    "    ) AS completed_lessons " +
                    "  FROM registration r " +
                    "  WHERE LOWER(r.status) IN ('approved', 'success', 'active') " +
                    ") AS course_lessons";

            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                completedCourses = resultSet.getInt("completed_courses");
                totalPurchasedCourses = resultSet.getInt("total_purchased_courses");
            }
            resultSet.close();

            // Nếu không có lượt mua có trạng thái Approved/Success/Active, fallback lấy tất cả lượt trong registration
            if (totalPurchasedCourses == 0) {
                String fallbackSql = "SELECT " +
                        "  COUNT(CASE WHEN course_lessons.total_lessons > 0 AND course_lessons.completed_lessons >= course_lessons.total_lessons THEN 1 END) AS completed_courses, " +
                        "  COUNT(*) AS total_purchased_courses " +
                        "FROM (" +
                        "  SELECT " +
                        "    r.account_id, " +
                        "    r.course_id, " +
                        "    (SELECT COUNT(DISTINCT l.id) FROM section s JOIN lesson l ON l.section_id = s.id WHERE s.course_id = r.course_id) AS total_lessons, " +
                        "    (SELECT COUNT(DISTINCT lp.lesson_id) FROM lesson_progress lp JOIN lesson l ON l.id = lp.lesson_id JOIN section s ON s.id = l.section_id WHERE lp.account_id = r.account_id AND lp.completed = 1 AND s.course_id = r.course_id) AS completed_lessons " +
                        "  FROM registration r " +
                        ") AS course_lessons";

                statement = connection.prepareStatement(fallbackSql);
                resultSet = statement.executeQuery();
                if (resultSet.next()) {
                    completedCourses = resultSet.getInt("completed_courses");
                    totalPurchasedCourses = resultSet.getInt("total_purchased_courses");
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeStatementAndResultSet();
        }
        return totalPurchasedCourses == 0 ? 0 : (int) Math.round((double) completedCourses / totalPurchasedCourses * 100);
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
