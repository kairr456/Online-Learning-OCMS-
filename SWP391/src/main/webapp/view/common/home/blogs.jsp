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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/blog/blogs.css">
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
        <form id="blogFilterForm" action="<%= ctx %>/blogs" method="get" style="display:none;">
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
                    <a href="<%= ctx %>/my-blogs" class="btn-create-blog" style="background:var(--primary-navy); color:#ffffff; padding:8px 16px; border-radius:8px; font-size:13.5px; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:7px; transition:all 0.2s; box-shadow: 0 2px 6px rgba(15, 30, 51, 0.15);">
                        <i class="fa-solid fa-feather-pointed"></i> Bài viết của tôi
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
                    <a href="<%= ctx %>/blogs" class="blog-empty__btn">
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
