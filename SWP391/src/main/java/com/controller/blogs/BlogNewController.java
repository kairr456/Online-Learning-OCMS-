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

@WebServlet(name = "BlogNewController", urlPatterns = {"/blogs-new"})
public class BlogNewController extends HttpServlet {

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

        // Lấy danh mục blog đổ ra dropdown select
        BlogDAO blogDAO = new BlogDAO();
        Map<Integer, String> categories = blogDAO.getBlogCategories();
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

        String title = request.getParameter("title");
        String thumbnail = request.getParameter("thumbnail");
        String briefInfo = request.getParameter("briefInfo");
        String content = request.getParameter("content");
        String categoryIdStr = request.getParameter("categoryId");
        String status = request.getParameter("status");

        // Validation cơ bản
        if (title == null || title.trim().isEmpty() ||
            content == null || content.trim().isEmpty() ||
            briefInfo == null || briefInfo.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ Tiêu đề, Tóm tắt và Nội dung bài viết!");
            
            // Giữ lại dữ liệu người dùng vừa nhập
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
            } catch (NumberFormatException ignored) {}
        }

        int authorId = account.getId();

        if (status == null || status.trim().isEmpty()) {
            status = "Active";
        }

        Blog newBlog = new Blog();
        newBlog.setTitle(title.trim());
        newBlog.setThumbnail(thumbnail != null ? thumbnail.trim() : "");
        newBlog.setBriefInfo(briefInfo.trim());
        newBlog.setContent(content.trim());
        newBlog.setCategoryId(categoryId);
        newBlog.setAuthor(authorId);
        newBlog.setStatus(status);

        BlogDAO blogDAO = new BlogDAO();
        boolean success = blogDAO.insertBlog(newBlog);

        if (success) {
            // Chuyển hướng về trang bài viết cá nhân
            response.sendRedirect(request.getContextPath() + "/my-blogs?message=created");
        } else {
            request.setAttribute("error", "Đã xảy ra lỗi khi lưu bài viết vào cơ sở dữ liệu. Vui lòng thử lại!");
            request.setAttribute("draft", newBlog);
            request.setAttribute("categories", blogDAO.getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
        }
    }
}
