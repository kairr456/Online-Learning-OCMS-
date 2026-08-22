<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OCMS Admin - Duyệt Giảng viên</title>

    <!-- Global CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/teacher-approval.css">
</head>

<body>

<div class="admin-layout">

    <!-- Sidebar -->
    <aside class="admin-sidebar">
        <div class="admin-sidebar__header">
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-logo">
                <span class="admin-logo__icon">OCMS</span>
                <span class="admin-logo__text">Admin</span>
            </a>
        </div>

        <nav class="admin-nav">
            <ul class="admin-nav__list">
                <li class="admin-nav__item">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-nav__link">
                        <span class="admin-nav__icon">&#128293;</span>
                        Dashboard
                    </a>
                </li>
                <li class="admin-nav__item">
                    <a href="${pageContext.request.contextPath}/admin/courses" class="admin-nav__link">
                        <span class="admin-nav__icon">&#128218;</span>
                        Khóa học
                    </a>
                </li>
                <li class="admin-nav__item admin-nav__item--active">
                    <a href="${pageContext.request.contextPath}/admin/teacher-approvals/list" class="admin-nav__link">
                        <span class="admin-nav__icon">&#128100;</span>
                        Duyệt Giảng viên
                    </a>
                </li>
                <li class="admin-nav__item">
                    <a href="${pageContext.request.contextPath}/admin/users" class="admin-nav__link">
                        <span class="admin-nav__icon">&#128101;</span>
                        Người dùng
                    </a>
                </li>
                <li class="admin-nav__item">
                    <a href="${pageContext.request.contextPath}/admin/blogs" class="admin-nav__link">
                        <span class="admin-nav__icon">&#128221;</span>
                        Blog
                    </a>
                </li>
            </ul>
        </nav>

        <div class="admin-sidebar__footer">
            <a href="${pageContext.request.contextPath}/logout" class="admin-nav__link admin-nav__link--logout">
                <span class="admin-nav__icon">&#8617;</span>
                Đăng xuất
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="admin-main">
        <header class="admin-header">
            <div class="admin-header__left">
                <h1 class="admin-header__title">Duyệt tài khoản Giảng viên</h1>
            </div>
            <div class="admin-header__right">
                <span class="admin-header__user">
                    <span class="admin-header__avatar">
                        <%= ((com.entity.Account)session.getAttribute("account")).getFullName() != null ?
                            ((com.entity.Account)session.getAttribute("account")).getFullName().substring(0,1).toUpperCase() : "A" %>
                    </span>
                    <%= ((com.entity.Account)session.getAttribute("account")).getFullName() %>
                </span>
            </div>
        </header>

        <div class="admin-content">

            <!-- Alert Messages -->
            <%
                String approved = request.getParameter("approved");
                String rejected = request.getParameter("rejected");
                if ("1".equals(approved)) {
            %>
            <div class="alert alert--success">
                <span class="alert__icon">&#10003;</span>
                <span>Đã duyệt tài khoản giảng viên thành công. Email thông báo đã được gửi.</span>
            </div>
            <%
                } else if ("1".equals(rejected)) {
            %>
            <div class="alert alert--warning">
                <span class="alert__icon">&#9888;</span>
                <span>Đã từ chối tài khoản giảng viên. Email thông báo đã được gửi.</span>
            </div>
            <%
                }
            %>

            <!-- Search & Filter -->
            <div class="teacher-approval__toolbar">
                <form method="get" action="${pageContext.request.contextPath}/admin/teacher-approvals/list" class="teacher-approval__search">
                    <div class="search-input-wrapper">
                        <input
                            type="text"
                            name="keyword"
                            class="search-input"
                            placeholder="Tìm kiếm username, email, họ tên, tiêu đề..."
                            value="<%= request.getAttribute("keyword") != null ? request.getAttribute("keyword") : "" %>"
                        >
                        <button type="submit" class="search-btn">&#128269;</button>
                    </div>
                </form>
            </div>

            <!-- Table -->
            <div class="table-responsive">
                <table class="admin-table teacher-approval__table">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Avatar</th>
                            <th>Thông tin tài khoản</th>
                            <th>Tiêu đề chuyên môn</th>
                            <th>Kinh nghiệm</th>
                            <th>Ngày đăng ký</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<TeacherProfile> profiles = (List<TeacherProfile>) request.getAttribute("profiles");
                            int currentPage = (Integer) request.getAttribute("currentPage");
                            int startIndex = (currentPage - 1) * 10;
                            if (profiles != null && !profiles.isEmpty()) {
                                for (int i = 0; i < profiles.size(); i++) {
                                    TeacherProfile p = profiles.get(i);
                        %>
                        <tr>
                            <td><%= startIndex + i + 1 %></td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty p.avatarUrl}">
                                        <img src="${p.avatarUrl}" alt="Avatar" class="teacher-avatar">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="teacher-avatar teacher-avatar--placeholder">
                                            ${p.fullName != null ? p.fullName.substring(0,1).toUpperCase() : '?'}
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="teacher-info">
                                    <strong>${p.fullName}</strong>
                                    <small>@${p.username}</small>
                                    <small>${p.email}</small>
                                </div>
                            </td>
                            <td>
                                <span class="teacher-headline">${p.headline}</span>
                            </td>
                            <td>
                                <span class="badge badge--info">${p.yearsExperience} năm</span>
                            </td>
                            <td>${p.createdAt != null ? p.createdAt.toString().substring(0, 16).replace('T', ' ') : ''}</td>
                            <td>
                                <span class="badge badge--warning">Chờ duyệt</span>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/teacher-approvals/detail?id=${p.id}"
                                   class="btn btn--primary btn--sm">
                                    Xem & Duyệt
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center">Không có tài khoản giảng viên nào chờ duyệt.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <%
                int totalPages = (Integer) request.getAttribute("totalPages");
                String keyword = (String) request.getAttribute("keyword");
                if (totalPages > 1) {
            %>
            <nav class="pagination" aria-label="Pagination">
                <ul class="pagination__list">
                    <c:if test="${currentPage > 1}">
                        <li class="pagination__item">
                            <a href="${pageContext.request.contextPath}/admin/teacher-approvals/list?page=${currentPage - 1}${not empty keyword ? '&keyword=' + keyword : ''}" class="pagination__link">
                                &laquo; Trước
                            </a>
                        </li>
                    </c:if>

                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="pagination__item">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <span class="pagination__link pagination__link--active">${i}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/admin/teacher-approvals/list?page=${i}${not empty keyword ? '&keyword=' + keyword : ''}" class="pagination__link">${i}</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                    </c:forEach>

                    <c:if test="${currentPage < totalPages}">
                        <li class="pagination__item">
                            <a href="${pageContext.request.contextPath}/admin/teacher-approvals/list?page=${currentPage + 1}${not empty keyword ? '&keyword=' + keyword : ''}" class="pagination__link">
                                Sau &raquo;
                            </a>
                        </li>
                    </c:if>
                </ul>
            </nav>
            <%
                }
            %>

        </div>
    </main>

</div>

</body>
</html>