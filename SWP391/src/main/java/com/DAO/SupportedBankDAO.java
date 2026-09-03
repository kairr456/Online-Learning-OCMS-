package com.DAO;

import com.entity.SupportedBank;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SupportedBankDAO extends DBContext {

    private static volatile boolean tableInitialized = false;

    public SupportedBankDAO() {
        if (!tableInitialized) {
            synchronized (SupportedBankDAO.class) {
                if (!tableInitialized) {
                    ensureTableExists();
                    tableInitialized = true;
                }
            }
        }
    }

    /**
     * Tự động khởi tạo bảng supported_bank nếu chưa có và nạp sẵn 10 ngân hàng mặc định
     */
    private void ensureTableExists() {
        Connection conn = null;
        Statement stmt = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            if (conn == null) return;
            stmt = conn.createStatement();

            String sql = "CREATE TABLE IF NOT EXISTS `supported_bank` ("
                    + "  `id` INT NOT NULL AUTO_INCREMENT,"
                    + "  `bank_code` VARCHAR(50) NOT NULL,"
                    + "  `bank_name` VARCHAR(255) NOT NULL,"
                    + "  `short_name` VARCHAR(255) NOT NULL,"
                    + "  `status` VARCHAR(20) DEFAULT 'active',"
                    + "  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
                    + "  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
                    + "  PRIMARY KEY (`id`),"
                    + "  UNIQUE KEY `bank_code_UNIQUE` (`bank_code`)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";
            stmt.execute(sql);

            // Kiểm tra nếu bảng đang rỗng thì nạp dữ liệu ban đầu
            String countSql = "SELECT COUNT(*) FROM `supported_bank`";
            rs = stmt.executeQuery(countSql);
            if (rs.next() && rs.getInt(1) == 0) {
                String[][] defaultBanks = {
                        {"MB", "Ngân hàng TMCP Quân Đội (MBBank)", "MBBank - Ngân hàng Quân Đội"},
                        {"VCB", "Ngân hàng Ngoại Thương Việt Nam (Vietcombank)", "Vietcombank - Ngân hàng Ngoại Thương VN"},
                        {"TCB", "Ngân hàng TMCP Kỹ Thương (Techcombank)", "Techcombank - Ngân hàng Kỹ Thương"},
                        {"ACB", "Ngân hàng TMCP Á Châu (ACB)", "ACB - Ngân hàng Á Châu"},
                        {"VPB", "Ngân hàng TMCP Việt Nam Thịnh Vượng (VPBank)", "VPBank - VN Thịnh Vượng"},
                        {"BIDV", "Ngân hàng Đầu tư và Phát triển VN (BIDV)", "BIDV - Đầu tư & Phát triển VN"},
                        {"ICB", "Ngân hàng Công Thương Việt Nam (VietinBank)", "VietinBank - Ngân hàng Công Thương VN"},
                        {"TPB", "Ngân hàng TMCP Tiên Phong (TPBank)", "TPBank - Tiên Phong Bank"},
                        {"STB", "Ngân hàng Sài Gòn Thương Tín (Sacombank)", "Sacombank - Sài Gòn Thương Tín"},
                        {"VIB", "Ngân hàng Quốc Tế (VIB)", "VIB - Ngân hàng Quốc Tế"}
                };

                String insertSql = "INSERT INTO `supported_bank` (`bank_code`, `bank_name`, `short_name`, `status`) VALUES (?, ?, ?, 'active')";
                ps = conn.prepareStatement(insertSql);
                for (String[] b : defaultBanks) {
                    ps.setString(1, b[0]);
                    ps.setString(2, b[1]);
                    ps.setString(3, b[2]);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] Error ensuring table exists: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (stmt != null) stmt.close();
            } catch (SQLException ignored) {}
        }
    }

    /**
     * Lấy danh sách tất cả ngân hàng đang hoạt động (dùng cho dropdown cài đặt STK ở Ví)
     */
    public List<SupportedBank> getActiveBanks() {
        List<SupportedBank> list = new ArrayList<>();
        String sql = "SELECT * FROM `supported_bank` WHERE `status` = 'active' ORDER BY `id` ASC";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                SupportedBank b = new SupportedBank();
                b.setId(resultSet.getInt("id"));
                b.setBankCode(resultSet.getString("bank_code"));
                b.setBankName(resultSet.getString("bank_name"));
                b.setShortName(resultSet.getString("short_name"));
                b.setStatus(resultSet.getString("status"));
                b.setCreatedAt(resultSet.getTimestamp("created_at"));
                b.setUpdatedAt(resultSet.getTimestamp("updated_at"));
                list.add(b);
            }
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] getActiveBanks error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Tìm kiếm và phân trang danh sách ngân hàng cho Admin
     */
    public List<SupportedBank> searchBanks(String keyword, int page, int pageSize) {
        List<SupportedBank> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT sb.*, "
                + "       (SELECT COUNT(*) FROM `teacher_bank_account` tba WHERE tba.bank_code = sb.bank_code) AS account_count "
                + "FROM `supported_bank` sb WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (sb.bank_code LIKE ? OR sb.bank_name LIKE ? OR sb.short_name LIKE ?) ");
        }

        sql.append("ORDER BY sb.id DESC LIMIT ? OFFSET ?");

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                statement.setString(idx++, kw);
                statement.setString(idx++, kw);
                statement.setString(idx++, kw);
            }

            int offset = Math.max(0, (page - 1) * pageSize);
            statement.setInt(idx++, pageSize);
            statement.setInt(idx, offset);

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                SupportedBank b = new SupportedBank();
                b.setId(resultSet.getInt("id"));
                b.setBankCode(resultSet.getString("bank_code"));
                b.setBankName(resultSet.getString("bank_name"));
                b.setShortName(resultSet.getString("short_name"));
                b.setStatus(resultSet.getString("status"));
                b.setCreatedAt(resultSet.getTimestamp("created_at"));
                b.setUpdatedAt(resultSet.getTimestamp("updated_at"));
                b.setAccountCount(resultSet.getInt("account_count"));
                list.add(b);
            }
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] searchBanks error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Đếm tổng số ngân hàng theo từ khóa tìm kiếm
     */
    public int countBanks(String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM `supported_bank` WHERE 1=1 ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (bank_code LIKE ? OR bank_name LIKE ? OR short_name LIKE ?) ");
        }

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                statement.setString(1, kw);
                statement.setString(2, kw);
                statement.setString(3, kw);
            }
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] countBanks error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    public SupportedBank getBankById(int id) {
        String sql = "SELECT * FROM `supported_bank` WHERE `id` = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                SupportedBank b = new SupportedBank();
                b.setId(resultSet.getInt("id"));
                b.setBankCode(resultSet.getString("bank_code"));
                b.setBankName(resultSet.getString("bank_name"));
                b.setShortName(resultSet.getString("short_name"));
                b.setStatus(resultSet.getString("status"));
                b.setCreatedAt(resultSet.getTimestamp("created_at"));
                b.setUpdatedAt(resultSet.getTimestamp("updated_at"));
                return b;
            }
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] getBankById error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public SupportedBank getBankByCode(String code) {
        String sql = "SELECT * FROM `supported_bank` WHERE UPPER(`bank_code`) = UPPER(?)";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, code != null ? code.trim() : "");
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                SupportedBank b = new SupportedBank();
                b.setId(resultSet.getInt("id"));
                b.setBankCode(resultSet.getString("bank_code"));
                b.setBankName(resultSet.getString("bank_name"));
                b.setShortName(resultSet.getString("short_name"));
                b.setStatus(resultSet.getString("status"));
                b.setCreatedAt(resultSet.getTimestamp("created_at"));
                b.setUpdatedAt(resultSet.getTimestamp("updated_at"));
                return b;
            }
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] getBankByCode error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    /**
     * Kiểm tra trùng mã ngân hàng (ngoại trừ ID hiện tại khi sửa)
     */
    public boolean isBankCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM `supported_bank` WHERE UPPER(`bank_code`) = UPPER(?) AND `id` != ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, code != null ? code.trim() : "");
            statement.setInt(2, excludeId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] isBankCodeExists error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    public boolean insertBank(SupportedBank bank) {
        String sql = "INSERT INTO `supported_bank` (`bank_code`, `bank_name`, `short_name`, `status`, `created_at`, `updated_at`) VALUES (?, ?, ?, ?, NOW(), NOW())";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, bank.getBankCode().trim().toUpperCase());
            statement.setString(2, bank.getBankName().trim());
            statement.setString(3, bank.getShortName().trim());
            statement.setString(4, bank.getStatus() != null ? bank.getStatus().trim() : "active");
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] insertBank error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    public boolean updateBank(SupportedBank bank) {
        String sql = "UPDATE `supported_bank` SET `bank_code` = ?, `bank_name` = ?, `short_name` = ?, `status` = ?, `updated_at` = NOW() WHERE `id` = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, bank.getBankCode().trim().toUpperCase());
            statement.setString(2, bank.getBankName().trim());
            statement.setString(3, bank.getShortName().trim());
            statement.setString(4, bank.getStatus() != null ? bank.getStatus().trim() : "active");
            statement.setInt(5, bank.getId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] updateBank error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Đếm số lượng tài khoản giảng viên đang sử dụng ngân hàng này
     */
    public int countAccountsUsingBank(int bankId) {
        String sql = "SELECT COUNT(*) FROM `teacher_bank_account` tba "
                + "JOIN `supported_bank` sb ON tba.bank_code = sb.bank_code "
                + "WHERE sb.id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, bankId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] countAccountsUsingBank error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    public boolean deleteBank(int id) {
        String sql = "DELETE FROM `supported_bank` WHERE `id` = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[SupportedBankDAO] deleteBank error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }
}
