<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Blog" %>
<%@ page import="com.DAO.BlogDAO" %>
<%@ page import="com.DAO.AccountDAO" %>
<%@ page import="com.DAO.DBContext" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    String ctx = request.getContextPath();

    // 1. Lấy danh mục blog từ database (bảng blog_category)
    Map<Integer, String> blogCategories = new HashMap<>();
    DBContext db = new DBContext();
    try {
        if (db.getConnection() != null) {
            PreparedStatement psCat = db.getConnection().prepareStatement("SELECT id, name FROM blog_category ORDER BY id ASC");
            ResultSet rsCat = psCat.executeQuery();
            while (rsCat.next()) {
                blogCategories.put(rsCat.getInt("id"), rsCat.getString("name"));
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        db.closeResources();
    }

    // 2. Lấy danh sách tên tác giả (từ bảng account)
    Map<Integer, String> authorNames = new AccountDAO().getAuthorNames();

    // 3. Nhận tham số tìm kiếm, lọc danh mục, sắp xếp và phân trang từ request
    String searchKeyword = request.getParameter("search");
    if (searchKeyword != null) {
        searchKeyword = searchKeyword.trim();
    } else {
        searchKeyword = "";
    }

    String categoryFilterParam = request.getParameter("category");
    int categoryFilter = 0;
    if (categoryFilterParam != null && !categoryFilterParam.isEmpty()) {
        try {
            categoryFilter = Integer.parseInt(categoryFilterParam);
        } catch (NumberFormatException ignored) {}
    }

    String sortParam = request.getParameter("sort");
    if (sortParam == null || sortParam.isEmpty()) {
        sortParam = "newest";
    }

    // 4. Lấy danh sách blog trực tiếp từ database theo câu truy vấn SQL động (hoàn toàn chính xác)
    List<Blog> filteredBlogs = new ArrayList<>();
    List<Blog> rawBlogs = new ArrayList<>();
    DBContext dbBlog = new DBContext();
    try {
        if (dbBlog.getConnection() != null) {
            StringBuilder sql = new StringBuilder("SELECT * FROM blog WHERE status = 'Active'");
            List<Object> params = new ArrayList<>();

            if (!searchKeyword.isEmpty()) {
                sql.append(" AND (LOWER(title) LIKE ? OR LOWER(brief_info) LIKE ?)");
                String pattern = "%" + searchKeyword.toLowerCase() + "%";
                params.add(pattern);
                params.add(pattern);
            }

            if (categoryFilter > 0) {
                sql.append(" AND category_id = ?");
                params.add(categoryFilter);
            }

            if ("oldest".equals(sortParam)) {
                sql.append(" ORDER BY created_date ASC, id ASC");
            } else if ("title_asc".equals(sortParam)) {
                sql.append(" ORDER BY title ASC");
            } else if ("title_desc".equals(sortParam)) {
                sql.append(" ORDER BY title DESC");
            } else {
                // Mặc định newest (Mới nhất)
                sql.append(" ORDER BY created_date DESC, id DESC");
            }

            PreparedStatement ps = dbBlog.getConnection().prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Blog b = new Blog(
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
                filteredBlogs.add(b);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        dbBlog.closeResources();
    }

    // Lấy 4 bài viết mới nhất cho Sidebar
    List<Blog> recentBlogs = new ArrayList<>();
    DBContext dbRecent = new DBContext();
    try {
        if (dbRecent.getConnection() != null) {
            PreparedStatement psRec = dbRecent.getConnection().prepareStatement("SELECT * FROM blog WHERE status = 'Active' ORDER BY created_date DESC, id DESC LIMIT 4");
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
        dbRecent.closeResources();
    }

    // 5. Phân trang
    int totalBlogs = filteredBlogs.size();
    int pageSize = 6;
    int totalPages = (int) Math.ceil((double) totalBlogs / pageSize);
    if (totalPages == 0) totalPages = 1;

    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
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

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blogs & Tin Tức · OCMS</title>
    <!-- Fonts & Icons -->
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

        /* Hero Banner */
        .blog-hero {
            background: linear-gradient(135deg, var(--primary-navy) 0%, var(--secondary-navy) 100%);
            color: #ffffff;
            padding: 50px 20px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .blog-hero::after {
            content: '';
            position: absolute;
            top: -50%;
            right: -20%;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(216, 162, 74, 0.15) 0%, rgba(216, 162, 74, 0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }
        .blog-hero__inner {
            max-width: 800px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }
        .blog-hero__badge {
            display: inline-block;
            background: rgba(216, 162, 74, 0.2);
            color: var(--accent-amber);
            border: 1px solid rgba(216, 162, 74, 0.4);
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
            text-transform: uppercase;
        }
        .blog-hero__title {
            font-family: var(--font-display, 'Space Grotesk', sans-serif);
            font-size: 34px;
            font-weight: 700;
            margin: 0 0 10px;
            color: #ffffff !important;
        }
        .blog-hero__desc {
            font-size: 15px;
            color: rgba(255, 255, 255, 0.8) !important;
            margin: 0;
            line-height: 1.6;
        }

        /* Container Layout */
        .blog-container {
            max-width: 1200px;
            margin: 36px auto 60px;
            padding: 0 20px;
            display: flex;
            gap: 32px;
            align-items: flex-start;
        }

        /* Main Content */
        .blog-main {
            flex: 1;
            min-width: 0;
        }

        /* Top Action Bar */
        .blog-toolbar {
            background: var(--card-bg);
            border-radius: var(--radius-md);
            padding: 16px 20px;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 24px;
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-subtle);
        }
        .blog-toolbar__count {
            font-size: 14.5px;
            color: var(--text-muted);
            font-weight: 500;
        }
        .blog-toolbar__count strong {
            color: var(--text-dark);
            font-weight: 700;
        }
        .blog-toolbar__sort {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
            color: var(--text-dark);
            font-weight: 500;
        }
        .blog-toolbar__select {
            padding: 8px 14px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            background: #ffffff !important;
            color: #0F1E33 !important;
            font-size: 13.5px;
            font-weight: 500;
            outline: none;
            cursor: pointer;
            transition: border-color 0.2s ease;
        }
        .blog-toolbar__select option {
            background: #ffffff !important;
            color: #0F1E33 !important;
        }
        .blog-toolbar__select:focus {
            border-color: var(--accent-amber);
        }

        /* Blog Grid */
        .blog-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 24px;
        }

        /* Blog Card */
        .blog-item {
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: var(--shadow-subtle);
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        .blog-item:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-hover);
            border-color: rgba(216, 162, 74, 0.4);
        }
        .blog-item__thumb-wrap {
            position: relative;
            width: 100%;
            height: 200px;
            background: #e9ecef;
            overflow: hidden;
        }
        .blog-item__thumb-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }
        .blog-item:hover .blog-item__thumb-wrap img {
            transform: scale(1.05);
        }
        .blog-item__fallback-thumb {
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, var(--secondary-navy) 0%, var(--primary-navy) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--accent-amber);
            font-size: 40px;
        }
        .blog-item__cat-badge {
            position: absolute;
            top: 12px;
            left: 12px;
            background: rgba(15, 30, 51, 0.85);
            backdrop-filter: blur(4px);
            color: #ffffff !important;
            font-size: 12px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 6px;
            border: 1px solid rgba(255, 255, 255, 0.15);
        }
        .blog-item__body {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }
        .blog-item__meta {
            display: flex;
            align-items: center;
            gap: 14px;
            font-size: 12.5px;
            color: var(--text-muted);
            margin-bottom: 10px;
        }
        .blog-item__meta span {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .blog-item__meta i {
            color: var(--accent-amber);
        }
        .blog-item__title {
            font-size: 17px;
            font-weight: 700;
            line-height: 1.4;
            color: var(--text-dark) !important;
            margin: 0 0 10px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            transition: color 0.2s ease;
        }
        .blog-item__title a {
            color: var(--text-dark) !important;
            text-decoration: none;
        }
        .blog-item:hover .blog-item__title a {
            color: var(--accent-amber-hover) !important;
        }
        .blog-item__brief {
            font-size: 13.5px;
            color: var(--text-muted);
            line-height: 1.5;
            margin: 0 0 16px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .blog-item__footer {
            margin-top: auto;
            padding-top: 14px;
            border-top: 1px dashed var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .blog-item__link {
            font-size: 13.5px;
            font-weight: 600;
            color: var(--primary-navy);
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
            text-decoration: none;
        }
        .blog-item__link:hover {
            color: var(--accent-amber-hover);
            transform: translateX(4px);
        }
        .blog-item__link i {
            font-size: 12px;
        }

        /* Empty State */
        .blog-empty {
            background: var(--card-bg);
            border-radius: var(--radius-md);
            padding: 50px 20px;
            text-align: center;
            border: 1px dashed var(--border-color);
        }
        .blog-empty i {
            font-size: 48px;
            color: var(--text-muted);
            opacity: 0.5;
            margin-bottom: 14px;
        }
        .blog-empty h4 {
            margin: 0 0 8px;
            font-size: 18px;
            color: var(--text-dark);
        }
        .blog-empty p {
            margin: 0 0 18px;
            color: var(--text-muted);
            font-size: 14px;
        }
        .blog-empty__btn {
            display: inline-block;
            background: var(--primary-navy);
            color: #ffffff;
            padding: 8px 18px;
            border-radius: 8px;
            font-size: 13.5px;
            font-weight: 600;
            text-decoration: none;
            transition: background 0.2s;
        }
        .blog-empty__btn:hover {
            background: var(--accent-amber-hover);
        }

        /* Sidebar */
        .blog-sidebar {
            width: 320px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            gap: 24px;
        }
        .blog-widget {
            background: var(--card-bg);
            border-radius: var(--radius-md);
            padding: 22px;
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-subtle);
        }
        .blog-widget__title {
            font-size: 17px;
            font-weight: 700;
            color: var(--primary-navy);
            margin: 0 0 16px;
            position: relative;
            padding-bottom: 10px;
        }
        .blog-widget__title::after {
            content: '';
            position: absolute;
            left: 0;
            bottom: 0;
            width: 36px;
            height: 3px;
            background: var(--accent-amber);
            border-radius: 2px;
        }

        /* Search Box in Widget */
        .blog-search-box {
            position: relative;
            display: flex;
            align-items: center;
        }
        .blog-search-box input {
            width: 100%;
            padding: 10px 42px 10px 14px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            outline: none;
            font-size: 14px;
            background: #ffffff !important;
            color: #0F1E33 !important;
            caret-color: #0F1E33 !important;
            transition: all 0.2s ease;
        }
        .blog-search-box input::placeholder {
            color: #8C99AC !important;
            opacity: 1;
        }
        .blog-search-box input:focus {
            border-color: var(--accent-amber);
            background: #ffffff !important;
            color: #0F1E33 !important;
            box-shadow: 0 0 0 3px rgba(216, 162, 74, 0.15);
        }
        .blog-search-box button {
            position: absolute;
            right: 8px;
            background: none;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            font-size: 15px;
            padding: 6px 8px;
            transition: color 0.2s;
        }
        .blog-search-box button:hover {
            color: var(--primary-navy);
        }

        /* Category List in Widget */
        .blog-cat-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .blog-cat-list li a {
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
        .blog-cat-list li a:hover,
        .blog-cat-list li a.active {
            background: var(--primary-navy);
            color: #ffffff !important;
            padding-left: 16px;
        }
        .blog-cat-list li a.active span,
        .blog-cat-list li a:hover span,
        .blog-cat-list li a.active i,
        .blog-cat-list li a:hover i {
            color: #ffffff !important;
        }
        .blog-cat-list li a i {
            font-size: 12px;
            opacity: 0.6;
        }

        /* Recent Posts in Widget */
        .blog-recent-list {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .blog-recent-item {
            display: flex;
            gap: 12px;
            align-items: center;
            text-decoration: none;
        }
        .blog-recent-item__thumb {
            width: 60px;
            height: 60px;
            border-radius: 8px;
            overflow: hidden;
            flex-shrink: 0;
            background: #e9ecef;
        }
        .blog-recent-item__thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .blog-recent-item__info {
            flex: 1;
            min-width: 0;
        }
        .blog-recent-item__title {
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
        .blog-recent-item:hover .blog-recent-item__title {
            color: var(--accent-amber-hover);
        }
        .blog-recent-item__date {
            font-size: 12px;
            color: var(--text-muted);
        }

        /* Pagination */
        .blog-pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            margin-top: 36px;
        }
        .blog-pagination a, 
        .blog-pagination span {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 38px;
            height: 38px;
            padding: 0 10px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            background: var(--card-bg);
            color: var(--primary-navy);
            border: 1px solid var(--border-color);
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .blog-pagination a:hover {
            background: var(--accent-amber);
            border-color: var(--accent-amber);
            color: var(--primary-navy);
            transform: translateY(-2px);
        }
        .blog-pagination .active {
            background: var(--primary-navy);
            border-color: var(--primary-navy);
            color: #ffffff !important;
        }

        /* Responsive */
        @media (max-width: 992px) {
            .blog-container {
                flex-direction: column;
            }
            .blog-sidebar {
                width: 100%;
            }
        }
        @media (max-width: 640px) {
            .blog-grid {
                grid-template-columns: 1fr;
            }
            .blog-hero__title {
                font-size: 26px;
            }
            .blog-toolbar {
                flex-direction: column;
                align-items: stretch;
            }
        }
    </style>
</head>
<body>

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Hero Banner -->
    <section class="blog-hero">
        <div class="blog-hero__inner">
            <span class="blog-hero__badge"><i class="fa-solid fa-newspaper me-1"></i> OCMS Blog & Articles</span>
            <h1 class="blog-hero__title">Khám Phá Kiến Thức Mới</h1>
            <p class="blog-hero__desc">Cập nhật những xu hướng công nghệ, mẹo học tập, tin tức và chia sẻ hữu ích từ các chuyên gia tại OCMS.</p>
        </div>
    </section>

    <!-- Main Container -->
    <div class="blog-container">

        <!-- Form quản lý tìm kiếm, lọc, sắp xếp, phân trang -->
        <form id="blogFilterForm" action="<%= ctx %>/view/common/home/blogs.jsp" method="get" style="display:none;">
            <input type="hidden" name="search" id="formSearch" value="<%= searchKeyword != null ? searchKeyword.replace("\"", "&quot;") : "" %>">
            <input type="hidden" name="category" id="formCategory" value="<%= categoryFilter > 0 ? categoryFilter : "" %>">
            <input type="hidden" name="sort" id="formSort" value="<%= sortParam %>">
            <input type="hidden" name="page" id="formPage" value="<%= currentPage %>">
        </form>

        <!-- Main Blog List -->
        <main class="blog-main">
            <!-- Toolbar -->
            <div class="blog-toolbar">
                <div class="blog-toolbar__count">
                    Hiển thị <strong><%= totalBlogs %></strong> bài viết <%= categoryFilter > 0 ? "trong danh mục này" : "" %>
                </div>
                <div style="display:flex; align-items:center; gap:16px; flex-wrap:wrap;">
                    <a href="<%= ctx %>/blogs-new" class="btn-create-blog" style="background:var(--primary-navy); color:#ffffff; padding:7px 14px; border-radius:8px; font-size:13.5px; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:6px; transition:all 0.2s;">
                        <i class="fa-solid fa-plus"></i> Viết bài mới
                    </a>
                    <div class="blog-toolbar__sort">
                        <label for="sortSelect"><i class="fa-solid fa-arrow-down-short-wide"></i> Sắp xếp:</label>
                        <select id="sortSelect" class="blog-toolbar__select" onchange="submitSort(this.value);">
                            <option value="newest" <%= "newest".equals(sortParam) ? "selected" : "" %>>Mới nhất</option>
                            <option value="oldest" <%= "oldest".equals(sortParam) ? "selected" : "" %>>Cũ nhất</option>
                            <option value="title_asc" <%= "title_asc".equals(sortParam) ? "selected" : "" %>>Tiêu đề (A - Z)</option>
                            <option value="title_desc" <%= "title_desc".equals(sortParam) ? "selected" : "" %>>Tiêu đề (Z - A)</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Blog Grid -->
            <% if (pagedBlogs.isEmpty()) { %>
                <div class="blog-empty">
                    <i class="fa-regular fa-folder-open"></i>
                    <h4>Không tìm thấy bài viết nào</h4>
                    <p>Hãy thử tìm kiếm với từ khóa khác hoặc xóa bộ lọc để xem toàn bộ bài viết.</p>
                    <a href="<%= ctx %>/view/common/home/blogs.jsp" class="blog-empty__btn">
                        <i class="fa-solid fa-rotate-left me-1"></i> Xem tất cả bài viết
                    </a>
                </div>
            <% } else { %>
                <div class="blog-grid">
                    <% for (Blog blog : pagedBlogs) { 
                        String catName = blogCategories.getOrDefault(blog.getCategoryId(), "Chung");
                        String authorName = authorNames.getOrDefault(blog.getAuthor(), "Tác giả OCMS");
                        String formattedDate = blog.getCreatedDate() != null ? dateFormat.format(blog.getCreatedDate()) : "Gần đây";
                    %>
                    <article class="blog-item">
                        <div class="blog-item__thumb-wrap">
                            <% if (blog.getThumbnail() != null && !blog.getThumbnail().trim().isEmpty()) { %>
                                <img src="<%= blog.getThumbnail() %>" alt="<%= blog.getTitle() %>" onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'blog-item__fallback-thumb\'><i class=\'fa-regular fa-newspaper\'></i></div>';">
                            <% } else { %>
                                <div class="blog-item__fallback-thumb">
                                    <i class="fa-regular fa-newspaper"></i>
                                </div>
                            <% } %>
                            <span class="blog-item__cat-badge"><%= catName %></span>
                        </div>

                        <div class="blog-item__body">
                            <div class="blog-item__meta">
                                <span><i class="fa-regular fa-user"></i> <%= authorName %></span>
                                <span><i class="fa-regular fa-calendar"></i> <%= formattedDate %></span>
                            </div>

                            <h3 class="blog-item__title">
                                <a href="<%= ctx %>/view/blogs/blog-detail.jsp?id=<%= blog.getId() %>">
                                    <%= blog.getTitle() %>
                                </a>
                            </h3>

                            <p class="blog-item__brief">
                                <%= blog.getBriefInfo() != null ? blog.getBriefInfo() : "" %>
                            </p>

                            <div class="blog-item__footer">
                                <a href="<%= ctx %>/view/blogs/blog-detail.jsp?id=<%= blog.getId() %>" class="blog-item__link">
                                    Đọc tiếp <i class="fa-solid fa-arrow-right"></i>
                                </a>
                            </div>
                        </div>
                    </article>
                    <% } %>
                </div>

                <!-- Pagination -->
                <% if (totalPages > 1) { %>
                <div class="blog-pagination">
                    <% if (currentPage > 1) { %>
                        <a href="javascript:void(0)" onclick="goToPage(1)" title="Trang đầu"><i class="fa-solid fa-angles-left"></i></a>
                        <a href="javascript:void(0)" onclick="goToPage(<%= currentPage - 1 %>)" title="Trang trước"><i class="fa-solid fa-angle-left"></i></a>
                    <% } %>

                    <% for (int p = 1; p <= totalPages; p++) { %>
                        <% if (p == currentPage) { %>
                            <span class="active"><%= p %></span>
                        <% } else if (p >= currentPage - 2 && p <= currentPage + 2) { %>
                            <a href="javascript:void(0)" onclick="goToPage(<%= p %>)"><%= p %></a>
                        <% } %>
                    <% } %>

                    <% if (currentPage < totalPages) { %>
                        <a href="javascript:void(0)" onclick="goToPage(<%= currentPage + 1 %>)" title="Trang sau"><i class="fa-solid fa-angle-right"></i></a>
                        <a href="javascript:void(0)" onclick="goToPage(<%= totalPages %>)" title="Trang cuối"><i class="fa-solid fa-angles-right"></i></a>
                    <% } %>
                </div>
                <% } %>
            <% } %>
        </main>

        <!-- Sidebar -->
        <aside class="blog-sidebar">
            <!-- Widget Search -->
            <div class="blog-widget">
                <h4 class="blog-widget__title">Tìm kiếm</h4>
                <div class="blog-search-box">
                    <input type="text" id="searchInput" placeholder="Tìm kiếm bài viết..." value="<%= searchKeyword != null ? searchKeyword.replace("\"", "&quot;") : "" %>" onkeydown="if(event.key === 'Enter'){ event.preventDefault(); submitSearch(); }">
                    <button type="button" onclick="submitSearch();" aria-label="Search">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </button>
                </div>
            </div>

            <!-- Widget Categories -->
            <div class="blog-widget">
                <h4 class="blog-widget__title">Danh mục bài viết</h4>
                <ul class="blog-cat-list">
                    <li>
                        <a href="javascript:void(0)" onclick="filterCategory(0)" class="<%= categoryFilter == 0 ? "active" : "" %>">
                            <span><i class="fa-solid fa-border-all me-2"></i> Tất cả danh mục</span>
                            <i class="fa-solid fa-chevron-right"></i>
                        </a>
                    </li>
                    <% for (Map.Entry<Integer, String> entry : blogCategories.entrySet()) { %>
                    <li>
                        <a href="javascript:void(0)" onclick="filterCategory(<%= entry.getKey() %>)" class="<%= categoryFilter == entry.getKey() ? "active" : "" %>">
                            <span><i class="fa-solid fa-tag me-2"></i> <%= entry.getValue() %></span>
                            <i class="fa-solid fa-chevron-right"></i>
                        </a>
                    </li>
                    <% } %>
                </ul>
            </div>

            <!-- Widget Recent Posts -->
            <% if (!recentBlogs.isEmpty()) { %>
            <div class="blog-widget">
                <h4 class="blog-widget__title">Bài viết mới nhất</h4>
                <div class="blog-recent-list">
                    <% for (Blog rb : recentBlogs) { 
                        String rbDate = rb.getCreatedDate() != null ? dateFormat.format(rb.getCreatedDate()) : "";
                    %>
                    <a href="<%= ctx %>/view/blogs/blog-detail.jsp?id=<%= rb.getId() %>" class="blog-recent-item">
                        <div class="blog-recent-item__thumb">
                            <% if (rb.getThumbnail() != null && !rb.getThumbnail().trim().isEmpty()) { %>
                                <img src="<%= rb.getThumbnail() %>" alt="<%= rb.getTitle() %>" onerror="this.onerror=null; this.parentElement.innerHTML='<div style=\'width:100%;height:100%;background:#16273F;display:flex;align-items:center;justify-content:center;color:#D8A24A;font-size:16px;\'><i class=\'fa-regular fa-newspaper\'></i></div>';">
                            <% } else { %>
                                <div style="width:100%;height:100%;background:#16273F;display:flex;align-items:center;justify-content:center;color:#D8A24A;font-size:16px;">
                                    <i class="fa-regular fa-newspaper"></i>
                                </div>
                            <% } %>
                        </div>
                        <div class="blog-recent-item__info">
                            <h5 class="blog-recent-item__title"><%= rb.getTitle() %></h5>
                            <span class="blog-recent-item__date"><i class="fa-regular fa-calendar me-1"></i><%= rbDate %></span>
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

    <!-- Script điều hướng lọc và tìm kiếm -->
    <script>
        function submitSearch() {
            var searchInput = document.getElementById('searchInput');
            var val = searchInput ? searchInput.value.trim() : '';
            document.getElementById('formSearch').value = val;
            document.getElementById('formPage').value = 1;
            document.getElementById('blogFilterForm').submit();
        }

        function filterCategory(catId) {
            document.getElementById('formCategory').value = catId > 0 ? catId : "";
            document.getElementById('formPage').value = 1;
            document.getElementById('blogFilterForm').submit();
        }

        function submitSort(sortVal) {
            document.getElementById('formSort').value = sortVal;
            document.getElementById('formPage').value = 1;
            document.getElementById('blogFilterForm').submit();
        }

        function goToPage(pageNum) {
            document.getElementById('formPage').value = pageNum;
            document.getElementById('blogFilterForm').submit();
        }
    </script>
</body>
</html>
