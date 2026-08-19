-- Bang luu archived course (moi nguoi dung mot danh sach archived rieng)
-- Khoa hoc dat 100% se duoc tu dong them vao day
-- Chay truc tiep trong MySQL (database: ocms)
CREATE TABLE IF NOT EXISTS archived_course (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    course_id INT NOT NULL,
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_archive_account_course (account_id, course_id),
    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
);