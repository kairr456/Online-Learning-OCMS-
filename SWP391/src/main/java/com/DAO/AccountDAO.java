package com.DAO;

import com.entity.Account;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

// Extends DBContext -- inherits the protected `connection`, `statement`, and
// `resultSet` fields, and opens a fresh MySQL connection every time this class
// is instantiated (see DBContext's no-arg constructor). closeResources() then
// closes that connection at the end of each call, so callers should create a
// new AccountDAO() per operation rather than reusing one instance for several
// calls in a row (see the "each call gets its own instance" note in
// RegisterController).
public class AccountDAO extends DBContext {

    // =========================================================
    // Check whether username already exists
    // =========================================================
    public boolean isUsernameExists(String username) {
        String sql = "SELECT id FROM account WHERE username = ?";
        try {
            statement = connection.prepareStatement(sql);
            statement.setString(1, username);
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException ex) {
            Logger.getLogger(AccountDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeResources();
        }
        return false;
    }

    // =========================================================
    // Check whether email already exists
    // =========================================================
    public boolean isEmailExists(String email) {
        String sql = "SELECT id FROM account WHERE email = ?";
        try {
            statement = connection.prepareStatement(sql);
            statement.setString(1, email);
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException ex) {
            Logger.getLogger(AccountDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeResources();
        }
        return false;
    }

    // =========================================================
    // Register new account
    // Column names here (full_name, is_active, role_id) match the ones
    // login() already reads -- the earlier version used fullName/isActive/
    // roleId, which don't exist in this schema and would have failed on
    // insert even once the connection itself worked.
    // =========================================================
    public boolean register(Account account) {
        String sql = "INSERT INTO account "
                + "(username, password, email, phone, full_name, gender, avatar, is_active, role_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            // RETURN_GENERATED_KEYS lets us read back the auto-increment id
            // MySQL assigned, so the controller doesn't need a second query.
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, account.getUsername());
            statement.setString(2, account.getPassword());
            statement.setString(3, account.getEmail());
            statement.setString(4, account.getPhone());
            statement.setString(5, account.getFullName());
            statement.setBoolean(6, account.isGender());
            statement.setString(7, account.getAvatar());
            statement.setBoolean(8, account.isActive());
            statement.setInt(9, account.getRoleId());

            int rowsInserted = statement.executeUpdate();
            if (rowsInserted > 0) {
                resultSet = statement.getGeneratedKeys();
                if (resultSet.next()) {
                    account.setId(resultSet.getInt(1)); // Account is passed by reference, so this is visible to the caller
                }
                return true;
            }
        } catch (SQLException ex) {
            Logger.getLogger(AccountDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeResources();
        }
        return false;
    }

    // =========================================================
    // Login
    // =========================================================
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

    // =========================================================
    // Get all author names
    // =========================================================
    public java.util.Map<Integer, String> getAuthorNames() {
        java.util.Map<Integer, String> authors = new java.util.HashMap<>();
        String sql = "SELECT id, username, full_name FROM account";
        try {
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String fullName = resultSet.getString("full_name");
                String username = resultSet.getString("username");
                authors.put(id, (fullName != null && !fullName.trim().isEmpty()) ? fullName : username);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AccountDAO.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeResources();
        }
        return authors;
    }
}