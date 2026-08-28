package com.DAO;

import com.entity.LearningReminder;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReminderDAO extends DBContext {

    public void ensureTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS learning_reminder (" +
                     "    id INT AUTO_INCREMENT PRIMARY KEY, " +
                     "    account_id INT NOT NULL, " +
                     "    days VARCHAR(13) NOT NULL DEFAULT '1,2,3,4,5', " +
                     "    reminder_time TIME NOT NULL DEFAULT '20:00:00', " +
                     "    enabled TINYINT(1) NOT NULL DEFAULT 1, " +
                     "    last_sent_date DATE NULL, " +
                     "    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, " +
                     "    UNIQUE KEY uk_reminder_account (account_id), " +
                     "    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE" +
                     ")";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[ReminderDAO] ensureTableExists error: " + e.getMessage());
        }
    }

    public LearningReminder getByAccountId(int accountId) {
        ensureTableExists();
        String sql = "SELECT id, account_id, days, reminder_time, enabled, last_sent_date FROM learning_reminder WHERE account_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LearningReminder reminder = new LearningReminder();
                    reminder.setId(rs.getInt("id"));
                    reminder.setAccountId(rs.getInt("account_id"));
                    reminder.setDays(rs.getString("days"));
                    String time = rs.getString("reminder_time");
                    reminder.setReminderTime(time != null && time.length() >= 5 ? time.substring(0, 5) : "20:00");
                    reminder.setEnabled(rs.getBoolean("enabled"));
                    if (rs.getDate("last_sent_date") != null) {
                        reminder.setLastSentDate(rs.getDate("last_sent_date").toString());
                    }
                    return reminder;
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReminderDAO] getByAccountId error: " + e.getMessage());
        }
        return null;
    }

    public boolean upsert(int accountId, String days, String time, boolean enabled) {
        ensureTableExists();
        String sql = "INSERT INTO learning_reminder (account_id, days, reminder_time, enabled) VALUES (?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE days = VALUES(days), reminder_time = VALUES(reminder_time), enabled = VALUES(enabled)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setString(2, days);
            ps.setString(3, time);
            ps.setBoolean(4, enabled);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("[ReminderDAO] upsert error: " + e.getMessage());
        }
        return false;
    }

    public List<LearningReminder> getAllEnabled() {
        ensureTableExists();
        List<LearningReminder> reminders = new ArrayList<>();
        String sql = "SELECT id, account_id, days, reminder_time, enabled, last_sent_date FROM learning_reminder WHERE enabled = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LearningReminder reminder = new LearningReminder();
                    reminder.setId(rs.getInt("id"));
                    reminder.setAccountId(rs.getInt("account_id"));
                    reminder.setDays(rs.getString("days"));
                    String time = rs.getString("reminder_time");
                    reminder.setReminderTime(time != null && time.length() >= 5 ? time.substring(0, 5) : "20:00");
                    reminder.setEnabled(rs.getBoolean("enabled"));
                    if (rs.getDate("last_sent_date") != null) {
                        reminder.setLastSentDate(rs.getDate("last_sent_date").toString());
                    }
                    reminders.add(reminder);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReminderDAO] getAllEnabled error: " + e.getMessage());
        }
        return reminders;
    }

    public boolean updateLastSentDate(int accountId) {
        ensureTableExists();
        String sql = "UPDATE learning_reminder SET last_sent_date = CURRENT_DATE WHERE account_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            System.err.println("[ReminderDAO] updateLastSentDate error: " + e.getMessage());
        }
        return false;
    }
}