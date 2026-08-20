package com.controller.blogs;

import com.DAO.AccountDAO;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Controller tổng hợp xử lý toàn bộ nghiệp vụ Blog cho người dùng:
 * - Xem danh sách blog công khai: /blogs
 * - Xem chi tiết bài viết: /blog-detail
 * - Xem danh sách blog cá nhân: /my-blogs
 * - Tạo bài viết mới: /blogs-new
 * - Chỉnh sửa bài viết: /blogs-edit
 * - Xóa bài viết: /blogs-delete
 */
@WebServlet(name = "BlogsUnifiedController", urlPatterns = {
    "/blogs",
    "/blog-detail",
    "/blog-details",
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

        String servletPath = request.getServletPath();

        // 1. Xem danh sách bài viết công khai
        if ("/blogs".equals(servletPath)) {
            handleBlogsList(request, response);
            return;
        }

        // 2. Xem chi tiết bài viết (Công khai, không yêu cầu bắt buộc đăng nhập)
        if ("/blog-detail".equals(servletPath) || "/blog-details".equals(servletPath)) {
            handleBlogDetail(request, response);
            return;
        }

        // 3. Kiểm tra đăng nhập cho các chức năng quản trị bài viết
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

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

    // ==========================================
    // 0. DANH SÁCH BÀI VIẾT CÔNG KHAI (/blogs)
    // ==========================================
    private void handleBlogsList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchKeyword = request.getParameter("search");
        searchKeyword = (searchKeyword != null) ? searchKeyword.trim() : "";

        String categoryFilterParam = request.getParameter("category");
        int categoryFilter = 0;
        if (categoryFilterParam != null && !categoryFilterParam.trim().isEmpty()) {
            try {
                categoryFilter = Integer.parseInt(categoryFilterParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        String sortParam = request.getParameter("sort");
        if (sortParam == null || sortParam.trim().isEmpty()) {
            sortParam = "newest";
        }

        Map<Integer, String> blogCategories = new BlogDAO().getBlogCategories();
        Map<Integer, String> authorNames = new AccountDAO().getAuthorNames();
        List<Blog> filteredBlogs = new BlogDAO().getFilteredBlogs(searchKeyword, categoryFilter, sortParam);
        List<Blog> recentBlogs = new BlogDAO().getRecentBlogs(4);

        int totalBlogs = filteredBlogs.size();
        int pageSize = 6;
        int totalPages = (int) Math.ceil((double) totalBlogs / pageSize);
        if (totalPages == 0) totalPages = 1;

        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam.trim());
                if (currentPage < 1) currentPage = 1;
                if (currentPage > totalPages) currentPage = totalPages;
            } catch (NumberFormatException ignored) {}
        }

        int startIndex = (currentPage - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalBlogs);
        List<Blog> pagedBlogs = new ArrayList<>();
        if (startIndex < totalBlogs) {
            pagedBlogs = filteredBlogs.subList(startIndex, endIndex);
        }

        request.setAttribute("blogCategories", blogCategories);
        request.setAttribute("authorNames", authorNames);
        request.setAttribute("pagedBlogs", pagedBlogs);
        request.setAttribute("recentBlogs", recentBlogs);
        request.setAttribute("totalBlogs", totalBlogs);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("searchKeyword", searchKeyword);
        request.setAttribute("categoryFilter", categoryFilter);
        request.setAttribute("sortParam", sortParam);

        request.getRequestDispatcher("/view/blogs/blogs.jsp").forward(request, response);
    }

    // ==========================================
    // 0.1 CHI TIẾT BÀI VIẾT (/blog-detail)
    // ==========================================
    private void handleBlogDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        int blogId = 0;
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                blogId = Integer.parseInt(idParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        Blog blog = (blogId > 0) ? new BlogDAO().getBlogById(blogId) : null;
        Map<Integer, String> blogCategories = new BlogDAO().getBlogCategories();
        Map<Integer, String> authorNames = new AccountDAO().getAuthorNames();
        List<Blog> relatedBlogs = (blog != null && blog.getCategoryId() > 0)
                ? new BlogDAO().getRelatedBlogs(blog.getCategoryId(), blog.getId(), 3)
                : new ArrayList<>();
        List<Blog> recentBlogs = new BlogDAO().getRecentBlogs(4);

        request.setAttribute("blog", blog);
        request.setAttribute("blogCategories", blogCategories);
        request.setAttribute("authorNames", authorNames);
        request.setAttribute("relatedBlogs", relatedBlogs);
        request.setAttribute("recentBlogs", recentBlogs);

        request.getRequestDispatcher("/view/blogs/blog-detail.jsp").forward(request, response);
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

        int totalCount = myBlogs != null ? myBlogs.size() : 0;
        int activeCount = 0;
        int inactiveCount = 0;
        if (myBlogs != null) {
            for (Blog b : myBlogs) {
                if ("Active".equalsIgnoreCase(b.getStatus())) {
                    activeCount++;
                } else {
                    inactiveCount++;
                }
            }
        }

        request.setAttribute("myBlogs", myBlogs);
        request.setAttribute("categories", categories);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("inactiveCount", inactiveCount);

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
        Blog newBlog = extractAndValidateBlogForm(request);

        if (newBlog == null) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ Tiêu đề, Tóm tắt và Nội dung bài viết!");
            request.setAttribute("draft", buildDraftFromRequest(request));
            request.setAttribute("categories", new BlogDAO().getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
            return;
        }

        newBlog.setAuthor(account.getId());
        boolean success = new BlogDAO().insertBlog(newBlog);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?message=created");
        } else {
            request.setAttribute("error", "Đã xảy ra lỗi khi lưu bài viết vào cơ sở dữ liệu. Vui lòng thử lại!");
            request.setAttribute("draft", newBlog);
            request.setAttribute("categories", new BlogDAO().getBlogCategories());
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
        int blogId = 0;
        try {
            blogId = Integer.parseInt(idStr.trim());
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/my-blogs");
            return;
        }

        Blog existingBlog = new BlogDAO().getBlogById(blogId);
        if (existingBlog == null) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=notfound");
            return;
        }

        // Quyền sở hữu
        if (existingBlog.getAuthor() != account.getId() && account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=unauthorized");
            return;
        }

        Blog updatedData = extractAndValidateBlogForm(request);
        if (updatedData == null) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ Tiêu đề, Tóm tắt và Nội dung bài viết!");
            request.setAttribute("blog", buildDraftFromRequest(request));
            request.setAttribute("categories", new BlogDAO().getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
            return;
        }

        existingBlog.setTitle(updatedData.getTitle());
        existingBlog.setThumbnail(updatedData.getThumbnail());
        existingBlog.setBriefInfo(updatedData.getBriefInfo());
        existingBlog.setContent(updatedData.getContent());
        existingBlog.setCategoryId(updatedData.getCategoryId());
        existingBlog.setStatus(updatedData.getStatus());

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

        Blog blog = new BlogDAO().getBlogById(blogId);
        if (blog != null) {
            // Chỉ tác giả hoặc admin mới có quyền xóa
            if (blog.getAuthor() == account.getId() || account.getRoleId() == 1) {
                boolean success = new BlogDAO().deleteBlog(blogId, blog.getAuthor());
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

    // ==========================================
    // HELPER METHODS
    // ==========================================
    private Blog extractAndValidateBlogForm(HttpServletRequest request) {
        String title = request.getParameter("title");
        String thumbnail = request.getParameter("thumbnail");
        String briefInfo = request.getParameter("briefInfo");
        String content = request.getParameter("content");
        String categoryIdStr = request.getParameter("categoryId");
        String status = request.getParameter("status");

        if (title == null || title.trim().isEmpty()
                || content == null || content.trim().isEmpty()
                || briefInfo == null || briefInfo.trim().isEmpty()) {
            return null;
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

        Blog blog = new Blog();
        blog.setTitle(title.trim());
        blog.setThumbnail(thumbnail != null ? thumbnail.trim() : "");
        blog.setBriefInfo(briefInfo.trim());
        blog.setContent(content.trim());
        blog.setCategoryId(categoryId);
        blog.setStatus(status);
        return blog;
    }

    private Blog buildDraftFromRequest(HttpServletRequest request) {
        String idStr = request.getParameter("id");
        int blogId = 0;
        if (idParamOrStr(idStr)) {
            try {
                blogId = Integer.parseInt(idStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        String categoryIdStr = request.getParameter("categoryId");
        int categoryId = 0;
        if (idParamOrStr(categoryIdStr)) {
            try {
                categoryId = Integer.parseInt(categoryIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        Blog draft = new Blog();
        draft.setId(blogId);
        draft.setTitle(request.getParameter("title"));
        draft.setThumbnail(request.getParameter("thumbnail"));
        draft.setBriefInfo(request.getParameter("briefInfo"));
        draft.setContent(request.getParameter("content"));
        draft.setCategoryId(categoryId);
        draft.setStatus(request.getParameter("status"));
        return draft;
    }

    private boolean idParamOrStr(String s) {
        return s != null && !s.trim().isEmpty();
    }
}
