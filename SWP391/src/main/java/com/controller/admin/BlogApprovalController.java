package com.controller.admin;

import com.DAO.BlogApprovalDAO;
import com.DAO.BlogDAO;
import com.entity.Account;
import com.entity.Blog;
import com.validator.adminValidator;
import com.validator.registrationValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

/**
 * Controller Phê duyệt bài viết Blog (Role: Admin)
 * URL Patterns: /admin/blog-approval, /admin/blogs
 * - Quản lý duyệt bài viết từ trạng thái Inactive (Chờ duyệt / Bản nháp) sang Active (Đã duyệt / Công khai).
 * - Cho phép xem trước (Quick Preview), lọc, tìm kiếm, phân trang và hủy duyệt / xóa bài viết.
 */
@WebServlet(name = "BlogApprovalController", urlPatterns = {"/admin/blog-approval", "/admin/blogs"})
public class BlogApprovalController extends HttpServlet {

    private static final int PAGE_SIZE = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra đăng nhập và quyền Admin (Role ID = 1)
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        // API trả chi tiết bài viết dạng JSON cho Quick Preview Modal
        if ("preview".equals(action) || "get_detail".equals(action)) {
            handleGetBlogDetailJson(request, response);
            return;
        }

        // Xử lý duyệt nhanh qua GET
        if ("approve".equals(action)) {
            int blogId = adminValidator.parseInt(request.getParameter("id"), -1);
            if (blogId > 0) {
                new BlogApprovalDAO().approveBlog(blogId);
            }
            response.sendRedirect(request.getContextPath() + "/admin/blog-approval?msg=approved");
            return;
        }

        // Xử lý từ chối / hủy duyệt / đặt Inactive bài viết qua GET
        if ("reject".equals(action) || "deactivate".equals(action)) {
            int blogId = adminValidator.parseInt(request.getParameter("id"), -1);
            if (blogId > 0) {
                new BlogApprovalDAO().deactivateBlog(blogId);
            }
            response.sendRedirect(request.getContextPath() + "/admin/blog-approval?msg=rejected");
            return;
        }

        // 2. Đọc các tham số tìm kiếm & lọc
        String keyword = registrationValidator.keywordFor(request.getParameter("keyword"));
        
