<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.entity.Account, com.entity.Cart, com.entity.CartItem, com.DAO.CartDAO, com.DAO.CartItemDAO, com.DAO.CourseDAO, com.ocms.config.GlobalConfig, java.util.List, java.math.BigDecimal"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Đảm bảo dữ liệu giỏ hàng luôn được nạp đầy đủ kể cả khi truy cập trực tiếp qua checkout.jsp
    Account acc = (Account) session.getAttribute(GlobalConfig.SESSION_ACCOUNT);
    if (acc == null) {
        acc = (Account) session.getAttribute("account");
    }
    if (acc == null) {
        response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
        return;
    }
    
    if (request.getAttribute("cartItems") == null && acc != null) {
        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        CourseDAO courseDAO = new CourseDAO();
        
        Cart userCart = cartDAO.findByAccountId(acc.getId());
        if (userCart == null) {
            userCart = cartDAO.getOrCreateCart(acc.getId());
        }
        
        if (userCart != null && userCart.getId() != null) {
            List<CartItem> items = cartItemDAO.getCartItemsWithCourseDetails(userCart.getId());
            BigDecimal total = cartItemDAO.getCartTotal(userCart.getId());
            
            request.setAttribute("cart", userCart);
            request.setAttribute("cartItems", items);
            request.setAttribute("cartTotal", total != null ? total : BigDecimal.ZERO);
            request.setAttribute("itemCount", items != null ? items.size() : 0);
            request.setAttribute("courseDAO", courseDAO);
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Checkout - OCMS</title>
    <meta name="description" content="Thanh toán khóa học an toàn và nhanh chóng trên OCMS">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSS chung -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">

    <!-- Checkout CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkoutcart/checkout.css">
</head>

<body>

    <!-- HEADER -->
    <jsp:include page="/view/common/header.jsp"></jsp:include>

    <main class="checkout-container">

        <!-- Top Navigation -->
        <div class="checkout-header">
            <h1 class="checkout-title">Thanh toán (Checkout)</h1>
            <a href="${pageContext.request.contextPath}/cart" class="back-to-cart">
                <i class="fa-solid fa-arrow-left"></i> Quay lại Giỏ hàng
            </a>
        </div>

        <!-- Alert messages -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="row g-4">

            <!-- LEFT COLUMN: BILLING & PAYMENT METHODS -->
            <div class="col-lg-7">

                <form action="${pageContext.request.contextPath}/checkout" method="post" id="checkoutForm">
                    <input type="hidden" name="action" value="pay">
                    
                    <!-- Selected Payment Method Value -->
                    <input type="hidden" name="paymentMethod" id="selectedPaymentMethodInput" value="Card">

                    <!-- 1. BILLING ADDRESS -->
                    <div class="section-box">
                        <div class="section-heading">
                            <span>1. Thông tin thanh toán (Billing Address)</span>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Quốc gia / Khu vực <span class="text-danger">*</span></label>
                            <select class="form-select" name="country" id="country">
                                <option value="Vietnam" ${paramCountry == 'Vietnam' || empty paramCountry ? 'selected' : ''}>🇻🇳 Vietnam</option>
                                <option value="United States" ${paramCountry == 'United States' ? 'selected' : ''}>🇺🇸 United States</option>
                                <option value="Japan" ${paramCountry == 'Japan' ? 'selected' : ''}>🇯🇵 Japan</option>
                                <option value="Singapore" ${paramCountry == 'Singapore' ? 'selected' : ''}>🇸🇬 Singapore</option>
                                <option value="Australia" ${paramCountry == 'Australia' ? 'selected' : ''}>🇦🇺 Australia</option>
                            </select>
                            <div class="field-error" id="countryError"></div>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" name="fullName" id="fullName" 
                                       value="${not empty paramFullName ? paramFullName : (sessionScope.account != null ? (not empty sessionScope.account.fullName ? sessionScope.account.fullName : sessionScope.account.username) : '')}" 
                                       placeholder="VD: Nguyễn Văn A">
                                <div class="field-error" id="fullNameError"></div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email liên hệ <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" name="email" id="email" 
                                       value="${not empty paramEmail ? paramEmail : (sessionScope.account != null ? sessionScope.account.email : '')}" 
                                       placeholder="email@example.com">
                                <div class="field-error" id="emailError"></div>
                            </div>
                        </div>

                        <div class="mt-3">
                            <label class="form-label">Địa chỉ <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="address" id="address" 
                                    placeholder="Số nhà, tên đường, quận/huyện..." 
                                    value="${not empty paramAddress ? paramAddress : 'Hồ Chí Minh, Việt Nam'}">
                            <div class="field-error" id="addressError"></div>
                        </div>
                    </div>

                    <!-- 2. PAYMENT METHOD SELECTION -->
                    <div class="section-box">
                        <div class="section-heading">
                            <span>2. Phương thức thanh toán (Payment Method)</span>
                            <span class="secure-badge">
                                <i class="fa-solid fa-shield-halved"></i> Bảo mật 256-bit
                            </span>
                        </div>

                        <!-- OPTION 1: CREDIT / DEBIT CARD -->
                        <div class="payment-option-card active" id="cardOptionBox">
                            <div class="payment-option-header" onclick="selectPaymentMethod('Card')">
                                <div class="payment-radio-wrap">
                                    <input type="radio" name="paymentTypeRadio" id="radioCard" value="Card" checked>
                                    <label for="radioCard" class="mb-0 pay-radio-label">
                                        <i class="fa-regular fa-credit-card me-1 text-primary"></i> Thẻ tín dụng / Ghi nợ (Cards)
                                    </label>
                                </div>
                                <div class="payment-logos">
                                    <span class="badge-card text-primary font-weight-bold">VISA</span>
                                    <span class="badge-card text-danger font-weight-bold">MasterCard</span>
                                    <span class="badge-card text-success font-weight-bold">JCB</span>
                                </div>
                            </div>

                            <!-- CARD FORM BODY -->
                            <div class="payment-option-body" id="cardBody">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <label class="form-label mb-0">Số thẻ (Card Number) <span class="text-danger">*</span></label>
                                    <button type="button" class="btn btn-sm btn-outline-primary py-0 px-2 fill-test-btn" onclick="fillTestCard()">
                                        <i class="fa-solid fa-wand-magic-sparkles me-1"></i> Điền thẻ test
                                    </button>
                                </div>
                                <div class="mb-3">
                                    <div class="input-group">
                                        <input type="text" class="form-control" id="cardNumber" name="cardNumber" 
                                               placeholder="4242 4242 4242 4242" maxlength="19" inputmode="numeric" 
                                               value="${not empty paramCardNumber ? paramCardNumber : '4242 4242 4242 4242'}">
                                        <span class="input-group-text bg-white"><i class="fa-regular fa-credit-card"></i></span>
                                    </div>
                                    <div class="field-error" id="cardNumberError"></div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-6">
                                        <label class="form-label">Ngày hết hạn (MM/YY) <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="expiry" name="expiry" 
                                               placeholder="12/28" maxlength="5" inputmode="numeric" 
                                               value="${not empty paramExpiry ? paramExpiry : '12/28'}">
                                        <div class="field-error" id="expiryError"></div>
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label">Mã CVC / CVV <span class="text-danger">*</span></label>
                                        <input type="password" class="form-control" id="cvc" name="cvc" 
                                               placeholder="123" maxlength="4" inputmode="numeric" 
                                               value="${not empty paramCvc ? paramCvc : '123'}">
                                        <div class="field-error" id="cvcError"></div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Tên in trên thẻ (Name on Card) <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control text-uppercase" id="cardName" name="cardName" 
                                           placeholder="NGUYEN VAN A" 
                                           value="${not empty paramCardName ? paramCardName : (sessionScope.account != null ? (not empty sessionScope.account.fullName ? sessionScope.account.fullName : sessionScope.account.username) : 'NGUYEN VAN A')}">
                                    <div class="field-error" id="cardNameError"></div>
                                </div>

                                <div class="form-check mb-3">
                                    <input class="form-check-input" type="checkbox" id="saveCard" name="saveCard" checked>
                                    <label class="form-check-label text-muted save-card-label" for="saveCard">
                                        Lưu thông tin thẻ an toàn cho lần thanh toán sau
                                    </label>
                                </div>

                                <button type="submit" onclick="selectPaymentMethod('Card')" class="btn-pay-submit btn-pay-submit--card">
                                    <i class="fa-solid fa-lock me-2"></i>
                                    <span>Thanh toán ngay <fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>₫</span>
                                </button>
                            </div>
                        </div>

                        <!-- OPTION 2: QR CODE / VIETQR -->
                        <div class="payment-option-card" id="qrOptionBox">
                            <div class="payment-option-header" onclick="selectPaymentMethod('QR_CODE')">
                                <div class="payment-radio-wrap">
                                    <input type="radio" name="paymentTypeRadio" id="radioQR" value="QR_CODE">
                                    <label for="radioQR" class="mb-0 pay-radio-label">
                                        <i class="fa-solid fa-qrcode me-1 text-success"></i> Thanh toán qua mã QR (VietQR / Mobile Banking)
                                    </label>
                                </div>
                                <div class="payment-logos">
                                    <span class="badge-qr"><i class="fa-solid fa-bolt"></i> Quét mã nhanh</span>
                                </div>
                            </div>

                            <!-- QR CODE BODY -->
                            <div class="payment-option-body" id="qrBody">
                                <div class="qr-payment-box">
                                    
                                    <!-- Dynamic VietQR Image -->
                                    <div class="qr-image-wrapper">
                                        <img src="https://img.vietqr.io/image/MB-0357899999-compact2.png?amount=${cartTotal != null ? cartTotal : '0'}&addInfo=OCMS%20DH${sessionScope.account != null ? sessionScope.account.id : '0'}&accountName=CONG%20TY%20OCMS" 
                                             alt="Mã QR thanh toán ngân hàng" id="vietQrImage">
                                    </div>

                                    <!-- Bank Transfer Details -->
                                    <div class="bank-info-grid">
                                        <div class="bank-info-row">
                                            <span class="bank-info-label">Ngân hàng:</span>
                                            <span class="bank-info-value text-primary">
                                                <i class="fa-solid fa-building-columns"></i> MB Bank (Ngân hàng Quân Đội)
                                            </span>
                                        </div>
                                        <div class="bank-info-row">
                                            <span class="bank-info-label">Chủ tài khoản:</span>
                                            <span class="bank-info-value">CONG TY CONG NGHE OCMS</span>
                                        </div>
                                        <div class="bank-info-row">
                                            <span class="bank-info-label">Số tài khoản:</span>
                                            <span class="bank-info-value">
                                                <span id="bankAccNo">0357899999</span>
                                                <button type="button" class="btn-copy" onclick="copyText('0357899999', 'Đã sao chép số tài khoản!')">
                                                    <i class="fa-regular fa-copy"></i> Sao chép
                                                </button>
                                            </span>
                                        </div>
                                        <div class="bank-info-row">
                                            <span class="bank-info-label">Số tiền:</span>
                                            <span class="bank-info-value text-danger" style="font-size:16px;">
                                                <fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>₫
                                            </span>
                                        </div>
                                        <div class="bank-info-row">
                                            <span class="bank-info-label">Nội dung CK:</span>
                                            <span class="bank-info-value">
                                                <span id="transferContent" class="text-uppercase">OCMS DH${sessionScope.account != null ? sessionScope.account.id : '0'}</span>
                                                <button type="button" class="btn-copy" onclick="copyText(document.getElementById('transferContent').innerText, 'Đã sao chép nội dung!')">
                                                    <i class="fa-regular fa-copy"></i> Sao chép
                                                </button>
                                            </span>
                                        </div>
                                    </div>

                                    <!-- Notice -->
                                    <div class="qr-instruction-alert mb-3">
                                        <i class="fa-solid fa-circle-info me-1"></i>
                                        Quét mã QR bằng App ngân hàng bất kỳ để thanh toán. Bấm nút bên dưới để <strong>Xác nhận mua ngay</strong>.
                                    </div>

                                    <!-- Direct Confirm Button inside QR Box -->
                                    <button type="submit" onclick="selectPaymentMethod('QR_CODE')" class="btn-pay-submit btn-pay-submit--qr">
                                        <i class="fa-solid fa-circle-check me-2"></i>
                                        <span>Xác nhận đã chuyển khoản (Kích hoạt khóa học ngay)</span>
                                    </button>
                                </div>
                            </div>
                        </div>

                    </div>

                </form>

            </div>

            <!-- RIGHT COLUMN: ORDER SUMMARY -->
            <div class="col-lg-5">
                <div class="order-summary-box">
                    <div class="summary-title summary-title--lg">
                        Order summary
                    </div>

                    <!-- Course Items List Preview -->
                    <c:if test="${not empty cartItems}">
                        <div class="mb-3 summary-items-scroll">
                            <c:forEach var="item" items="${cartItems}">
                                <div class="course-item-summary">
                                    <c:set var="cObj" value="${courseDAO != null ? courseDAO.findById(item.courseId) : null}" />
                                    <img src="${not empty cObj.thumbnail ? cObj.thumbnail : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=120'}" 
                                         class="course-thumb-mini" alt="${not empty cObj.name ? cObj.name : 'Course'}">
                                    <div class="course-info-mini">
                                        <div class="course-name-mini" title="${not empty cObj.name ? cObj.name : 'Khóa học'}"><c:out value="${not empty cObj.name ? cObj.name : ('Khóa học #' + item.courseId)}" /></div>
                                        <div class="course-price-mini"><fmt:formatNumber value="${item.price}" pattern="#,##0.00"/>₫</div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>

                    <!-- Total Row -->
                    <div class="summary-calc-total summary-calc-total--summary">
                        <span>Total (${itemCount} course<c:if test="${itemCount > 1}">s</c:if>):</span>
                        <span class="total-amount-display" style="font-size: 24px; font-weight: 800; color: #1e293b;">
                            <fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>₫
                        </span>
                    </div>

                    <p class="text-muted mt-3 terms-note">
                        By completing your purchase, you agree to these <a href="#" class="terms-link">Terms of Use</a>.
                    </p>

                    <!-- Pay Submit Button (Main) -->
                    <button type="submit" form="checkoutForm" class="btn-pay-submit btn-pay-submit--main" id="btnSubmitPayment">
                        <i class="fa-solid fa-lock me-2"></i>
                        <span>Pay <fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>₫</span>
                    </button>
                </div>
            </div>

        </div>

    </main>

    <!-- FOOTER -->
    <jsp:include page="/view/common/footer.jsp"></jsp:include>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

    <script>
        // Switch between Card and QR Code methods
        function selectPaymentMethod(method) {
            const cardBox = document.getElementById('cardOptionBox');
            const qrBox = document.getElementById('qrOptionBox');
            const radioCard = document.getElementById('radioCard');
            const radioQR = document.getElementById('radioQR');
            const paymentInput = document.getElementById('selectedPaymentMethodInput');
            const btnSubmit = document.getElementById('btnSubmitPayment');

            paymentInput.value = method;

            if (method === 'Card') {
                cardBox.classList.add('active');
                qrBox.classList.remove('active');
                radioCard.checked = true;
                btnSubmit.style.background = '#6f2bd9';
                btnSubmit.innerHTML = '<i class="fa-solid fa-lock me-2"></i> <span>Pay <fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>₫</span>';
            } else if (method === 'QR_CODE') {
                qrBox.classList.add('active');
                cardBox.classList.remove('active');
                radioQR.checked = true;
                btnSubmit.style.background = '#16a34a';
                btnSubmit.innerHTML = '<i class="fa-solid fa-qrcode me-2"></i> <span>Xác nhận đã chuyển khoản</span>';
            }
        }

        // Fill Test Card helper
        function fillTestCard() {
            const fullName = document.getElementById('fullName').value.trim() || 'NGUYEN VAN A';
            document.getElementById('cardNumber').value = '4242 4242 4242 4242';
            document.getElementById('expiry').value = '12/28';
            document.getElementById('cvc').value = '123';
            document.getElementById('cardName').value = fullName.toUpperCase();
            Toastify({
                text: "Đã điền thông tin thẻ test!",
                duration: 2000,
                gravity: "top",
                position: "right",
                backgroundColor: "#6f2bd9"
            }).showToast();
        }

        // Copy text to clipboard helper
        function copyText(text, successMsg) {
            navigator.clipboard.writeText(text).then(function() {
                Toastify({
                    text: successMsg || "Đã sao chép thành công!",
                    duration: 3000,
                    gravity: "top",
                    position: "right",
                    backgroundColor: "#16a34a"
                }).showToast();
            }).catch(function(err) {
                console.error('Không thể sao chép: ', err);
            });
        }

        // Format Card Number (adds space every 4 digits)
        document.getElementById('cardNumber')?.addEventListener('input', function() {
            let val = this.value.replace(/\D/g, '').substring(0, 16);
            let formatted = '';
            for (let i = 0; i < val.length; i++) {
                if (i > 0 && i % 4 === 0) formatted += ' ';
                formatted += val[i];
            }
            this.value = formatted;
        });

        // Format Expiry Date (MM/YY)
        document.getElementById('expiry')?.addEventListener('input', function() {
            let val = this.value.replace(/\D/g, '').substring(0, 4);
            if (val.length >= 3) {
                this.value = val.substring(0, 2) + '/' + val.substring(2);
            } else {
                this.value = val;
            }
        });

        // CVC digits only
        document.getElementById('cvc')?.addEventListener('input', function() {
            this.value = this.value.replace(/\D/g, '').substring(0, 4);
        });

        // Form Validation on Submit
        document.getElementById('checkoutForm')?.addEventListener('submit', function(e) {
            const method = document.getElementById('selectedPaymentMethodInput').value || 'Card';
            let isValid = true;

            // Clear previous errors
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

            // 1. Quốc gia / Khu vực
            const countryEl = document.getElementById('country');
            if (!countryEl || !countryEl.value.trim()) {
                showError('country', 'countryError', 'Thiếu trường chưa điền: Vui lòng chọn Quốc gia / Khu vực.');
            }

            // 2. Họ và tên
            const fullNameEl = document.getElementById('fullName');
            const fullNameVal = fullNameEl ? fullNameEl.value.trim() : '';
            if (!fullNameVal) {
                showError('fullName', 'fullNameError', 'Thiếu trường chưa điền: Vui lòng nhập Họ và tên.');
            } else if (/\d/.test(fullNameVal)) {
                showError('fullName', 'fullNameError', 'Họ và tên chỉ được chứa chữ cái, không được chứa số.');
            } else if (!/^[\p{L}\s'-]+$/u.test(fullNameVal)) {
                showError('fullName', 'fullNameError', 'Họ và tên không hợp lệ (chỉ được chứa chữ cái và khoảng trắng).');
            }

            // 3. Email
            const emailEl = document.getElementById('email');
            const emailVal = emailEl ? emailEl.value.trim() : '';
            const emailRegex = /^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$/;
            if (!emailVal) {
                showError('email', 'emailError', 'Thiếu trường chưa điền: Vui lòng nhập Email liên hệ.');
            } else if (!emailRegex.test(emailVal)) {
                showError('email', 'emailError', 'Email liên hệ không đúng định dạng.');
            }

            // 4. Địa chỉ
            const addressEl = document.getElementById('address');
            const addressVal = addressEl ? addressEl.value.trim() : '';
            if (!addressVal) {
                showError('address', 'addressError', 'Thiếu trường chưa điền: Vui lòng nhập Địa chỉ.');
            }

            // 5. Nếu phương thức thanh toán là Thẻ tín dụng/Ghi nợ (Card)
            if (method === 'Card') {
                // Số thẻ: 16 chữ số
                const cardNumEl = document.getElementById('cardNumber');
                const cardNumRaw = cardNumEl ? cardNumEl.value.trim() : '';
                const cardNumClean = cardNumRaw.replace(/\s+/g, '');
                if (!cardNumRaw) {
                    showError('cardNumber', 'cardNumberError', 'Thiếu trường chưa điền: Vui lòng nhập Số thẻ.');
                } else if (!/^\d+$/.test(cardNumClean)) {
                    showError('cardNumber', 'cardNumberError', 'Số thẻ chỉ được chứa chữ số.');
                } else if (cardNumClean.length !== 16) {
                    showError('cardNumber', 'cardNumberError', 'Số thẻ phải gồm đúng 16 chữ số.');
                }

                // Ngày hết hạn: MM/YY
                const expiryEl = document.getElementById('expiry');
                const expiryVal = expiryEl ? expiryEl.value.trim() : '';
                const expiryRegex = /^(0[1-9]|1[0-2])\/\d{2}$/;
                if (!expiryVal) {
                    showError('expiry', 'expiryError', 'Thiếu trường chưa điền: Vui lòng nhập Ngày hết hạn thẻ.');
                } else if (!expiryRegex.test(expiryVal)) {
                    showError('expiry', 'expiryError', 'Định dạng ngày hết hạn không hợp lệ (MM/YY, ví dụ: 12/28).');
                }

                // CVC/CVV: 3-4 chữ số
                const cvcEl = document.getElementById('cvc');
                const cvcVal = cvcEl ? cvcEl.value.trim() : '';
                if (!cvcVal) {
                    showError('cvc', 'cvcError', 'Thiếu trường chưa điền: Vui lòng nhập Mã CVC / CVV.');
                } else if (!/^\d{3,4}$/.test(cvcVal)) {
                    showError('cvc', 'cvcError', 'Mã CVC / CVV phải gồm 3 hoặc 4 chữ số.');
                }

                // Tên in trên thẻ: là chữ, không được chứa số
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

            // Nếu có lỗi, chặn submit và hiển thị thông báo
            if (!isValid) {
                e.preventDefault();
                const firstErrorEl = document.querySelector('.input-error');
                if (firstErrorEl) {
                    firstErrorEl.focus();
                    firstErrorEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
                Toastify({
                    text: "Vui lòng điền đầy đủ và chính xác thông tin thanh toán!",
                    duration: 3500,
                    gravity: "top",
                    position: "right",
                    backgroundColor: "#dc2626"
                }).showToast();
                return false;
            }

            // Nếu dữ liệu hợp lệ, cho phép gửi form và hiển thị thông báo
            Toastify({
                text: "Đang xử lý thanh toán và kích hoạt khóa học...",
                duration: 2500,
                gravity: "top",
                position: "right",
                backgroundColor: "#6f2bd9"
            }).showToast();
        });
    </script>
</body>
</html>
