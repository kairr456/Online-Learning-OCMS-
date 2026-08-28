<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
                    <input type="hidden" name="paymentMethod" id="selectedPaymentMethodInput" value="${not empty paramPaymentMethod ? paramPaymentMethod : 'Card'}">

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
                                       placeholder="VD: Nguyễn Văn A" maxlength="100">
                                <div class="field-error" id="fullNameError"></div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email liên hệ <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" name="email" id="email" 
                                       value="${not empty paramEmail ? paramEmail : (sessionScope.account != null ? sessionScope.account.email : '')}" 
                                       placeholder="email@example.com" maxlength="255">
                                <div class="field-error" id="emailError"></div>
                            </div>
                        </div>

                        <div class="mt-3">
                            <label class="form-label">Địa chỉ <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="address" id="address" 
                                    placeholder="Số nhà, tên đường, quận/huyện..." 
                                    value="${not empty paramAddress ? paramAddress : 'Hồ Chí Minh, Việt Nam'}" maxlength="255">
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
                            <div class="payment-option-header" id="cardHeaderClick">
                                <div class="payment-radio-wrap">
                                    <input type="radio" name="paymentTypeRadio" id="radioCard" value="Card" checked>
                                    <label for="radioCard" class="mb-0" style="cursor:pointer;">
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
                                    <button type="button" class="btn btn-sm btn-outline-primary py-0 px-2 fill-test-btn" id="btnFillTestCard">
                                        <i class="fa-solid fa-wand-magic-sparkles me-1"></i> Điền thẻ test
                                    </button>
                                </div>
                                <div class="mb-3">
                                    <div class="input-group">
                                        <input type="text" class="form-control" id="cardNumber" name="cardNumber" 
                                               placeholder="4242 4242 4242 4242" maxlength="24" inputmode="numeric" 
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
                                               placeholder="123" maxlength="3" inputmode="numeric" 
                                               value="${not empty paramCvc ? paramCvc : '123'}">
                                        <div class="field-error" id="cvcError"></div>
                                    </div>
                                </div>

                                <div class="mb-0">
                                    <label class="form-label">Tên in trên thẻ (Name on Card) <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control text-uppercase" id="cardName" name="cardName" 
                                           placeholder="NGUYEN VAN A" maxlength="100"
                                           value="${not empty paramCardName ? paramCardName : (sessionScope.account != null ? (not empty sessionScope.account.fullName ? sessionScope.account.fullName : sessionScope.account.username) : 'NGUYEN VAN A')}">
                                    <div class="field-error" id="cardNameError"></div>
                                </div>
                            </div>
                        </div>

                        <!-- OPTION 2: QR CODE / VIETQR -->
                        <div class="payment-option-card" id="qrOptionBox">
                            <div class="payment-option-header" id="qrHeaderClick">
                                <div class="payment-radio-wrap">
                                    <input type="radio" name="paymentTypeRadio" id="radioQR" value="QR_CODE">
                                    <label for="radioQR" class="mb-0" style="cursor:pointer;">
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
                                                <button type="button" class="btn-copy" id="btnCopyAccNo">
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
                                                <button type="button" class="btn-copy" id="btnCopyTransferContent">
                                                    <i class="fa-regular fa-copy"></i> Sao chép
                                                </button>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                </form>

            </div>

            <!-- RIGHT COLUMN: ORDER SUMMARY -->
            <div class="col-lg-5">
                <div class="order-summary-box">
                    <div class="summary-title" style="font-size: 26px; font-weight: 700; color: #1e293b; margin-bottom: 20px; padding-bottom: 0; border-bottom: none;">
                        Order summary
                    </div>

                    <!-- Course Items List Preview -->
                    <c:if test="${not empty cartItems}">
                        <div class="mb-3" style="max-height: 220px; overflow-y: auto; padding-right: 4px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px;">
                            <c:forEach var="item" items="${cartItems}">
                                <div class="course-item-summary">
                                    <c:set var="cObj" value="${courseMap[item.courseId]}" />
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
                    <div class="summary-calc-total" style="border-top: none; margin-top: 0; padding-top: 0; display: flex; justify-content: space-between; align-items: baseline; font-size: 18px; font-weight: 700; color: #1e293b; padding-bottom: 20px; border-bottom: 1px solid #e2e8f0;">
                        <span>Total (${itemCount} course<c:if test="${itemCount > 1}">s</c:if>):</span>
                        <span class="total-amount-display" style="font-size: 24px; font-weight: 800; color: #1e293b;">
                            <fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>₫
                        </span>
                    </div>

                    <p class="text-muted mt-3" style="font-size: 13px; line-height: 1.5; color: #64748b;">
                        By completing your purchase, you agree to these <a href="#" style="color: #6f2bd9; text-decoration: none;">Terms of Use</a>.
                    </p>

                    <!-- Hidden input for total text used in JS -->
                    <input type="hidden" id="orderTotalHiddenDisplay" value="<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>₫">

                    <!-- Pay Submit Button (Main) -->
                    <button type="submit" form="checkoutForm" class="btn-pay-submit" id="btnSubmitPayment" style="background: #6f2bd9; padding: 16px; border-radius: 8px; font-size: 18px; font-weight: 700; box-shadow: none;">
                        <i class="fa-solid fa-lock me-2"></i>
                        <span>Pay <fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/>₫</span>
                    </button>
                </div>
            </div>

        </div>

    </main>

    <!-- FOOTER -->
    <jsp:include page="/view/common/footer.jsp"></jsp:include>

    <!-- JS Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

    <!-- Checkout Module JS riêng biệt -->
    <script src="${pageContext.request.contextPath}/assets/js/shopcart/checkout.js"></script>
</body>
</html>
