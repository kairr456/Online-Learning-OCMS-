/**
 * OCMS - Admin Payout Management JavaScript (payouts.js)
 * Xử lý popup VietQR duyệt rút tiền, popup từ chối rút tiền và thông báo hệ thống
 */

const processModalEl = document.getElementById('processModal');
const rejectModalEl = document.getElementById('rejectModal');

/**
 * Mở modal Quét VietQR và xác nhận chuyển tiền
 */
function openProcessModal(id, teacherName, amount, bankCode, bankName, accountNumber, accountHolder) {
    const modalPayoutId = document.getElementById('modalPayoutId');
    const modalTeacherName = document.getElementById('modalTeacherName');
    const modalBankName = document.getElementById('modalBankName');
    const modalAccountNumber = document.getElementById('modalAccountNumber');
    const modalAccountHolder = document.getElementById('modalAccountHolder');
    const modalAmountDisplay = document.getElementById('modalAmountDisplay');
    const vietQrImg = document.getElementById('vietQrImg');
    const transactionCodeInput = document.getElementById('transactionCodeInput');

    if (modalPayoutId) modalPayoutId.value = id;
    if (modalTeacherName) modalTeacherName.innerText = teacherName;
    if (modalBankName) modalBankName.innerText = bankName + ' (' + bankCode + ')';
    if (modalAccountNumber) modalAccountNumber.innerText = accountNumber;
    if (modalAccountHolder) modalAccountHolder.innerText = accountHolder;
    if (modalAmountDisplay) {
        modalAmountDisplay.innerText = Number(amount).toLocaleString('vi-VN') + ' ₫';
    }

    if (transactionCodeInput) {
        transactionCodeInput.value = '';
    }

    // Tạo URL VietQR động theo chuẩn Napas247
    if (vietQrImg) {
        const cleanBank = encodeURIComponent(bankCode || '');
        const cleanAcc = encodeURIComponent(accountNumber || '');
        const cleanAmt = encodeURIComponent(amount || 0);
        const cleanInfo = encodeURIComponent('PAYOUT ' + id);
        vietQrImg.src = 'https://img.vietqr.io/image/' + cleanBank + '-' + cleanAcc + '-compact.png?amount=' + cleanAmt + '&addInfo=' + cleanInfo;
    }

    const modal = document.getElementById('processModal');
    if (modal) {
        modal.style.display = 'flex';
    }
}

/**
 * Đóng modal Quét VietQR
 */
function closeProcessModal() {
    const modal = document.getElementById('processModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

/**
 * Mở modal Từ chối yêu cầu rút tiền
 */
function openRejectModal(id, teacherName, amount) {
    const rejectPayoutId = document.getElementById('rejectPayoutId');
    const rejectTeacherName = document.getElementById('rejectTeacherName');
    const rejectAmountDisplay = document.getElementById('rejectAmountDisplay');
    const rejectReason = document.getElementById('rejectReason');

    if (rejectPayoutId) rejectPayoutId.value = id;
    if (rejectTeacherName) rejectTeacherName.innerText = teacherName;
    if (rejectAmountDisplay) {
        rejectAmountDisplay.innerText = Number(amount).toLocaleString('vi-VN') + ' ₫';
    }
    if (rejectReason) {
        rejectReason.value = '';
    }

    const modal = document.getElementById('rejectModal');
    if (modal) {
        modal.style.display = 'flex';
    }
}

/**
 * Đóng modal Từ chối
 */
function closeRejectModal() {
    const modal = document.getElementById('rejectModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

/**
 * Hiển thị thông báo Toast
 */
function showPayoutToast(msg, type) {
    if (typeof Toastify === 'function') {
        Toastify({
            text: msg,
            duration: 4000,
            close: true,
            gravity: "top",
            position: "right",
            backgroundColor: type === "error" ? "#ef4444" : (type === "warning" ? "#f59e0b" : "#10b981")
        }).showToast();
    } else {
        alert(msg);
    }
}

// Đóng modal khi bấm ra vùng bên ngoài nội dung modal
window.addEventListener('click', function(e) {
    const processModal = document.getElementById('processModal');
    const rejectModal = document.getElementById('rejectModal');

    if (processModal && e.target === processModal) {
        closeProcessModal();
    }
    if (rejectModal && e.target === rejectModal) {
        closeRejectModal();
    }
});

// Điều hướng phân trang (Pagination)
function goToPage(page) {
    const pageInput = document.getElementById('pageInput');
    const filterForm = document.getElementById('payoutFilterForm');
    if (pageInput && filterForm) {
        pageInput.value = page;
        filterForm.submit();
    }
}
window.goToPage = goToPage;

// Khởi chạy khi tài liệu tải xong
document.addEventListener("DOMContentLoaded", function() {
    const container = document.querySelector('.account-manager-container') || document.body;
    const flashMsg = container.getAttribute('data-flash-message');
    const flashType = container.getAttribute('data-flash-type');

    if (flashMsg && flashMsg.trim() !== '') {
        showPayoutToast(flashMsg, flashType);
    }
});
