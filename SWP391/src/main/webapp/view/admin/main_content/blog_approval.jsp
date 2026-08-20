<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="account-manager-container">
    <div class="dashboard-title">Quản lý Phê duyệt Blog</div>

    <!-- Quick Stats Cards -->
    <div class="blog-stats-grid">
        <a href="javascript:void(0)" onclick="filterByStatus('Inactive')" class="blog-stat-box ${currentStatus == 'Inactive' ? 'active-filter' : ''}">
            <div>
                <div class="stat-label">Chưa phê duyệt</div>
                <div class="stat-val stat-val--pending">${inactiveCount != null ? inactiveCount : 0}</div>
            </div>
            <div class="blog-stat-icon pending">
                <i class="fa-solid fa-hourglass-half"></i>
            </div>
        </a>

        <a href="javascript:void(0)" onclick="filterByStatus('Active')" class="blog-stat-box ${currentStatus == 'Active' ? 'active-filter' : ''}">
            <div>
                <div class="stat-label">Đã duyệt</div>
                <div class="stat-val stat-val--active">${activeCount != null ? activeCount : 0}</div>
            </div>
            <div class="blog-stat-icon active">
                <i class="fa-solid fa-circle-check"></i>
            </div>
        </a>

        <a href="javascript:void(0)" onclick="filterByStatus('all')" class="blog-stat-box ${currentStatus == 'all' || empty currentStatus ? 'active-filter' : ''}">
            <div>
                <div class="stat-label">Tổng bài viết</div>
                <div class="stat-val stat-val--total">${totalCount != null ? totalCount : 0}</div>
            </div>
            <div class="blog-stat-icon total">
                <i class="fa-solid fa-newspaper"></i>
            </div>
        </a>
    </div>

    <!-- Top Filter Bar -->
    <form id="blogFilterForm" action="${pageContext.request.contextPath}/admin/blog-approval" method="GET" class="toolbar-section">
        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">

        <!-- Tìm kiếm theo tiêu đề, tóm tắt, tên tác giả, email -->
        <div class="search-box">
            <input type="text" name="keyword" value="${keyword}" placeholder="Tìm tiêu đề, tóm tắt, tác giả..."/>
            <button type="submit" class="btn-search" title="Tìm kiếm">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <div class="filter-group">
            <!-- Lọc theo Trạng thái -->
            <select name="status" id="statusSelect" class="filter-select" onchange="submitFilter()">
                <option value="all" ${currentStatus == 'all' || empty currentStatus ? 'selected' : ''}>Tất cả</option>
                <option value="Inactive" ${currentStatus == 'Inactive' ? 'selected' : ''}>Chưa phê duyệt</option>
                <option value="Active" ${currentStatus == 'Active' ? 'selected' : ''}>Đã duyệt</option>
            </select>

            <!-- Lọc theo Danh mục Blog -->
            <select name="categoryId" class="filter-select" onchange="submitFilter()">
                <option value="">Tất cả danh mục</option>
                <c:if test="${not empty blogCategories}">
                    <c:forEach var="entry" items="${blogCategories}">
                        <option value="${entry.key}" ${categoryId == entry.key ? 'selected' : ''}><c:out value="${entry.value}" /></option>
                    </c:forEach>
                </c:if>
            </select>
        </div>
    </form>

    <!-- Bảng danh sách bài viết duyệt -->
    <div class="table-responsive">
        <table class="account-table">
            <thead>
                <tr>
                    <th style="width: 50px;">ID</th>
                    <th>Bài Viết</th>
                    <th>Tác Giả</th>
                    <th>Danh Mục</th>
                    <th>Ngày Tạo</th>
                    <th>Trạng Thái</th>
                    <th style="text-align: center; width: 230px;">Hành Động</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty blogList}">
                        <c:forEach var="b" items="${blogList}">
                            <fmt:formatDate value="${b.createdDate}" pattern="dd/MM/yyyy HH:mm" var="createdDateStr" />
                            <c:set var="isActive" value="${'Active' == b.status}" />
                            
                            <tr>
                                <td><strong>#${b.id}</strong></td>
                                <td>
                                    <div class="blog-post-cell">
                                        <c:choose>
                                            <c:when test="${not empty b.thumbnail}">
                                                <img src="${b.thumbnail}" alt="${fn:escapeXml(b.title)}" class="blog-post-thumb" onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'blog-post-thumb-fallback\'><i class=\'fa-regular fa-newspaper\'></i></div>';">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="blog-post-thumb-fallback">
                                                    <i class="fa-regular fa-newspaper"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="blog-post-info">
                                            <a href="javascript:void(0)" onclick="openPreview('${b.id}')" class="blog-post-title" title="Nhấn để xem trước nội dung">
                                                <c:out value="${b.title}" />
                                            </a>
                                            <div class="blog-post-brief"><c:out value="${b.briefInfo}" /></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="blog-author-cell">
                                        <div class="blog-author-name"><c:out value="${not empty b.authorName ? b.authorName : 'Người dùng #' += b.author}" /></div>
                                        <div class="blog-author-email"><c:out value="${b.authorEmail}" /></div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge-category">
                                        <i class="fa-solid fa-tag"></i> <c:out value="${not empty b.categoryName ? b.categoryName : 'Chung'}" />
                                    </span>
                                </td>
                                <td>
                                    <small><c:out value="${createdDateStr}" /></small>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${isActive}">
                                            <span class="badge-blog-status active">
                                                <span class="badge-dot active"></span> Đã duyệt
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-blog-status pending">
                                                <span class="badge-dot pending"></span> Chưa phê duyệt
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align: center;">
                                    <div class="blog-action-group">
                                        <!-- Nút Xem trước bài viết -->
                                        <button type="button" class="btn-blog-action preview" title="Xem trước nội dung chi tiết" onclick="openPreview('${b.id}')">
                                            <i class="fa-regular fa-eye"></i> Xem
                                        </button>

                                        <!-- Nút Duyệt (chỉ hiện khi bài viết chưa duyệt) -->
                                        <c:if test="${!isActive}">
                                            <button type="button" class="btn-blog-action approve" title="Duyệt bài viết" onclick="approveBlog('${b.id}', '${fn:escapeXml(b.title)}')">
                                                <i class="fa-solid fa-check"></i> Duyệt
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="payout-empty-state">
                                <i class="fa-regular fa-folder-open payout-empty-icon"></i>
                                Không tìm thấy bài viết nào phù hợp với bộ lọc.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <!-- Phân trang (Pagination) -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage - 1}')" title="Trang trước">
                    <i class="fa-solid fa-angle-left"></i>
                </a>
            </c:if>
            <c:forEach var="i" begin="1" end="${totalPages}">
                <a href="javascript:void(0)" class="page-link ${currentPage == i ? 'active' : ''}" onclick="goToPage('${i}')">${i}</a>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage + 1}')" title="Trang sau">
                    <i class="fa-solid fa-angle-right"></i>
                </a>
            </c:if>
        </div>
    </c:if>
