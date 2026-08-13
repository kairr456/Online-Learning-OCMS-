package com.DAO;

import java.sql.SQLException;
public class AdminDashboardDAO extends DBContext {
    // Đếm số lượng User thông qua bảng account
    public int getTotalUsers(){
        // Câu lệnh Query
        String sql = "SELECT COUNT(*) FROM Account";
        try{
            // Biên dịch câu lệnh SQL
            statement = connection.prepareStatement(sql);
            // Thực thi (chạy) câu SQL trên Database và trả về tập kết quả chứa trong biến
            resultSet = statement.executeQuery();
            if(resultSet.next()){
                // Trả về con số đầu tiền trong bảng
                return resultSet.getInt(1);
            }
        }
        catch (SQLException ex){
            ex.printStackTrace();
        }
        finally {
            closeStatementAndResultSet(); // CHỈ đóng Statement và ResultSet!
        }
        return 0;
    }
    
    public int getTotalCourses(){
        // Câu lệnh Query
        String sql = "SELECT COUNT(*) FROM Course";
        try{
            // Biên dịch câu lệnh SQL
            statement = connection.prepareStatement(sql);
            // Thực thi (chạy) câu SQL trên Database và trả về tập kết quả chứa trong biến
            resultSet = statement.executeQuery();
            if(resultSet.next()){
                // Trả về con số đầu tiền trong bảng
                return resultSet.getInt(1);
            }
        }
        catch (SQLException ex){
            ex.printStackTrace();
        }
        finally {
            closeStatementAndResultSet(); // CHỈ đóng Statement và ResultSet!
        }
        return 0;
    }
    
    public int getTotalRegistrations(){
        // Câu lệnh Query
        String sql = "SELECT COUNT(*) FROM Registration";
        try{
            // Biên dịch câu lệnh SQL
            statement = connection.prepareStatement(sql);
            // Thực thi (chạy) câu SQL trên Database và trả về tập kết quả chứa trong biến
            resultSet = statement.executeQuery();
            if(resultSet.next()){
                // Trả về con số đầu tiền trong bảng
                return resultSet.getInt(1);
            }
        }
        catch (SQLException ex){
            ex.printStackTrace();
        }
        finally {
            closeStatementAndResultSet(); // CHỈ đóng Statement và ResultSet!
        }
        return 0;
    }
    
    // Hàm phụ trợ đóng Statement và ResultSet an toàn
    private void closeStatementAndResultSet() {
        try {
            if (resultSet != null && !resultSet.isClosed()) resultSet.close();
            if (statement != null && !statement.isClosed()) statement.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
