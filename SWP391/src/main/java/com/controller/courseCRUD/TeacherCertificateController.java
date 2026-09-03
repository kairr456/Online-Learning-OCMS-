package com.controller.courseCRUD;

import com.DAO.CertificateDAO;
import com.DAO.CourseDAO;
import com.entity.Account;
import com.entity.Course;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Trang "Course Certificate" của giảng viên — URL: /teacher-certificates
 * - GET : danh sách khóa học của GV + trạng thái template (có/chưa).
 * - POST: action=add|edit|delete template (upload ảnh nền + nhập title).
 * Chỉ khóa học đã được admin duyệt (status='active') mới được tạo template.
 */
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 50,
    maxRequestSize = 1024 * 1024 * 100
)
@WebServlet(name = "TeacherCertificateController", urlPatterns = {"/teacher-certificates"})
public class TeacherCertificateController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Course> courses = new CourseDAO().findByCreator(account.getId());
        Set<Integer> templateCourseIds = new HashSet<>();
        java.util.Map<Integer, com.entity.CertificateTemplate> templatesMap = new java.util.HashMap<>();
        for (com.entity.CertificateTemplate t : new CertificateDAO().getTemplatesByCreator(account.getId())) {
            templateCourseIds.add(t.getCourseId());
            templatesMap.put(t.getCourseId(), t);
        }

        request.setAttribute("courses", courses);
        request.setAttribute("templateCourseIds", templateCourseIds);
        request.setAttribute("templatesMap", templatesMap);
        request.getRequestDispatcher("/view/courseCRUD/teacher-certificates.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 2) {
            writeJson(response, false, "Unauthorized");
            return;
        }

        String action = request.getParameter("action");
        CertificateDAO dao = new CertificateDAO();
        boolean ok = false;

        try {
            if ("add".equals(action) || "edit".equals(action)) {
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                String title = request.getParameter("title");
                if (title == null || title.trim().isEmpty()) {
                    title = "Certificate of Completion";
                }
                boolean showTitle = "true".equalsIgnoreCase(request.getParameter("showTitle"))
                        || "on".equalsIgnoreCase(request.getParameter("showTitle"))
                        || "1".equals(request.getParameter("showTitle"));
                
                int topOffset = 140;
                try {
                    topOffset = Integer.parseInt(request.getParameter("topOffset"));
                } catch (Exception ignored) {}

                String backgroundUrl = saveBackground(request);

                if ("add".equals(action)) {
                    Course course = new CourseDAO().findById(courseId);
                    if (course == null || !"active".equals(course.getStatus()) || course.getCreatedBy() != account.getId()) {
                        writeJson(response, false, "Course not found or not approved");
                        return;
                    }
                    if (dao.hasTemplate(courseId)) {
                        writeJson(response, false, "This course already has a certificate");
                        return;
                    }

                    // Phân biệt TH1 (chưa từng có certificate) vs TH2 (đã từng có certificate nhưng đã xóa)
                    boolean wasNeverHadTemplate = !dao.hasEverHadTemplate(courseId);

                    ok = dao.insertTemplate(courseId, backgroundUrl, title, account.getId(), showTitle, topOffset);

                    if (ok && wasNeverHadTemplate) {
                        // TH1: Tự động cấp bù chứng chỉ cho tất cả học viên đã đạt 100% tiến độ trước đó
                        dao.autoIssueCertificatesForCourse(courseId);
                    }
                    // TH2: Từng có certificate và đã xóa -> dừng cấp phát bù cho thời gian bị xóa,
                    // chỉ học sinh hoàn thành sau khi tạo template mới sẽ được nhận chứng chỉ mới.
                } else {
                    ok = dao.updateTemplate(courseId, backgroundUrl, title, showTitle, topOffset);
                }
            } else if ("delete".equals(action)) {
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                ok = dao.deleteTemplate(courseId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, false, e.getMessage());
            return;
        }
        writeJson(response, ok, ok ? null : (dao.getLastError() != null ? dao.getLastError() : "Operation failed"));
    }

    /**
     * Lưu ảnh nền chứng chỉ vào assets/css/img/ (giống saveThumbnail của CourseManagerController).
     * Không có file upload -> trả về null (giữ ảnh cũ khi edit).
     */
    private String saveBackground(HttpServletRequest request) {
        try {
            Part filePart = request.getPart("background");
            if (filePart == null || filePart.getSize() <= 0) {
                System.out.println("[Certificate] no file upload -> keep old background");
                return null;
            }
            if (filePart.getSize() > 1024 * 1024) {
                throw new IllegalArgumentException("Dung lượng ảnh nền chứng chỉ không được vượt quá 1MB!");
            }
            String fileName = new File(filePart.getSubmittedFileName()).getName();
            fileName = System.currentTimeMillis() + "_" + fileName;
            String buildPath = getServletContext().getRealPath("");
            String uploadPath = buildPath + File.separator + "assets" + File.separator + "img";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            filePart.write(uploadPath + File.separator + fileName);

            // Also save to source directory so it is not lost on server restart/rebuild
            try {
                String srcPath = buildPath;
                if (buildPath.contains("target" + File.separator + "Test")) {
                    srcPath = buildPath.replace("target" + File.separator + "Test", "src" + File.separator + "main" + File.separator + "webapp");
                } else if (buildPath.contains("build" + File.separator + "web")) {
                    srcPath = buildPath.replace("build" + File.separator + "web", "src" + File.separator + "main" + File.separator + "webapp");
                }
                if (!srcPath.equals(buildPath)) {
                    String srcUploadPath = srcPath + File.separator + "assets" + File.separator + "img";
                    File srcUploadDir = new File(srcUploadPath);
                    if (!srcUploadDir.exists()) srcUploadDir.mkdirs();
                    java.nio.file.Files.copy(
                        filePart.getInputStream(), 
                        java.nio.file.Paths.get(srcUploadPath, fileName), 
                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                    );
                }
            } catch (Exception ex) {
                System.out.println("[Certificate] Warning: Could not copy background to source directory: " + ex.getMessage());
            }

            return request.getContextPath() + "/assets/img/" + fileName;
        } catch (Exception ex) {
            System.out.println("[Certificate] EXCEPTION while saving background: " + ex.getMessage());
            ex.printStackTrace();
            return null;
        }
    }

    private void writeJson(HttpServletResponse response, boolean success, String error) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().print("{\"success\": " + success + ", \"error\": \"" + (error == null ? "" : error) + "\"}");
    }
}