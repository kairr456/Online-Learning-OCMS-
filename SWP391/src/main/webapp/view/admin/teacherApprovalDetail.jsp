<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OCMS Admin - Chi tiết duyệt Giảng viên</title>

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
                <a href="${pageContext.request.contextPath}/admin/teacher-approvals/list" class="admin-header__back">&#8592; Quay lại danh sách</a>
                <h1 class="admin-header__title">Chi tiết duyệt Giảng viên</h1>
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

            <div class="teacher-approval-detail">

                <!-- Account Info Card -->
                <div class="detail-card">
                    <h2 class="detail-card__title">Thông tin tài khoản</h2>
                    <div class="detail-grid">
                        <div class="detail-field">
                            <label>Họ tên</label>
                            <span>${account.fullName}</span>
                        </div>
                        <div class="detail-field">
                            <label>Username</label>
                            <span>@${account.username}</span>
                        </div>
                        <div class="detail-field">
                            <label>Email</label>
                            <span>${account.email}</span>
                        </div>
                        <div class="detail-field">
                            <label>Số điện thoại</label>
                            <span>${account.phone != null ? account.phone : 'Chưa cung cấp'}</span>
                        </div>
                        <div class="detail-field">
                            <label>Giới tính</label>
                            <span>${account.gender ? 'Nam' : 'Nữ'}</span>
                        </div>
                        <div class="detail-field">
                            <label>Trạng thái</label>
                            <span>
                                <c:choose>
                                    <c:when test="${account.active}">
                                        <span class="badge badge--success">Đang hoạt động</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge--danger">Chưa kích hoạt</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Profile Info Card -->
                <div class="detail-card">
                    <h2 class="detail-card__title">Hồ sơ chuyên môn</h2>
                    <div class="detail-grid">
                        <div class="detail-field detail-field--full">
                            <label>Tiêu đề chuyên môn</label>
                            <span>${profile.headline}</span>
                        </div>
                        <div class="detail-field detail-field--full">
                            <label>Giới thiệu bản thân</label>
                            <div class="detail-bio">${profile.bio}</div>
                        </div>
                        <div class="detail-field">
                            <label>Số năm kinh nghiệm</label>
                            <span>${profile.yearsExperience} năm</span>
                        </div>
                        <div class="detail-field">
                            <label>Trình độ học vấn</label>
                            <span>${profile.education != null ? profile.education : 'Chưa cung cấp'}</span>
                        </div>
                        <div class="detail-field detail-field--full">
                            <label>Chứng chỉ & Giải thưởng</label>
                            <div class="detail-certifications">${profile.certifications != null ? profile.certifications : 'Chưa cung cấp'}</div>
                        </div>
                        <div class="detail-field">
                            <label>LinkedIn</label>
                            <c:choose>
                                <c:when test="${not empty profile.linkedinUrl}">
                                    <a href="${profile.linkedinUrl}" target="_blank" class="link-external">${profile.linkedinUrl}</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Chưa cung cấp</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="detail-field">
                            <label>Website</label>
                            <c:choose>
                                <c:when test="${not empty profile.websiteUrl}">
                                    <a href="${profile.websiteUrl}" target="_blank" class="link-external">${profile.websiteUrl}</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Chưa cung cấp</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="detail-field">
                            <label>Ảnh đại diện</label>
                            <c:choose>
                                <c:when test="${not empty profile.avatarUrl}">
                                    <a href="${profile.avatarUrl}" target="_blank" class="link-external">Xem ảnh</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Chưa cung cấp</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- CV File -->
                    <div class="detail-field detail-field--full">
                        <label>File CV</label>
                        <c:choose>
                            <c:when test="${not empty profile.cvFilePath}">
                                <a href="${pageContext.request.contextPath}${profile.cvFilePath}" target="_blank" class="btn btn--secondary btn--sm">
                                    &#128206; Tải xuống / Xem CV
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted">Không có file CV</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="detail-field detail-field--full">
                        <label>Ngày tạo hồ sơ</label>
                        <span>${profile.createdAt != null ? profile.createdAt.toString().substring(0, 19).replace('T', ' ') : ''}</span>
                    </div>
                </div>

                <!-- Action Buttons -->
                <c:if test="${profile.status == 'pending'}">
                <div class="detail-actions">
                    <form method="post" action="${pageContext.request.contextPath}/admin/teacher-approvals/approve" class="action-form" onsubmit="return confirm('Xác nhận DUYỆT tài khoản giảng viên này?');">
                        <input type="hidden" name="id" value="${profile.id}">
                        <button type="submit" class="btn btn--success btn--lg">
                            &#10003; Duyệt tài khoản
                        </button>
                    </form>

                    <button type="button" class="btn btn--danger btn--lg" data-bs-toggle="modal" data-bs-target="#rejectModal">
                        &#10007; Từ chối
                    </button>
                </div>
                </c:if>

                <c:if test="${profile.status != 'pending'}">
                <div class="detail-status">
                    <div class="status-badge status-badge--${profile.status == 'approved' ? 'success' : 'danger'}">
                        <span class="status-badge__icon">${profile.status == 'approved' ? '&#10003;' : '&#10007;'}</span>
                        <span>Đã ${profile.status == 'approved' ? 'DUYỆT' : 'TỪ CHỐI'}</span>
                    </div>
                    <c:if test="${not empty profile.adminNote}">
                        <div class="admin-note">
                            <strong>Ghi chú admin:</strong>
                            <p>${profile.adminNote}</p>
                        </div>
                    </c:if>
                    <c:if test="${not empty profile.reviewedAt}">
                        <div class="reviewed-info">
                            Xử lý bởi Admin ID: ${profile.reviewedBy} lúc ${profile.reviewedAt.toString().substring(0, 19).replace('T', ' ')}
                        </div>
                    </c:if>
                </div>
                </c:if>

            </div>

        </div>
    </main>

</div>

<!-- Reject Modal -->
<div class="modal fade" id="rejectModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Từ chối tài khoản giảng viên</h5>
                <button type="button" class="modal-close" data-bs-dismiss="modal">&times;</button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/teacher-approvals/reject">
                <input type="hidden" name="id" value="${profile.id}">
                <div class="modal-body">
                    <p class="text-warning">Hành động này sẽ từ chối tài khoản giảng viên. Tài khoản sẽ bị xóa khỏi hệ thống.</p>
                    <div class="form-group">
                        <label for="adminNote">Lý do từ chối (bắt buộc)</label>
                        <textarea id="adminNote" name="adminNote" rows="4" class="form-control" required placeholder="Nhập lý do từ chối..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn--secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn--danger">Xác nhận từ chối</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Simple modal toggle
    document.querySelectorAll('[data-bs-toggle="modal"]').forEach(btn => {
        btn.addEventListener('click', function() {
            const target = document.querySelector(this.dataset.bsTarget);
            if (target) target.classList.add('show');
        });
    });

    document.querySelectorAll('[data-bs-dismiss="modal"]').forEach(btn => {
        btn.addEventListener('click', function() {
            this.closest('.modal').classList.remove('show');
        });
    });

    // Close modal on backdrop click
    document.querySelectorAll('.modal').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) this.classList.remove('show');
        });
    });
</script>

</body>
</html>