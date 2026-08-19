<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="account-manager-container">
    <div class="dashboard-title">Manage Blog Categories</div>

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${param.msg == 'deleted'}">
        <div style="background-color: #E7F6EC; color: #1B8F4A; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 8px;">
            <i class="fa-solid fa-circle-check"></i> Blog category deleted successfully!
        </div>
    </c:if>
    <c:if test="${param.error == 'delete_failed'}">
        <div style="background-color: #FDEBEC; color: #D63646; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 8px;">
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
                    <th style="width: 60px;">ID</th>
                    <th style="width: 200px;">Name</th>
                    <th>Description</th>
                    <th style="width: 100px; text-align: center;">Blogs</th>
                    <th style="width: 170px;">Created Date</th>
                    <th style="width: 170px;">Updated Date</th>
                    <th style="width: 110px; text-align: center;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="cat" items="${categoryList}">
                    <tr>
                        <td><strong>${cat.id}</strong></td>
                        <td style="font-weight: 600; color: #161439;">${cat.name}</td>
                        <td style="color: #4B5563; max-width: 350px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${fn:escapeXml(cat.description)}">
                            ${cat.description != null && !cat.description.trim().isEmpty() ? cat.description : '<em style="color:#9CA3AF;">No description</em>'}
                        </td>
                        <td style="text-align: center;">
                            <span class="badge active" style="font-size: 11.5px; padding: 3px 10px;">${cat.blogCount} posts</span>
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

                            <!-- Nút Xóa (Có xác nhận) -->
                            <a href="${pageContext.request.contextPath}/admin/blog-categories?action=delete&id=${cat.id}"
                               class="btn-action delete"
                               onclick="return confirm('Are you sure you want to delete category \'${fn:escapeXml(cat.name)}\'?')"
                               title="Delete">
                                <i class="fa-regular fa-trash-can"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>

                <!-- Trống danh mục -->
                <c:if test="${empty categoryList}">
                    <tr>
                        <td colspan="7" style="text-align:center; padding: 30px; color: #6B7280;">
                            <i class="fa-regular fa-folder-open" style="font-size: 28px; margin-bottom: 8px; display: block; color: #9CA3AF;"></i>
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
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage - 1}')" title="Previous page">
                    <i class="fa-solid fa-angle-left"></i>
                </a>
            </c:if>
            <c:forEach var="i" begin="1" end="${totalPages}">
                <a href="javascript:void(0)" class="page-link ${currentPage == i ? 'active' : ''}" onclick="goToPage('${i}')">${i}</a>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage + 1}')" title="Next page">
                    <i class="fa-solid fa-angle-right"></i>
                </a>
            </c:if>
        </div>
    </c:if>
</div>

<!-- ===== Modal Add / Edit Blog Category ===== -->
<div id="categoryModal" class="modal" style="display:none;">
    <div class="modal-content">
        <span class="modal-close" onclick="closeModal()">&times;</span>
        <h3 id="modalTitle" style="margin-bottom: 15px; color: #161439; font-size: 18px; font-weight: 700;">Add Blog Category</h3>

        <form id="categoryForm">
            <input type="hidden" id="formAction" name="action" value="add">
            <input type="hidden" id="categoryId" name="id">

            <label for="f_name">Category Name <span style="color:#dc3545;">*</span></label>
            <input type="text" id="f_name" name="name" placeholder="e.g. Technology, Education..." maxlength="100" required>

            <label for="f_description">Description</label>
            <textarea id="f_description" name="description" rows="4" placeholder="Brief summary about this blog category..." style="width: 100%; padding: 9px 10px; margin-top: 4px; border: 1px solid #E7E7E7; border-radius: 8px; box-sizing: border-box; outline: none; font-family: inherit; font-size: 14px; resize: vertical;"></textarea>

            <p id="modalError" style="color:#dc3545; font-size: 13px; margin-top: 10px;"></p>

            <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px;">
                <button type="button" onclick="closeModal()" style="margin-top:0; padding: 10px 18px; border: 1px solid #E7E7E7; border-radius: 8px; background: #fff; cursor: pointer; color: #555;">Cancel</button>
                <button type="submit" id="btnSaveCategory" style="margin-top:0; background: #5751E1; border: none; color: #fff; padding: 10px 22px; border-radius: 8px; cursor: pointer; font-weight: 500;">Save Category</button>
            </div>
        </form>
    </div>
</div>

<!-- JavaScript xử lý Modal, Fetch API và Phân trang -->
<script>
    (function () {
        const CONTEXT_PATH = '${pageContext.request.contextPath}';
        const modal = document.getElementById('categoryModal');
        const form = document.getElementById('categoryForm');
        const modalError = document.getElementById('modalError');

        function openAdd() {
            form.reset();
            document.getElementById('formAction').value = 'add';
            document.getElementById('categoryId').value = '';
            document.getElementById('modalTitle').textContent = 'Add Blog Category';
            modalError.textContent = '';
            modal.style.display = 'flex';
            setTimeout(() => document.getElementById('f_name').focus(), 50);
        }

        function openEdit(btn) {
            const d = btn.dataset;
            form.reset();
            document.getElementById('formAction').value = 'edit';
            document.getElementById('categoryId').value = d.id;
            document.getElementById('f_name').value = d.name || '';
            document.getElementById('f_description').value = d.description || '';
            document.getElementById('modalTitle').textContent = 'Edit Blog Category';
            modalError.textContent = '';
            modal.style.display = 'flex';
            setTimeout(() => document.getElementById('f_name').focus(), 50);
        }

        function closeModal() {
            modal.style.display = 'none';
        }

        // Đóng modal khi click ra ngoài vùng modal-content
        window.addEventListener('click', function (e) {
            if (e.target === modal) {
                closeModal();
            }
        });

        // Xử lý submit form thêm/sửa qua fetch POST
        form.addEventListener('submit', function (e) {
            e.preventDefault();
            modalError.textContent = '';
            const btnSave = document.getElementById('btnSaveCategory');
            btnSave.disabled = true;
            btnSave.textContent = 'Saving...';

            const body = new URLSearchParams(new FormData(form)).toString();
            fetch(CONTEXT_PATH + '/admin/blog-categories', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: body
            })
            .then(res => res.json())
            .then(data => {
                btnSave.disabled = false;
                btnSave.textContent = 'Save Category';
                if (data.success) {
                    closeModal();
                    location.reload();
                } else {
                    modalError.textContent = data.error || 'An error occurred while saving category.';
                }
            })
            .catch(err => {
                btnSave.disabled = false;
                btnSave.textContent = 'Save Category';
                modalError.textContent = 'Network error or server error. Please try again.';
            });
        });

        function goToPage(page) {
            document.getElementById('pageInput').value = page;
            document.getElementById('filterForm').submit();
        }

        window.openAdd = openAdd;
        window.openEdit = openEdit;
        window.closeModal = closeModal;
        window.goToPage = goToPage;
    })();
</script>
