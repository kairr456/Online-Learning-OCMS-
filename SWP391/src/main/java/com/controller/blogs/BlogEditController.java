package com.controller.blogs;

import com.DAO.BlogDAO;
import com.entity.Account;
import com.entity.Blog;
import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "BlogEditController", urlPatterns = {"/blogs-edit"})
public class BlogEditController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

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
        if (title == null || title.trim().isEmpty() ||
            content == null || content.trim().isEmpty() ||
            briefInfo == null || briefInfo.trim().isEmpty()) {

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
            } catch (NumberFormatException ignored) {}
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
            request.setAttribute("error", "Đã xảy ra lỗi khi cập nhật bài viết vào cơ sở dữ liệu!");
            request.setAttribute("blog", existingBlog);
            request.setAttribute("categories", new BlogDAO().getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
        }
    }
}
