<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Blog" %>
<%@ page import="com.entity.Account" %>
<%@ page import="com.DAO.DBContext" %>
<%@ page import="com.DAO.AccountDAO" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    String ctx = request.getContextPath();
    Account detailUser = (Account) session.getAttribute("account");
    String idParam = request.getParameter("id");
    int blogId = 0;
    if (idParam != null && !idParam.trim().isEmpty()) {
        try {
            blogId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException ignored) {}
    }

    Blog blog = null;
    Map<Integer, String> blogCategories = new HashMap<>();
    Map<Integer, String> authorNames = new AccountDAO().getAuthorNames();
    List<Blog> relatedBlogs = new ArrayList<>();
    List<Blog> recentBlogs = new ArrayList<>();

    DBContext db = new DBContext();
    try {
        if (db.getConnection() != null) {
            // 1. Lấy thông tin danh mục
            PreparedStatement psCat = db.getConnection().prepareStatement("SELECT id, name FROM blog_category ORDER BY id ASC");
            ResultSet rsCat = psCat.executeQuery();
            while (rsCat.next()) {
                blogCategories.put(rsCat.getInt("id"), rsCat.getString("name"));
            }

            // 2. Lấy chi tiết bài viết theo ID
            if (blogId > 0) {
                PreparedStatement ps = db.getConnection().prepareStatement("SELECT * FROM blog WHERE id = ?");
                ps.setInt(1, blogId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    blog = new Blog(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getString("thumbnail"),
                        rs.getString("brief_info"),
                        rs.getString("content"),
                        rs.getInt("category_id"),
                        rs.getInt("author"),
                        rs.getTimestamp("updated_date"),
                        rs.getTimestamp("created_date"),
                        rs.getString("status")
                    );
                }
            }

            // 3. Lấy bài viết liên quan (cùng danh mục)
            if (blog != null && blog.getCategoryId() > 0) {
                PreparedStatement psRel = db.getConnection().prepareStatement(
                    "SELECT * FROM blog WHERE category_id = ? AND id != ? AND status = 'Active' ORDER BY created_date DESC LIMIT 3"
                );
                psRel.setInt(1, blog.getCategoryId());
                psRel.setInt(2, blog.getId());
                ResultSet rsRel = psRel.executeQuery();
                while (rsRel.next()) {
                    relatedBlogs.add(new Blog(
                        rsRel.getInt("id"),
                        rsRel.getString("title"),
                        rsRel.getString("thumbnail"),
                        rsRel.getString("brief_info"),
                        rsRel.getString("content"),
                        rsRel.getInt("category_id"),
                        rsRel.getInt("author"),
                        rsRel.getTimestamp("updated_date"),
                        rsRel.getTimestamp("created_date"),
                        rsRel.getString("status")
                    ));
                }
            }

            // 4. Lấy 4 bài viết mới nhất cho Sidebar
            PreparedStatement psRec = db.getConnection().prepareStatement(
                "SELECT * FROM blog WHERE status = 'Active' ORDER BY created_date DESC LIMIT 4"
            );
            ResultSet rsRec = psRec.executeQuery();
            while (rsRec.next()) {
                recentBlogs.add(new Blog(
                    rsRec.getInt("id"),
                    rsRec.getString("title"),
                    rsRec.getString("thumbnail"),
                    rsRec.getString("brief_info"),
                    rsRec.getString("content"),
                    rsRec.getInt("category_id"),
                    rsRec.getInt("author"),
                    rsRec.getTimestamp("updated_date"),
                    rsRec.getTimestamp("created_date"),
                    rsRec.getString("status")
                ));
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        db.closeResources();
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= (blog != null && blog.getTitle() != null) ? blog.getTitle() : "Chi tiết bài viết" %> · OCMS</title>
    <!-- FontAwesome & Base CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/blog/blog-detail.css">
</head>
<body>

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Breadcrumbs -->
    <div class="detail-breadcrumb-bar">
        <div class="detail-breadcrumb">
            <a href="<%= ctx %>/"><i class="fa-solid fa-house me-1"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
            <a href="<%= ctx %>/blogs">Danh sách bài viết</a>
            <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
            <span class="current"><%= blog != null ? blog.getTitle() : "Bài viết" %></span>
        </div>
    </div>

    <!-- Main Container -->
    <div class="detail-container">
        
        <% if (blog == null) { %>
            <div class="detail-main notfound-box">
                <i class="fa-regular fa-file-circle-question"></i>
                <h2>Không tìm thấy bài viết</h2>
                <p style="color:var(--text-muted); margin-bottom: 24px;">Bài viết bạn đang tìm kiếm có thể đã bị xóa hoặc không tồn tại.</p>
                <a href="<%= ctx %>/blogs" class="btn-back-blogs">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại trang danh sách Blog
                </a>
            </div>
        <% } else { 
            String catName = blogCategories.getOrDefault(blog.getCategoryId(), "Tin tức chung");
            String authorName = authorNames.getOrDefault(blog.getAuthor(), "Tác giả OCMS");
            String formattedDate = blog.getCreatedDate() != null ? dateFormat.format(blog.getCreatedDate()) : "Gần đây";
        %>
            <article class="detail-main">
                <span class="article-cat-badge"><i class="fa-solid fa-tag me-1"></i> <%= catName %></span>
                
                <h1 class="article-title"><%= blog.getTitle() %></h1>

                <div class="article-meta">
                    <span><i class="fa-regular fa-user"></i> <strong><%= authorName %></strong></span>
                    <span><i class="fa-regular fa-calendar"></i> <%= formattedDate %></span>
                    <% if (blog.getStatus() != null && !blog.getStatus().isEmpty()) { %>
                        <span><i class="fa-solid fa-circle-check"></i> <%= blog.getStatus() %></span>
                    <% } %>
                </div>

                <!-- Thumbnail -->
                <% if (blog.getThumbnail() != null && !blog.getThumbnail().trim().isEmpty()) { %>
                    <div class="article-thumbnail-wrap">
                        <img src="<%= blog.getThumbnail() %>" alt="<%= blog.getTitle() %>" onerror="this.parentElement.style.display='none';">
                    </div>
                <% } %>

                <!-- Tóm tắt -->
                <% if (blog.getBriefInfo() != null && !blog.getBriefInfo().trim().isEmpty()) { %>
                    <div class="article-lead">
                        <%= blog.getBriefInfo() %>
                    </div>
                <% } %>

                <!-- Nội dung chi tiết -->
                <div class="article-content">
                    <%= blog.getContent() != null ? blog.getContent() : "" %>
                </div>

                <!-- Điều hướng cuối bài -->
                <div class="article-footer-nav">
                    <a href="<%= ctx %>/blogs" class="btn-back-blogs">
                        <i class="fa-solid fa-arrow-left"></i> Xem tất cả bài viết khác
                    </a>
                    <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
                        <% if (detailUser != null && (detailUser.getId() == blog.getAuthor() || detailUser.getRoleId() == 1)) { %>
                            <a href="<%= ctx %>/blogs-edit?id=<%= blog.getId() %>" class="btn-back-blogs" style="background:var(--accent-amber); color:var(--primary-navy); font-weight:700;">
                                <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa bài này
                            </a>
                        <% } %>
                        <a href="<%= ctx %>/my-blogs" class="btn-back-blogs" style="background:var(--primary-navy); color:#fff;">
                            <i class="fa-solid fa-feather-pointed"></i> Quản lý bài viết của tôi
                        </a>
                    </div>
                </div>

                <!-- Bài viết liên quan -->
                <% if (!relatedBlogs.isEmpty()) { %>
                    <div class="related-section">
                        <h3 class="related-section__title">
                            <i class="fa-solid fa-layer-group" style="color:var(--accent-amber);"></i> Bài viết cùng chủ đề
                        </h3>
                        <div class="related-grid">
                            <% for (Blog rel : relatedBlogs) { 
                                String relDate = rel.getCreatedDate() != null ? dateFormat.format(rel.getCreatedDate()) : "";
                            %>
                            <a href="<%= ctx %>/view/blogs/blog-detail.jsp?id=<%= rel.getId() %>" class="related-card">
                                <div class="related-card__thumb">
                                    <% if (rel.getThumbnail() != null && !rel.getThumbnail().trim().isEmpty()) { %>
                                        <img src="<%= rel.getThumbnail() %>" alt="<%= rel.getTitle() %>" onerror="this.onerror=null; this.src='<%= ctx %>/assets/img/blog-default.jpg';">
                                    <% } else { %>
                                        <div style="width:100%;height:100%;background:#16273F;display:flex;align-items:center;justify-content:center;color:#D8A24A;font-size:20px;">
                                            <i class="fa-regular fa-newspaper"></i>
                                        </div>
                                    <% } %>
                                </div>
                                <div class="related-card__body">
                                    <h4 class="related-card__title"><%= rel.getTitle() %></h4>
                                    <span class="related-card__date"><i class="fa-regular fa-calendar me-1"></i><%= relDate %></span>
                                </div>
                            </a>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </article>
        <% } %>

        <!-- Sidebar -->
        <aside class="detail-sidebar">
            <!-- Bài viết mới nhất -->
            <% if (!recentBlogs.isEmpty()) { %>
            <div class="detail-widget">
                <h4 class="detail-widget__title">Bài viết mới nhất</h4>
                <div class="detail-recent-list">
                    <% for (Blog rb : recentBlogs) { 
                        String rbDate = rb.getCreatedDate() != null ? dateFormat.format(rb.getCreatedDate()) : "";
                    %>
                    <a href="<%= ctx %>/view/blogs/blog-detail.jsp?id=<%= rb.getId() %>" class="detail-recent-item">
                        <div class="detail-recent-item__thumb">
                            <% if (rb.getThumbnail() != null && !rb.getThumbnail().trim().isEmpty()) { %>
                                <img src="<%= rb.getThumbnail() %>" alt="<%= rb.getTitle() %>" onerror="this.onerror=null; this.parentElement.innerHTML='<div style=\'width:100%;height:100%;background:#16273F;display:flex;align-items:center;justify-content:center;color:#D8A24A;font-size:16px;\'><i class=\'fa-regular fa-newspaper\'></i></div>';">
                            <% } else { %>
                                <div style="width:100%;height:100%;background:#16273F;display:flex;align-items:center;justify-content:center;color:#D8A24A;font-size:16px;">
                                    <i class="fa-regular fa-newspaper"></i>
                                </div>
                            <% } %>
                        </div>
                        <div class="detail-recent-item__info">
                            <h5 class="detail-recent-item__title"><%= rb.getTitle() %></h5>
                            <span class="detail-recent-item__date"><i class="fa-regular fa-calendar me-1"></i><%= rbDate %></span>
                        </div>
                    </a>
                    <% } %>
                </div>
            </div>
            <% } %>
        </aside>

    </div>

    <!-- Footer chung -->
    <jsp:include page="/view/common/footer.jsp" />

</body>
</html>
