package com.DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DBContext {

    protected Connection connection;
    protected ResultSet resultSet;
    protected PreparedStatement statement;

    public DBContext() {
        try {
            String username = "root";
            String password = "1234";// Mk Default
            // String password = "1234"; //Mk Duy
            // String password = ""; //Mk Luong
            // String url =
            // "jdbc:mysql://localhost:3306/ocms?useSSL=false&allowPublicKeyRetrieval=true";
            String url = "jdbc:mysql://localhost:3306/ocms";

            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException e) {
            System.err.println("LỖI: Chưa thêm Driver MySQL vào dự án!");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("LỖI: Kết nối CSDL thất bại! Kiểm tra User/Pass/Database Name hoặc dịch vụ MySQL.");
            e.printStackTrace();
        }
    }

    public void closeResources() {
        try {
            if (resultSet != null && !resultSet.isClosed()) {
                resultSet.close();
            }
            if (statement != null && !statement.isClosed()) {
                statement.close();
            }
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    public Connection getConnection() {
        return connection;
    }

    public static void main(String[] args) {
        DBContext db = new DBContext();
        if (db.connection != null) {
            System.out.println("Kết nối CSDL thành công!");
        } else {
            System.out.println("Kết nối CSDL thất bại!");
        }
    }
}