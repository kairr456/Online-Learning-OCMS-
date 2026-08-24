/**
 * OCMS - Checkout JavaScript (checkout.js)
 * Quản lý toàn bộ tương tác giao diện và kiểm tra dữ liệu thanh toán
 */

document.addEventListener('DOMContentLoaded', function () {
    // 1. Lắng nghe sự kiện chuyển đổi Phương thức thanh toán
    const radioCard = document.getElementById('radioCard');
    const radioQR = document.getElementById('radioQR');
    const cardHeaderClick = document.getElementById('cardHeaderClick');
    const qrHeaderClick = document.getElementById('qrHeaderClick');
    const paymentInput = document.getElementById('selectedPaymentMethodInput');

    if (radioCard) {
        radioCard.addEventListener('change', function () {
            if (this.checked) selectPaymentMethod('Card');
        });
    }
    if (radioQR) {
        radioQR.addEventListener('change', function () {
            if (this.checked) selectPaymentMethod('QR_CODE');
        });
    }
    if (cardHeaderClick) {
        cardHeaderClick.addEventListener('click', function () {
            selectPaymentMethod('Card');
        });
    }
    if (qrHeaderClick) {
        qrHeaderClick.addEventListener('click', function () {
            selectPaymentMethod('QR_CODE');
        });
    }

    // Khởi tạo trạng thái nút ban đầu
    const initialMethod = paymentInput?.value || (radioQR?.checked ? 'QR_CODE' : 'Card');
    selectPaymentMethod(initialMethod);

    // 2. Định dạng Số thẻ tín dụng (Tự động chèn khoảng trắng sau mỗi 4 số, tối đa 20 số)
    const cardNumInput = document.getElementById('cardNumber');
    if (cardNumInput) {
        cardNumInput.addEventListener('input', function () {
            let val = this.value.replace(/\D/g, '').substring(0, 20);
            let formatted = '';
            for (let i = 0; i < val.length; i++) {
                if (i > 0 && i % 4 === 0) formatted += ' ';
                formatted += val[i];
            }
            this.value = formatted;
        });
    }

    // 3. Định dạng Ngày hết hạn (MM/YY)
    const expiryInput = document.getElementById('expiry');
    if (expiryInput) {
        expiryInput.addEventListener('input', function () {
            let val = this.value.replace(/\D/g, '').substring(0, 4);
            if (val.length >= 3) {
                this.value = val.substring(0, 2) + '/' + val.substring(2);
            } else {
                this.value = val;
            }
        });
    }

    // 4. Định dạng Mã CVC / CVV (Chỉ cho phép 3 số)
    const cvcInput = document.getElementById('cvc');
    if (cvcInput) {
        cvcInput.addEventListener('input', function () {
            this.value = this.value.replace(/\D/g, '').substring(0, 3);
        });
    }

    // 5. Nút điền thông tin thẻ Test
    const btnFillTest = document.getElementById('btnFillTestCard');
    if (btnFillTest) {
        btnFillTest.addEventListener('click', fillTestCard);
    }

    // 6. Các nút sao chép thông tin ngân hàng
    const btnCopyAccNo = document.getElementById('btnCopyAccNo');
    if (btnCopyAccNo) {
        btnCopyAccNo.addEventListener('click', function () {
            const accNo = document.getElementById('bankAccNo')?.innerText || '0357899999';
            copyText(accNo.trim(), 'Đã sao chép số tài khoản!');
        });
    }

    const btnCopyTransferContent = document.getElementById('btnCopyTransferContent');
    if (btnCopyTransferContent) {
        btnCopyTransferContent.addEventListener('click', function () {
            const content = document.getElementById('transferContent')?.innerText || '';
            copyText(content.trim(), 'Đã sao chép nội dung chuyển khoản!');
        });
    }

    // 7. Validate dữ liệu khi submit form thanh toán
    const checkoutForm = document.getElementById('checkoutForm');
    if (checkoutForm) {
        checkoutForm.addEventListener('submit', function (e) {
            const method = document.getElementById('selectedPaymentMethodInput')?.value || 'Card';
            let isValid = true;

            // Xóa các lỗi cũ trước đó
            document.querySelectorAll('.field-error').forEach(el => {
                el.style.display = 'none';
                el.textContent = '';
            });
            document.querySelectorAll('.form-control, .form-select').forEach(el => el.classList.remove('input-error'));

            function showError(inputId, errorId, message) {
                const inputEl = document.getElementById(inputId);
                const errorEl = document.getElementById(errorId);
                if (inputEl) inputEl.classList.add('input-error');
                if (errorEl) {
                    errorEl.textContent = message;
                    errorEl.style.display = 'block';
                }
                isValid = false;
            }

            // A. Kiểm tra Quốc gia / Khu vực
            const countryEl = document.getElementById('country');
            if (!countryEl || !countryEl.value.trim()) {
                showError('country', 'countryError', 'Thiếu trường chưa điền: Vui lòng chọn Quốc gia / Khu vực.');
            }

            // B. Kiểm tra Họ và tên
            const fullNameEl = document.getElementById('fullName');
            const fullNameVal = fullNameEl ? fullNameEl.value.trim() : '';
            if (!fullNameVal) {
                showError('fullName', 'fullNameError', 'Thiếu trường chưa điền: Vui lòng nhập Họ và tên.');
            } else if (/\d/.test(fullNameVal)) {
                showError('fullName', 'fullNameError', 'Họ và tên chỉ được chứa chữ cái, không được chứa số.');
            } else if (!/^[\p{L}\s'-]+$/u.test(fullNameVal)) {
                showError('fullName', 'fullNameError', 'Họ và tên không hợp lệ (chỉ được chứa chữ cái và khoảng trắng).');
            }

            // C. Kiểm tra Email
            const emailEl = document.getElementById('email');
            const emailVal = emailEl ? emailEl.value.trim() : '';
            const emailRegex = /^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$/;
            if (!emailVal) {
                showError('email', 'emailError', 'Thiếu trường chưa điền: Vui lòng nhập Email liên hệ.');
            } else if (!emailRegex.test(emailVal)) {
                showError('email', 'emailError', 'Email liên hệ không đúng định dạng.');
            }

            // D. Kiểm tra Địa chỉ
            const addressEl = document.getElementById('address');
            const addressVal = addressEl ? addressEl.value.trim() : '';
            if (!addressVal) {
                showError('address', 'addressError', 'Thiếu trường chưa điền: Vui lòng nhập Địa chỉ.');
            }

            // E. Kiểm tra Thẻ tín dụng/Ghi nợ (Nếu chọn phương thức Card)
            if (method === 'Card') {
                const cardNumEl = document.getElementById('cardNumber');
                const cardNumRaw = cardNumEl ? cardNumEl.value.trim() : '';
                const cardNumClean = cardNumRaw.replace(/\s+/g, '');
                if (!cardNumRaw) {
                    showError('cardNumber', 'cardNumberError', 'Thiếu trường chưa điền: Vui lòng nhập Số thẻ.');
                } else if (!/^\d+$/.test(cardNumClean)) {
                    showError('cardNumber', 'cardNumberError', 'Số thẻ chỉ được chứa chữ số.');
                } else if (cardNumClean.length < 12 || cardNumClean.length > 20) {
                    showError('cardNumber', 'cardNumberError', 'Số thẻ phải gồm từ 12 đến 20 chữ số.');
                }

                const expiryEl = document.getElementById('expiry');
                const expiryVal = expiryEl ? expiryEl.value.trim() : '';
                const expiryRegex = /^(0[1-9]|1[0-2])\/\d{2}$/;
                if (!expiryVal) {
                    showError('expiry', 'expiryError', 'Thiếu trường chưa điền: Vui lòng nhập Ngày hết hạn thẻ.');
                } else if (!expiryRegex.test(expiryVal)) {
                    showError('expiry', 'expiryError', 'Định dạng ngày hết hạn không hợp lệ (MM/YY, ví dụ: 12/28).');
                }

                const cvcEl = document.getElementById('cvc');
                const cvcVal = cvcEl ? cvcEl.value.trim() : '';
                if (!cvcVal) {
                    showError('cvc', 'cvcError', 'Thiếu trường chưa điền: Vui lòng nhập Mã CVC / CVV.');
                } else if (!/^\d{3}$/.test(cvcVal)) {
                    showError('cvc', 'cvcError', 'Mã CVC / CVV phải gồm đúng 3 chữ số.');
                }

                const cardNameEl = document.getElementById('cardName');
                const cardNameVal = cardNameEl ? cardNameEl.value.trim() : '';
                if (!cardNameVal) {
                    showError('cardName', 'cardNameError', 'Thiếu trường chưa điền: Vui lòng nhập Tên in trên thẻ.');
                } else if (/\d/.test(cardNameVal)) {
                    showError('cardName', 'cardNameError', 'Tên in trên thẻ chỉ được chứa chữ cái, không được chứa số.');
                } else if (!/^[\p{L}\s'-]+$/u.test(cardNameVal)) {
                    showError('cardName', 'cardNameError', 'Tên in trên thẻ chỉ được chứa chữ cái và khoảng trắng.');
                }
            }

            // Nếu có lỗi, chặn gửi form và cuộn đến ô lỗi đầu tiên
            if (!isValid) {
                e.preventDefault();
                const firstErrorEl = document.querySelector('.input-error');
                if (firstErrorEl) {
                    firstErrorEl.focus();
                    firstErrorEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
                showToast("Vui lòng điền đầy đủ và chính xác thông tin thanh toán!", "error");
                return false;
            }

            showToast("Đang xử lý thanh toán và kích hoạt khóa học...", "info");
        });
    }
});

/**
 * Chuyển đổi giữa 2 hình thức thanh toán: Card và QR_CODE
 */
function selectPaymentMethod(method) {
    const cardBox = document.getElementById('cardOptionBox');
    const qrBox = document.getElementById('qrOptionBox');
    const radioCard = document.getElementById('radioCard');
    const radioQR = document.getElementById('radioQR');
    const paymentInput = document.getElementById('selectedPaymentMethodInput');
    const btnSubmit = document.getElementById('btnSubmitPayment');

    if (paymentInput) {
        paymentInput.value = method;
    }

    if (method === 'Card') {
        if (cardBox) cardBox.classList.add('active');
        if (qrBox) qrBox.classList.remove('active');
        if (radioCard) radioCard.checked = true;
        if (btnSubmit) {
            btnSubmit.style.background = '#6f2bd9';
            const totalText = document.getElementById('orderTotalHiddenDisplay')?.value || '';
            btnSubmit.innerHTML = '<i class="fa-solid fa-lock me-2"></i> <span>Pay ' + totalText + '</span>';
        }
    } else if (method === 'QR_CODE') {
        if (qrBox) qrBox.classList.add('active');
        if (cardBox) cardBox.classList.remove('active');
        if (radioQR) radioQR.checked = true;
        if (btnSubmit) {
            btnSubmit.style.background = '#16a34a';
            btnSubmit.innerHTML = '<i class="fa-solid fa-qrcode me-2"></i> <span>Xác nhận đã chuyển khoản</span>';
        }
    }
}

/**
 * Tự động điền dữ liệu thẻ Test
 */
function fillTestCard() {
    const fullName = document.getElementById('fullName')?.value.trim() || 'NGUYEN VAN A';
    const cardNum = document.getElementById('cardNumber');
    const expiry = document.getElementById('expiry');
    const cvc = document.getElementById('cvc');
    const cardName = document.getElementById('cardName');

    if (cardNum) cardNum.value = '4242 4242 4242 4242';
    if (expiry) expiry.value = '12/28';
    if (cvc) cvc.value = '123';
    if (cardName) cardName.value = fullName.toUpperCase();

    showToast("Đã điền thông tin thẻ test!", "info");
}

/**
 * Sao chép văn bản vào bộ nhớ tạm
 */
function copyText(text, successMsg) {
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(function () {
            showToast(successMsg || "Đã sao chép thành công!", "success");
        }).catch(function (err) {
            console.error('Không thể sao chép: ', err);
        });
    }
}

/**
 * Hiển thị thông báo Toastify
 */
function showToast(message, type) {
    if (typeof Toastify === 'undefined') {
        alert(message);
        return;
    }

    let backgroundColor = "#6f2bd9"; // Mặc định tím
    if (type === "error") {
        backgroundColor = "#dc2626"; // Đỏ
    } else if (type === "success") {
        backgroundColor = "#16a34a"; // Xanh lá
    } else if (type === "info") {
        backgroundColor = "#2563eb"; // Xanh dương
    }

    Toastify({
        text: message,
        duration: 3500,
        gravity: "top",
        position: "right",
        backgroundColor: backgroundColor,
        stopOnFocus: true
    }).showToast();
}
