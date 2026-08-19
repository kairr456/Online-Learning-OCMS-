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

    /** Thông điệp lỗi SQL cuối cùng (để controller hiển thị cho người dùng). */
    private String lastError;

    public String getLastError() {
        return lastError;
    }

    // ==================== TEMPLATE (giảng viên) ====================

    public CertificateTemplate getTemplateByCourseId(int courseId) {
        CertificateTemplate t = null;
        String sql = "SELECT ct.*, c.name AS course_name FROM certificate_template ct "
                + "JOIN course c ON ct.course_id = c.id WHERE ct.course_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                t = mapTemplate(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error getTemplateByCourseId: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return t;
    }

    /** Danh sách template của 1 GV — dùng để biết khóa nào đã có chứng chỉ. */
    public List<CertificateTemplate> getTemplatesByCreator(int creatorId) {
        List<CertificateTemplate> list = new ArrayList<>();
        String sql = "SELECT ct.*, c.name AS course_name FROM certificate_template ct "
                + "JOIN course c ON ct.course_id = c.id WHERE ct.created_by = ? ORDER BY ct.updated_date DESC";
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
        String sql = "INSERT INTO certificate_template (course_id, background_url, title, created_by) VALUES (?, ?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            statement.setString(2, backgroundUrl);
            statement.setString(3, title);
            statement.setInt(4, createdBy);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error insertTemplate: " + ex.getMessage());
            lastError = ex.getMessage();
            return false;
        } finally {
            closeResources();
        }
    }

    /** Cập nhật template: backgroundUrl null/empty nghĩa là giữ ảnh cũ (không chọn file mới). */
    public boolean updateTemplate(int courseId, String backgroundUrl, String title) {
        StringBuilder sql = new StringBuilder("UPDATE certificate_template SET title = ?");
        if (backgroundUrl != null && !backgroundUrl.isEmpty()) {
            sql.append(", background_url = ?");
        }
        sql.append(", updated_date = NOW() WHERE course_id = ?");
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql.toString());
            int idx = 1;
            statement.setString(idx++, title);
            if (backgroundUrl != null && !backgroundUrl.isEmpty()) {
                statement.setString(idx++, backgroundUrl);
            }
            statement.setInt(idx, courseId);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error updateTemplate: " + ex.getMessage());
            lastError = ex.getMessage();
            return false;
        } finally {
            closeResources();
        }
    }

    public boolean deleteTemplate(int courseId) {
        String sql = "DELETE FROM certificate_template WHERE course_id = ?";
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
            System.out.println("Error hasTemplate: " + ex.getMessage());
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
     * Cấp chứng chỉ cho HV khi đạt 100% progress.
     * - Không cấp nếu khóa chưa có template / HV đã có chứng chỉ khóa đó.
     * - Snapshot course_name + student_name + tạo mã duy nhất (thử tối đa 5 lần).
     * - Trả về mã chứng chỉ nếu thành công, null nếu không.
     */
    public String issueCertificate(int accountId, int courseId) {
        if (hasCertificate(accountId, courseId)) {
            return null;
        }
        CertificateTemplate template = getTemplateByCourseId(courseId);
        if (template == null) {
            return null;
        }
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
            statement.setInt(1, template.getId());
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

    /** JOIN certificate_template để lấy ảnh nền + tiêu đề cho trang hiển thị. */
    public List<Certificate> getCertificatesByAccount(int accountId) {
        List<Certificate> list = new ArrayList<>();
        String sql = "SELECT c.*, ct.background_url AS background_url, ct.title AS template_title "
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
        String sql = "SELECT c.*, ct.background_url AS background_url, ct.title AS template_title "
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
        return c;
    }
}