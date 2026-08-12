package com.DAO;

import com.entity.Account;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AccountDAO extends DBContext {
 private Connection connection;

    public AccountDAO(Connection connection) {
        this.connection = connection;
    }

    // =========================================================
    // Check whether username already exists
    // =========================================================
    public boolean isUsernameExists(String username) {

        String sql = "SELECT id FROM Account WHERE username = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================================================
    // Check whether email already exists
    // =========================================================
    public boolean isEmailExists(String email) {

        String sql = "SELECT id FROM Account WHERE email = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================================================
    // Register new account
    // =========================================================
    public boolean register(Account account) {

        String sql = """
                INSERT INTO Account
                (
                    username,
                    password,
                    email,
                    phone,
                    fullName,
                    gender,
                    avatar,
                    isActive,
                    roleId
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, account.getUsername());
            ps.setString(2, account.getPassword());
            ps.setString(3, account.getEmail());
            ps.setString(4, account.getPhone());
            ps.setString(5, account.getFullName());
            ps.setBoolean(6, account.isGender());
            ps.setString(7, account.getAvatar());
            ps.setBoolean(8, account.isActive());
            ps.setInt(9, account.getRoleId());

            int rowsInserted = ps.executeUpdate();

            return rowsInserted > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
    public Account login(String username, String password) {
        String sql = "SELECT * FROM account WHERE username = ? AND password = ?";
        try {
            statement = connection.prepareStatement(sql);
            statement.setString(1, username);
            statement.setString(2, password);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                Account account = new Account();
                account.setId(resultSet.getInt("id"));
                account.setUsername(resultSet.getString("username"));
                account.setPassword(resultSet.getString("password"));
                account.setEmail(resultSet.getString("email"));
                account.setPhone(resultSet.getString("phone"));
                account.setFullName(resultSet.getString("full_name"));
                account.setGender(resultSet.getBoolean("gender"));
                account.setAvatar(resultSet.getString("avatar"));
                account.setActive(resultSet.getBoolean("is_active"));
                account.setRoleId(resultSet.getInt("role_id"));

                return account;
            }
        } catch (SQLException ex) {
            Logger.getLogger(AccountDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeResources();
        }
        return null; // Return null if login fails
    }
    
}