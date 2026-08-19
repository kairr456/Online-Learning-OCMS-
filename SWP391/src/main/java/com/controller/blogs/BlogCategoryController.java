package com.controller.blogs;

import com.DAO.BlogCategoryDAO;
import com.entity.Account;
import com.entity.BlogCategory;
import com.validator.adminValidator;
import com.validator.registrationValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller Quản lý Danh mục Blog (Role: Admin)
 * URL: /admin/blog-categories
 * - GET : Hiển thị bảng danh sách, tìm kiếm, phân trang, xử lý xóa.
 * - POST: Thêm mới (action=add) / Cập nhật (action=edit) danh mục từ Modal (trả JSON).
 */
@WebServlet(name = "BlogCategoryController", urlPatterns = {"/admin/blog-categories", "/admin/blog-category"})
public class BlogCategoryController extends HttpServlet {

    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra đăng nhập và quyền Admin (Role = 1)
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Xử lý xóa nếu action = delete
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            handleDelete(request, response);
            return;
        }

        // 3. Đọc từ khóa tìm kiếm & phân trang
        String keyword = registrationValidator.keywordFor(request.getParameter("keyword"));
        int page = registrationValidator.pageFor(request.getParameter("page"));

        BlogCategoryDAO dao = new BlogCategoryDAO();
        int totalRecords = dao.countBlogCategories(keyword);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<BlogCategory> categoryList = new BlogCategoryDAO().searchBlogCategories(keyword, page, PAGE_SIZE);

        // 4. Truyền dữ liệu sang JSP
        request.setAttribute("categoryList", categoryList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("keyword", keyword);

        // Đặt nội dung hiển thị trong admin_layout.jsp
        request.setAttribute("contentPage", "blog_categories.jsp");

        // Forward sang admin layout
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp").forward(request, response);
    }

    /**
     * Xử lý xóa danh mục blog
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idRaw = request.getParameter("id");
        int id = adminValidator.parseInt(idRaw, -1);

        if (id > 0) {
            boolean ok = new BlogCategoryDAO().deleteBlogCategory(id);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/blog-categories?msg=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/blog-categories?error=delete_failed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/blog-categories?error=invalid_id");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền Admin
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 1) {
            writeJson(response, false, "Unauthorized access.");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            handleAdd(request, response);
        } else if ("edit".equals(action)) {
            handleEdit(request, response);
        } else {
            writeJson(response, false, "Invalid action.");
        }
    }

    /**
     * Xử lý thêm mới danh mục
     */
    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = adminValidator.trim(request.getParameter("name"));
        String description = adminValidator.trim(request.getParameter("description"));

        if (name == null || name.isEmpty()) {
            writeJson(response, false, "Category name is required.");
            return;
        }

        if (name.length() > 100) {
            writeJson(response, false, "Category name must not exceed 100 characters.");
            return;
        }

        BlogCategoryDAO dao = new BlogCategoryDAO();
        if (dao.isCategoryNameExists(name, -1)) {
            writeJson(response, false, "Category name already exists.");
            return;
        }

        BlogCategory category = new BlogCategory(name, description);
        boolean ok = new BlogCategoryDAO().insertBlogCategory(category);
        writeJson(response, ok, ok ? null : "Failed to insert category.");
    }

    /**
     * Xử lý chỉnh sửa danh mục
     */
    private void handleEdit(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = adminValidator.parseInt(request.getParameter("id"), -1);
        String name = adminValidator.trim(request.getParameter("name"));
        String description = adminValidator.trim(request.getParameter("description"));

        if (id <= 0) {
            writeJson(response, false, "Invalid category ID.");
            return;
        }

        if (name == null || name.isEmpty()) {
            writeJson(response, false, "Category name is required.");
            return;
        }

        if (name.length() > 100) {
            writeJson(response, false, "Category name must not exceed 100 characters.");
            return;
        }

        BlogCategoryDAO dao = new BlogCategoryDAO();
        BlogCategory existing = dao.getBlogCategoryById(id);
        if (existing == null) {
            writeJson(response, false, "Category not found.");
            return;
        }

        if (new BlogCategoryDAO().isCategoryNameExists(name, id)) {
            writeJson(response, false, "Category name already exists.");
            return;
        }

        existing.setName(name);
        existing.setDescription(description);

        boolean ok = new BlogCategoryDAO().updateBlogCategory(existing);
        writeJson(response, ok, ok ? null : "Failed to update category.");
    }

    /**
     * Trả kết quả JSON về cho client fetch API
     */
    private void writeJson(HttpServletResponse response, boolean success, String error) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String json = String.format("{\"success\": %b, \"error\": \"%s\"}",
                success,
                error == null ? "" : error.replace("\"", "\\\""));
        response.getWriter().print(json);
    }
}
