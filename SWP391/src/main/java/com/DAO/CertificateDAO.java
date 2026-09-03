package com.DAO;

import com.entity.Account;
import com.entity.Certificate;
import com.entity.CertificateTemplate;
import com.entity.Course;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * DAO chứng chỉ: GV quản lý template + hệ thống cấp/lấy chứng chỉ cho HV.
 * LƯU Ý: mỗi lần gọi dùng instance riêng vì closeResources() đóng connection.
 */
public class CertificateDAO extends DBContext {

    static {
        try {
            java.sql.Connection conn = new DBContext().connection;
            if (conn != null) {
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("ALTER TABLE certificate_template ADD COLUMN show_title TINYINT(1) DEFAULT 1");
                } catch (Exception ignored) {}
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("ALTER TABLE certificate_template ADD COLUMN top_offset INT DEFAULT 140");
                } catch (Exception ignored) {}
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("ALTER TABLE certificate_template ADD COLUMN is_deleted TINYINT(1) DEFAULT 0");
                } catch (Exception ignored) {}
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("ALTER TABLE certificate_template ADD INDEX certificate_template_course_idx (course_id)");
                } catch (Exception ignored) {}
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("ALTER TABLE certificate_template DROP INDEX certificate_template_course_unique");
                } catch (Exception ignored) {}
                try (java.sql.Statement st = conn.createStatement()) {
                    st.execute("UPDATE certificate c JOIN certificate_template ct ON c.course_id = ct.course_id SET c.template_id = ct.id WHERE c.template_id IS NULL");
                } catch (Exception ignored) {}
                conn.close();
            }
        } catch (Exception ignored) {}
    }

    /** Thông điệp lỗi SQL cuối cùng (để controller hiển thị cho người dùng). */
    private String lastError;

    public String getLastError() {
        return lastError;
    }

    // ==================== TEMPLATE (giảng viên) ====================

    public CertificateTemplate getTemplateByCourseId(int courseId) {
        return getActiveTemplateByCourseId(courseId);
    }

    public CertificateTemplate getActiveTemplateByCourseId(int courseId) {
        CertificateTemplate t = null;
        String sql = "SELECT ct.*, c.name AS course_name FROM certificate_template ct "
                + "JOIN course c ON ct.course_id = c.id "
                + "WHERE ct.course_id = ? AND (ct.is_deleted = 0 OR ct.is_deleted IS NULL) "
                + "ORDER BY ct.id DESC LIMIT 1";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                t = mapTemplate(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error getActiveTemplateByCourseId: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return t;
    }

    public CertificateTemplate getTemplateById(int templateId) {
        CertificateTemplate t = null;
        String sql = "SELECT ct.*, c.name AS course_name FROM certificate_template ct "
                + "JOIN course c ON ct.course_id = c.id WHERE ct.id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, templateId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                t = mapTemplate(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error getTemplateById: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return t;
    }

    /** Danh sách template đang hoạt động của 1 GV — dùng để biết khóa nào đang có chứng chỉ. */
    public List<CertificateTemplate> getTemplatesByCreator(int creatorId) {
        List<CertificateTemplate> list = new ArrayList<>();
        String sql = "SELECT ct.*, c.name AS course_name FROM certificate_template ct "
                + "JOIN course c ON ct.course_id = c.id "
                + "WHERE ct.created_by = ? AND (ct.is_deleted = 0 OR ct.is_deleted IS NULL) "
                + "ORDER BY ct.updated_date DESC";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, creatorId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(mapTemplate(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error getTemplatesByCreator: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return list;
    }

    public boolean insertTemplate(int courseId, String backgroundUrl, String title, int createdBy) {
        return insertTemplate(courseId, backgroundUrl, title, createdBy, true, 140);
    }

    public boolean insertTemplate(int courseId, String backgroundUrl, String title, int createdBy, boolean showTitle, int topOffset) {
        markActiveTemplatesDeleted(courseId);
        String sql = "INSERT INTO certificate_template (course_id, background_url, title, created_by, show_title, top_offset, is_deleted) VALUES (?, ?, ?, ?, ?, ?, 0)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            statement.setString(2, backgroundUrl);
            statement.setString(3, title);
            statement.setInt(4, createdBy);
            statement.setBoolean(5, showTitle);
            statement.setInt(6, topOffset);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error insertTemplate: " + ex.getMessage());
            lastError = ex.getMessage();
            return false;
        } finally {
            closeResources();
        }
    }

    private void markActiveTemplatesDeleted(int courseId) {
        String sql = "UPDATE certificate_template SET is_deleted = 1 WHERE course_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            statement.executeUpdate();
        } catch (Exception ignored) {
        } finally {
            closeResources();
        }
    }

    /**
     * Cập nhật template:
     * Giữ nguyên template cũ (đánh dấu is_deleted = 1) để học sinh đã có bằng trước đây không bị ảnh hưởng.
     * Tạo bản ghi template mới (is_deleted = 0) để chỉ những học sinh hoàn thành sau này nhận template mới.
     */
    public boolean updateTemplate(int courseId, String backgroundUrl, String title) {
        return updateTemplate(courseId, backgroundUrl, title, true, 140);
    }

    public boolean updateTemplate(int courseId, String backgroundUrl, String title, boolean showTitle, int topOffset) {
        CertificateTemplate old = getActiveTemplateByCourseId(courseId);
        if (old == null) {
            return false;
        }
        String finalBg = (backgroundUrl != null && !backgroundUrl.isEmpty()) ? backgroundUrl : old.getBackgroundUrl();
        markActiveTemplatesDeleted(courseId);
        return insertTemplate(courseId, finalBg, title, old.getCreatedBy(), showTitle, topOffset);
    }

    /**
     * Xóa mẫu chứng chỉ:
     * Chỉ đánh dấu is_deleted = 1 trong bảng certificate_template.
     * KHÔNG XÓA trong bảng certificate để những học sinh đã được cấp trước đó vẫn giữ và hiển thị bằng.
     */
    public boolean deleteTemplate(int courseId) {
        String sql = "UPDATE certificate_template SET is_deleted = 1 WHERE course_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error deleteTemplate: " + ex.getMessage());
            lastError = ex.getMessage();
            return false;
        } finally {
            closeResources();
        }
    }

    public boolean hasTemplate(int courseId) {
        return hasActiveTemplate(courseId);
    }

    public boolean hasActiveTemplate(int courseId) {
        String sql = "SELECT COUNT(*) FROM certificate_template WHERE course_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            System.out.println("Error hasActiveTemplate: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    /** Phân biệt TH1 (chưa từng có template nào) vs TH2 (đã từng có template nhưng hiện đã xóa). */
    public boolean hasEverHadTemplate(int courseId) {
        String sql = "SELECT COUNT(*) FROM certificate_template WHERE course_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            System.out.println("Error hasEverHadTemplate: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    // ==================== CERTIFICATE (học viên) ====================

    public boolean hasCertificate(int accountId, int courseId) {
        String sql = "SELECT COUNT(*) FROM certificate WHERE account_id = ? AND course_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            statement.setInt(2, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            System.out.println("Error hasCertificate: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Lấy mã chứng chỉ nếu HV đã có chứng chỉ của khóa học.
     */
    public String getCertificateCode(int accountId, int courseId) {
        String sql = "SELECT certificate_code FROM certificate WHERE account_id = ? AND course_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            statement.setInt(2, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString("certificate_code");
            }
        } catch (SQLException ex) {
            System.out.println("Error getCertificateCode: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public String issueCertificate(int accountId, int courseId) {
        // Chỉ cấp chứng chỉ nếu khóa học ĐÃ CÓ certificate template
        CertificateTemplate template = getTemplateByCourseId(courseId);
        if (template == null) {
            return null;
        }

        if (hasCertificate(accountId, courseId)) {
            return getCertificateCode(accountId, courseId);
        }

        int templateId = template.getId();

        Course course = new CourseDAO().findById(courseId);
        Account student = new AccountDAO().getAccountById(accountId);
        String courseName = course != null ? course.getName() : "Course #" + courseId;
        String studentName = (student != null && student.getFullName() != null && !student.getFullName().isEmpty())
                ? student.getFullName() : (student != null ? student.getUsername() : "Student #" + accountId);

        String code = null;
        for (int i = 0; i < 5; i++) {
            String candidate = "OCMS-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            if (getCertificateByCode(candidate) == null) {
                code = candidate;
                break;
            }
        }
        if (code == null) {
            return null;
        }

        String sql = "INSERT INTO certificate (template_id, account_id, course_id, course_name, student_name, certificate_code) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, templateId);
            statement.setInt(2, accountId);
            statement.setInt(3, courseId);
            statement.setString(4, courseName);
            statement.setString(5, studentName);
            statement.setString(6, code);
            return statement.executeUpdate() > 0 ? code : null;
        } catch (SQLException ex) {
            System.out.println("Error issueCertificate: " + ex.getMessage());
            return null;
        } finally {
            closeResources();
        }
    }

    /**
     * Tự động cấp chứng chỉ cho TẤT CẢ học viên đã hoàn thành 100% khóa học này
     * nhưng trước đây chưa được cấp chứng chỉ (do giảng viên tạo template sau).
     */
    public void autoIssueCertificatesForCourse(int courseId) {
        if (!hasTemplate(courseId)) {
            return;
        }
        List<Integer> studentIds = new ArrayList<>();
        // Tìm tất cả học viên có đăng ký khóa học HOẶC có tiến độ học tập trong khóa này
        String sql = "SELECT DISTINCT account_id FROM ("
                + "SELECT account_id FROM registration WHERE course_id = ? "
                + "UNION "
                + "SELECT lp.account_id FROM lesson_progress lp JOIN lesson l ON lp.lesson_id = l.id JOIN section s ON l.section_id = s.id WHERE s.course_id = ?"
                + ") AS all_students";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            statement.setInt(2, courseId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                studentIds.add(resultSet.getInt("account_id"));
            }
        } catch (SQLException ex) {
            System.out.println("Error autoIssueCertificatesForCourse finding students: " + ex.getMessage());
        } finally {
            closeResources();
        }

        LearningDAO learningDAO = new LearningDAO();
        for (int studentId : studentIds) {
            if (!hasCertificate(studentId, courseId)) {
                int progress = learningDAO.getCourseProgress(studentId, courseId);
                if (progress >= 100) {
                    issueCertificate(studentId, courseId);
                }
            }
        }
    }

    public void autoIssuePendingCertificatesForStudent(int accountId) {
        CourseRegistrationDAO regDAO = new CourseRegistrationDAO();
        List<Course> enrolled = regDAO.getCoursesByAccountId(accountId);
        CourseDAO courseDAO = new CourseDAO();
        List<Course> created = courseDAO.findByCreator(accountId);
        for (Course c : created) {
            boolean exists = false;
            for (Course e : enrolled) {
                if (e.getId() == c.getId()) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                enrolled.add(c);
            }
        }
        LearningDAO learningDAO = new LearningDAO();
        java.util.Map<Integer, Integer> progressMap = learningDAO.getCourseProgressMap(accountId);
        java.util.Set<Integer> templateCourseIds = getTemplateCourseIds();

        for (Course c : enrolled) {
            // Chỉ xét các khóa học ĐÃ CÓ template chứng chỉ do giảng viên tạo
            if (!templateCourseIds.contains(c.getId())) {
                continue;
            }
            Integer p = progressMap.get(c.getId());
            if (p == null) {
                p = learningDAO.getCourseProgress(accountId, c.getId());
            }
            if (p >= 100) {
                if (!hasCertificate(accountId, c.getId())) {
                    issueCertificate(accountId, c.getId());
                }
            }
        }
    }

    public java.util.Map<Integer, String> getCertificateCodeMapByAccount(int accountId) {
        java.util.Map<Integer, String> map = new java.util.HashMap<>();
        String sql = "SELECT course_id, certificate_code FROM certificate WHERE account_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                map.put(resultSet.getInt("course_id"), resultSet.getString("certificate_code"));
            }
        } catch (SQLException ex) {
            System.out.println("Error getCertificateCodeMapByAccount: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return map;
    }

    /** Lấy Set tất cả course_id ĐANG CÓ template chứng chỉ hoạt động (chưa bị xóa). */
    public java.util.Set<Integer> getTemplateCourseIds() {
        java.util.Set<Integer> set = new java.util.HashSet<>();
        String sql = "SELECT DISTINCT course_id FROM certificate_template WHERE (is_deleted = 0 OR is_deleted IS NULL)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                set.add(resultSet.getInt("course_id"));
            }
        } catch (SQLException ex) {
            System.out.println("Error getTemplateCourseIds: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return set;
    }

    /** JOIN certificate_template qua template_id để lấy đúng mẫu chứng chỉ lúc cấp cho học viên. */
    public List<Certificate> getCertificatesByAccount(int accountId) {
        List<Certificate> list = new ArrayList<>();
        String sql = "SELECT c.*, ct.background_url AS background_url, ct.title AS template_title, ct.show_title AS show_title, ct.top_offset AS top_offset "
                + "FROM certificate c LEFT JOIN certificate_template ct ON c.template_id = ct.id "
                + "WHERE c.account_id = ? ORDER BY c.issued_date DESC, c.id DESC";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(mapCertificate(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error getCertificatesByAccount: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return list;
    }

    public Certificate getCertificateByCode(String code) {
        Certificate c = null;
        String sql = "SELECT c.*, ct.background_url AS background_url, ct.title AS template_title, ct.show_title AS show_title, ct.top_offset AS top_offset "
                + "FROM certificate c LEFT JOIN certificate_template ct ON c.template_id = ct.id "
                + "WHERE c.certificate_code = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setString(1, code);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                c = mapCertificate(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error getCertificateByCode: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return c;
    }

    private CertificateTemplate mapTemplate(java.sql.ResultSet rs) throws SQLException {
        CertificateTemplate t = new CertificateTemplate();
        t.setId(rs.getInt("id"));
        t.setCourseId(rs.getInt("course_id"));
        t.setCourseName(rs.getString("course_name"));
        t.setBackgroundUrl(rs.getString("background_url"));
        t.setTitle(rs.getString("title"));
        try {
            t.setShowTitle(rs.getBoolean("show_title"));
        } catch (Exception e) {
            t.setShowTitle(true);
        }
        try {
            int offset = rs.getInt("top_offset");
            t.setTopOffset(offset > 0 ? offset : 140);
        } catch (Exception e) {
            t.setTopOffset(140);
        }
        t.setCreatedBy(rs.getInt("created_by"));
        java.sql.Timestamp cd = rs.getTimestamp("created_date");
        t.setCreatedDate(cd != null ? cd.toLocalDateTime() : null);
        java.sql.Timestamp ud = rs.getTimestamp("updated_date");
        t.setUpdatedDate(ud != null ? ud.toLocalDateTime() : null);
        return t;
    }

    private Certificate mapCertificate(java.sql.ResultSet rs) throws SQLException {
        Certificate c = new Certificate();
        c.setId(rs.getInt("id"));
        int templateId = rs.getInt("template_id");
        c.setTemplateId(rs.wasNull() ? null : templateId);
        c.setAccountId(rs.getInt("account_id"));
        c.setCourseId(rs.getInt("course_id"));
        c.setCourseName(rs.getString("course_name"));
        c.setStudentName(rs.getString("student_name"));
        c.setCertificateCode(rs.getString("certificate_code"));
        java.sql.Timestamp ts = rs.getTimestamp("issued_date");
        c.setIssuedDate(ts != null ? ts.toLocalDateTime() : null);
        c.setBackgroundUrl(rs.getString("background_url"));
        c.setTitle(rs.getString("template_title"));
        try {
            c.setShowTitle(rs.getBoolean("show_title"));
        } catch (Exception e) {
            c.setShowTitle(true);
        }
        try {
            int offset = rs.getInt("top_offset");
            c.setTopOffset(offset > 0 ? offset : 140);
        } catch (Exception e) {
            c.setTopOffset(140);
        }
        return c;
    }
}