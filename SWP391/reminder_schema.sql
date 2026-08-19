-- Bang luu cai dat Learning Reminder (moi account mot dong)
-- days: cac ngay trong tuan duoc chon, quy uoc T2=1 ... CN=7, phan tach boi dau phay (VD '1,3,5')
-- Chay truc tiep trong MySQL (database: ocms)
DROP TABLE IF EXISTS learning_reminder;
CREATE TABLE IF NOT EXISTS learning_reminder (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    days VARCHAR(13) NOT NULL DEFAULT '1,2,3,4,5',
    reminder_time TIME NOT NULL DEFAULT '20:00:00',
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    last_sent_date DATE NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_reminder_account (account_id),
    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE
);