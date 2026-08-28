/**
 * OCMS - Order Success JavaScript (order-success.js)
 * Quản lý các tương tác trên trang hoàn tất thanh toán
 */

document.addEventListener('DOMContentLoaded', function () {
    // 1. Xử lý ảnh đại diện khóa học bị lỗi (fallback image)
    const courseImages = document.querySelectorAll('.purchased-course-item img');
    courseImages.forEach(function (img) {
        img.addEventListener('error', function () {
            const parent = this.parentElement;
            if (parent) {
                parent.innerHTML = '<div class="course-thumb-fallback"><i class="fa-solid fa-book-open"></i></div>';
            }
        });
    });

    // 2. Xử lý sao chép Mã đơn hàng (nếu có nút sao chép)
    const btnCopyOrderCode = document.getElementById('btnCopyOrderCode');
    if (btnCopyOrderCode) {
        btnCopyOrderCode.addEventListener('click', function () {
            const orderCode = document.getElementById('orderCodeText')?.innerText || '';
            if (orderCode && navigator.clipboard) {
                navigator.clipboard.writeText(orderCode.trim()).then(function () {
                    showToast("Đã sao chép mã đơn hàng!", "success");
                });
            }
        });
    }

    // 3. Hiển thị thông báo Toastify chào mừng học viên
    if (typeof Toastify !== 'undefined') {
        Toastify({
            text: "🎉 Chúc mừng bạn đã mua khóa học thành công!",
            duration: 4000,
            gravity: "top",
            position: "right",
            backgroundColor: "#16a34a",
            stopOnFocus: true
        }).showToast();
    }
});

/**
 * Hiển thị thông báo Toastify
 */
function showToast(message, type) {
    if (typeof Toastify === 'undefined') {
        alert(message);
        return;
    }

    let backgroundColor = "#16a34a"; // Mặc định xanh lá
    if (type === "error") {
        backgroundColor = "#dc2626";
    } else if (type === "info") {
        backgroundColor = "#2563eb";
    }

    Toastify({
        text: message,
        duration: 3000,
        gravity: "top",
        position: "right",
        backgroundColor: backgroundColor,
        stopOnFocus: true
    }).showToast();
}
