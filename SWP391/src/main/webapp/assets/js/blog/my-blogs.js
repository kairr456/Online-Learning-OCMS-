/**
 * OCMS - My Blogs JavaScript (my-blogs.js)
 * Quản lý tìm kiếm, lọc danh mục/trạng thái và popup xác nhận xóa bài viết
 */

/**
 * Lọc bảng danh sách bài viết theo từ khóa, danh mục và trạng thái
 */
function filterTable() {
    var keywordEl = document.getElementById('filterKeyword');
    var categoryEl = document.getElementById('filterCategory');
    var statusEl = document.getElementById('filterStatus');

    var keyword = keywordEl ? keywordEl.value.toLowerCase().trim() : '';
    var category = categoryEl ? categoryEl.value : '';
    var status = statusEl ? statusEl.value : '';

    var table = document.getElementById('myBlogTable');
    if (!table) return;
    var tbody = table.getElementsByTagName('tbody')[0];
    if (!tbody) return;
    var rows = tbody.getElementsByTagName('tr');

    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        var rowTitle = (row.getAttribute('data-title') || '').toLowerCase();
        var rowCat = row.getAttribute('data-cat') || '';
        var rowStatus = row.getAttribute('data-status') || '';

        var matchKeyword = keyword === '' || rowTitle.indexOf(keyword) > -1;
        var matchCategory = category === '' || rowCat === category;
        var matchStatus = status === '' || rowStatus === status || (status === 'Rejected' && rowStatus === 'Reject');

        if (matchKeyword && matchCategory && matchStatus) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    }
}

/**
 * Mở modal xác nhận xóa bài viết
 */
function confirmDelete(blogId, title, contextPath) {
    var titleEl = document.getElementById('deleteBlogTitle');
    var btnConfirm = document.getElementById('btnConfirmDelete');
    var modal = document.getElementById('deleteModal');

    if (titleEl) {
        titleEl.innerText = '"' + title + '"';
    }
    if (btnConfirm) {
        var ctx = contextPath || '';
        btnConfirm.href = ctx + '/blogs-delete?id=' + blogId;
    }
    if (modal) {
        modal.style.display = 'flex';
    }
}

/**
 * Đóng modal xác nhận xóa
 */
function closeDeleteModal(e) {
    var modal = document.getElementById('deleteModal');
    if (!modal) return;

    if (!e || e.target.id === 'deleteModal' || (e.target && e.target.classList && e.target.classList.contains('btn-modal-cancel'))) {
        modal.style.display = 'none';
    }
}
