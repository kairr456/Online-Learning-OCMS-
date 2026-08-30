package com.controller.admin;

import com.DAO.CategoryDAO;
import com.entity.Account;
import com.entity.Category;
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
 * Controller Quản lý Danh mục Khóa học (Role: Admin)
 * URL: /admin/course-categories
 * - GET : Hiển thị bảng danh sách, tìm kiếm, phân trang, xử lý xóa mềm.
 * - POST: Thêm mới (action=add) / Cập nhật (action=edit) danh mục từ Modal (trả JSON).
 */
@WebServlet(name = "CourseCategoryController", urlPatterns = {"/admin/course-categories"})
public class CourseCategoryController extends HttpServlet {

    private static final int PAGE_SIZE = 5;
    private final CategoryDAO categoryDAO = new CategoryDAO();

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

        int totalRecords = categoryDAO.countCourseCategories(keyword);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<Category> categoryList = categoryDAO.searchCourseCategories(keyword, page, PAGE_SIZE);

        // 4. Truyền dữ liệu sang JSP
        request.setAttribute("categoryList", categoryList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("keyword", keyword);

        // Đặt nội dung hiển thị trong admin_layout.jsp
        request.setAttribute("contentPage", "course_categories.jsp");

        // Forward sang admin layout
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp").forward(request, response);
    }

    /**
     * Xử lý xóa danh mục khóa học (Xóa mềm và chặn xóa khi có khóa học)
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idRaw = request.getParameter("id");
        int id = adminValidator.parseInt(idRaw, -1);

        if (id > 0) {
            int courseCount = categoryDAO.countCoursesByCategoryId(id);
            if (courseCount > 0) {
                response.sendRedirect(request.getContextPath() + "/admin/course-categories?error=has_courses");
                return;
            }

            boolean ok = categoryDAO.deleteCourseCategory(id);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/course-categories?msg=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/course-categories?error=delete_failed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/course-categories?error=invalid_id");
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
     * Xử lý thêm mới danh mục khóa học
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

        if (description != null && description.length() > 500) {
            writeJson(response, false, "Category description must not exceed 500 characters.");
            return;
        }

        if (categoryDAO.isCategoryNameExists(name, -1)) {
            writeJson(response, false, "Category name already exists.");
            return;
        }

        Category cat = new Category();
        cat.setName(name);
        cat.setDescription(description);

        int newId = categoryDAO.insert(cat);
        if (newId > 0) {
            writeJson(response, true, "Course category created successfully!");
        } else {
            writeJson(response, false, "Failed to create course category.");
        }
    }

    /**
     * Xử lý cập nhật danh mục khóa học
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

        if (description != null && description.length() > 500) {
            writeJson(response, false, "Category description must not exceed 500 characters.");
            return;
        }

        if (categoryDAO.isCategoryNameExists(name, id)) {
            writeJson(response, false, "Category name already exists.");
            return;
        }

        Category cat = new Category();
        cat.setId(id);
        cat.setName(name);
        cat.setDescription(description);

        boolean ok = categoryDAO.update(cat);
        if (ok) {
            writeJson(response, true, "Course category updated successfully!");
        } else {
            writeJson(response, false, "Failed to update course category.");
        }
    }

    /**
     * Ghi kết quả phản hồi dạng JSON đơn giản
     */
    private void writeJson(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String json = String.format("{\"success\":%b,\"message\":\"%s\"}",
                success,
                message.replace("\"", "\\\""));
        response.getWriter().write(json);
    }
}