</div>

<!-- ===== MODAL QUICK PREVIEW BÀI VIẾT ===== -->
<div id="previewModal" class="modal modal-hidden" style="display:none; align-items:center; justify-content:center; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); z-index:9999;">
    <div class="modal-preview-dialog">
        <span class="modal-close" onclick="closePreview()" style="position:absolute; top:18px; right:20px; font-size:26px; cursor:pointer; color:#64748B;">&times;</span>
        
        <div class="preview-hero-meta">
            <span id="previewCategory" class="badge-category">Chung</span>
            <span id="previewStatusBadge" class="badge-blog-status pending">Chưa phê duyệt</span>
            <span style="font-size:12.5px; color:#64748B;"><i class="fa-regular fa-clock"></i> <span id="previewDate"></span></span>
        </div>

        <h2 id="previewTitle" class="preview-title">Tiêu đề bài viết</h2>

        <div class="preview-author-box">
            <div class="preview-author-info">
                <div class="preview-author-avatar"><i class="fa-solid fa-user"></i></div>
                <div>
                    <strong id="previewAuthorName" style="font-size:14px; color:#0F172A;">Tác giả</strong>
                    <div id="previewAuthorEmail" style="font-size:12px; color:#64748B;">email@example.com</div>
                </div>
            </div>
        </div>

        <div id="previewBrief" class="preview-brief-box">
            Tóm tắt bài viết...
        </div>

        <div class="preview-thumb-wrap">
            <img id="previewThumb" src="" alt="Thumbnail preview" class="preview-thumb-img" onerror="this.style.display='none'">
        </div>

        <div id="previewBody" class="preview-body-content">
            Nội dung chi tiết bài viết...
        </div>

        <div class="preview-action-footer">
            <button type="button" class="btn-blog-action approve" id="btnApproveInPreview" style="padding:10px 20px; font-size:14px;">
                <i class="fa-solid fa-check"></i> Duyệt bài
            </button>
            <button type="button" class="btn-modal-close-custom" onclick="closePreview()" style="padding:10px 18px; border-radius:8px; border:none; cursor:pointer; font-weight:600;">
                Đóng
            </button>
        </div>
    </div>
</div>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/admin/blog_approval.js"></script>
