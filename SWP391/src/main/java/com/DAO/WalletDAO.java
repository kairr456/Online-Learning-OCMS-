package com.DAO;

import com.entity.PayoutRequest;
import com.entity.TeacherBankAccount;
import com.entity.TeacherWallet;
import com.entity.WalletTransaction;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class WalletDAO extends DBContext {

    private String lastError = null;

    public String getLastError() {
        return lastError;
    }

    public WalletDAO() {
        ensureTablesExist();
    }

    /**
     * Đảm bảo các bảng cần thiết (đặc biệt là payout_request) luôn tồn tại và có đủ cột trong Database
     */
    public void ensureTablesExist() {
        Connection conn = null;
        Statement stmt = null;
        try {
            conn = new DBContext().getConnection();
            if (conn == null) return;
            stmt = conn.createStatement();

            // 1. Bảng teacher_wallet
            stmt.execute("CREATE TABLE IF NOT EXISTS `teacher_wallet` ("
                    + "  `id` INT NOT NULL AUTO_INCREMENT,"
                    + "  `teacher_id` INT NOT NULL,"
                    + "  `balance` DECIMAL(15,2) DEFAULT '0.00',"
                    + "  `total_earned` DECIMAL(15,2) DEFAULT '0.00',"
                    + "  `total_withdrawn` DECIMAL(15,2) DEFAULT '0.00',"
                    + "  `status` VARCHAR(50) DEFAULT 'active',"
                    + "  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
                    + "  PRIMARY KEY (`id`),"
                    + "  UNIQUE KEY `teacher_id_UNIQUE` (`teacher_id`)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

            // 2. Bảng teacher_bank_account
            stmt.execute("CREATE TABLE IF NOT EXISTS `teacher_bank_account` ("
                    + "  `id` INT NOT NULL AUTO_INCREMENT,"
                    + "  `teacher_id` INT NOT NULL,"
                    + "  `bank_code` VARCHAR(50) NOT NULL,"
                    + "  `bank_name` VARCHAR(255) NOT NULL,"
                    + "  `account_number` VARCHAR(50) NOT NULL,"
                    + "  `account_holder` VARCHAR(255) NOT NULL,"
                    + "  `tax_code` VARCHAR(50) DEFAULT NULL,"
                    + "  `is_default` TINYINT(1) DEFAULT 1,"
                    + "  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
                    + "  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
                    + "  PRIMARY KEY (`id`),"
                    + "  KEY `idx_teacher_bank` (`teacher_id`)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

            // 3. Bảng wallet_transaction
            stmt.execute("CREATE TABLE IF NOT EXISTS `wallet_transaction` ("
                    + "  `id` INT NOT NULL AUTO_INCREMENT,"
                    + "  `wallet_id` INT NOT NULL,"
                    + "  `amount` DECIMAL(15,2) NOT NULL,"
                    + "  `balance_after` DECIMAL(15,2) DEFAULT '0.00',"
                    + "  `type` VARCHAR(50) NOT NULL,"
                    + "  `reference_id` INT DEFAULT NULL,"
                    + "  `description` TEXT,"
                    + "  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
                    + "  PRIMARY KEY (`id`),"
                    + "  KEY `idx_tx_wallet` (`wallet_id`)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

            // 4. Bảng payout_request
            stmt.execute("CREATE TABLE IF NOT EXISTS `payout_request` ("
                    + "  `id` INT NOT NULL AUTO_INCREMENT,"
                    + "  `teacher_id` INT NOT NULL,"
                    + "  `bank_account_id` INT DEFAULT NULL,"
                    + "  `bank_code` VARCHAR(50) DEFAULT NULL,"
                    + "  `bank_name` VARCHAR(255) DEFAULT NULL,"
                    + "  `account_number` VARCHAR(50) DEFAULT NULL,"
                    + "  `account_holder` VARCHAR(255) DEFAULT NULL,"
                    + "  `amount` DECIMAL(15,2) NOT NULL,"
                    + "  `status` VARCHAR(50) DEFAULT 'pending',"
                    + "  `transaction_code` VARCHAR(100) DEFAULT NULL,"
                    + "  `admin_note` TEXT,"
                    + "  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
                    + "  `processed_at` TIMESTAMP NULL DEFAULT NULL,"
                    + "  PRIMARY KEY (`id`),"
                    + "  KEY `idx_payout_teacher` (`teacher_id`)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

            // Tự động bổ sung các cột còn thiếu nếu bảng đã tồn tại từ trước
            String[] alterCols = {
                "ALTER TABLE `payout_request` ADD COLUMN `bank_account_id` INT DEFAULT NULL",
                "ALTER TABLE `payout_request` ADD COLUMN `bank_code` VARCHAR(50) DEFAULT NULL",
                "ALTER TABLE `payout_request` ADD COLUMN `bank_name` VARCHAR(255) DEFAULT NULL",
                "ALTER TABLE `payout_request` ADD COLUMN `account_number` VARCHAR(50) DEFAULT NULL",
                "ALTER TABLE `payout_request` ADD COLUMN `account_holder` VARCHAR(255) DEFAULT NULL",
                "ALTER TABLE `payout_request` ADD COLUMN `amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00",
                "ALTER TABLE `payout_request` ADD COLUMN `status` VARCHAR(50) DEFAULT 'pending'",
                "ALTER TABLE `payout_request` ADD COLUMN `transaction_code` VARCHAR(100) DEFAULT NULL",
                "ALTER TABLE `payout_request` ADD COLUMN `admin_note` TEXT",
                "ALTER TABLE `payout_request` ADD COLUMN `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
                "ALTER TABLE `payout_request` ADD COLUMN `processed_at` TIMESTAMP NULL DEFAULT NULL"
            };
            for (String alterSql : alterCols) {
                try {
                    stmt.execute(alterSql);
                } catch (Exception ignored) {}
            }

            // Đảm bảo kiểu dữ liệu type của transaction chấp nhận 'payout'
            try { stmt.execute("ALTER TABLE wallet_transaction MODIFY COLUMN `type` VARCHAR(50)"); } catch (Exception ignored) {}
            try { stmt.execute("ALTER TABLE payout_request MODIFY COLUMN `status` VARCHAR(50) DEFAULT 'pending'"); } catch (Exception ignored) {}

        } catch (SQLException e) {
            System.err.println("[WALLET_DB_INIT] Lỗi khởi tạo bảng: " + e.getMessage());
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ignored) {}
        }
    }

    /**
     * Lấy ví của giáo viên theo teacher_id. Nếu chưa có ví thì tự động khởi tạo với số dư = 0.
     */
    public TeacherWallet getOrCreateWallet(int teacherId) {
        String sql = "SELECT * FROM teacher_wallet WHERE teacher_id = ?";
        try {
            connection = new DBContext().getConnection();
            if (connection == null) return null;

            statement = connection.prepareStatement(sql);
            statement.setInt(1, teacherId);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                return mapWallet(resultSet);
            }

            // Nếu chưa có ví -> Tạo ví mới số dư 0đ
            String insertSql = "INSERT INTO teacher_wallet (teacher_id, balance, total_earned, total_withdrawn, status) VALUES (?, 0.00, 0.00, 0.00, 'active')";
            PreparedStatement insertStmt = connection.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            insertStmt.setInt(1, teacherId);
            insertStmt.executeUpdate();

            ResultSet rsKeys = insertStmt.getGeneratedKeys();
            int newId = 0;
            if (rsKeys.next()) {
                newId = rsKeys.getInt(1);
            }
            insertStmt.close();

            TeacherWallet newWallet = new TeacherWallet();
            newWallet.setId(newId);
            newWallet.setTeacherId(teacherId);
            newWallet.setBalance(BigDecimal.ZERO);
            newWallet.setTotalEarned(BigDecimal.ZERO);
            newWallet.setTotalWithdrawn(BigDecimal.ZERO);
            newWallet.setStatus("active");
            return newWallet;

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    /**
     * Lấy tài khoản ngân hàng mặc định của giảng viên
     */
    public TeacherBankAccount getBankAccountByTeacherId(int teacherId) {
        String sql = "SELECT * FROM teacher_bank_account WHERE teacher_id = ? ORDER BY is_default DESC, id DESC LIMIT 1";
        try {
            connection = new DBContext().getConnection();
            if (connection == null) return null;

            statement = connection.prepareStatement(sql);
            statement.setInt(1, teacherId);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                TeacherBankAccount b = new TeacherBankAccount();
                b.setId(resultSet.getInt("id"));
                b.setTeacherId(resultSet.getInt("teacher_id"));
                b.setBankCode(resultSet.getString("bank_code"));
                b.setBankName(resultSet.getString("bank_name"));
                b.setAccountNumber(resultSet.getString("account_number"));
                b.setAccountHolder(resultSet.getString("account_holder"));
                b.setTaxCode(resultSet.getString("tax_code"));
                b.setDefault(resultSet.getBoolean("is_default"));
                b.setCreatedAt(resultSet.getTimestamp("created_at"));
                b.setUpdatedAt(resultSet.getTimestamp("updated_at"));
                return b;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    /**
     * Cập nhật hoặc lưu thông tin tài khoản ngân hàng của giảng viên
     */
    public boolean saveOrUpdateBankAccount(TeacherBankAccount bank) {
        TeacherBankAccount existing = getBankAccountByTeacherId(bank.getTeacherId());
        try {
            connection = new DBContext().getConnection();
            if (connection == null) return false;

            if (existing != null) {
                String sql = "UPDATE teacher_bank_account SET bank_code = ?, bank_name = ?, account_number = ?, account_holder = ?, tax_code = ?, updated_at = NOW() WHERE id = ?";
                statement = connection.prepareStatement(sql);
                statement.setString(1, bank.getBankCode());
                statement.setString(2, bank.getBankName());
                statement.setString(3, bank.getAccountNumber());
                statement.setString(4, bank.getAccountHolder());
                statement.setString(5, bank.getTaxCode());
                statement.setInt(6, existing.getId());
                return statement.executeUpdate() > 0;
            } else {
                String sql = "INSERT INTO teacher_bank_account (teacher_id, bank_code, bank_name, account_number, account_holder, tax_code, is_default) VALUES (?, ?, ?, ?, ?, ?, 1)";
                statement = connection.prepareStatement(sql);
                statement.setInt(1, bank.getTeacherId());
                statement.setString(2, bank.getBankCode());
                statement.setString(3, bank.getBankName());
                statement.setString(4, bank.getAccountNumber());
                statement.setString(5, bank.getAccountHolder());
                statement.setString(6, bank.getTaxCode());
                return statement.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Tính tổng số tiền rút đang chờ duyệt (Pending) của giảng viên
     */
    public BigDecimal getPendingPayoutAmount(int teacherId) {
        String sql = "SELECT COALESCE(SUM(amount), 0) AS pending_total FROM payout_request WHERE teacher_id = ? AND status = 'pending'";
        try {
            connection = new DBContext().getConnection();
            if (connection == null) return BigDecimal.ZERO;

            statement = connection.prepareStatement(sql);
            statement.setInt(1, teacherId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getBigDecimal("pending_total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Lấy danh sách lịch sử biến động số dư theo wallet_id
     */
    public List<WalletTransaction> getTransactionsByWalletId(int walletId) {
        return getTransactionsByWalletId(walletId, "newest");
    }

    public List<WalletTransaction> getTransactionsByWalletId(int walletId, String sortOrder) {
        List<WalletTransaction> list = new ArrayList<>();
        String order = "oldest".equalsIgnoreCase(sortOrder) ? "ASC" : "DESC";
        String sql = "SELECT * FROM wallet_transaction WHERE wallet_id = ? ORDER BY created_at " + order + " LIMIT 50";
        try {
            connection = new DBContext().getConnection();
            if (connection == null) return list;

            statement = connection.prepareStatement(sql);
            statement.setInt(1, walletId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                WalletTransaction tx = new WalletTransaction();
                tx.setId(resultSet.getInt("id"));
                tx.setWalletId(resultSet.getInt("wallet_id"));
                tx.setAmount(resultSet.getBigDecimal("amount"));
                tx.setBalanceAfter(resultSet.getBigDecimal("balance_after"));
                tx.setType(resultSet.getString("type"));
                tx.setReferenceId(resultSet.getObject("reference_id") != null ? resultSet.getInt("reference_id") : null);
                tx.setDescription(resultSet.getString("description"));
                tx.setCreatedAt(resultSet.getTimestamp("created_at"));
                list.add(tx);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Lấy danh sách yêu cầu rút tiền của giảng viên
     */
    public List<PayoutRequest> getPayoutRequestsByTeacherId(int teacherId) {
        return getPayoutRequestsByTeacherId(teacherId, "newest");
    }

    public List<PayoutRequest> getPayoutRequestsByTeacherId(int teacherId, String sortOrder) {
        List<PayoutRequest> list = new ArrayList<>();
        String order = "oldest".equalsIgnoreCase(sortOrder) ? "ASC" : "DESC";
        String sql = "SELECT * FROM payout_request WHERE teacher_id = ? ORDER BY created_at " + order + " LIMIT 50";
        try {
            connection = new DBContext().getConnection();
            if (connection == null) return list;

            statement = connection.prepareStatement(sql);
            statement.setInt(1, teacherId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                PayoutRequest po = new PayoutRequest();
                po.setId(resultSet.getInt("id"));
                po.setTeacherId(resultSet.getInt("teacher_id"));
                try { po.setBankAccountId(resultSet.getObject("bank_account_id") != null ? resultSet.getInt("bank_account_id") : null); } catch (Exception ignored) {}
                try { po.setBankCode(resultSet.getString("bank_code")); } catch (Exception ignored) {}
                try { po.setBankName(resultSet.getString("bank_name")); } catch (Exception ignored) {}
                try { po.setAccountNumber(resultSet.getString("account_number")); } catch (Exception ignored) {}
                try { po.setAccountHolder(resultSet.getString("account_holder")); } catch (Exception ignored) {}
                po.setAmount(resultSet.getBigDecimal("amount") != null ? resultSet.getBigDecimal("amount") : BigDecimal.ZERO);
                try { po.setStatus(resultSet.getString("status")); } catch (Exception ignored) {}
                try { po.setTransactionCode(resultSet.getString("transaction_code")); } catch (Exception ignored) {}
                try { po.setAdminNote(resultSet.getString("admin_note")); } catch (Exception ignored) {}
                try { po.setCreatedAt(resultSet.getTimestamp("created_at")); } catch (Exception ignored) {}
                try { po.setProcessedAt(resultSet.getTimestamp("processed_at")); } catch (Exception ignored) {}
                list.add(po);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Tạo yêu cầu rút tiền (Trừ số dư ví ngay lập tức, thêm vào bảng payout_request và ghi nhận transaction)
     */
    public boolean requestPayout(int teacherId, BigDecimal amount, String note) {
        Connection conn = null;
        this.lastError = null;
        try {
            System.out.println("========== [PAYOUT_REQUEST] START: teacherId=" + teacherId + ", amount=" + amount + ", note=" + note + " ==========");
            conn = new DBContext().getConnection();
            if (conn == null) {
                this.lastError = "Không thể kết nối cơ sở dữ liệu.";
                System.err.println("[PAYOUT_REQUEST] Lỗi: Không thể kết nối Database!");
                return false;
            }
            conn.setAutoCommit(false);

            // 1. Khóa hàng và kiểm tra số dư ví
            String checkSql = "SELECT * FROM teacher_wallet WHERE teacher_id = ? FOR UPDATE";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, teacherId);
            ResultSet rs = psCheck.executeQuery();

            if (!rs.next()) {
                this.lastError = "Không tìm thấy thông tin ví của giảng viên.";
                System.err.println("[PAYOUT_REQUEST] Lỗi: Không tìm thấy ví cho teacherId=" + teacherId);
                conn.rollback();
                return false;
            }

            int walletId = rs.getInt("id");
            BigDecimal currentBalance = rs.getBigDecimal("balance");
            if (currentBalance == null) currentBalance = BigDecimal.ZERO;
            System.out.println("[PAYOUT_REQUEST] Số dư hiện tại trong ví: " + currentBalance + " đ, Số tiền yêu cầu rút: " + amount + " đ");

            if (currentBalance.compareTo(amount) < 0) {
                this.lastError = "Số dư khả dụng không đủ (Hiện có: " + currentBalance + " ₫, Rút: " + amount + " ₫).";
                System.err.println("[PAYOUT_REQUEST] Lỗi: Số dư không đủ (" + currentBalance + " < " + amount + ")");
                conn.rollback();
                return false;
            }

            BigDecimal newBalance = currentBalance.subtract(amount);

            // 2. Lấy thông tin tài khoản ngân hàng mặc định
            String bankSql = "SELECT * FROM teacher_bank_account WHERE teacher_id = ? ORDER BY is_default DESC, id DESC LIMIT 1";
            PreparedStatement psBank = conn.prepareStatement(bankSql);
            psBank.setInt(1, teacherId);
            ResultSet rsBank = psBank.executeQuery();
            if (!rsBank.next()) {
                this.lastError = "Bạn chưa liên kết tài khoản ngân hàng để nhận tiền.";
                System.err.println("[PAYOUT_REQUEST] Lỗi: Giảng viên chưa liên kết tài khoản ngân hàng!");
                conn.rollback();
                return false; // Chưa có STK ngân hàng
            }

            int bankId = rsBank.getInt("id");
            String bankCode = rsBank.getString("bank_code");
            String bankName = rsBank.getString("bank_name");
            String accNum = rsBank.getString("account_number");
            String accHolder = rsBank.getString("account_holder");
            psBank.close();

            // 3. Trừ số dư ví
            String updateWalletSql = "UPDATE teacher_wallet SET balance = ?, updated_at = NOW() WHERE id = ?";
            PreparedStatement psUpdate = conn.prepareStatement(updateWalletSql);
            psUpdate.setBigDecimal(1, newBalance);
            psUpdate.setInt(2, walletId);
            psUpdate.executeUpdate();
            psUpdate.close();
            System.out.println("[PAYOUT_REQUEST] Đã cập nhật trừ số dư ví thành công -> Số dư mới: " + newBalance + " đ");

            // 4. Tạo bản ghi Payout Request (xây dựng câu lệnh INSERT động theo các cột thực tế có trong DB)
            Set<String> actualCols = new HashSet<>();
            try (ResultSet rsCols = conn.getMetaData().getColumns(null, null, "payout_request", null)) {
                while (rsCols.next()) {
                    actualCols.add(rsCols.getString("COLUMN_NAME").toLowerCase());
                }
            } catch (Exception ignored) {}

            if (actualCols.isEmpty()) {
                try (ResultSet rsCols = conn.getMetaData().getColumns(null, null, "PAYOUT_REQUEST", null)) {
                    while (rsCols.next()) {
                        actualCols.add(rsCols.getString("COLUMN_NAME").toLowerCase());
                    }
                } catch (Exception ignored) {}
            }

            List<String> insertCols = new ArrayList<>();
            List<Object> insertVals = new ArrayList<>();

            if (actualCols.isEmpty() || actualCols.contains("teacher_id")) {
                insertCols.add("teacher_id");
                insertVals.add(teacherId);
            }
            if (actualCols.contains("bank_account_id")) {
                insertCols.add("bank_account_id");
                insertVals.add(bankId);
            }
            if (actualCols.contains("bank_code")) {
                insertCols.add("bank_code");
                insertVals.add(bankCode);
            }
            if (actualCols.contains("bank_name")) {
                insertCols.add("bank_name");
                insertVals.add(bankName);
            }
            if (actualCols.contains("account_number")) {
                insertCols.add("account_number");
                insertVals.add(accNum);
            }
            if (actualCols.contains("account_holder")) {
                insertCols.add("account_holder");
                insertVals.add(accHolder);
            }
            if (actualCols.isEmpty() || actualCols.contains("amount")) {
                insertCols.add("amount");
                insertVals.add(amount);
            }
            if (actualCols.isEmpty() || actualCols.contains("status")) {
                insertCols.add("status");
                insertVals.add("pending");
            }
            if (actualCols.contains("admin_note")) {
                insertCols.add("admin_note");
                insertVals.add(note != null ? note : "");
            } else if (actualCols.contains("note")) {
                insertCols.add("note");
                insertVals.add(note != null ? note : "");
            }

            StringBuilder colNames = new StringBuilder();
            StringBuilder placeholders = new StringBuilder();
            for (int i = 0; i < insertCols.size(); i++) {
                if (i > 0) {
                    colNames.append(", ");
                    placeholders.append(", ");
                }
                colNames.append("`").append(insertCols.get(i)).append("`");
                placeholders.append("?");
            }

            String insertPayoutSql = "INSERT INTO payout_request (" + colNames + ") VALUES (" + placeholders + ")";
            System.out.println("[PAYOUT_REQUEST] Thực thi SQL: " + insertPayoutSql);
            PreparedStatement psPayout = conn.prepareStatement(insertPayoutSql, Statement.RETURN_GENERATED_KEYS);
            for (int i = 0; i < insertVals.size(); i++) {
                Object val = insertVals.get(i);
                if (val instanceof Integer) {
                    psPayout.setInt(i + 1, (Integer) val);
                } else if (val instanceof BigDecimal) {
                    psPayout.setBigDecimal(i + 1, (BigDecimal) val);
                } else {
                    psPayout.setString(i + 1, val != null ? val.toString() : null);
                }
            }
            psPayout.executeUpdate();

            ResultSet rsKeys = psPayout.getGeneratedKeys();
            int payoutId = 0;
            if (rsKeys.next()) {
                payoutId = rsKeys.getInt(1);
            }
            psPayout.close();
            System.out.println("[PAYOUT_REQUEST] Đã tạo yêu cầu rút tiền payout_request thành công -> Mã yêu cầu #" + payoutId);

            // 5. Thêm bản ghi Wallet Transaction
            String txSql = "INSERT INTO wallet_transaction (wallet_id, amount, balance_after, type, reference_id, description) VALUES (?, ?, ?, 'payout', ?, ?)";
            PreparedStatement psTx = conn.prepareStatement(txSql);
            psTx.setInt(1, walletId);
            psTx.setBigDecimal(2, amount.negate()); // Số âm biểu thị rút tiền
            psTx.setBigDecimal(3, newBalance);
            psTx.setInt(4, payoutId);
            psTx.setString(5, "Yêu cầu rút tiền về " + bankName + " (STK: " + accNum + ")");
            psTx.executeUpdate();
            psTx.close();
            System.out.println("[PAYOUT_REQUEST] Đã ghi nhận lịch sử biến động số dư thành công!");

            conn.commit();
            System.out.println("========== [PAYOUT_REQUEST] HOÀN TẤT THÀNH CÔNG ==========");
            return true;

        } catch (SQLException e) {
            this.lastError = "Lỗi khi xử lý giao dịch: " + e.getMessage();
            System.err.println("[PAYOUT_REQUEST_EXCEPTION] Lỗi khi tạo yêu cầu rút tiền: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    /**
     * Dành cho Admin: Lấy danh sách tất cả các yêu cầu rút tiền
     */
    public List<PayoutRequest> getAllPayoutRequests(String keyword, String status) {
        List<PayoutRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, a.full_name AS teacher_name, a.email AS teacher_email " +
                "FROM payout_request p " +
                "JOIN account a ON p.teacher_id = a.id WHERE 1=1 "
        );

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND p.status = ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (a.full_name LIKE ? OR a.email LIKE ? OR p.account_number LIKE ?) ");
        }
        sql.append(" ORDER BY p.created_at DESC");

        try {
            connection = new DBContext().getConnection();
            if (connection == null) return list;

            statement = connection.prepareStatement(sql.toString());
            int idx = 1;
            if (status != null && !status.trim().isEmpty()) {
                statement.setString(idx++, status.trim());
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                statement.setString(idx++, kw);
                statement.setString(idx++, kw);
                statement.setString(idx++, kw);
            }

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                PayoutRequest po = new PayoutRequest();
                po.setId(resultSet.getInt("id"));
                po.setTeacherId(resultSet.getInt("teacher_id"));
                try { po.setBankAccountId(resultSet.getObject("bank_account_id") != null ? resultSet.getInt("bank_account_id") : null); } catch (Exception ignored) {}
                try { po.setBankCode(resultSet.getString("bank_code")); } catch (Exception ignored) {}
                try { po.setBankName(resultSet.getString("bank_name")); } catch (Exception ignored) {}
                try { po.setAccountNumber(resultSet.getString("account_number")); } catch (Exception ignored) {}
                try { po.setAccountHolder(resultSet.getString("account_holder")); } catch (Exception ignored) {}
                po.setAmount(resultSet.getBigDecimal("amount") != null ? resultSet.getBigDecimal("amount") : BigDecimal.ZERO);
                try { po.setStatus(resultSet.getString("status")); } catch (Exception ignored) {}
                try { po.setTransactionCode(resultSet.getString("transaction_code")); } catch (Exception ignored) {}
                try { po.setAdminNote(resultSet.getString("admin_note")); } catch (Exception ignored) {}
                try { po.setCreatedAt(resultSet.getTimestamp("created_at")); } catch (Exception ignored) {}
                try { po.setProcessedAt(resultSet.getTimestamp("processed_at")); } catch (Exception ignored) {}
                try { po.setTeacherName(resultSet.getString("teacher_name")); } catch (Exception ignored) {}
                try { po.setTeacherEmail(resultSet.getString("teacher_email")); } catch (Exception ignored) {}
                list.add(po);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Dành cho Admin: Phê duyệt rút tiền
     */
    public boolean approvePayout(int payoutId, String transactionCode) {
        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            // 1. Lấy thông tin payout
            String getSql = "SELECT * FROM payout_request WHERE id = ? AND status = 'pending' FOR UPDATE";
            PreparedStatement psGet = conn.prepareStatement(getSql);
            psGet.setInt(1, payoutId);
            ResultSet rs = psGet.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                return false;
            }

            int teacherId = rs.getInt("teacher_id");
            BigDecimal amount = rs.getBigDecimal("amount");

            // 2. Cập nhật trạng thái Payout
            String updatePoSql = "UPDATE payout_request SET status = 'completed', transaction_code = ?, processed_at = NOW() WHERE id = ?";
            PreparedStatement psPo = conn.prepareStatement(updatePoSql);
            psPo.setString(1, transactionCode);
            psPo.setInt(2, payoutId);
            psPo.executeUpdate();

            // 3. Tăng tổng tiền đã rút trong ví của GV
            String updateWalletSql = "UPDATE teacher_wallet SET total_withdrawn = total_withdrawn + ?, updated_at = NOW() WHERE teacher_id = ?";
            PreparedStatement psW = conn.prepareStatement(updateWalletSql);
            psW.setBigDecimal(1, amount);
            psW.setInt(2, teacherId);
            psW.executeUpdate();

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    /**
     * Dành cho Admin: Từ chối rút tiền (Hoàn trả lại số dư cho giáo viên)
     */
    public boolean rejectPayout(int payoutId, String adminNote) {
        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            // 1. Lấy thông tin payout
            String getSql = "SELECT * FROM payout_request WHERE id = ? AND status = 'pending' FOR UPDATE";
            PreparedStatement psGet = conn.prepareStatement(getSql);
            psGet.setInt(1, payoutId);
            ResultSet rs = psGet.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                return false;
            }

            int teacherId = rs.getInt("teacher_id");
            BigDecimal amount = rs.getBigDecimal("amount");

            // 2. Cập nhật trạng thái Payout thành rejected
            String updatePoSql = "UPDATE payout_request SET status = 'rejected', admin_note = ?, processed_at = NOW() WHERE id = ?";
            PreparedStatement psPo = conn.prepareStatement(updatePoSql);
            psPo.setString(1, adminNote);
            psPo.setInt(2, payoutId);
            psPo.executeUpdate();

            // 3. Hoàn trả số dư ví
            String getWalletSql = "SELECT * FROM teacher_wallet WHERE teacher_id = ? FOR UPDATE";
            PreparedStatement psW = conn.prepareStatement(getWalletSql);
            psW.setInt(1, teacherId);
            ResultSet rsW = psW.executeQuery();
            if (rsW.next()) {
                int walletId = rsW.getInt("id");
                BigDecimal currentBal = rsW.getBigDecimal("balance");
                BigDecimal refundedBal = currentBal.add(amount);

                String refundWalletSql = "UPDATE teacher_wallet SET balance = ?, updated_at = NOW() WHERE id = ?";
                PreparedStatement psRefund = conn.prepareStatement(refundWalletSql);
                psRefund.setBigDecimal(1, refundedBal);
                psRefund.setInt(2, walletId);
                psRefund.executeUpdate();

                // 4. Ghi nhận giao dịch hoàn trả
                String txSql = "INSERT INTO wallet_transaction (wallet_id, amount, balance_after, type, reference_id, description) VALUES (?, ?, ?, 'refund', ?, ?)";
                PreparedStatement psTx = conn.prepareStatement(txSql);
                psTx.setInt(1, walletId);
                psTx.setBigDecimal(2, amount);
                psTx.setBigDecimal(3, refundedBal);
                psTx.setInt(4, payoutId);
                psTx.setString(5, "Hoàn tiền do từ chối yêu cầu rút đơn #PO-" + payoutId + (adminNote != null ? " (" + adminNote + ")" : ""));
                psTx.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    /**
     * Tự động quét và đồng bộ toàn diện ví giáo viên từ bảng registration và payout_request.
     * Đảm bảo Số dư khả dụng và Tổng thu nhập luôn khớp 100% với doanh thu thực tế.
     */
    public boolean syncWalletWithRegistrations(int teacherId) {
        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            // 1. Kiểm tra hoặc tạo ví cho giáo viên nếu chưa có
            int walletId = 0;
            String checkWalletSql = "SELECT id FROM teacher_wallet WHERE teacher_id = ? FOR UPDATE";
            PreparedStatement psCheck = conn.prepareStatement(checkWalletSql);
            psCheck.setInt(1, teacherId);
            ResultSet rsCheck = psCheck.executeQuery();
            if (rsCheck.next()) {
                walletId = rsCheck.getInt("id");
            } else {
                String createWalletSql = "INSERT INTO teacher_wallet (teacher_id, balance, total_earned, total_withdrawn, status) VALUES (?, 0.00, 0.00, 0.00, 'active')";
                PreparedStatement psCreate = conn.prepareStatement(createWalletSql, Statement.RETURN_GENERATED_KEYS);
                psCreate.setInt(1, teacherId);
                psCreate.executeUpdate();
                ResultSet rsKeys = psCreate.getGeneratedKeys();
                if (rsKeys.next()) {
                    walletId = rsKeys.getInt(1);
                }
                psCreate.close();
            }
            psCheck.close();

            if (walletId == 0) {
                conn.rollback();
                return false;
            }

            System.out.println("========== [WALLET_DEBUG] START SYNC FOR TEACHER ID: " + teacherId + " ==========");

            // 2. Tìm tất cả các đơn mua thành công của các khóa học do giáo viên này tạo mà chưa có trong wallet_transaction
            String missingTxSql = "SELECT r.id AS reg_id, r.course_id, r.total_cost, r.registration_time, c.name AS course_name, c.price AS course_price, c.created_by "
                    + "FROM registration r "
                    + "JOIN course c ON r.course_id = c.id "
                    + "LEFT JOIN wallet_transaction wt ON wt.wallet_id = ? AND wt.type = 'course_sale' AND wt.reference_id = r.id "
                    + "WHERE (c.created_by = ? OR c.created_by IN (SELECT a.id FROM account a WHERE a.email = (SELECT a2.email FROM account a2 WHERE a2.id = ? AND a2.email IS NOT NULL AND a2.email != ''))) "
                    + "  AND (TRIM(LOWER(r.status)) IN ('approved', 'active', 'success', 'completed') OR r.status IS NULL) "
                    + "  AND wt.id IS NULL "
                    + "ORDER BY r.registration_time ASC, r.id ASC";

            PreparedStatement psMissing = conn.prepareStatement(missingTxSql);
            psMissing.setInt(1, walletId);
            psMissing.setInt(2, teacherId);
            psMissing.setInt(3, teacherId);
            ResultSet rsMissing = psMissing.executeQuery();

            String insertTxSql = "INSERT INTO wallet_transaction (wallet_id, amount, balance_after, type, reference_id, description) VALUES (?, ?, ?, 'course_sale', ?, ?)";
            PreparedStatement psInsertTx = conn.prepareStatement(insertTxSql);

            int missingCount = 0;
            while (rsMissing.next()) {
                missingCount++;
                int regId = rsMissing.getInt("reg_id");
                int courseId = rsMissing.getInt("course_id");
                String courseName = rsMissing.getString("course_name");
                BigDecimal totalCost = rsMissing.getBigDecimal("total_cost");
                float coursePrice = rsMissing.getFloat("course_price");

                BigDecimal salePrice = (totalCost != null && totalCost.compareTo(BigDecimal.ZERO) > 0)
                        ? totalCost
                        : (coursePrice > 0 ? BigDecimal.valueOf(coursePrice) : BigDecimal.ZERO);

                BigDecimal commission = salePrice.multiply(new BigDecimal("0.70"));
                System.out.println("[WALLET_DEBUG] -> Phát hiện đơn mua mới: Đơn #" + regId + " | Khóa học #" + courseId + " (" + courseName + ") | Giá: " + salePrice + " | Hoa hồng 70%: " + commission);

                psInsertTx.setInt(1, walletId);
                psInsertTx.setBigDecimal(2, commission);
                psInsertTx.setBigDecimal(3, commission);
                psInsertTx.setInt(4, regId);
                psInsertTx.setString(5, "Hoa hồng 70% từ bán khóa học: " + (courseName != null ? courseName : ("ID #" + courseId)) + " (Đơn #" + regId + ")");
                psInsertTx.executeUpdate();
            }
            System.out.println("[WALLET_DEBUG] Tổng số đơn mua mới vừa được ghi nhận: " + missingCount);
            psMissing.close();
            psInsertTx.close();

            // 3. Tính lại Tổng thu nhập từ toàn bộ các giao dịch bán khóa học (70% của tất cả registrations)
            String totalEarnedSql = "SELECT COALESCE(SUM( "
                    + "  CASE WHEN r.total_cost IS NOT NULL AND r.total_cost > 0 THEN r.total_cost * 0.70 "
                    + "       WHEN c.price > 0 THEN c.price * 0.70 "
                    + "       ELSE 0 END "
                    + "), 0) AS calculated_earned "
                    + "FROM registration r "
                    + "JOIN course c ON r.course_id = c.id "
                    + "WHERE (c.created_by = ? OR c.created_by IN (SELECT a.id FROM account a WHERE a.email = (SELECT a2.email FROM account a2 WHERE a2.id = ? AND a2.email IS NOT NULL AND a2.email != ''))) "
                    + "  AND (TRIM(LOWER(r.status)) IN ('approved', 'active', 'success', 'completed') OR r.status IS NULL)";

            PreparedStatement psEarned = conn.prepareStatement(totalEarnedSql);
            psEarned.setInt(1, teacherId);
            psEarned.setInt(2, teacherId);
            ResultSet rsEarned = psEarned.executeQuery();
            BigDecimal calculatedTotalEarned = BigDecimal.ZERO;
            if (rsEarned.next()) {
                calculatedTotalEarned = rsEarned.getBigDecimal("calculated_earned");
                if (calculatedTotalEarned == null) calculatedTotalEarned = BigDecimal.ZERO;
            }
            System.out.println("[WALLET_DEBUG] Tổng thu nhập tính được từ tất cả đơn mua: " + calculatedTotalEarned + " đ");
            psEarned.close();

            // 4. Tính tổng tiền đã rút thành công (completed / approved)
            String withdrawnSql = "SELECT COALESCE(SUM(amount), 0) AS calculated_withdrawn "
                    + "FROM payout_request "
                    + "WHERE teacher_id = ? AND status IN ('completed', 'approved')";
            PreparedStatement psWithdrawn = conn.prepareStatement(withdrawnSql);
            psWithdrawn.setInt(1, teacherId);
            ResultSet rsWithdrawn = psWithdrawn.executeQuery();
            BigDecimal calculatedWithdrawn = BigDecimal.ZERO;
            if (rsWithdrawn.next()) {
                calculatedWithdrawn = rsWithdrawn.getBigDecimal("calculated_withdrawn");
                if (calculatedWithdrawn == null) calculatedWithdrawn = BigDecimal.ZERO;
            }
            psWithdrawn.close();

            // 5. Tính tổng tiền rút đang chờ duyệt (pending)
            String pendingSql = "SELECT COALESCE(SUM(amount), 0) AS calculated_pending "
                    + "FROM payout_request "
                    + "WHERE teacher_id = ? AND status = 'pending'";
            PreparedStatement psPending = conn.prepareStatement(pendingSql);
            psPending.setInt(1, teacherId);
            ResultSet rsPending = psPending.executeQuery();
            BigDecimal calculatedPending = BigDecimal.ZERO;
            if (rsPending.next()) {
                calculatedPending = rsPending.getBigDecimal("calculated_pending");
                if (calculatedPending == null) calculatedPending = BigDecimal.ZERO;
            }
            psPending.close();

            // Số dư khả dụng = Tổng thu nhập - Đã rút thành công - Đang chờ duyệt
            BigDecimal calculatedBalance = calculatedTotalEarned.subtract(calculatedWithdrawn).subtract(calculatedPending);
            if (calculatedBalance.compareTo(BigDecimal.ZERO) < 0) {
                calculatedBalance = BigDecimal.ZERO;
            }

            // 6. Cập nhật lại teacher_wallet với số liệu chuẩn xác tuyệt đối
            String updateWalletSql = "UPDATE teacher_wallet SET balance = ?, total_earned = ?, total_withdrawn = ?, updated_at = NOW() WHERE id = ?";
            PreparedStatement psUpdate = conn.prepareStatement(updateWalletSql);
            psUpdate.setBigDecimal(1, calculatedBalance);
            psUpdate.setBigDecimal(2, calculatedTotalEarned);
            psUpdate.setBigDecimal(3, calculatedWithdrawn);
            psUpdate.setInt(4, walletId);
            psUpdate.executeUpdate();
            psUpdate.close();

            // 7. Cập nhật lại balance_after cho các giao dịch trong wallet_transaction theo thứ tự thời gian tăng dần
            String allTxSql = "SELECT id, amount FROM wallet_transaction WHERE wallet_id = ? ORDER BY created_at ASC, id ASC";
            PreparedStatement psAllTx = conn.prepareStatement(allTxSql);
            psAllTx.setInt(1, walletId);
            ResultSet rsAllTx = psAllTx.executeQuery();

            String updateTxBalSql = "UPDATE wallet_transaction SET balance_after = ? WHERE id = ?";
            PreparedStatement psUpTxBal = conn.prepareStatement(updateTxBalSql);
            BigDecimal runningBal = BigDecimal.ZERO;
            while (rsAllTx.next()) {
                int txId = rsAllTx.getInt("id");
                BigDecimal txAmount = rsAllTx.getBigDecimal("amount");
                if (txAmount != null) {
                    runningBal = runningBal.add(txAmount);
                }
                psUpTxBal.setBigDecimal(1, runningBal);
                psUpTxBal.setInt(2, txId);
                psUpTxBal.executeUpdate();
            }
            psAllTx.close();
            psUpTxBal.close();

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    /**
     * Lấy ID giảng viên tạo khóa học
     */
    public int getTeacherIdByCourseId(int courseId) {
        String sql = "SELECT created_by FROM course WHERE id = ?";
        try {
            connection = new DBContext().getConnection();
            if (connection == null) return 0;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("created_by");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return 0;
    }

    /**
     * Tự động cộng 70% doanh thu bán khóa học vào ví giảng viên tạo khóa học
     */
    public boolean creditTeacherForCourseSale(int courseId, double itemPrice) {
        return creditTeacherForCourseSale(0, courseId, BigDecimal.valueOf(itemPrice));
    }

    public boolean creditTeacherForCourseSale(int courseId, BigDecimal price) {
        return creditTeacherForCourseSale(0, courseId, price);
    }

    public boolean creditTeacherForCourseSale(int registrationId, int courseId, BigDecimal price) {
        int teacherId = getTeacherIdByCourseId(courseId);
        if (teacherId > 0) {
            return syncWalletWithRegistrations(teacherId);
        }
        return false;
    }

    private TeacherWallet mapWallet(ResultSet rs) throws SQLException {
        TeacherWallet w = new TeacherWallet();
        w.setId(rs.getInt("id"));
        w.setTeacherId(rs.getInt("teacher_id"));
        w.setBalance(rs.getBigDecimal("balance") != null ? rs.getBigDecimal("balance") : BigDecimal.ZERO);
        w.setTotalEarned(rs.getBigDecimal("total_earned") != null ? rs.getBigDecimal("total_earned") : BigDecimal.ZERO);
        w.setTotalWithdrawn(rs.getBigDecimal("total_withdrawn") != null ? rs.getBigDecimal("total_withdrawn") : BigDecimal.ZERO);
        w.setStatus(rs.getString("status"));
        try {
            w.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (Exception ignored) {}
        try {
            w.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (Exception ignored) {}
        return w;
    }
}
