<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/blog/my-blogs.css">
</head>
<body>

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Hero Section -->
    <section class="myblog-hero">
        <div class="myblog-hero__inner">
            <div>
                <div class="myblog-breadcrumb">
                    <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/blogs">Blogs & Tin Tức</a>
                    <span>/</span>
                    <span>Bài viết của tôi</span>
                </div>
                <h1 class="myblog-hero__title">
                    <i class="fa-solid fa-newspaper"></i> Quản Lý Bài Viết Của Tôi
                </h1>
                <p class="myblog-hero__desc">Xem, chỉnh sửa, xóa và quản lý tất cả các bài viết do bạn tạo trên nền tảng OCMS.</p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/blogs-new" class="btn-create-post">
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
                    <h3>${totalCount}</h3>
                    <p>Tổng số bài viết</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon--green">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
                <div class="stat-content">
                    <h3>${activeCount}</h3>
                    <p>Đang hoạt động</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon stat-icon--orange">
                    <i class="fa-solid fa-eye-slash"></i>
                </div>
                <div class="stat-content">
                    <h3>${inactiveCount}</h3>
                    <p>Bản nháp / Đang ẩn</p>
                </div>
            </div>
        </div>

        <!-- Alert Notification -->
        <c:if test="${param.message == 'created'}">
            <div class="alert-box alert-box--success">
                <i class="fa-solid fa-circle-check"></i>
                <span>Tạo bài viết mới thành công! Bài viết đã được thêm vào danh sách của bạn.</span>
            </div>
        </c:if>
        <c:if test="${param.message == 'updated'}">
            <div class="alert-box alert-box--success">
                <i class="fa-solid fa-circle-check"></i>
                <span>Cập nhật bài viết thành công! Các thay đổi đã được lưu.</span>
            </div>
        </c:if>
        <c:if test="${param.message == 'deleted'}">
            <div class="alert-box alert-box--success">
                <i class="fa-solid fa-circle-check"></i>
                <span>Đã xóa bài viết thành công khỏi hệ thống!</span>
            </div>
        </c:if>
        <c:if test="${param.error == 'unauthorized'}">
            <div class="alert-box alert-box--danger">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span>Bạn không có quyền thực hiện thao tác trên bài viết này!</span>
            </div>
        </c:if>
        <c:if test="${param.error == 'notfound'}">
            <div class="alert-box alert-box--danger">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span>Không tìm thấy bài viết yêu cầu!</span>
            </div>
        </c:if>

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
                        <c:forEach var="entry" items="${categories}">
                            <option value="${entry.value}"><c:out value="${entry.value}" /></option>
                        </c:forEach>
                    </select>
                    <select id="filterStatus" class="filter-select" onchange="filterTable()">
                        <option value="">Tất cả trạng thái</option>
                        <option value="Active">Hoạt động (Active)</option>
                        <option value="Inactive">Đang ẩn (Inactive)</option>
                    </select>
                </div>
            </div>

            <!-- Table of Posts -->
            <c:choose>
                <c:when test="${empty myBlogs}">
                    <div class="empty-state">
                        <div class="empty-icon">
                            <i class="fa-regular fa-folder-open"></i>
                        </div>
                        <h4>Bạn chưa có bài viết nào</h4>
                        <p>Hãy bắt đầu chia sẻ kiến thức và kinh nghiệm của bạn với cộng đồng học viên OCMS ngay hôm nay.</p>
                        <a href="${pageContext.request.contextPath}/blogs-new" class="btn-create-post">
                            <i class="fa-solid fa-plus"></i> Tạo bài viết đầu tiên
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
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
                                <c:forEach var="b" items="${myBlogs}" varStatus="loop">
                                    <c:set var="catName" value="${not empty categories[b.categoryId] ? categories[b.categoryId] : 'Chung'}" />
                                    <fmt:formatDate value="${b.createdDate}" pattern="dd/MM/yyyy HH:mm" var="createdStr" />
                                    <fmt:formatDate value="${b.updatedDate}" pattern="dd/MM/yyyy HH:mm" var="updatedStr" />
                                    <c:set var="isActive" value="${'Active' == b.status}" />

                                    <tr data-title="${b.title}" data-cat="${catName}" data-status="${b.status}">
                                        <td class="td-index">${loop.count}</td>
                                        <td>
                                            <div class="post-cell">
                                                <c:choose>
                                                    <c:when test="${not empty b.thumbnail}">
                                                        <img src="${b.thumbnail}" alt="${b.title}" class="post-thumb" onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'post-fallback-thumb\'><i class=\'fa-regular fa-newspaper\'></i></div>';">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="post-fallback-thumb">
                                                            <i class="fa-regular fa-newspaper"></i>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div>
                                                    <a href="${pageContext.request.contextPath}/blog-detail?id=${b.id}" class="post-title-link" title="${b.title}">
                                                        <c:out value="${b.title}" />
                                                    </a>
                                                    <div class="post-brief"><c:out value="${b.briefInfo}" /></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge badge--category">
                                                <i class="fa-solid fa-tag"></i> <c:out value="${catName}" />
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${isActive}">
                                                    <span class="badge badge--active">
                                                        <span class="badge-dot badge-dot--active"></span> Hoạt động
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge--inactive">
                                                        <span class="badge-dot badge-dot--inactive"></span> Đang ẩn
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="td-date"><c:out value="${not empty createdStr ? createdStr : 'N/A'}" /></td>
                                        <td class="td-date"><c:out value="${not empty updatedStr ? updatedStr : (not empty createdStr ? createdStr : 'N/A')}" /></td>
                                        <td class="td-center">
                                            <div class="action-btns action-btns--center">
                                                <a href="${pageContext.request.contextPath}/blog-detail?id=${b.id}" class="btn-action btn-action--view" title="Xem chi tiết">
                                                    <i class="fa-regular fa-eye"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/blogs-edit?id=${b.id}" class="btn-action btn-action--edit" title="Chỉnh sửa bài viết">
                                                    <i class="fa-solid fa-pen-to-square"></i>
                                                </a>
                                                <button type="button" class="btn-action btn-action--delete" title="Xóa bài viết" onclick="confirmDelete(${b.id}, '${b.title}', '${pageContext.request.contextPath}')">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
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

    <!-- JS riêng biệt cho My Blogs -->
    <script src="${pageContext.request.contextPath}/assets/js/blog/my-blogs.js"></script>
</body>
</html>
