/**
 * OCMS - My Blogs JavaScript (my-blogs.js)
 * Quản lý tìm kiếm, lọc danh mục/trạng thái, phân trang và popup xác nhận xóa bài viết
 */

var BLOGS_PAGE_SIZE = 10;
var currentBlogPage = 1;

/**
 * Lọc bảng danh sách bài viết theo từ khóa, danh mục và trạng thái kết hợp phân trang
 */
function filterTable(resetPage) {
    if (resetPage !== false) {
        currentBlogPage = 1;
    }

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

    var allRows = Array.from(tbody.querySelectorAll('tr[data-title]'));
    var matchingRows = [];

    for (var i = 0; i < allRows.length; i++) {
        var row = allRows[i];
        var rowTitle = (row.getAttribute('data-title') || '').toLowerCase();
        var rowCat = row.getAttribute('data-cat') || '';
        var rowStatus = row.getAttribute('data-status') || '';

        var matchKeyword = keyword === '' || rowTitle.indexOf(keyword) > -1;
        var matchCategory = category === '' || rowCat === category;
        var matchStatus = status === '' || rowStatus === status || (status === 'Rejected' && rowStatus === 'Reject');

        if (matchKeyword && matchCategory && matchStatus) {
            matchingRows.push(row);
        } else {
            row.style.display = 'none';
        }
    }

    // Xử lý thông báo không tìm thấy kết quả
    var noResultRow = document.getElementById('noResultsRow');
    if (matchingRows.length === 0) {
        if (!noResultRow) {
            noResultRow = document.createElement('tr');
            noResultRow.id = 'noResultsRow';
            noResultRow.innerHTML = '<td colspan="7" style="text-align:center; padding: 40px 20px; color: #5B6B82;"><i class="fa-solid fa-magnifying-glass" style="font-size: 24px; margin-bottom: 8px; display:block; opacity:0.5;"></i>Không tìm thấy bài viết nào phù hợp với bộ lọc.</td>';
            tbody.appendChild(noResultRow);
        } else {
            noResultRow.style.display = '';
        }
    } else {
        if (noResultRow) {
            noResultRow.style.display = 'none';
        }
    }

    var totalMatching = matchingRows.length;
    var totalPages = Math.ceil(totalMatching / BLOGS_PAGE_SIZE) || 1;

    if (currentBlogPage > totalPages) {
        currentBlogPage = totalPages;
    }
    if (currentBlogPage < 1) {
        currentBlogPage = 1;
    }

    var startIndex = (currentBlogPage - 1) * BLOGS_PAGE_SIZE;
    var endIndex = startIndex + BLOGS_PAGE_SIZE;

    for (var j = 0; j < matchingRows.length; j++) {
        var indexCell = matchingRows[j].querySelector('.td-index');
        if (indexCell) {
            indexCell.textContent = j + 1;
        }

        if (j >= startIndex && j < endIndex) {
            matchingRows[j].style.display = '';
        } else {
            matchingRows[j].style.display = 'none';
        }
    }

    renderPagination(totalPages, currentBlogPage);
}

/**
 * Chuyển trang
 */
function setBlogPage(page) {
    currentBlogPage = page;
    filterTable(false);
    var card = document.querySelector('.main-card');
    if (card) {
        card.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

/**
 * Hiển thị thanh phân trang theo thiết kế
 */
function renderPagination(totalPages, page) {
    var container = document.getElementById('myBlogPagination');
    if (!container) return;

    if (totalPages <= 1) {
        container.style.display = 'none';
        container.innerHTML = '';
        return;
    }

    container.style.display = 'flex';
    var html = '';

    // Nút Trang đầu (First <<) nếu ở các trang sau
    if (page > 2) {
        html += '<button type="button" class="myblog-page-btn" onclick="setBlogPage(1)" title="Trang đầu"><i class="fa-solid fa-angles-left"></i></button>';
    }

    // Nút Trang trước (Prev <)
    if (page > 1) {
        html += '<button type="button" class="myblog-page-btn" onclick="setBlogPage(' + (page - 1) + ')" title="Trang trước"><i class="fa-solid fa-angle-left"></i></button>';
    }

    // Các trang số xung quanh trang hiện tại
    var startPage = Math.max(1, page - 2);
    var endPage = Math.min(totalPages, page + 2);

    if (endPage - startPage < 4) {
        if (startPage === 1) {
            endPage = Math.min(totalPages, startPage + 4);
        } else if (endPage === totalPages) {
            startPage = Math.max(1, endPage - 4);
        }
    }

    for (var p = startPage; p <= endPage; p++) {
        if (p === page) {
            html += '<button type="button" class="myblog-page-btn active">' + p + '</button>';
        } else {
            html += '<button type="button" class="myblog-page-btn" onclick="setBlogPage(' + p + ')">' + p + '</button>';
        }
    }

    // Nút Trang sau (Next >)
    if (page < totalPages) {
        html += '<button type="button" class="myblog-page-btn" onclick="setBlogPage(' + (page + 1) + ')" title="Trang sau"><i class="fa-solid fa-angle-right"></i></button>';
    }

    // Nút Trang cuối (Last >>)
    if (page < totalPages) {
        html += '<button type="button" class="myblog-page-btn" onclick="setBlogPage(' + totalPages + ')" title="Trang cuối"><i class="fa-solid fa-angles-right"></i></button>';
    }

    container.innerHTML = html;
}

/**
 * Mở modal xác nhận xóa bài viết
 */
function confirmDelete(blogId, title, contextPath) {
    var titleEl = document.getElementById('deleteBlogTitle');
    var btnConfirm = document.getElementById('btnConfirmDelete');
    var modal = document.getElementById('deleteModal');

    if (titleEl) {
        titleEl.textContent = '"' + (title || '') + '"';
    }
    if (btnConfirm) {
        var ctx = contextPath || '';
        btnConfirm.href = ctx + '/blogs-delete?id=' + encodeURIComponent(blogId);
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

// Khởi chạy phân trang ngay khi trang tải xong
document.addEventListener('DOMContentLoaded', function () {
    filterTable(true);
});
