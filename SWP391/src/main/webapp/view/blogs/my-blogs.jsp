<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Blog" %>
<%@ page import="com.entity.Account" %>
<%@ page import="com.DAO.BlogDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    String ctx = request.getContextPath();
    Account account = (Account) session.getAttribute("account");
    if (account == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    List<Blog> myBlogs = (List<Blog>) request.getAttribute("myBlogs");
    if (myBlogs == null) {
        BlogDAO bDAO = new BlogDAO();
        myBlogs = bDAO.getBlogsByAuthor(account.getId());
    }

    Map<Integer, String> categories = (Map<Integer, String>) request.getAttribute("categories");
    if (categories == null || categories.isEmpty()) {
        BlogDAO bDAO = new BlogDAO();
        categories = bDAO.getBlogCategories();
    }

    String message = request.getParameter("message");
    String error = request.getParameter("error");

    int totalCount = myBlogs.size();
    int activeCount = 0;
    int inactiveCount = 0;
    for (Blog b : myBlogs) {
        if ("Active".equalsIgnoreCase(b.getStatus())) {
            activeCount++;
        } else {
            inactiveCount++;
        }
    }

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bài Viết Của Tôi · OCMS</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- FontAwesome & Base CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/blog/my-blogs.css?v=<%= System.currentTimeMillis() %>">
    <style>
        /* Force light theme colors on search and filter inputs */
        .search-input-wrap .search-input {
            background-color: #ffffff !important;
            color: #0F1E33 !important;
            caret-color: #0F1E33 !important;
            color-scheme: light !important;
            -webkit-text-fill-color: #0F1E33 !important;
            opacity: 1 !important;
        }
        .search-input-wrap .search-input::placeholder {
            color: #5B6B82 !important;
            -webkit-text-fill-color: #5B6B82 !important;
            opacity: 0.85 !important;
        }
        .filter-select {
            background-color: #ffffff !important;
            color: #0F1E33 !important;
            color-scheme: light !important;
        }
        .filter-select option {
            background-color: #ffffff !important;
            color: #0F1E33 !important;
        }
    </style>
</head>
<body>

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Hero Section -->
    <section class="myblog-hero">
        <div class="myblog-hero__inner">
            <div>
                <div class="myblog-breadcrumb">
                    <a href="<%= ctx %>/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="<%= ctx %>/blogs">Blogs & Tin Tức</a>
                    <span>/</span>
                    <span>Bài viết của tôi</span>
                </div>
                <h1 class="myblog-hero__title">
                    <i class="fa-solid fa-newspaper"></i> Quản Lý Bài Viết Của Tôi
                </h1>
                <p class="myblog-hero__desc">Xem, chỉnh sửa, xóa và quản lý tất cả các bài viết do bạn tạo trên nền tảng OCMS.</p>
            </div>
            <div>
                <a href="<%= ctx %>/blogs-new" class="btn-create-post">
                    <i class="fa-solid fa-plus"></i> Viết bài mới
                </a>
            </div>
        </div>
    </section>

    <!-- Main Container -->
    <div class="myblog-container">

        <!-- Stats Overview -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon stat-icon--blue">
                    <i class="fa-solid fa-book-open"></i>
                </div>
                <div class="stat-content">
                    <h3><%= totalCount %></h3>
                    <p>Tổng số bài viết</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon--green">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
                <div class="stat-content">
                    <h3><%= activeCount %></h3>
                    <p>Đang hoạt động</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon--orange">
                    <i class="fa-solid fa-eye-slash"></i>
                </div>
                <div class="stat-content">
                    <h3><%= inactiveCount %></h3>
                    <p>Bản nháp / Đang ẩn</p>
                </div>
            </div>
        </div>

        <!-- Alert Notification -->
        <% if ("created".equals(message)) { %>
            <div class="alert-box alert-box--success">
                <i class="fa-solid fa-circle-check"></i>
                <span>Tạo bài viết mới thành công! Bài viết đã được thêm vào danh sách của bạn.</span>
            </div>
        <% } else if ("updated".equals(message)) { %>
            <div class="alert-box alert-box--success">
                <i class="fa-solid fa-circle-check"></i>
                <span>Cập nhật bài viết thành công! Các thay đổi đã được lưu.</span>
            </div>
        <% } else if ("deleted".equals(message)) { %>
            <div class="alert-box alert-box--success">
                <i class="fa-solid fa-circle-check"></i>
                <span>Đã xóa bài viết thành công khỏi hệ thống!</span>
            </div>
        <% } else if ("unauthorized".equals(error)) { %>
            <div class="alert-box alert-box--danger">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span>Bạn không có quyền thực hiện thao tác trên bài viết này!</span>
            </div>
        <% } else if ("notfound".equals(error)) { %>
            <div class="alert-box alert-box--danger">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span>Không tìm thấy bài viết yêu cầu!</span>
            </div>
        <% } %>

        <!-- Table Card -->
        <div class="main-card">
            <!-- Table Toolbar -->
            <div class="table-toolbar">
                <div class="search-filter-wrap">
                    <div class="search-input-wrap">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="filterKeyword" class="search-input" placeholder="Tìm theo tiêu đề bài viết..." autocomplete="off" onkeyup="filterTable()" style="color: #0F1E33 !important; background-color: #ffffff !important; -webkit-text-fill-color: #0F1E33 !important;">
                    </div>
                    <select id="filterCategory" class="filter-select" onchange="filterTable()">
                        <option value="">Tất cả danh mục</option>
                        <% for (Map.Entry<Integer, String> entry : categories.entrySet()) { %>
                            <option value="<%= entry.getValue() %>"><%= entry.getValue() %></option>
                        <% } %>
                    </select>
                    <select id="filterStatus" class="filter-select" onchange="filterTable()">
                        <option value="">Tất cả trạng thái</option>
                        <option value="Active">Hoạt động (Active)</option>
                        <option value="Inactive">Đang ẩn (Inactive)</option>
                    </select>
                </div>
            </div>

            <!-- Table of Posts -->
            <% if (myBlogs == null || myBlogs.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-icon">
                        <i class="fa-regular fa-folder-open"></i>
                    </div>
                    <h4>Bạn chưa có bài viết nào</h4>
                    <p>Hãy bắt đầu chia sẻ kiến thức và kinh nghiệm của bạn với cộng đồng học viên OCMS ngay hôm nay.</p>
                    <a href="<%= ctx %>/blogs-new" class="btn-create-post">
                        <i class="fa-solid fa-plus"></i> Tạo bài viết đầu tiên
                    </a>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="blog-table" id="myBlogTable">
                        <thead>
                            <tr>
                                <th class="col-stt">STT</th>
                                <th>Bài Viết</th>
                                <th>Danh Mục</th>
                                <th>Trạng Thái</th>
                                <th>Ngày Tạo</th>
                                <th>Cập Nhật</th>
                                <th class="col-action-head">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int index = 1; for (Blog b : myBlogs) { 
                                String catName = categories.getOrDefault(b.getCategoryId(), "Chung");
                                String createdStr = b.getCreatedDate() != null ? sdf.format(b.getCreatedDate()) : "N/A";
                                String updatedStr = b.getUpdatedDate() != null ? sdf.format(b.getUpdatedDate()) : createdStr;
                                boolean isActive = "Active".equalsIgnoreCase(b.getStatus());
                            %>
                            <tr data-title="<%= b.getTitle().toLowerCase() %>" data-cat="<%= catName %>" data-status="<%= b.getStatus() %>">
                                <td class="td-index"><%= index++ %></td>
                                <td>
                                    <div class="post-cell">
                                        <% if (b.getThumbnail() != null && !b.getThumbnail().trim().isEmpty()) { %>
                                            <img src="<%= b.getThumbnail() %>" alt="<%= b.getTitle() %>" class="post-thumb" onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'post-fallback-thumb\'><i class=\'fa-regular fa-newspaper\'></i></div>';">
                                        <% } else { %>
                                            <div class="post-fallback-thumb">
                                                <i class="fa-regular fa-newspaper"></i>
                                            </div>
                                        <% } %>
                                        <div>
                                            <a href="<%= ctx %>/view/blogs/blog-detail.jsp?id=<%= b.getId() %>" class="post-title-link" target="_blank" title="<%= b.getTitle() %>">
                                                <%= b.getTitle() %>
                                            </a>
                                            <div class="post-brief"><%= b.getBriefInfo() != null ? b.getBriefInfo() : "" %></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge badge--category">
                                        <i class="fa-solid fa-tag"></i> <%= catName %>
                                    </span>
                                </td>
                                <td>
                                    <% if (isActive) { %>
                                        <span class="badge badge--active">
                                            <span class="badge-dot badge-dot--active"></span> Hoạt động
                                        </span>
                                    <% } else { %>
                                        <span class="badge badge--inactive">
                                            <span class="badge-dot badge-dot--inactive"></span> Đang ẩn
                                        </span>
                                    <% } %>
                                </td>
                                <td class="td-date"><%= createdStr %></td>
                                <td class="td-date"><%= updatedStr %></td>
                                <td class="td-center">
                                    <div class="action-btns action-btns--center">
                                        <a href="<%= ctx %>/view/blogs/blog-detail.jsp?id=<%= b.getId() %>" target="_blank" class="btn-action btn-action--view" title="Xem chi tiết">
                                            <i class="fa-regular fa-eye"></i>
                                        </a>
                                        <a href="<%= ctx %>/blogs-edit?id=<%= b.getId() %>" class="btn-action btn-action--edit" title="Chỉnh sửa bài viết">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </a>
                                        <button type="button" class="btn-action btn-action--delete" title="Xóa bài viết" onclick="confirmDelete(<%= b.getId() %>, '<%= b.getTitle().replace("'", "\\'").replace("\"", "&quot;") %>')">
                                            <i class="fa-regular fa-trash-can"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

    </div>

    <!-- Modal Confirm Delete -->
    <div id="deleteModal" class="modal-overlay" onclick="closeDeleteModal(event)">
        <div class="modal-card" onclick="event.stopPropagation()">
            <div class="modal-icon">
                <i class="fa-solid fa-trash-can"></i>
            </div>
            <h3>Xác nhận xóa bài viết?</h3>
            <p>Bạn có chắc chắn muốn xóa bài viết <strong id="deleteBlogTitle" class="delete-blog-title"></strong>? Hành động này sẽ xóa vĩnh viễn bài viết khỏi hệ thống và không thể hoàn tác.</p>
            <div class="modal-actions">
                <button type="button" class="btn-modal-cancel" onclick="closeDeleteModal()">Hủy bỏ</button>
                <a id="btnConfirmDelete" href="#" class="btn-modal-confirm">
                    <i class="fa-regular fa-trash-can"></i> Xóa vĩnh viễn
                </a>
            </div>
        </div>
    </div>

    <!-- Footer chung -->
    <jsp:include page="/view/common/footer.jsp" />

    <script>
        function filterTable() {
            var keyword = document.getElementById('filterKeyword').value.toLowerCase().trim();
            var category = document.getElementById('filterCategory').value;
            var status = document.getElementById('filterStatus').value;

            var table = document.getElementById('myBlogTable');
            if (!table) return;
            var rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');

            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                var rowTitle = row.getAttribute('data-title') || '';
                var rowCat = row.getAttribute('data-cat') || '';
                var rowStatus = row.getAttribute('data-status') || '';

                var matchKeyword = keyword === '' || rowTitle.indexOf(keyword) > -1;
                var matchCategory = category === '' || rowCat === category;
                var matchStatus = status === '' || rowStatus === status;

                if (matchKeyword && matchCategory && matchStatus) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            }
        }

        function confirmDelete(blogId, title) {
            document.getElementById('deleteBlogTitle').innerText = '"' + title + '"';
            document.getElementById('btnConfirmDelete').href = '<%= ctx %>/blogs-delete?id=' + blogId;
            document.getElementById('deleteModal').style.display = 'flex';
        }

        function closeDeleteModal(e) {
            if (!e || e.target.id === 'deleteModal' || e.target.classList.contains('btn-modal-cancel')) {
                document.getElementById('deleteModal').style.display = 'none';
            }
        }
    </script>
</body>
</html>
