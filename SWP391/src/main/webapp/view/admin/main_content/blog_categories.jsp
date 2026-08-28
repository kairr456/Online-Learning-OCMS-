<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="account-manager-container">
    <div class="dashboard-title">Manage Blog Categories</div>

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${param.msg == 'deleted'}">
        <div class="alert-box alert-success">
            <i class="fa-solid fa-circle-check"></i> Blog category deleted successfully!
        </div>
    </c:if>
    <c:if test="${param.error == 'has_posts'}">
        <div class="alert-box alert-danger">
            <i class="fa-solid fa-triangle-exclamation"></i> Cannot delete this category because it contains existing blog posts!
        </div>
    </c:if>
    <c:if test="${param.error == 'delete_failed'}">
        <div class="alert-box alert-danger">
            <i class="fa-solid fa-triangle-exclamation"></i> Failed to delete blog category. Please try again.
        </div>
    </c:if>

    <!-- ===== Toolbar (Search + Nút Thêm mới) ===== -->
    <form id="filterForm"
          action="${pageContext.request.contextPath}/admin/blog-categories"
          method="GET"
          class="toolbar-section">

        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">

        <!-- Ô tìm kiếm theo tên hoặc mô tả -->
        <div class="search-box">
            <input type="text" name="keyword" value="${param.keyword}" placeholder="Search categories..."/>
            <button type="submit" class="btn-search" title="Search">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <!-- Nút Thêm mới danh mục -->
        <div class="action-btn-group">
            <button type="button" class="btn-add-user" onclick="openAdd()">
                <i class="fa-solid fa-plus"></i> Add Category
            </button>
        </div>
    </form>

    <!-- ===== Bảng danh sách danh mục Blog ===== -->
    <div class="table-responsive">
        <table class="account-table">
            <thead>
                <tr>
                    <th class="col-cat-id">ID</th>
                    <th class="col-cat-name">Name</th>
                    <th>Description</th>
                    <th class="col-cat-blogs">Blogs</th>
                    <th class="col-cat-date">Created Date</th>
                    <th class="col-cat-date">Updated Date</th>
                    <th class="col-cat-actions">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="cat" items="${categoryList}">
                    <tr>
                        <td><strong>${cat.id}</strong></td>
                        <td class="cat-name-cell">${cat.name}</td>
                        <td class="cat-desc-cell" title="${fn:escapeXml(cat.description)}">
                            <c:choose>
                                <c:when test="${cat.description != null && !cat.description.trim().isEmpty()}">
                                    ${cat.description}
                                </c:when>
                                <c:otherwise>
                                    <span class="cat-no-desc">No description</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <span class="badge active cat-badge-count">${cat.blogCount} posts</span>
                        </td>
                        <td>${cat.createdAt}</td>
                        <td>${cat.updatedAt}</td>
                        <td class="action-cell">
                            <!-- Nút Sửa (Mở modal Edit) -->
                            <button type="button" class="btn-action edit" title="Edit"
                                    onclick="openEdit(this)"
                                    data-id="${cat.id}"
                                    data-name="${fn:escapeXml(cat.name)}"
                                    data-description="${fn:escapeXml(cat.description)}">
                                <i class="fa-regular fa-pen-to-square"></i>
                            </button>

                            <!-- Nút Xóa (Chỉ cho phép xóa khi posts = 0) -->
                            <c:choose>
                                <c:when test="${cat.blogCount == 0}">
                                    <a href="${pageContext.request.contextPath}/admin/blog-categories?action=delete&id=${cat.id}"
                                       class="btn-action delete"
                                       onclick="return confirm('Are you sure you want to delete category \'${fn:escapeXml(cat.name)}\'?')"
                                       title="Delete">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button type="button"
                                            class="btn-action delete disabled"
                                            disabled
                                            title="Cannot delete: Category contains ${cat.blogCount} post(s)">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>

                <!-- Trống danh mục -->
                <c:if test="${empty categoryList}">
                    <tr>
                        <td colspan="7" class="cat-empty-state">
                            <i class="fa-regular fa-folder-open cat-empty-icon"></i>
                            No blog categories found.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- ===== Phân trang ===== -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <!-- Trang đầu (<<) -->
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('1')" title="First page">
                    <i class="fa-solid fa-angles-left"></i>
                </a>
            </c:if>

            <!-- Trang trước (<) -->
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage - 1}')" title="Previous page">
                    <i class="fa-solid fa-angle-left"></i>
                </a>
            </c:if>

            <!-- Danh sách số trang -->
            <c:forEach var="i" begin="1" end="${totalPages}">
                <a href="javascript:void(0)" class="page-link ${currentPage == i ? 'active' : ''}" onclick="goToPage('${i}')">${i}</a>
            </c:forEach>

            <!-- Trang sau (>) -->
            <c:if test="${currentPage < totalPages}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage + 1}')" title="Next page">
                    <i class="fa-solid fa-angle-right"></i>
                </a>
            </c:if>

            <!-- Trang cuối (>>) -->
            <c:if test="${currentPage < totalPages}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${totalPages}')" title="Last page">
                    <i class="fa-solid fa-angles-right"></i>
                </a>
            </c:if>
        </div>
    </c:if>
</div>

<!-- ===== Modal Add / Edit Blog Category ===== -->
<div id="categoryModal" class="modal" style="display:none;">
    <div class="modal-content">
        <span class="modal-close" onclick="closeModal()">&times;</span>
        <h3 id="modalTitle" class="cat-modal-title">Add Blog Category</h3>

        <form id="categoryForm">
            <input type="hidden" id="formAction" name="action" value="add">
            <input type="hidden" id="categoryId" name="id">

            <label for="f_name">Category Name <span class="text-danger">*</span></label>
            <input type="text" id="f_name" name="name" placeholder="e.g. Technology, Education..." maxlength="100" required>
            
            <label for="f_description">Description</label>
            <textarea id="f_description" name="description" rows="4" placeholder="Brief summary about this blog category..." maxlength="500" class="cat-textarea"></textarea>

            <p id="modalError" class="cat-modal-error"></p>

            <div class="cat-modal-actions">
                <button type="button" class="btn-cat-cancel" onclick="closeModal()">Cancel</button>
                <button type="submit" id="btnSaveCategory" class="btn-cat-save">Save Category</button>
            </div>
        </form>
    </div>
</div>

<!-- JavaScript xử lý Modal, Fetch API và Phân trang -->
<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/admin/blog_categories.js?v=1.0"></script>
