<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Blog" %>
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

    <style>
        :root {
            --primary-navy: #0F1E33;
            --secondary-navy: #16273F;
            --accent-amber: #D8A24A;
            --accent-amber-hover: #b9812e;
            --surface-bg: #F6F7FA;
            --card-bg: #FFFFFF;
            --text-dark: #0F1E33;
            --text-muted: #5B6B82;
            --border-color: #E3E7EE;
            --radius-md: 12px;
            --radius-lg: 16px;
            --shadow-subtle: 0 4px 20px rgba(15, 30, 51, 0.05);
            --shadow-hover: 0 12px 30px rgba(15, 30, 51, 0.12);
        }

        body {
            background-color: var(--surface-bg) !important;
            color: var(--text-dark) !important;
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            color-scheme: light !important;
        }

        /* Breadcrumb Navigation */
        .detail-breadcrumb-bar {
            background: #ffffff;
            border-bottom: 1px solid var(--border-color);
            padding: 14px 0;
        }
        .detail-breadcrumb {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13.5px;
            color: var(--text-muted);
            flex-wrap: wrap;
        }
        .detail-breadcrumb a {
            color: var(--text-dark);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.15s;
        }
        .detail-breadcrumb a:hover {
            color: var(--accent-amber-hover);
        }
        .detail-breadcrumb span.current {
            color: var(--accent-amber-hover);
            font-weight: 600;
            max-width: 400px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* Container Layout */
        .detail-container {
            max-width: 1200px;
            margin: 36px auto 60px;
            padding: 0 20px;
            display: flex;
            gap: 32px;
            align-items: flex-start;
        }

        /* Main Article */
        .detail-main {
            flex: 1;
            min-width: 0;
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            padding: 40px;
            box-shadow: var(--shadow-subtle);
        }

        .article-cat-badge {
            display: inline-block;
            background: rgba(216, 162, 74, 0.15);
            color: var(--accent-amber-hover);
            border: 1px solid rgba(216, 162, 74, 0.4);
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 16px;
        }

        .article-title {
            font-family: var(--font-display, 'Space Grotesk', sans-serif);
            font-size: 32px;
            font-weight: 700;
            line-height: 1.35;
            color: var(--text-dark) !important;
            margin: 0 0 18px;
        }

        .article-meta {
            display: flex;
            align-items: center;
            gap: 20px;
            font-size: 13.5px;
            color: var(--text-muted);
            padding-bottom: 24px;
            margin-bottom: 24px;
            border-bottom: 1px solid var(--border-color);
            flex-wrap: wrap;
        }
        .article-meta span {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .article-meta i {
            color: var(--accent-amber);
        }

        /* Thumbnail */
        .article-thumbnail-wrap {
            width: 100%;
            max-height: 440px;
            border-radius: var(--radius-md);
            overflow: hidden;
            margin-bottom: 30px;
            background: #e9ecef;
        }
        .article-thumbnail-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        /* Lead brief info */
        .article-lead {
            font-size: 16px;
            font-weight: 500;
            line-height: 1.7;
            color: var(--primary-navy);
            background: var(--surface-bg);
            border-left: 4px solid var(--accent-amber);
            padding: 16px 20px;
            border-radius: 0 8px 8px 0;
            margin-bottom: 30px;
        }

        /* Body Content */
        .article-content {
            font-size: 15.5px;
            line-height: 1.8;
            color: #2D3748;
        }
        .article-content p {
            margin-bottom: 1.4em;
        }
        .article-content img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 16px 0;
        }

        /* Bottom Share / Navigation */
        .article-footer-nav {
            margin-top: 40px;
            padding-top: 24px;
            border-top: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
        }
        .btn-back-blogs {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 18px;
            border-radius: 8px;
            background: var(--surface-bg);
            color: var(--primary-navy);
            border: 1px solid var(--border-color);
            font-weight: 600;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-back-blogs:hover {
            background: var(--primary-navy);
            color: #ffffff;
        }

        /* Related Blogs Section */
        .related-section {
            margin-top: 48px;
            padding-top: 36px;
            border-top: 2px dashed var(--border-color);
        }
        .related-section__title {
            font-size: 20px;
            font-weight: 700;
            color: var(--primary-navy);
            margin: 0 0 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .related-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }
        .related-card {
            background: var(--surface-bg);
            border-radius: var(--radius-md);
            border: 1px solid var(--border-color);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .related-card:hover {
            transform: translateY(-4px);
            border-color: var(--accent-amber);
            box-shadow: var(--shadow-subtle);
        }
        .related-card__thumb {
            width: 100%;
            height: 120px;
            background: #e9ecef;
            overflow: hidden;
        }
        .related-card__thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .related-card__body {
            padding: 14px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }
        .related-card__title {
            font-size: 13.5px;
            font-weight: 700;
            color: var(--text-dark);
            margin: 0 0 8px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            line-height: 1.35;
        }
        .related-card__date {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: auto;
        }

        /* Sidebar */
        .detail-sidebar {
            width: 340px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            gap: 24px;
        }
        .detail-widget {
            background: var(--card-bg);
            border-radius: var(--radius-md);
            padding: 22px;
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-subtle);
        }
        .detail-widget__title {
            font-size: 17px;
            font-weight: 700;
            color: var(--primary-navy);
            margin: 0 0 16px;
            position: relative;
            padding-bottom: 10px;
        }
        .detail-widget__title::after {
            content: '';
            position: absolute;
            left: 0;
            bottom: 0;
            width: 36px;
            height: 3px;
            background: var(--accent-amber);
            border-radius: 2px;
        }

        /* Recent List */
        .detail-recent-list {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .detail-recent-item {
            display: flex;
            gap: 12px;
            align-items: center;
            text-decoration: none;
        }
        .detail-recent-item__thumb {
            width: 65px;
            height: 65px;
            border-radius: 8px;
            overflow: hidden;
            flex-shrink: 0;
            background: #e9ecef;
        }
        .detail-recent-item__thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .detail-recent-item__info {
            flex: 1;
            min-width: 0;
        }
        .detail-recent-item__title {
            font-size: 13.5px;
            font-weight: 600;
            color: var(--text-dark);
            margin: 0 0 4px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            line-height: 1.35;
            transition: color 0.2s ease;
        }
        .detail-recent-item:hover .detail-recent-item__title {
            color: var(--accent-amber-hover);
        }
        .detail-recent-item__date {
            font-size: 12px;
            color: var(--text-muted);
        }

        /* Categories List */
        .detail-cat-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .detail-cat-list li a {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 9px 12px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            color: var(--text-dark);
            text-decoration: none;
            background: var(--surface-bg);
            transition: all 0.2s ease;
        }
        .detail-cat-list li a:hover {
            background: var(--primary-navy);
            color: #ffffff;
            padding-left: 16px;
        }

        /* Not Found Box */
        .notfound-box {
            text-align: center;
            padding: 60px 20px;
        }
        .notfound-box i {
            font-size: 54px;
            color: var(--text-muted);
            margin-bottom: 16px;
            opacity: 0.5;
        }

        @media (max-width: 992px) {
            .detail-container {
                flex-direction: column;
            }
            .detail-sidebar {
                width: 100%;
            }
            .related-grid {
                grid-template-columns: 1fr;
            }
            .detail-main {
                padding: 24px;
            }
        }
    </style>
</head>
<body>

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Breadcrumbs -->
    <div class="detail-breadcrumb-bar">
        <div class="detail-breadcrumb">
            <a href="<%= ctx %>/"><i class="fa-solid fa-house me-1"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right chevron-sm"></i>
            <a href="<%= ctx %>/blogs">Danh sách bài viết</a>
            <i class="fa-solid fa-chevron-right chevron-sm"></i>
            <span class="current"><%= blog != null ? blog.getTitle() : "Bài viết" %></span>
        </div>
    </div>

    <!-- Main Container -->
    <div class="detail-container">
        
        <% if (blog == null) { %>
            <div class="detail-main notfound-box">
                <i class="fa-regular fa-file-circle-question"></i>
                <h2>Không tìm thấy bài viết</h2>
                <p class="blog-empty-msg">Bài viết bạn đang tìm kiếm có thể đã bị xóa hoặc không tồn tại.</p>
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
                    <div class="article-footer-actions">
                        <% if (detailUser != null && (detailUser.getId() == blog.getAuthor() || detailUser.getRoleId() == 1)) { %>
                            <a href="<%= ctx %>/blogs-edit?id=<%= blog.getId() %>" class="btn-back-blogs btn-back-blogs--edit">
                                <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa bài này
                            </a>
                        <% } %>
                        <a href="<%= ctx %>/my-blogs" class="btn-back-blogs btn-back-blogs--list">
                            <i class="fa-solid fa-feather-pointed"></i> Quản lý bài viết của tôi
                        </a>
                    </div>
                </div>

                <!-- Bài viết liên quan -->
                <% if (!relatedBlogs.isEmpty()) { %>
                    <div class="related-section">
                        <h3 class="related-section__title">
                            <i class="fa-solid fa-layer-group related-section__icon"></i> Bài viết cùng chủ đề
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
                                        <div class="blog-thumb-fallback blog-thumb-fallback--lg">
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
                                <img src="<%= rb.getThumbnail() %>" alt="<%= rb.getTitle() %>" onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'blog-thumb-fallback\'><i class=\'fa-regular fa-newspaper\'></i></div>';">
                            <% } else { %>
                                <div class="blog-thumb-fallback">
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
