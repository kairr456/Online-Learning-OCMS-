package com.DAO;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.LinkedHashMap;
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

    //"D:\Các kỳ học\SUM2026\SWP391\DB_Old.txt"
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
        LocalDate now = LocalDate.now();
        for (int i = 11; i >= 0; i--) {
            YearMonth ym = YearMonth.now().minusMonths(i);
            map.put(ym.getMonthValue() + "/" + ym.getYear(), 0);
        }
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
