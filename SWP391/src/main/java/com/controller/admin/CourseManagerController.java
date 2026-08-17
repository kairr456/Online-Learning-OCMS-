package com.controller.admin;

import com.DAO.CategoryDAO;
import com.DAO.CourseAdminDAO;
import com.DAO.CourseApprovalDAO;
import com.DAO.CourseDAO;
import com.entity.Category;
import com.entity.Course;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.util.List;

/**
 * Controller trang "Quản lý khóa học" (admin) — URL: /admin/courses
 * - GET  : hiển thị bảng danh sách (search + filter + phân trang), xử lý delete (soft).
 * - POST : Add/Edit khóa học từ modal, trả JSON thủ công (không cần thư viện).
 * - Ghi chú: mỗi lần gọi DAO dùng instance mới vì connection bị đóng sau mỗi call.
 */
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 50,
    maxRequestSize = 1024 * 1024 * 100
)
@WebServlet(name = "CourseManagerController", urlPatterns = {"/admin/courses"})
public class CourseManagerController extends HttpServlet {

    // Số khóa học trên 1 trang (giữ đồng bộ với trang Account Management)
    private static final int PAGE_SIZE = 5;

    // ---------- GET: list + delete ----------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // Xử lý action=delete trước khi render danh sách
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
            return;
        }
        if ("approve".equals(action)) {
            handleApprove(request, response);
            return;
        }

        // Lấy thông tin filter & search từ URL
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        Integer categoryId = parseInteger(request.getParameter("categoryId"));

        // Đọc tham số trang (mặc định 1, sai định dạng thì bỏ qua)
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {
            }
        }

        // Đếm tổng số record TRƯỚC (instance riêng) → tính tổng số trang → clamp page về trong khoảng hợp lệ
        int totalRecords = new CourseAdminDAO().countCourses(keyword, status, categoryId);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        // Lấy danh sách khóa học + danh sách category cho dropdown lọc / modal
        List<Course> courseList = new CourseAdminDAO().searchCourses(keyword, status, categoryId, page, PAGE_SIZE);
        List<Category> categoryList = new CategoryDAO().findAll();

        // Đẩy dữ liệu sang JSP
        request.setAttribute("courseList", courseList);
        request.setAttribute("categoryList", categoryList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("courseApprovalLogs", new CourseApprovalDAO().getRecentLogs(10));

        // Main content cần render
        request.setAttribute("contentPage", "courses.jsp");

        // Render Admin Layout
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp")
                .forward(request, response);
    }

    /** Soft delete: đổi status = 'inactive' rồi quay lại trang danh sách. */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idRaw = request.getParameter("id");
        if (idRaw != null && !idRaw.trim().isEmpty()) {
            try {
                new CourseAdminDAO().deactivateCourse(Integer.parseInt(idRaw));
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // Quay lại danh sách (mất filter đang chọn — giống trang Account Management)
        response.sendRedirect(request.getContextPath() + "/admin/courses");
    }

    // ---------- Approve / Reject / History ----------
    private void handleApprove(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idRaw = request.getParameter("id");
        if (idRaw != null && !idRaw.trim().isEmpty()) {
            try {
                int adminId = getAdminId(request);
                new CourseApprovalDAO().approveCourse(Integer.parseInt(idRaw), adminId, request.getRemoteAddr());
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/courses?status=pending");
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            writeJson(response, false, "Invalid course id.");
            return;
        }
        String note = trim(request.getParameter("note"));
        int adminId = getAdminId(request);
        boolean ok = new CourseApprovalDAO().rejectCourse(id, adminId, note, request.getRemoteAddr());
        writeJson(response, ok, ok ? null : "Reject failed.");
    }

    private int getAdminId(HttpServletRequest request) {
        com.entity.Account account = (com.entity.Account) request.getSession().getAttribute("account");
        return account != null ? account.getId() : 0;
    }

    // ---------- POST: edit (từ modal, trả JSON) ----------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");   // "edit" | "reject"
        if ("edit".equals(action)) {
            handleEdit(request, response);
        } else if ("reject".equals(action)) {
            handleReject(request, response);
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            System.out.println("[CourseEdit] id invalid or missing: '" + request.getParameter("id") + "'");
            writeJson(response, false, "Invalid course id.");
            return;
        }

        Course course = new CourseDAO().findById(id);
        if (course == null) {
            System.out.println("[CourseEdit] course id=" + id + " not found");
            writeJson(response, false, "Course not found.");
            return;
        }

        // Lấy giá trị mới từ form, giữ nguyên created_by/created_date của bản cũ
        Course nv = readCourseFromRequest(request);
        course.setName(nv.getName());
        course.setDescription(nv.getDescription());
        course.setPrice(nv.getPrice());
        course.setStatus(nv.getStatus());
        course.setCategoryId(nv.getCategoryId());
        course.setRating(nv.getRating());

        // Thumbnail: chỉ ghi đè nếu có upload file mới; không chọn thì giữ ảnh cũ
        String newThumb = saveThumbnail(request);
        if (newThumb != null) {
            course.setThumbnail(newThumb);
        }

        System.out.println("[CourseEdit] fields -> id=" + id
                + " | name='" + course.getName()
                + "' | thumbnail='" + course.getThumbnail()
                + "' | price=" + course.getPrice()
                + " | status='" + course.getStatus()
                + "' | categoryId=" + course.getCategoryId()
                + " | rating=" + course.getRating());

        boolean ok = false;
        try {
            ok = new CourseDAO().update(course);
        } catch (Exception ex) {
            System.out.println("[CourseEdit] EXCEPTION while update: " + ex.getMessage());
            ex.printStackTrace();
        }
        if (!ok) {
            System.out.println("[CourseEdit] FAILED update -> kiểm tra các field đã in ở trên");
        }
        writeJson(response, ok, ok ? null : "Update failed.");
    }

    /** Gom việc đọc dữ liệu khóa học từ form (dùng chung cho Add và Edit). */
    private Course readCourseFromRequest(HttpServletRequest request) {
        Course course = new Course();
        course.setName(trim(request.getParameter("name")));
        course.setDescription(trim(request.getParameter("description")));

        Float price = parseFloat(request.getParameter("price"));
        if (price == null && request.getParameter("price") != null
                && !request.getParameter("price").trim().isEmpty()) {
            System.out.println("[Course] price invalid -> use default 0. raw='" + request.getParameter("price") + "'");
        }
        course.setPrice(price != null ? price : 0f);

        course.setStatus(trim(request.getParameter("status")));
        if (course.getStatus() == null || course.getStatus().trim().isEmpty()) {
            System.out.println("[Course] status empty -> use default 'draft'");
            course.setStatus("draft");
        }

        Integer cat = parseInteger(request.getParameter("categoryId"));
        if (cat == null && request.getParameter("categoryId") != null
                && !request.getParameter("categoryId").trim().isEmpty()) {
            System.out.println("[Course] categoryId invalid -> use default 1. raw='" + request.getParameter("categoryId") + "'");
        }
        course.setCategoryId(cat != null ? cat : 1);

        Integer rating = parseInteger(request.getParameter("rating"));
        if (rating == null && request.getParameter("rating") != null
                && !request.getParameter("rating").trim().isEmpty()) {
            System.out.println("[Course] rating invalid -> use default 0. raw='" + request.getParameter("rating") + "'");
        }
        course.setRating(rating != null ? rating : 0);

        if (course.getName() == null || course.getName().trim().isEmpty()) {
            System.out.println("[Course] name is empty!");
        }
        return course;
    }

    /**
     * Lưu ảnh thumbnail upload từ modal (dạng file, giống lesson.jsp).
     * File ghi vào assets/css/img/ (cùng thư mục với LessonController), tên
     * thêm timestamp để không bị đè. Không có file upload -> trả về null.
     */
    private String saveThumbnail(HttpServletRequest request) {
        try {
            Part filePart = request.getPart("thumbnail");
            if (filePart == null || filePart.getSize() <= 0) {
                System.out.println("[CourseThumbnail] no file upload -> keep old/empty thumbnail");
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
            String url = request.getContextPath() + "/assets/css/img/" + fileName;
            System.out.println("[CourseThumbnail] saved -> " + url);
            return url;
        } catch (Exception ex) {
            System.out.println("[CourseThumbnail] EXCEPTION while saving: " + ex.getMessage());
            ex.printStackTrace();
            return null;
        }
    }

    // Trả JSON thủ công (không cần thư viện)
    private void writeJson(HttpServletResponse response, boolean success, String error) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().print(
                "{\"success\": " + success + ", \"error\": \"" + (error == null ? "" : error) + "\"}");
    }

    private Integer parseInteger(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Float parseFloat(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return Float.parseFloat(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}