        // Trạng thái lọc: nếu không truyền param thì mặc định là 'all' (Tất cả)
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "all";
        }

        Integer categoryId = adminValidator.parseInt(request.getParameter("categoryId"), -1);
        if (categoryId != null && categoryId <= 0) {
            categoryId = null;
        }

        int page = registrationValidator.pageFor(request.getParameter("page"));

        // 3. Đếm số lượng & tính phân trang
        BlogApprovalDAO dao = new BlogApprovalDAO();
        int totalRecords = dao.countBlogs(keyword, status, categoryId);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        // 4. Lấy dữ liệu bài viết
        List<Blog> blogList = new BlogApprovalDAO().searchBlogs(keyword, status, categoryId, page, PAGE_SIZE);
        Map<Integer, String> blogCategories = new BlogDAO().getBlogCategories();

        // 5. Thống kê số lượng bài viết (Inactive, Active, Total)
        int inactiveCount = new BlogApprovalDAO().countByStatus("Inactive");
        int activeCount = new BlogApprovalDAO().countByStatus("Active");
        int totalCount = new BlogApprovalDAO().countByStatus("all");

        // 6. Truyền dữ liệu sang JSP
        request.setAttribute("blogList", blogList);
        request.setAttribute("blogCategories", blogCategories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("keyword", keyword);
        request.setAttribute("currentStatus", status);
        request.setAttribute("categoryId", categoryId);

        request.setAttribute("inactiveCount", inactiveCount);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("totalCount", totalCount);

        // Đặt nội dung hiển thị trong admin_layout.jsp
        request.setAttribute("contentPage", "blog_approval.jsp");

        // Forward sang Admin Layout
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra quyền Admin
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 1) {
            writeJsonResponse(response, false, "Bạn không có quyền thực hiện hành động này.");
            return;
        }

        String action = request.getParameter("action");

        if ("approve".equals(action)) {
            handleApprovePost(request, response);
        } else if ("reject".equals(action) || "deactivate".equals(action)) {
            handleRejectPost(request, response);
        } else if ("preview".equals(action)) {
            handleGetBlogDetailJson(request, response);
        } else {
            writeJsonResponse(response, false, "Hành động không hợp lệ.");
        }
    }

    /**
     * Xử lý Phê duyệt bài viết (Inactive -> Active) qua AJAX POST
     */
    private void handleApprovePost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = adminValidator.parseInt(request.getParameter("id"), -1);
        if (id <= 0) {
            writeJsonResponse(response, false, "ID bài viết không hợp lệ.");
            return;
        }

        boolean ok = new BlogApprovalDAO().approveBlog(id);
        if (ok) {
            writeJsonResponse(response, true, "Bài viết đã được phê duyệt và chuyển sang trạng thái Active (Công khai)!");
        } else {
            writeJsonResponse(response, false, "Phê duyệt thất bại. Vui lòng thử lại!");
        }
    }

    /**
     * Xử lý Từ chối / Ẩn bài viết (Active -> Inactive) qua AJAX POST
     */
    private void handleRejectPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = adminValidator.parseInt(request.getParameter("id"), -1);
        if (id <= 0) {
            writeJsonResponse(response, false, "ID bài viết không hợp lệ.");
            return;
        }

        boolean ok = new BlogApprovalDAO().deactivateBlog(id);
        if (ok) {
            writeJsonResponse(response, true, "Bài viết đã chuyển sang trạng thái Inactive (Ẩn / Từ chối)!");
        } else {
            writeJsonResponse(response, false, "Thao tác thất bại. Vui lòng thử lại!");
        }
    }

    /**
     * Trả về chi tiết bài viết dạng JSON để hiển thị trên Quick Preview Modal
     */
    private void handleGetBlogDetailJson(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        int id = adminValidator.parseInt(request.getParameter("id"), -1);
        if (id <= 0) {
            response.getWriter().print("{\"success\": false, \"error\": \"Invalid blog ID.\"}");
            return;
        }

        Blog blog = new BlogApprovalDAO().getBlogDetail(id);
        if (blog == null) {
            response.getWriter().print("{\"success\": false, \"error\": \"Blog not found.\"}");
            return;
        }

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        String createdStr = blog.getCreatedDate() != null ? sdf.format(blog.getCreatedDate()) : "";

        StringBuilder json = new StringBuilder();
        json.append("{")
            .append("\"success\": true, ")
            .append("\"id\": ").append(blog.getId()).append(", ")
            .append("\"title\": ").append(escapeJson(blog.getTitle())).append(", ")
            .append("\"thumbnail\": ").append(escapeJson(blog.getThumbnail())).append(", ")
            .append("\"briefInfo\": ").append(escapeJson(blog.getBriefInfo())).append(", ")
            .append("\"content\": ").append(escapeJson(blog.getContent())).append(", ")
            .append("\"authorName\": ").append(escapeJson(blog.getAuthorName())).append(", ")
            .append("\"authorEmail\": ").append(escapeJson(blog.getAuthorEmail())).append(", ")
            .append("\"categoryName\": ").append(escapeJson(blog.getCategoryName())).append(", ")
            .append("\"status\": ").append(escapeJson(blog.getStatus())).append(", ")
            .append("\"createdDate\": ").append(escapeJson(createdStr))
            .append("}");

        response.getWriter().print(json.toString());
    }

    private void writeJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String json = String.format("{\"success\": %b, \"message\": %s, \"error\": %s}",
                success,
                success ? escapeJson(message) : "\"\"",
                !success ? escapeJson(message) : "\"\"");
        response.getWriter().print(json);
    }

    private String escapeJson(String str) {
        if (str == null) return "null";
        StringBuilder sb = new StringBuilder("\"");
        for (char c : str.toCharArray()) {
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        String t = "000" + Integer.toHexString(c);
                        sb.append("\\u").append(t.substring(t.length() - 4));
                    } else {
                        sb.append(c);
                    }
                    break;
            }
        }
        sb.append("\"");
        return sb.toString();
    }
}
