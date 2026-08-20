/**
 * OCMS - Shopping Cart JavaScript (cart.js)
 * Tách biệt hoàn toàn logic JavaScript của giỏ hàng ra khỏi file JSP
 */

document.addEventListener('DOMContentLoaded', function () {
    // 1. Xử lý sự kiện Tìm kiếm khi nhấn Enter
    const searchInput = document.getElementById('cartSearchInput');
    const searchForm = document.getElementById('cartSearchForm');
    if (searchInput && searchForm) {
        searchInput.addEventListener('keydown', function (event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                searchForm.submit();
            }
        });
    }

    // 2. Xử lý sự kiện Sắp xếp khóa học
    const sortSelect = document.getElementById('cartSortSelect');
    if (sortSelect) {
        sortSelect.addEventListener('change', function () {
            applyCartSort(this.value);
        });
    }

    // 3. Xử lý xác nhận xóa khóa học khỏi giỏ hàng
    const removeButtons = document.querySelectorAll('.btn-remove-item');
    removeButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            const itemId = this.getAttribute('data-item-id');
            const courseName = this.getAttribute('data-course-name') || 'khóa học này';
            confirmRemove(itemId, courseName);
        });
    });

    const removeForms = document.querySelectorAll('.remove-item-form');
    removeForms.forEach(function (form) {
        form.addEventListener('submit', function (e) {
            e.preventDefault();
            const itemId = this.querySelector('input[name="itemId"]').value;
            const courseName = this.getAttribute('data-course-name') || 'khóa học này';
            confirmRemove(itemId, courseName);
        });
    });

    // 4. Xử lý xác nhận thanh toán (nếu có checkout form)
    const checkoutForm = document.getElementById('checkoutForm');
    if (checkoutForm) {
        checkoutForm.addEventListener('submit', function (e) {
            e.preventDefault();
            if (confirm('Bạn có chắc chắn muốn tiến hành thanh toán cho tất cả khóa học trong giỏ hàng không?')) {
                this.submit();
            }
        });
    }

    // 5. Hiển thị thông báo Toast từ dữ liệu do CartController truyền xuống
    const toastData = document.getElementById('cartToastData');
    if (toastData) {
        const message = toastData.getAttribute('data-message');
        const type = toastData.getAttribute('data-type') || 'info';
        if (message && message.trim().length > 0) {
            showToast(message, type);
        }
    }
});

/**
 * Hàm điều hướng áp dụng sắp xếp và giữ lại từ khóa tìm kiếm
 */
function applyCartSort(sortVal) {
    const searchInput = document.getElementById('cartSearchInput');
    const searchVal = searchInput ? searchInput.value.trim() : '';
    
    // Lấy context path từ form action hoặc pathname hiện tại
    const searchForm = document.getElementById('cartSearchForm');
    let baseUrl = searchForm ? searchForm.getAttribute('action') : window.location.pathname;
    
    let url = baseUrl + '?page=1&sort=' + encodeURIComponent(sortVal);
    if (searchVal) {
        url += '&search=' + encodeURIComponent(searchVal);
    }
    window.location.href = url;
}

/**
 * Hàm xác nhận xóa khóa học
 */
function confirmRemove(itemId, courseName) {
    if (confirm('Bạn có chắc chắn muốn xóa khóa học "' + courseName + '" khỏi giỏ hàng?')) {
        const form = document.getElementById('removeForm_' + itemId);
        if (form) {
            form.submit();
        }
    }
    return false;
}

/**
 * Hàm hiển thị thông báo Toast đẹp mắt
 */
function showToast(message, type) {
    if (typeof Toastify === 'undefined') {
        alert(message);
        return;
    }

    let backgroundColor = "#28a745"; // Success (Mặc định)
    if (type === "error") {
        backgroundColor = "#dc3545"; // Lỗi
    } else if (type === "info") {
        backgroundColor = "#17a2b8"; // Thông tin
    } else if (type === "warning") {
        backgroundColor = "#ffc107"; // Cảnh báo
    }

    Toastify({
        text: message,
        duration: 4000,
        close: true,
        gravity: "top",
        position: "right",
        backgroundColor: backgroundColor,
        stopOnFocus: true
    }).showToast();
}
