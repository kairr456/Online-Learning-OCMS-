/**
 * OCMS - Admin Payout Management JavaScript (payouts.js)
 * Xử lý popup VietQR duyệt rút tiền, popup từ chối rút tiền và thông báo hệ thống
 */

const processModalEl = document.getElementById('processModal');
const rejectModalEl = document.getElementById('rejectModal');

/**
 * Kiểm tra và hiển thị lỗi cho trường Mã giao dịch (không được để trống hoặc chỉ có khoảng trắng)
 */
function validateTransactionCode(el) {
    if (!el) return true;
    const rawVal = el.value || '';
    const trimmed = rawVal.trim();
    const err = document.getElementById('transactionCodeError');

    if (trimmed.length === 0) {
        if (rawVal.length > 0) {
            if (err) err.innerText = "Mã giao dịch không được chỉ chứa khoảng trắng.";
        } else {
            if (err) err.innerText = "Vui lòng nhập mã giao dịch ngân hàng / Ủy nhiệm chi.";
        }
        if (err) err.style.display = "block";
        el.classList.add("is-invalid");
        return false;
    } else {
        if (err) err.style.display = "none";
        el.classList.remove("is-invalid");
        return true;
    }
}

/**
 * Kiểm tra và hiển thị lỗi cho trường Lý do từ chối (không được để trống hoặc chỉ có khoảng trắng, tối đa 100 ký tự)
 */
function validateRejectReason(el) {
    if (!el) return true;
    const maxChars = 100;
    const rawVal = el.value || '';
    const noSpaceStr = rawVal.replace(/\s/g, '');
    const count = noSpaceStr.length; // Khoảng trắng không tính là ký tự hợp lệ
    const err = document.getElementById('rejectReasonError');
    const counter = document.getElementById('rejectReasonCount');

    if (counter) {
        counter.innerText = count + '/' + maxChars + ' ký tự';
        if (count > maxChars) {
            counter.style.color = '#dc2626';
            counter.style.fontWeight = 'bold';
        } else {
            counter.style.color = '#64748b';
            counter.style.fontWeight = 'normal';
        }
    }

    if (trimmed.length === 0) {
        if (rawVal.length > 0) {
            if (err) {
                err.innerText = "Lý do từ chối không được chỉ chứa khoảng trắng.";
                err.style.display = "block";
            }
            el.classList.add("is-invalid");
        } else {
            if (err) {
                err.style.display = "none";
                err.innerText = "";
            }
            el.classList.remove("is-invalid");
        }
        return false;
    } else if (count > maxChars) {
        if (err) err.innerText = "Lý do từ chối không được vượt quá " + maxChars + " ký tự (hiện tại: " + count + " ký tự).";
        if (err) err.style.display = "block";
        el.classList.add("is-invalid");
        return false;
    } else {
        if (err) err.style.display = "none";
        el.classList.remove("is-invalid");
        return true;
    }
}

/**
 * Mở modal Quét VietQR và xác nhận chuyển tiền
 */
function openProcessModal(id, teacherName, amount, bankCode, bankName, accountNumber, accountHolder, note) {
    const modalPayoutId = document.getElementById('modalPayoutId');
    const modalTeacherName = document.getElementById('modalTeacherName');
    const modalBankName = document.getElementById('modalBankName');
    const modalAccountNumber = document.getElementById('modalAccountNumber');
    const modalAccountHolder = document.getElementById('modalAccountHolder');
    const modalNoteRow = document.getElementById('modalNoteRow');
    const modalTeacherNote = document.getElementById('modalTeacherNote');
    const modalAmountDisplay = document.getElementById('modalAmountDisplay');
    const vietQrImg = document.getElementById('vietQrImg');
    const transactionCodeInput = document.getElementById('transactionCodeInput');
    const transactionCodeError = document.getElementById('transactionCodeError');

    if (modalPayoutId) modalPayoutId.value = id;
    if (modalTeacherName) modalTeacherName.innerText = teacherName;
    if (modalBankName) modalBankName.innerText = bankName + ' (' + bankCode + ')';
    const maskAcc = (accountNumber && accountNumber.trim().length > 4)
        ? (accountNumber.trim().substring(0, accountNumber.trim().length - 4) + '****')
        : (accountNumber ? '****' : '-');
    if (modalAccountNumber) modalAccountNumber.innerText = maskAcc;
    if (modalAccountHolder) modalAccountHolder.innerText = accountHolder;
    if (modalAmountDisplay) {
        modalAmountDisplay.innerText = Number(amount).toLocaleString('vi-VN') + ' ₫';
    }

    if (modalNoteRow && modalTeacherNote) {
        if (note && note.trim() !== '') {
            modalTeacherNote.innerText = note;
            modalNoteRow.style.display = 'flex';
        } else {
            modalTeacherNote.innerText = '-';
            modalNoteRow.style.display = 'none';
        }
    }

    if (transactionCodeInput) {
        transactionCodeInput.value = '';
        transactionCodeInput.classList.remove('is-invalid');
    }
    if (transactionCodeError) {
        transactionCodeError.style.display = 'none';
        transactionCodeError.innerText = '';
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
function openRejectModal(id, teacherName, amount, note) {
    const rejectPayoutId = document.getElementById('rejectPayoutId');
    const rejectTeacherName = document.getElementById('rejectTeacherName');
    const rejectAmountDisplay = document.getElementById('rejectAmountDisplay');
    const rejectNoteRow = document.getElementById('rejectNoteRow');
    const rejectTeacherNote = document.getElementById('rejectTeacherNote');
    const rejectReason = document.getElementById('rejectReason');
    const rejectReasonError = document.getElementById('rejectReasonError');
    const rejectReasonCount = document.getElementById('rejectReasonCount');

    if (rejectPayoutId) rejectPayoutId.value = id;
    if (rejectTeacherName) rejectTeacherName.innerText = teacherName;
    if (rejectAmountDisplay) {
        rejectAmountDisplay.innerText = Number(amount).toLocaleString('vi-VN') + ' ₫';
    }

    if (rejectNoteRow && rejectTeacherNote) {
        if (note && note.trim() !== '') {
            rejectTeacherNote.innerText = note;
            rejectNoteRow.style.display = 'block';
        } else {
            rejectTeacherNote.innerText = '-';
            rejectNoteRow.style.display = 'none';
        }
    }

    if (rejectReason) {
        rejectReason.value = '';
        rejectReason.classList.remove('is-invalid');
    }
    if (rejectReasonError) {
        rejectReasonError.style.display = 'none';
        rejectReasonError.innerText = '';
    }
    if (rejectReasonCount) {
        rejectReasonCount.innerText = '0/100 ký tự';
        rejectReasonCount.style.color = '#64748b';
        rejectReasonCount.style.fontWeight = 'normal';
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

    // Gắn submit listener cho form Duyệt rút tiền
    const approveForm = document.getElementById('approvePayoutForm');
    if (approveForm) {
        approveForm.addEventListener('submit', function (e) {
            const input = document.getElementById('transactionCodeInput');
            if (!validateTransactionCode(input)) {
                e.preventDefault();
                if (input) input.focus();
                return false;
            }
        });
    }

    // Gắn submit listener cho form Từ chối rút tiền
    const rejectForm = document.getElementById('rejectPayoutForm');
    if (rejectForm) {
        rejectForm.addEventListener('submit', function (e) {
            const textarea = document.getElementById('rejectReason');
            if (!validateRejectReason(textarea)) {
                e.preventDefault();
                if (textarea) textarea.focus();
                return false;
            }
        });
    }
});
