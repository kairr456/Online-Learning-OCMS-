package com.controller.blogs;

import com.DAO.BlogDAO;
import com.entity.Account;
import com.entity.Blog;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Controller tổng hợp xử lý toàn bộ nghiệp vụ Blog cho người dùng:
 * - Xem danh sách blog cá nhân: /my-blogs
 * - Tạo bài viết mới: /blogs-new
 * - Chỉnh sửa bài viết: /blogs-edit
 * - Xóa bài viết: /blogs-delete
 */
@WebServlet(name = "BlogsUnifiedController", urlPatterns = {
    "/my-blogs",
    "/blogs-new",
    "/blogs-edit",
    "/blogs-delete"
})
public class BlogController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String servletPath = request.getServletPath();

        switch (servletPath) {
            case "/my-blogs":
                handleMyBlogs(request, response, account);
                break;
            case "/blogs-new":
                handleBlogNewGet(request, response);
                break;
            case "/blogs-edit":
                handleBlogEditGet(request, response, account);
                break;
            case "/blogs-delete":
                handleBlogDelete(request, response, account);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/my-blogs");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String servletPath = request.getServletPath();

        switch (servletPath) {
            case "/blogs-new":
                handleBlogNewPost(request, response, account);
                break;
            case "/blogs-edit":
                handleBlogEditPost(request, response, account);
                break;
            case "/blogs-delete":
                handleBlogDelete(request, response, account);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/my-blogs");
                break;
        }
    }

    // ==========================================
    // 1. DANH SÁCH BÀI VIẾT CỦA TÔI (/my-blogs)
    // ==========================================
    private void handleMyBlogs(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        List<Blog> myBlogs = new BlogDAO().getBlogsByAuthor(account.getId());
        Map<Integer, String> categories = new BlogDAO().getBlogCategories();

        request.setAttribute("myBlogs", myBlogs);
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/view/blogs/my-blogs.jsp").forward(request, response);
    }

    // ==========================================
    // 2. TẠO MỚI BÀI VIẾT (/blogs-new)
    // ==========================================
    private void handleBlogNewGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<Integer, String> categories = new BlogDAO().getBlogCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
    }

    private void handleBlogNewPost(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        String title = request.getParameter("title");
        String thumbnail = request.getParameter("thumbnail");
        String briefInfo = request.getParameter("briefInfo");
        String content = request.getParameter("content");
        String categoryIdStr = request.getParameter("categoryId");
        String status = request.getParameter("status");

        // Validation cơ bản
        if (title == null || title.trim().isEmpty()
                || content == null || content.trim().isEmpty()
                || briefInfo == null || briefInfo.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ Tiêu đề, Tóm tắt và Nội dung bài viết!");

            Blog draft = new Blog();
            draft.setTitle(title);
            draft.setThumbnail(thumbnail);
            draft.setBriefInfo(briefInfo);
            draft.setContent(content);
            draft.setStatus(status);
            request.setAttribute("draft", draft);

            BlogDAO blogDAO = new BlogDAO();
            request.setAttribute("categories", blogDAO.getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
            return;
        }

        int categoryId = 0;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        if (status == null || status.trim().isEmpty()) {
            status = "Active";
        }

        Blog newBlog = new Blog();
        newBlog.setTitle(title.trim());
        newBlog.setThumbnail(thumbnail != null ? thumbnail.trim() : "");
        newBlog.setBriefInfo(briefInfo.trim());
        newBlog.setContent(content.trim());
        newBlog.setCategoryId(categoryId);
        newBlog.setAuthor(account.getId());
        newBlog.setStatus(status);

        BlogDAO blogDAO = new BlogDAO();
        boolean success = blogDAO.insertBlog(newBlog);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?message=created");
        } else {
            request.setAttribute("error", "Đã xảy ra lỗi khi lưu bài viết vào cơ sở dữ liệu. Vui lòng thử lại!");
            request.setAttribute("draft", newBlog);
            request.setAttribute("categories", blogDAO.getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
        }
    }

    // ==========================================
    // 3. CHỈNH SỬA BÀI VIẾT (/blogs-edit)
    // ==========================================
    private void handleBlogEditGet(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/my-blogs");
            return;
        }

        int blogId = 0;
        try {
            blogId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/my-blogs");
            return;
        }

        Blog blog = new BlogDAO().getBlogById(blogId);
        if (blog == null) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=notfound");
            return;
        }

        // Kiểm tra quyền sở hữu (chỉ chính tác giả hoặc admin mới được sửa)
        if (blog.getAuthor() != account.getId() && account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=unauthorized");
            return;
        }

        Map<Integer, String> categories = new BlogDAO().getBlogCategories();
        request.setAttribute("blog", blog);
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
    }

    private void handleBlogEditPost(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String title = request.getParameter("title");
        String thumbnail = request.getParameter("thumbnail");
        String briefInfo = request.getParameter("briefInfo");
        String content = request.getParameter("content");
        String categoryIdStr = request.getParameter("categoryId");
        String status = request.getParameter("status");

        int blogId = 0;
        try {
            blogId = Integer.parseInt(idStr.trim());
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/my-blogs");
            return;
        }

        BlogDAO blogDAO = new BlogDAO();
        Blog existingBlog = blogDAO.getBlogById(blogId);

        if (existingBlog == null) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=notfound");
            return;
        }

        // Quyền sở hữu
        if (existingBlog.getAuthor() != account.getId() && account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=unauthorized");
            return;
        }

        // Validation
        if (title == null || title.trim().isEmpty()
                || content == null || content.trim().isEmpty()
                || briefInfo == null || briefInfo.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ Tiêu đề, Tóm tắt và Nội dung bài viết!");

            existingBlog.setTitle(title);
            existingBlog.setThumbnail(thumbnail);
            existingBlog.setBriefInfo(briefInfo);
            existingBlog.setContent(content);
            existingBlog.setStatus(status);
            request.setAttribute("blog", existingBlog);
            request.setAttribute("categories", new BlogDAO().getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
            return;
        }

        int categoryId = 0;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        if (status == null || status.trim().isEmpty()) {
            status = "Active";
        }

        existingBlog.setTitle(title.trim());
        existingBlog.setThumbnail(thumbnail != null ? thumbnail.trim() : "");
        existingBlog.setBriefInfo(briefInfo.trim());
        existingBlog.setContent(content.trim());
        existingBlog.setCategoryId(categoryId);
        existingBlog.setStatus(status);

        boolean success = new BlogDAO().updateBlog(existingBlog);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?message=updated");
        } else {
            request.setAttribute("error", "Đã xảy ra lỗi khi cập nhật bài viết. Vui lòng thử lại!");
            request.setAttribute("blog", existingBlog);
            request.setAttribute("categories", new BlogDAO().getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
        }
    }

    // ==========================================
    // 4. XÓA BÀI VIẾT (/blogs-delete)
    // ==========================================
    private void handleBlogDelete(HttpServletRequest request, HttpServletResponse response, Account account)
            throws IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/my-blogs");
            return;
        }

        int blogId = 0;
        try {
            blogId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/my-blogs");
            return;
        }

        BlogDAO blogDAO = new BlogDAO();
        Blog blog = blogDAO.getBlogById(blogId);

        if (blog != null) {
            // Chỉ tác giả hoặc admin mới có quyền xóa
            if (blog.getAuthor() == account.getId() || account.getRoleId() == 1) {
                boolean success = blogDAO.deleteBlog(blogId, blog.getAuthor());
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/my-blogs?message=deleted");
                    return;
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/my-blogs?error=unauthorized");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/my-blogs?error=delete_failed");
    }
}
