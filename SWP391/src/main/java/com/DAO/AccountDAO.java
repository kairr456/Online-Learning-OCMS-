package com.DAO;

import com.entity.Account;
import com.utils.AccountFilterBuilder;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
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
                    account.setId(resultSet.getInt(1)); // Account is passed by reference, so this is visible to the
                    // caller
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

    /**
     * Lấy danh sách tài khoản theo điều kiện: - Tìm kiếm username, email,
     * full_name - Lọc Role - Lọc Status
     */
    public List<Account> searchAccounts(String keyword, String roleId, String status, int page, int pageSize) {
        List<Account> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT id, username, email, phone, full_name, "
                + "gender, is_active, role_id "
                + "FROM Account WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        // Tìm kiếm theo username, email hoặc full_name
        AccountFilterBuilder.appendFilters(sql, keyword, roleId, status, params);

        sql.append(" ORDER BY id ASC LIMIT ? OFFSET ?");
        params.add(pageSize);               // LIMIT
        params.add((page - 1) * pageSize);  // OFFSET
        try {
            statement = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));   // setObject xử lý cả String lẫn Integer
            }
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                Account u = new Account();
                u.setId(resultSet.getInt("id"));
                u.setUsername(resultSet.getString("username"));
                u.setEmail(resultSet.getString("email"));
                u.setPhone(resultSet.getString("phone"));
                u.setFullName(resultSet.getString("full_name"));
                u.setGender(resultSet.getBoolean("gender"));

                // Đã BỎ dòng u.setAvatar(...) để tránh lỗi Column not found!
                u.setActive(resultSet.getBoolean("is_active"));
                u.setRoleId(resultSet.getInt("role_id"));

                list.add(u);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }

        return list;
    }

    /**
     * Vô hiệu hóa tài khoản theo ID trong bảng Account.
     */
    public boolean deactivateAccount(int userId) {

        String sql = "UPDATE Account "
                + "SET is_active = 0 "
                + "WHERE id = ?";

        try {

            // Mỗi lần gọi dùng instance AccountDAO mới nên connection luôn mới
            statement = connection.prepareStatement(sql);

            statement.setInt(1, userId);

            int rows = statement.executeUpdate();

            System.out.println(
                    "Deactivate Account ID = "
                    + userId
                    + ", affected rows = "
                    + rows);

            return rows > 0;

        } catch (SQLException e) {

            e.printStackTrace();

        } finally {

            closeResources();
        }

        return false;
    }

    // Đếm tổng số record theo bộ lọc — cùng filter với searchAccounts, chỉ khác câu SELECT
    public int countAccounts(String keyword, String roleId, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Account WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        AccountFilterBuilder.appendFilters(sql, keyword, roleId, status, params);  // không có LIMIT

        try {
            statement = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return 0;
    }

// Lấy 1 account theo id (đổ vào modal khi Edit)
    public Account getAccountById(int id) {
        String sql = "SELECT id, username, email, phone, full_name, gender, is_active, role_id "
                + "FROM Account WHERE id = ?";
        try {
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                Account u = new Account();
                u.setId(resultSet.getInt("id"));
                u.setUsername(resultSet.getString("username"));
                u.setEmail(resultSet.getString("email"));
                u.setPhone(resultSet.getString("phone"));
                u.setFullName(resultSet.getString("full_name"));
                u.setGender(resultSet.getBoolean("gender"));
                u.setActive(resultSet.getBoolean("is_active"));
                u.setRoleId(resultSet.getInt("role_id"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

// Cập nhật account (không đụng username/password)
    public boolean updateAccount(Account a) {
        String sql = "UPDATE Account SET email=?, phone=?, full_name=?, gender=?, is_active=?, role_id=? WHERE id=?";
        try {
            statement = connection.prepareStatement(sql);
            statement.setString(1, a.getEmail());
            statement.setString(2, a.getPhone());
            statement.setString(3, a.getFullName());
            statement.setBoolean(4, a.isGender());
            statement.setBoolean(5, a.isActive());
            statement.setInt(6, a.getRoleId());
            statement.setInt(7, a.getId());
            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return false;
    }
}
