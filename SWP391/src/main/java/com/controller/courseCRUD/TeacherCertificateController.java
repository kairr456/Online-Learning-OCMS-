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
        for (com.entity.CertificateTemplate t : new CertificateDAO().getTemplatesByCreator(account.getId())) {
            templateCourseIds.add(t.getCourseId());
        }

        request.setAttribute("courses", courses);
        request.setAttribute("templateCourseIds", templateCourseIds);
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
            if ("add".equals(action)) {
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                String title = request.getParameter("title");
                if (title == null || title.trim().isEmpty()) {
                    title = "Certificate of Completion";
                }
                // Chỉ khóa active (đã duyệt) và thuộc GV này mới được tạo template
                Course course = new CourseDAO().findById(courseId);
                if (course == null || !"active".equals(course.getStatus()) || course.getCreatedBy() != account.getId()) {
                    writeJson(response, false, "Course not found or not approved");
                    return;
                }
                if (dao.hasTemplate(courseId)) {
                    writeJson(response, false, "This course already has a certificate");
                    return;
                }
                String backgroundUrl = saveBackground(request);
                ok = dao.insertTemplate(courseId, backgroundUrl, title, account.getId());
            } else if ("edit".equals(action)) {
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                String title = request.getParameter("title");
                if (title == null || title.trim().isEmpty()) {
                    title = "Certificate of Completion";
                }
                String backgroundUrl = saveBackground(request); // null nếu không chọn file mới
                ok = dao.updateTemplate(courseId, backgroundUrl, title);
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
            String fileName = new File(filePart.getSubmittedFileName()).getName();
            fileName = System.currentTimeMillis() + "_" + fileName;
            String uploadPath = getServletContext().getRealPath("") + File.separator
                    + "assets" + File.separator + "css" + File.separator + "img";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            filePart.write(uploadPath + File.separator + fileName);
            return request.getContextPath() + "/assets/css/img/" + fileName;
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