package com.controller.blogs;

import com.DAO.AccountDAO;
import com.DAO.BlogDAO;
import com.entity.Account;
import com.entity.Blog;

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
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
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
        if (blog == null) {
            response.sendRedirect(request.getContextPath() + "/blogs?error=notfound");
            return;
        }

        // Bài viết chưa duyệt (Inactive) chỉ cho phép tác giả hoặc Admin xem
        if (!"Active".equalsIgnoreCase(blog.getStatus())) {
            Account currentAcc = (Account) request.getSession().getAttribute("account");
            boolean canView = (currentAcc != null && (currentAcc.getRoleId() == 1 || currentAcc.getId() == blog.getAuthor()));
            if (!canView) {
                response.sendRedirect(request.getContextPath() + "/blogs");
                return;
            }
        }

        Map<Integer, String> blogCategories = new BlogDAO().getBlogCategories();
        Map<Integer, String> authorNames = new AccountDAO().getAuthorNames();
        List<Blog> relatedBlogs = (blog.getCategoryId() > 0)
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
        int draftCount = 0;
        int rejectedCount = 0;
        if (myBlogs != null) {
            for (Blog b : myBlogs) {
                if ("Active".equalsIgnoreCase(b.getStatus())) {
                    activeCount++;
                } else if ("Draft".equalsIgnoreCase(b.getStatus())) {
                    draftCount++;
                } else if ("Rejected".equalsIgnoreCase(b.getStatus()) || "Reject".equalsIgnoreCase(b.getStatus())) {
                    rejectedCount++;
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
        request.setAttribute("draftCount", draftCount);
        request.setAttribute("rejectedCount", rejectedCount);

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
            Blog draft = buildDraftFromRequest(request);
            request.setAttribute("draft", draft);
            request.setAttribute("blog", draft);
            request.setAttribute("categories", new BlogDAO().getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
            return;
        }

        newBlog.setAuthor(account.getId());

        String statusParam = getStringParam(request, "status");
        if (account.getRoleId() != 1) {
            if ("Draft".equalsIgnoreCase(statusParam)) {
                newBlog.setStatus("Draft");
            } else {
                newBlog.setStatus("Inactive");
            }
        } else {
            newBlog.setStatus(!statusParam.isEmpty() ? statusParam : "Active");
        }

        boolean success = new BlogDAO().insertBlog(newBlog);

        if (success) {
            String msg = "created";
            if ("Draft".equalsIgnoreCase(newBlog.getStatus())) {
                msg = "draft_saved";
            } else if ("Inactive".equalsIgnoreCase(newBlog.getStatus())) {
                msg = "submitted";
            }
            response.sendRedirect(request.getContextPath() + "/my-blogs?message=" + msg);
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

        // Bài viết đã được duyệt (Active) hoặc đang chờ duyệt (Inactive) thì tác giả không được phép sửa
        if ("Active".equalsIgnoreCase(blog.getStatus()) && account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=already_approved");
            return;
        }
        if ("Inactive".equalsIgnoreCase(blog.getStatus()) && account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=pending_approval");
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

        // Bài viết đã được duyệt (Active) hoặc đang chờ duyệt (Inactive) thì tác giả không được phép sửa
        if ("Active".equalsIgnoreCase(existingBlog.getStatus()) && account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=already_approved");
            return;
        }
        if ("Inactive".equalsIgnoreCase(existingBlog.getStatus()) && account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/my-blogs?error=pending_approval");
            return;
        }

        Blog updatedData = extractAndValidateBlogForm(request);
        if (updatedData == null) {
            Blog draft = buildDraftFromRequest(request);
            request.setAttribute("draft", draft);
            request.setAttribute("blog", draft);
            request.setAttribute("categories", new BlogDAO().getBlogCategories());
            request.getRequestDispatcher("/view/blogs/blog-form.jsp").forward(request, response);
            return;
        }

        existingBlog.setTitle(updatedData.getTitle());
        existingBlog.setThumbnail(updatedData.getThumbnail());
        existingBlog.setBriefInfo(updatedData.getBriefInfo());
        existingBlog.setContent(updatedData.getContent());
        existingBlog.setCategoryId(updatedData.getCategoryId());

        String statusParam = getStringParam(request, "status");

        if (account.getRoleId() != 1) {
            // Tác giả sửa bài viết (bao gồm cả bài viết bị từ chối):
            // - Nếu bấm "Lưu bài viết" (Draft) -> Lưu thành Draft
            // - Nếu bấm "Gửi bài viết" / gửi lại -> Chuyển thành Inactive (Chờ phê duyệt) để Admin duyệt lại
            // - Đồng thời xóa lý do từ chối cũ
            existingBlog.setRejectReason(null);
            if ("Draft".equalsIgnoreCase(statusParam)) {
                existingBlog.setStatus("Draft");
            } else {
                existingBlog.setStatus("Inactive");
            }
        } else {
            existingBlog.setStatus(!statusParam.isEmpty() ? statusParam : updatedData.getStatus());
        }

        boolean success = new BlogDAO().updateBlog(existingBlog);

        if (success) {
            String msg = "updated";
            if ("Draft".equalsIgnoreCase(existingBlog.getStatus())) {
                msg = "draft_saved";
            } else if ("Inactive".equalsIgnoreCase(existingBlog.getStatus())) {
                msg = "submitted";
            }
            response.sendRedirect(request.getContextPath() + "/my-blogs?message=" + msg);
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
            // Bài viết đang trong trạng thái Chờ phê duyệt (Inactive) không cho phép xóa
            if ("Inactive".equalsIgnoreCase(blog.getStatus()) && account.getRoleId() != 1) {
                response.sendRedirect(request.getContextPath() + "/my-blogs?error=pending_approval_delete");
                return;
            }

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
    private String saveThumbnailFile(HttpServletRequest request) {
        try {
            Part filePart = request.getPart("thumbnailFile");
            if (filePart != null && filePart.getSize() > 0) {
                if (filePart.getSize() > 1024 * 1024) {
                    throw new IllegalArgumentException("Dung lượng ảnh Thumbnail không được vượt quá 1MB!");
                }
                String submittedFileName = filePart.getSubmittedFileName();
                if (submittedFileName != null && !submittedFileName.trim().isEmpty()) {
                    String originalName = new File(submittedFileName).getName();
                    String cleanName = originalName.replaceAll("[^a-zA-Z0-9._-]", "_");
                    String fileName = System.currentTimeMillis() + "_" + cleanName;
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
                        System.out.println("[BlogThumbnail] Warning: Could not copy blog thumbnail to source directory: " + ex.getMessage());
                    }

                    return request.getContextPath() + "/assets/img/" + fileName;
                }
            }
        } catch (Exception ex) {
            System.out.println("[BlogThumbnail] Exception saving thumbnail file: " + ex.getMessage());
        }

        // Nếu không upload file mới, kiểm tra ảnh cũ khi sửa
        String existingThumbnail = getStringParam(request, "existingThumbnail");
        if (!existingThumbnail.isEmpty()) {
            return existingThumbnail;
        }
        String thumbnail = getStringParam(request, "thumbnail");
        if (!thumbnail.isEmpty()) {
            return thumbnail;
        }
        return "";
    }

    private String getStringParam(HttpServletRequest request, String name) {
        try {
            String val = request.getParameter(name);
            if (val != null && !val.trim().isEmpty()) {
                return val.trim();
            }
        } catch (Exception ignored) {}

        // Fallback đọc trực tiếp từ Part nếu multipart request chưa được container giải mã qua getParameter
        try {
            Part part = request.getPart(name);
            if (part != null && part.getSize() > 0) {
                try (java.io.InputStream is = part.getInputStream();
                     java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(is, java.nio.charset.StandardCharsets.UTF_8))) {
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        if (sb.length() > 0) sb.append("\n");
                        sb.append(line);
                    }
                    return sb.toString().trim();
                }
            }
        } catch (Exception ignored) {}

        return "";
    }

    private Blog extractAndValidateBlogForm(HttpServletRequest request) {
        String title = getStringParam(request, "title");
        String briefInfo = getStringParam(request, "briefInfo");
        String content = getStringParam(request, "content");
        if (content.isEmpty()) {
            content = getStringParam(request, "mainContent");
        }
        String categoryIdStr = getStringParam(request, "categoryId");
        String status = getStringParam(request, "status");
        String thumbnail = saveThumbnailFile(request);

        int categoryId = 0;
        if (!categoryIdStr.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (NumberFormatException ignored) {}
        }

        boolean hasError = false;
        if (title.isEmpty()) {
            request.setAttribute("errorTitle", "Vui lòng nhập Tiêu đề bài viết!");
            hasError = true;
        } else if (title.length() > 255) {
            request.setAttribute("errorTitle", "Tiêu đề bài viết không được vượt quá 255 ký tự!");
            hasError = true;
        }
        if (categoryId <= 0) {
            request.setAttribute("errorCategory", "Vui lòng chọn Danh mục bài viết!");
            hasError = true;
        }
        if (briefInfo.isEmpty()) {
            request.setAttribute("errorBrief", "Vui lòng nhập Mô tả tóm tắt của bài viết!");
            hasError = true;
        } else if (briefInfo.length() > 500) {
            request.setAttribute("errorBrief", "Mô tả tóm tắt bài viết không được vượt quá 500 ký tự!");
            hasError = true;
        }
        if (content.isEmpty()) {
            request.setAttribute("errorContent", "Vui lòng nhập Nội dung chi tiết của bài viết!");
            hasError = true;
        }

        if (hasError) {
            return null;
        }

        if (status.isEmpty()) {
            status = "Draft";
        }

        Blog blog = new Blog();
        blog.setTitle(title);
        blog.setThumbnail(thumbnail);
        blog.setBriefInfo(briefInfo);
        blog.setContent(content);
        blog.setCategoryId(categoryId);
        blog.setStatus(status);
        return blog;
    }

    private Blog buildDraftFromRequest(HttpServletRequest request) {
        String idStr = getStringParam(request, "id");
        int blogId = 0;
        if (!idStr.isEmpty()) {
            try {
                blogId = Integer.parseInt(idStr);
            } catch (NumberFormatException ignored) {}
        }

        String categoryIdStr = getStringParam(request, "categoryId");
        int categoryId = 0;
        if (!categoryIdStr.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (NumberFormatException ignored) {}
        }

        String content = getStringParam(request, "content");
        if (content.isEmpty()) {
            content = getStringParam(request, "mainContent");
        }

        String thumb = saveThumbnailFile(request);

        Blog draft = new Blog();
        draft.setId(blogId);
        draft.setTitle(getStringParam(request, "title"));
        draft.setThumbnail(thumb);
        draft.setBriefInfo(getStringParam(request, "briefInfo"));
        draft.setContent(content);
        draft.setCategoryId(categoryId);
        draft.setStatus(getStringParam(request, "status"));
        return draft;
    }

    private boolean idParamOrStr(String s) {
        return s != null && !s.trim().isEmpty();
    }

    private boolean safeEquals(String a, String b) {
        if (a == null) a = "";
        if (b == null) b = "";
        return a.trim().equals(b.trim());
    }
}
