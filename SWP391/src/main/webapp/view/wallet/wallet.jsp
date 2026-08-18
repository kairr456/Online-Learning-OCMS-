<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ví & Doanh thu - OCMS</title>
    
    <!-- CSS Dependencies -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
    
    <!-- Custom Wallet CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/wallet/wallet.css?v=2.1">
    
    <style>
        .wallet-pagination-wrapper {
            display: flex !important;
            justify-content: center !important;
            align-items: center !important;
            width: 100% !important;
            gap: 14px !important;
            margin: 36px auto 16px auto !important;
            padding: 12px 0 !important;
            user-select: none !important;
            clear: both !important;
        }
        .wallet-page-btn {
            width: 44px !important;
            height: 44px !important;
            min-width: 44px !important;
            border-radius: 50% !important;
            background: #ffffff !important;
            color: #1e1b4b !important;
            border: 1px solid rgba(0, 0, 0, 0.06) !important;
            outline: none !important;
            font-size: 15px !important;
            font-weight: 700 !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08) !important;
            cursor: pointer !important;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
            text-decoration: none !important;
            padding: 0 !important;
            line-height: 1 !important;
        }
        .wallet-page-btn:hover:not(.disabled):not(.active) {
            background: #ffffff !important;
            color: #5d3fd3 !important;
            transform: translateY(-3px) !important;
            box-shadow: 0 8px 18px rgba(0, 0, 0, 0.13) !important;
            border-color: #c7d2fe !important;
        }
        .wallet-page-btn.active {
            background: #181928 !important;
            color: #ffffff !important;
            box-shadow: 0 6px 18px rgba(24, 25, 40, 0.35) !important;
            border-color: #181928 !important;
            cursor: default !important;
            transform: none !important;
        }
        .wallet-page-btn.disabled {
            opacity: 0.35 !important;
            cursor: not-allowed !important;
            pointer-events: none !important;
        }
        .wallet-page-btn i {
            font-size: 14px !important;
            color: inherit !important;
        }
    </style>
</head>
<body>

    <!-- Header Area -->
    <jsp:include page="/view/common/header.jsp"/>

    <main class="wallet-page-wrapper">
        <div class="container">
            
            <!-- Page Header -->
            <div class="wallet-header">
                <div>
                    <h1 class="wallet-header__title">
                        <i class="fa-solid fa-wallet"></i> Ví & Doanh thu
                    </h1>
                    <div class="wallet-header__subtitle">
                        Theo dõi thu nhập từ các khóa học và quản lý yêu cầu rút tiền về tài khoản ngân hàng.
                    </div>
                </div>
                <div class="wallet-header__actions">
                    <button type="button" class="btn-wallet-outline" data-bs-toggle="modal" data-bs-target="#bankModal">
                        <i class="fa-solid fa-building-columns"></i> ${bankAccount != null ? 'Cài đặt STK' : '+ Liên kết STK'}
                    </button>
                    <button type="button" class="btn-wallet-primary" onclick="openWithdrawModal()">
                        <i class="fa-solid fa-money-bill-transfer"></i> Yêu cầu rút tiền
                    </button>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="wallet-stats-grid">
                <!-- 1. Số dư khả dụng -->
                <div class="wallet-stat-card wallet-stat-card--primary">
                    <div class="wallet-stat-card__header">
                        <span class="wallet-stat-card__label">Số dư khả dụng</span>
                        <div class="wallet-stat-card__icon">
                            <i class="fa-solid fa-coins"></i>
                        </div>
                    </div>
                    <div class="wallet-stat-card__value">
                        <fmt:formatNumber value="${wallet.balance != null ? wallet.balance : 0}" type="currency" currencySymbol="₫" maxFractionDigits="2"/>
                    </div>
                    <div class="wallet-stat-card__sub">
                        <c:choose>
                            <c:when test="${wallet.balance >= 100000}">
                                <i class="fa-solid fa-circle-check text-success"></i> Sẵn sàng để rút về tài khoản
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-circle-info text-warning"></i> Hạn mức rút tối thiểu: 100.000 ₫
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- 2. Tổng thu nhập tích lũy -->
                <div class="wallet-stat-card">
                    <div class="wallet-stat-card__header">
                        <span class="wallet-stat-card__label">Tổng thu nhập</span>
                        <div class="wallet-stat-card__icon wallet-stat-card__icon--earned">
                            <i class="fa-solid fa-arrow-trend-up"></i>
                        </div>
                    </div>
                    <div class="wallet-stat-card__value">
                        <fmt:formatNumber value="${wallet.totalEarned != null ? wallet.totalEarned : 0}" type="currency" currencySymbol="₫" maxFractionDigits="2"/>
                    </div>
                    <div class="wallet-stat-card__sub text-success">
                        <i class="fa-solid fa-percent"></i> 70% chia sẻ doanh thu từ khóa học
                    </div>
                </div>

                <!-- 3. Đã rút thành công -->
                <div class="wallet-stat-card">
                    <div class="wallet-stat-card__header">
                        <span class="wallet-stat-card__label">Đã rút thành công</span>
                        <div class="wallet-stat-card__icon wallet-stat-card__icon--withdrawn">
                            <i class="fa-solid fa-building-columns"></i>
                        </div>
                    </div>
                    <div class="wallet-stat-card__value">
                        <fmt:formatNumber value="${wallet.totalWithdrawn != null ? wallet.totalWithdrawn : 0}" type="currency" currencySymbol="₫" maxFractionDigits="2"/>
                    </div>
                    <div class="wallet-stat-card__sub">
                        <i class="fa-solid fa-clock-rotate-left"></i> Đã chuyển về tài khoản ngân hàng
                    </div>
                </div>

                <!-- 4. Đang chờ xử lý -->
                <div class="wallet-stat-card">
                    <div class="wallet-stat-card__header">
                        <span class="wallet-stat-card__label">Đang chờ duyệt</span>
                        <div class="wallet-stat-card__icon wallet-stat-card__icon--pending">
                            <i class="fa-solid fa-hourglass-half"></i>
                        </div>
                    </div>
                    <div class="wallet-stat-card__value text-warning">
                        <fmt:formatNumber value="${pendingAmount != null ? pendingAmount : 0}" type="currency" currencySymbol="₫" maxFractionDigits="2"/>
                    </div>
                    <div class="wallet-stat-card__sub text-muted">
                        <i class="fa-solid fa-info-circle"></i> Đang chờ Admin xử lý
                    </div>
                </div>
            </div>

            <!-- Main Content Area (2 Columns) -->
            <div class="wallet-main-grid">
                
                <!-- Left Column: History Tables with Tabs -->
                <div class="wallet-panel">
                    
                    <!-- Tabs Header with Sort Dropdown -->
                    <div class="wallet-tabs-header">
                        <div class="wallet-tabs">
                            <button type="button" class="wallet-tab-btn active" id="tabBtnTransactions" onclick="switchWalletTab('transactions')">
                                <i class="fa-solid fa-list-check"></i> Lịch sử biến động số dư
                            </button>
                            <button type="button" class="wallet-tab-btn" id="tabBtnPayouts" onclick="switchWalletTab('payouts')">
                                <i class="fa-solid fa-money-bill-wave"></i> Lịch sử rút tiền
                            </button>
                        </div>
                        <div class="wallet-sort-wrapper">
                            <label for="walletSortSelect" class="wallet-sort-label">
                                <i class="fa-solid fa-arrow-down-wide-short text-primary"></i> Sắp xếp:
                            </label>
                            <select id="walletSortSelect" class="wallet-sort-select" onchange="handleWalletSort(this.value)">
                                <option value="newest" <c:if test="${sort != 'oldest'}">selected</c:if>>Mới nhất</option>
                                <option value="oldest" <c:if test="${sort == 'oldest'}">selected</c:if>>Lâu nhất</option>
                            </select>
                        </div>
                    </div>

                    <!-- TAB 1: Biến động số dư (Transactions) -->
                    <div id="tabTransactionsContent" class="wallet-tab-content">
                        <div class="table-responsive">
                            <table class="wallet-table">
                                <thead>
                                    <tr>
                                        <th class="wallet-sort-col-btn" onclick="toggleWalletSort()" title="Nhấn để đổi sắp xếp mới nhất / lâu nhất">
                                            Thời gian <i id="sortIconTx" class="fa-solid fa-arrow-down-wide-short ms-1 text-primary"></i>
                                        </th>
                                        <th>Loại giao dịch</th>
                                        <th>Mô tả chi tiết</th>
                                        <th>Số tiền</th>
                                        <th>Số dư sau GD</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty transactions}">
                                            <c:forEach items="${transactions}" var="tx">
                                                <tr class="wallet-tx-row" data-timestamp="${tx.createdAt != null ? tx.createdAt.time : 0}">
                                                    <td><fmt:formatDate value="${tx.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${tx.type == 'course_sale'}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle">
                                                                    <i class="fa-solid fa-cart-plus me-1"></i> Bán khóa học
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${tx.type == 'payout'}">
                                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle">
                                                                    <i class="fa-solid fa-arrow-up-right-from-square me-1"></i> Rút tiền
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${tx.type == 'refund'}">
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">
                                                                    <i class="fa-solid fa-rotate-left me-1"></i> Hoàn trả
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">${tx.type}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>${tx.description}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${tx.amount > 0}">
                                                                <span class="amount-plus">+<fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="₫" maxFractionDigits="2"/></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="amount-minus"><fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="₫" maxFractionDigits="2"/></span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><strong><fmt:formatNumber value="${tx.balanceAfter}" type="currency" currencySymbol="₫" maxFractionDigits="2"/></strong></td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="5" class="text-center py-5 text-muted">
                                                    <i class="fa-solid fa-receipt fs-2 mb-2 d-block opacity-25"></i>
                                                    Chưa có biến động số dư nào.
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- TAB 2: Lịch sử rút tiền (Payouts) -->
                    <div id="tabPayoutsContent" class="wallet-tab-content" style="display: none;">
                        <div class="table-responsive">
                            <table class="wallet-table">
                                <thead>
                                    <tr>
                                        <th>Mã đơn</th>
                                        <th class="wallet-sort-col-btn" onclick="toggleWalletSort()" title="Nhấn để đổi sắp xếp mới nhất / lâu nhất">
                                            Ngày yêu cầu <i id="sortIconPo" class="fa-solid fa-arrow-down-wide-short ms-1 text-primary"></i>
                                        </th>
                                        <th>Số tiền rút</th>
                                        <th>Tài khoản nhận</th>
                                        <th>Trạng thái</th>
                                        <th>Ghi chú / Mã GD</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty payoutRequests}">
                                            <c:forEach items="${payoutRequests}" var="po">
                                                <tr class="wallet-po-row" data-timestamp="${po.createdAt != null ? po.createdAt.time : 0}">
                                                    <td><strong>#PO-${po.id}</strong></td>
                                                    <td><fmt:formatDate value="${po.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                    <td><span class="amount-minus"><fmt:formatNumber value="${po.amount}" type="currency" currencySymbol="₫" maxFractionDigits="2"/></span></td>
                                                    <td>${po.bankName} (${po.accountNumber})</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${po.status == 'pending'}">
                                                                <span class="badge-status badge-status--pending">
                                                                    <i class="fa-solid fa-hourglass-half"></i> Chờ duyệt
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${po.status == 'completed' || po.status == 'approved'}">
                                                                <span class="badge-status badge-status--completed">
                                                                    <i class="fa-solid fa-circle-check"></i> Đã chuyển tiền
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge-status badge-status--rejected">
                                                                    <i class="fa-solid fa-circle-xmark"></i> Bị từ chối
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${not empty po.transactionCode}">
                                                            <code>${po.transactionCode}</code>
                                                        </c:if>
                                                        <c:if test="${not empty po.adminNote}">
                                                            <small class="text-danger d-block">${po.adminNote}</small>
                                                        </c:if>
                                                        <c:if test="${empty po.transactionCode && empty po.adminNote}">
                                                            <span class="text-muted">-</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="6" class="text-center py-5 text-muted">
                                                    <i class="fa-solid fa-money-bill-wave fs-2 mb-2 d-block opacity-25"></i>
                                                    Chưa có yêu cầu rút tiền nào.
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Pagination Component -->
                    <div class="wallet-pagination-wrapper" id="walletPagination"></div>

                </div>

                <!-- Right Column: Bank Account & Policies -->
                <div>
                    <!-- Bank Account Card -->
                    <div class="wallet-panel">
                        <div class="wallet-panel__header">
                            <h3 class="wallet-panel__title">
                                <i class="fa-solid fa-credit-card text-primary"></i> Tài khoản nhận tiền
                            </h3>
                            <button type="button" class="btn btn-sm btn-link p-0 text-decoration-none" data-bs-toggle="modal" data-bs-target="#bankModal">
                                <i class="fa-solid fa-pen-to-square"></i> ${bankAccount != null ? 'Sửa' : 'Cài đặt'}
                            </button>
                        </div>

                        <c:choose>
                            <c:when test="${not empty bankAccount}">
                                <!-- Credit Card / Bank Card Visual -->
                                <div class="bank-card">
                                    <div class="bank-card__top">
                                        <div class="bank-card__logo">
                                            <i class="fa-solid fa-building-columns me-1"></i> 
                                            <span>${bankAccount.bankCode}</span>
                                        </div>
                                        <span class="bank-card__badge">Mặc định</span>
                                    </div>
                                    <div class="bank-card__number">
                                        ${bankAccount.accountNumber}
                                    </div>
                                    <div class="bank-card__bottom">
                                        <div>
                                            <div class="text-xs">CHỦ TÀI KHOẢN</div>
                                            <div class="bank-card__holder">
                                                ${bankAccount.accountHolder}
                                            </div>
                                        </div>
                                        <c:if test="${not empty bankAccount.taxCode}">
                                            <div class="text-end">
                                                <div class="text-xs">MÃ SỐ THUẾ</div>
                                                <div class="text-white font-monospace">${bankAccount.taxCode}</div>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>

                                <div class="d-grid">
                                    <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" data-bs-toggle="modal" data-bs-target="#bankModal">
                                        <i class="fa-solid fa-arrows-rotate me-1"></i> Thay đổi thông tin ngân hàng
                                    </button>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <!-- Empty state for Bank Card -->
                                <div class="p-4 border border-dashed rounded-3 text-center mb-3 bg-light">
                                    <i class="fa-solid fa-building-columns text-muted fs-1 mb-2 opacity-50"></i>
                                    <h6 class="fw-bold mb-1">Chưa liên kết ngân hàng</h6>
                                    <p class="text-muted small mb-3">Vui lòng thêm số tài khoản ngân hàng để có thể thực hiện rút tiền hoa hồng.</p>
                                    <button type="button" class="btn btn-primary btn-sm rounded-pill" data-bs-toggle="modal" data-bs-target="#bankModal">
                                        <i class="fa-solid fa-plus me-1"></i> Liên kết tài khoản ngay
                                    </button>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Revenue Policy Info Panel -->
                    <div class="wallet-panel">
                        <h4 class="wallet-panel__title mb-3" style="font-size: 16px;">
                            <i class="fa-solid fa-circle-info text-info"></i> Chính sách thanh toán
                        </h4>
                        <ul class="list-unstyled text-muted font-14 mb-0" style="font-size: 13.5px; line-height: 1.8;">
                            <li class="d-flex align-items-start gap-2 mb-2">
                                <i class="fa-solid fa-check text-success mt-1"></i>
                                <span>Tỷ lệ hoa hồng giảng viên: <strong>70% giá bán</strong>.</span>
                            </li>
                            <li class="d-flex align-items-start gap-2 mb-2">
                                <i class="fa-solid fa-check text-success mt-1"></i>
                                <span>Hạn mức rút tiền tối thiểu: <strong>100.000 ₫</strong>.</span>
                            </li>
                            <li class="d-flex align-items-start gap-2 mb-2">
                                <i class="fa-solid fa-check text-success mt-1"></i>
                                <span>Thời gian xử lý: <strong>1 - 3 ngày làm việc</strong> sau khi Admin duyệt.</span>
                            </li>
                            <li class="d-flex align-items-start gap-2">
                                <i class="fa-solid fa-check text-success mt-1"></i>
                                <span>Phí chuyển khoản: <strong>Miễn phí (0đ)</strong>.</span>
                            </li>
                        </ul>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- ================================================================= -->
    <!-- MODAL 1: YÊU CẦU RÚT TIỀN (WITHDRAW MODAL) -->
    <!-- ================================================================= -->
    <div class="modal fade" id="withdrawModal" tabindex="-1" aria-labelledby="withdrawModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/wallet" method="POST" id="withdrawForm">
                    <input type="hidden" name="action" value="request_payout">
                    
                    <div class="modal-header">
                        <h5 class="modal-title" id="withdrawModalLabel">
                            <i class="fa-solid fa-money-bill-transfer text-primary"></i> Yêu cầu rút tiền
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    
                    <div class="modal-body">
                        
                        <!-- Cảnh báo nếu số dư chưa đủ 100.000đ -->
                        <c:if test="${empty wallet || wallet.balance < 100000}">
                            <div class="alert alert-warning d-flex align-items-center gap-2 mb-3">
                                <i class="fa-solid fa-triangle-exclamation fs-5"></i>
                                <div>
                                    <div class="fw-bold">Chưa đủ hạn mức rút tiền!</div>
                                    <div class="small">Số dư khả dụng hiện tại (<fmt:formatNumber value="${wallet.balance != null ? wallet.balance : 0}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>) cần đạt tối thiểu <strong>100.000 ₫</strong> để tạo yêu cầu rút.</div>
                                </div>
                            </div>
                        </c:if>

                        <!-- Số dư khả dụng hiện có -->
                        <div class="p-3 bg-light rounded-3 mb-3 d-flex justify-content-between align-items-center">
                            <span class="text-muted">Số dư khả dụng hiện tại:</span>
                            <span class="fs-5 fw-bold text-primary" id="availableBalanceDisplay">
                                <fmt:formatNumber value="${wallet.balance != null ? wallet.balance : 0}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                            </span>
                        </div>

                        <!-- Tài khoản nhận tiền -->
                        <div class="mb-3">
                            <label class="form-label fw-bold">Tài khoản nhận tiền</label>
                            <c:choose>
                                <c:when test="${not empty bankAccount}">
                                    <div class="p-3 border rounded-3 bg-white d-flex align-items-center justify-content-between">
                                        <div class="d-flex align-items-center gap-3">
                                            <i class="fa-solid fa-building-columns fs-4 text-primary"></i>
                                            <div>
                                                <div class="fw-bold">${bankAccount.bankName}</div>
                                                <small class="text-muted">STK: ${bankAccount.accountNumber} - ${bankAccount.accountHolder}</small>
                                            </div>
                                        </div>
                                        <span class="badge bg-success-subtle text-success">Đã liên kết</span>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-warning mb-0 py-2">
                                        <i class="fa-solid fa-triangle-exclamation me-1"></i> Chưa liên kết tài khoản ngân hàng. Vui lòng cài đặt STK trước.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Số tiền muốn rút -->
                        <div class="mb-3">
                            <label for="withdrawAmount" class="form-label fw-bold">Số tiền muốn rút (VNĐ)</label>
                            <div class="input-group input-group-lg">
                                <input type="number" name="amount" id="withdrawAmount" class="form-control fw-bold text-primary" 
                                       placeholder="Ví dụ: 500000" min="100000" max="${wallet.balance != null ? wallet.balance : 0}" step="10000" 
                                       <c:if test="${empty wallet || wallet.balance < 100000}">disabled</c:if> required>
                                <span class="input-group-text bg-light fw-bold">VNĐ</span>
                            </div>
                            
                            <!-- Nút chọn số tiền nhanh -->
                            <div class="quick-amounts">
                                <button type="button" class="quick-amount-pill" onclick="setQuickAmount(100000)" <c:if test="${empty wallet || wallet.balance < 100000}">disabled</c:if>>100.000 ₫</button>
                                <button type="button" class="quick-amount-pill" onclick="setQuickAmount(200000)" <c:if test="${empty wallet || wallet.balance < 200000}">disabled</c:if>>200.000 ₫</button>
                                <button type="button" class="quick-amount-pill" onclick="setQuickAmount(500000)" <c:if test="${empty wallet || wallet.balance < 500000}">disabled</c:if>>500.000 ₫</button>
                                <button type="button" class="quick-amount-pill" onclick="setQuickAmount(${wallet.balance != null ? wallet.balance : 0})" <c:if test="${empty wallet || wallet.balance < 100000}">disabled</c:if>>Rút tối đa</button>
                            </div>
                            <div class="form-text text-muted">Số tiền tối thiểu: 100.000 ₫ / lần rút (bội số 10.000 ₫).</div>
                        </div>

                        <!-- Ghi chú cho Admin (Tùy chọn) -->
                        <div class="mb-2">
                            <label for="withdrawNote" class="form-label fw-bold">Ghi chú (Tùy chọn)</label>
                            <textarea name="note" id="withdrawNote" class="form-control" rows="2" placeholder="Ghi chú thêm nếu cần..."></textarea>
                        </div>
                    </div>
                    
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-primary px-4 fw-bold" <c:if test="${empty bankAccount || empty wallet || wallet.balance < 100000}">disabled</c:if>>
                            <i class="fa-solid fa-paper-plane me-1"></i> ${empty wallet || wallet.balance < 100000 ? 'Chưa đủ hạn mức rút (100.000 ₫)' : 'Gửi yêu cầu rút tiền'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ================================================================= -->
    <!-- MODAL 2: CÀI ĐẶT TÀI KHOẢN NGÂN HÀNG (BANK SETTINGS MODAL) -->
    <!-- ================================================================= -->
    <div class="modal fade" id="bankModal" tabindex="-1" aria-labelledby="bankModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/wallet" method="POST" id="bankForm">
                    <input type="hidden" name="action" value="update_bank">
                    
                    <div class="modal-header">
                        <h5 class="modal-title" id="bankModalLabel">
                            <i class="fa-solid fa-building-columns text-primary"></i> Cài đặt tài khoản nhận tiền
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    
                    <div class="modal-body">
                        <!-- Chọn Ngân hàng -->
                        <div class="mb-3">
                            <label for="bankCodeSelect" class="form-label fw-bold">Ngân hàng nhận tiền <span class="text-danger">*</span></label>
                            <select name="bankCode" id="bankCodeSelect" class="form-select form-select-lg" required onchange="handleBankSelect(this)">
                                <option value="" disabled <c:if test="${empty bankAccount}">selected</c:if>>-- Chọn ngân hàng --</option>
                                <option value="MB" data-name="Ngân hàng TMCP Quân Đội (MBBank)" <c:if test="${bankAccount.bankCode == 'MB'}">selected</c:if>>MBBank - Ngân hàng Quân Đội</option>
                                <option value="VCB" data-name="Ngân hàng Ngoại Thương Việt Nam (Vietcombank)" <c:if test="${bankAccount.bankCode == 'VCB'}">selected</c:if>>Vietcombank - Ngân hàng Ngoại Thương VN</option>
                                <option value="TCB" data-name="Ngân hàng TMCP Kỹ Thương (Techcombank)" <c:if test="${bankAccount.bankCode == 'TCB'}">selected</c:if>>Techcombank - Ngân hàng Kỹ Thương</option>
                                <option value="ACB" data-name="Ngân hàng TMCP Á Châu (ACB)" <c:if test="${bankAccount.bankCode == 'ACB'}">selected</c:if>>ACB - Ngân hàng Á Châu</option>
                                <option value="VPB" data-name="Ngân hàng TMCP Việt Nam Thịnh Vượng (VPBank)" <c:if test="${bankAccount.bankCode == 'VPB'}">selected</c:if>>VPBank - VN Thịnh Vượng</option>
                                <option value="BIDV" data-name="Ngân hàng Đầu tư và Phát triển VN (BIDV)" <c:if test="${bankAccount.bankCode == 'BIDV'}">selected</c:if>>BIDV - Đầu tư & Phát triển VN</option>
                                <option value="ICB" data-name="Ngân hàng Công Thương Việt Nam (VietinBank)" <c:if test="${bankAccount.bankCode == 'ICB'}">selected</c:if>>VietinBank - Ngân hàng Công Thương VN</option>
                                <option value="TPB" data-name="Ngân hàng TMCP Tiên Phong (TPBank)" <c:if test="${bankAccount.bankCode == 'TPB'}">selected</c:if>>TPBank - Tiên Phong Bank</option>
                                <option value="STB" data-name="Ngân hàng Sài Gòn Thương Tín (Sacombank)" <c:if test="${bankAccount.bankCode == 'STB'}">selected</c:if>>Sacombank - Sài Gòn Thương Tín</option>
                                <option value="VIB" data-name="Ngân hàng Quốc Tế (VIB)" <c:if test="${bankAccount.bankCode == 'VIB'}">selected</c:if>>VIB - Ngân hàng Quốc Tế</option>
                            </select>
                            <input type="hidden" name="bankName" id="bankNameHidden" value="${bankAccount.bankName != null ? bankAccount.bankName : 'Ngân hàng TMCP Quân Đội (MBBank)'}">
                        </div>

                        <!-- Số tài khoản -->
                        <div class="mb-3">
                            <label for="accountNumberInput" class="form-label fw-bold">Số tài khoản ngân hàng (STK) <span class="text-danger">*</span></label>
                            <input type="text" name="accountNumber" id="accountNumberInput" class="form-control form-control-lg font-monospace" 
                                   placeholder="Ví dụ: 0987654321" value="${bankAccount.accountNumber}" required
                                   oninput="handleAccountNumberInput(this)">
                            <div id="accNumberError" class="text-danger small mt-1" style="display: none;"></div>
                        </div>

                        <!-- Tên chủ tài khoản -->
                        <div class="mb-3">
                            <label for="accountHolderInput" class="form-label fw-bold">Tên chủ tài khoản (Viết hoa không dấu) <span class="text-danger">*</span></label>
                            <input type="text" name="accountHolder" id="accountHolderInput" class="form-control form-control-lg text-uppercase" 
                                   placeholder="Ví dụ: NGUYEN VAN A" value="${bankAccount.accountHolder}" required
                                   oninput="handleAccountHolderInput(this)">
                            <div id="accHolderError" class="text-danger small mt-1" style="display: none;"></div>
                            <div class="form-text">Tên phải viết hoa không dấu, không chứa số, trùng khớp với tên trên thẻ ngân hàng.</div>
                        </div>

                        <!-- Mã số thuế (MST) -->
                        <div class="mb-2">
                            <label for="taxCodeInput" class="form-label fw-bold">Mã số thuế cá nhân (MST) <span class="text-muted fw-normal">(Tùy chọn)</span></label>
                            <input type="text" name="taxCode" id="taxCodeInput" class="form-control" 
                                   placeholder="Ví dụ: 8401234567" value="${bankAccount.taxCode}"
                                   oninput="handleTaxCodeInput(this)">
                            <div id="taxCodeError" class="text-danger small mt-1" style="display: none;"></div>
                        </div>
                    </div>
                    
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-primary px-4 fw-bold">
                            <i class="fa-solid fa-floppy-disk me-1"></i> Lưu thông tin STK
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Footer Area -->
    <jsp:include page="/view/common/footer.jsp"/>

    <!-- JS Dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

    <script>
        // Real-time Sanitizers & Validators
        function handleAccountNumberInput(el) {
            // Chặn ký tự chữ, chỉ cho phép số
            el.value = el.value.replace(/\D/g, '');
            const err = document.getElementById('accNumberError');
            if (el.value.length > 0 && (el.value.length < 6 || el.value.length > 20)) {
                err.innerText = "Số tài khoản ngân hàng phải từ 6 đến 20 chữ số.";
                err.style.display = "block";
                el.classList.add("is-invalid");
            } else {
                err.style.display = "none";
                el.classList.remove("is-invalid");
            }
        }

        function handleAccountHolderInput(el) {
            // Tự động viết hoa và chặn số, chỉ giữ chữ cái và khoảng trắng
            el.value = el.value.replace(/[^a-zA-Z\s]/g, '').toUpperCase();
            const err = document.getElementById('accHolderError');
            if (el.value.trim().length > 0 && el.value.trim().length < 3) {
                err.innerText = "Tên chủ tài khoản phải có ít nhất 3 ký tự (Viết hoa không dấu).";
                err.style.display = "block";
                el.classList.add("is-invalid");
            } else {
                err.style.display = "none";
                el.classList.remove("is-invalid");
            }
        }

        function handleTaxCodeInput(el) {
            el.value = el.value.replace(/\D/g, '');
            const err = document.getElementById('taxCodeError');
            if (el.value.length > 0 && el.value.length !== 10 && el.value.length !== 13) {
                err.innerText = "Mã số thuế cá nhân phải gồm đúng 10 hoặc 13 chữ số.";
                err.style.display = "block";
                el.classList.add("is-invalid");
            } else {
                err.style.display = "none";
                el.classList.remove("is-invalid");
            }
        }

        // Validate Bank Form on Submit
        document.getElementById('bankForm').addEventListener('submit', function(e) {
            const bankCode = document.getElementById('bankCodeSelect').value;
            const accNumber = document.getElementById('accountNumberInput').value.trim();
            const accHolder = document.getElementById('accountHolderInput').value.trim();
            const taxCode = document.getElementById('taxCodeInput').value.trim();

            if (!bankCode) {
                e.preventDefault();
                showToast("Vui lòng chọn ngân hàng nhận tiền.", "error");
                return false;
            }

            if (!/^\d{6,20}$/.test(accNumber)) {
                e.preventDefault();
                showToast("Số tài khoản chỉ được chứa chữ số (từ 6 đến 20 số).", "error");
                document.getElementById('accountNumberInput').focus();
                return false;
            }

            if (!/^[a-zA-Z\s]{3,100}$/.test(accHolder)) {
                e.preventDefault();
                showToast("Tên chủ tài khoản phải viết hoa không dấu, không chứa số hoặc ký tự đặc biệt.", "error");
                document.getElementById('accountHolderInput').focus();
                return false;
            }

            if (taxCode && !/^\d{10}(\d{3})?$/.test(taxCode)) {
                e.preventDefault();
                showToast("Mã số thuế cá nhân phải gồm 10 hoặc 13 chữ số.", "error");
                document.getElementById('taxCodeInput').focus();
                return false;
            }
        });

        // Validate Withdraw Form on Submit
        document.getElementById('withdrawForm').addEventListener('submit', function(e) {
            const amountInput = document.getElementById('withdrawAmount');
            const amount = Number(amountInput.value);
            const maxBalance = Number(amountInput.getAttribute('max') || 0);

            if (isNaN(amount) || amount < 100000) {
                e.preventDefault();
                showToast("Số tiền rút tối thiểu là 100.000 ₫.", "error");
                amountInput.focus();
                return false;
            }

            if (amount % 10000 !== 0) {
                e.preventDefault();
                showToast("Số tiền rút phải là bội số của 10.000 ₫.", "error");
                amountInput.focus();
                return false;
            }

            if (amount > maxBalance) {
                e.preventDefault();
                showToast("Số tiền rút không được vượt quá số dư khả dụng.", "error");
                amountInput.focus();
                return false;
            }
        });

        function openWithdrawModal() {
            const hasBank = ${not empty bankAccount ? 'true' : 'false'};

            if (!hasBank) {
                showToast("Bạn chưa liên kết tài khoản ngân hàng. Vui lòng thêm số tài khoản trước.", "error");
                const bankModalEl = document.getElementById('bankModal');
                const bankModal = bootstrap.Modal.getOrCreateInstance(bankModalEl);
                bankModal.show();
                return;
            }

            const withdrawModalEl = document.getElementById('withdrawModal');
            const withdrawModal = bootstrap.Modal.getOrCreateInstance(withdrawModalEl);
            withdrawModal.show();
        }

        function showToast(msg, type) {
            Toastify({
                text: msg,
                duration: 4000,
                close: true,
                gravity: "top",
                position: "right",
                backgroundColor: type === "error" ? "#ef4444" : "#10b981"
            }).showToast();
        }

        // Pagination state
        let currentTxPage = 1;
        let currentPoPage = 1;
        const WALLET_PAGE_SIZE = 5;

        // Switch between History Tabs
        function switchWalletTab(tabName) {
            const btnTx = document.getElementById('tabBtnTransactions');
            const btnPo = document.getElementById('tabBtnPayouts');
            const contentTx = document.getElementById('tabTransactionsContent');
            const contentPo = document.getElementById('tabPayoutsContent');

            if (tabName === 'transactions') {
                btnTx.classList.add('active');
                btnPo.classList.remove('active');
                contentTx.style.display = 'block';
                contentPo.style.display = 'none';
            } else {
                btnPo.classList.add('active');
                btnTx.classList.remove('active');
                contentPo.style.display = 'block';
                contentTx.style.display = 'none';
            }
            renderWalletPagination();
        }

        // Render Pagination UI matching circular style
        function renderWalletPagination() {
            const contentTx = document.getElementById('tabTransactionsContent');
            const isTx = contentTx && contentTx.style.display !== 'none';
            const tbody = document.querySelector(isTx ? '#tabTransactionsContent tbody' : '#tabPayoutsContent tbody');
            const rowSelector = isTx ? '.wallet-tx-row' : '.wallet-po-row';
            const rows = tbody ? Array.from(tbody.querySelectorAll(rowSelector)) : [];
            const container = document.getElementById('walletPagination');
            if (!container) return;

            if (rows.length === 0) {
                container.innerHTML = '';
                return;
            }

            const totalPages = Math.max(1, Math.ceil(rows.length / WALLET_PAGE_SIZE));
            let currentPage = isTx ? currentTxPage : currentPoPage;
            if (currentPage > totalPages) {
                currentPage = totalPages;
                if (isTx) currentTxPage = currentPage; else currentPoPage = currentPage;
            }
            if (currentPage < 1) {
                currentPage = 1;
                if (isTx) currentTxPage = 1; else currentPoPage = 1;
            }

            // Show/hide rows for current page
            const startIndex = (currentPage - 1) * WALLET_PAGE_SIZE;
            const endIndex = startIndex + WALLET_PAGE_SIZE;

            rows.forEach((row, idx) => {
                if (idx >= startIndex && idx < endIndex) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });

            // Build circular pagination buttons
            let html = '';

            // First page << button (if on page > 2)
            if (totalPages > 2 && currentPage > 1) {
                html += '<button type="button" class="wallet-page-btn" onclick="setWalletPage(1)" title="Trang đầu"><i class="fa-solid fa-angles-left"></i></button>';
            }

            // Previous page < button (if on page > 1)
            if (currentPage > 1) {
                html += '<button type="button" class="wallet-page-btn" onclick="setWalletPage(' + (currentPage - 1) + ')" title="Trang trước"><i class="fa-solid fa-angle-left"></i></button>';
            }

            // Page numbers (e.g. 1, 2, 3, 4, 5, 6, 7...)
            let startPage = 1;
            let endPage = totalPages;
            if (totalPages > 7) {
                if (currentPage <= 4) {
                    startPage = 1;
                    endPage = 7;
                } else if (currentPage + 3 >= totalPages) {
                    startPage = totalPages - 6;
                    endPage = totalPages;
                } else {
                    startPage = currentPage - 3;
                    endPage = currentPage + 3;
                }
            }

            for (let p = startPage; p <= endPage; p++) {
                const activeClass = p === currentPage ? 'active' : '';
                html += '<button type="button" class="wallet-page-btn ' + activeClass + '" onclick="setWalletPage(' + p + ')">' + p + '</button>';
            }

            // Next page > button (if on page < totalPages)
            if (currentPage < totalPages) {
                html += '<button type="button" class="wallet-page-btn" onclick="setWalletPage(' + (currentPage + 1) + ')" title="Trang kế tiếp"><i class="fa-solid fa-angle-right"></i></button>';
            }

            // Last page >> button (if on page < totalPages - 1 or totalPages > 2)
            if (totalPages > 2 && currentPage < totalPages) {
                html += '<button type="button" class="wallet-page-btn" onclick="setWalletPage(' + totalPages + ')" title="Trang cuối"><i class="fa-solid fa-angles-right"></i></button>';
            }

            container.innerHTML = html;
        }

        function setWalletPage(page) {
            const isTx = document.getElementById('tabTransactionsContent').style.display !== 'none';
            if (isTx) {
                currentTxPage = page;
            } else {
                currentPoPage = page;
            }
            renderWalletPagination();
        }

        // Quick amount button click
        function setQuickAmount(amount) {
            const input = document.getElementById('withdrawAmount');
            if (input) {
                input.value = amount;
                input.focus();
            }
        }

        // Handle Bank Select dropdown change
        function handleBankSelect(selectEl) {
            const selectedOpt = selectEl.options[selectEl.selectedIndex];
            const bankName = selectedOpt.getAttribute('data-name');
            document.getElementById('bankNameHidden').value = bankName;
        }

        // Sorting functions (Mới nhất / Lâu nhất)
        let currentSortOrder = "${sort != null && sort == 'oldest' ? 'oldest' : 'newest'}";

        function updateSortIcons(order) {
            const iconTx = document.getElementById('sortIconTx');
            const iconPo = document.getElementById('sortIconPo');
            const className = order === 'oldest' 
                ? 'fa-solid fa-arrow-up-wide-short ms-1 text-primary' 
                : 'fa-solid fa-arrow-down-wide-short ms-1 text-primary';
            if (iconTx) iconTx.className = className;
            if (iconPo) iconPo.className = className;
        }

        function sortWalletTable(tbodySelector, rowSelector, order) {
            const tbody = document.querySelector(tbodySelector);
            if (!tbody) return;
            const rows = Array.from(tbody.querySelectorAll(rowSelector));
            if (rows.length <= 1) return;

            rows.sort((a, b) => {
                const timeA = parseInt(a.getAttribute('data-timestamp') || '0', 10);
                const timeB = parseInt(b.getAttribute('data-timestamp') || '0', 10);
                return order === 'oldest' ? timeA - timeB : timeB - timeA;
            });

            rows.forEach(row => tbody.appendChild(row));
        }

        function handleWalletSort(order) {
            currentSortOrder = order;
            const selectEl = document.getElementById('walletSortSelect');
            if (selectEl && selectEl.value !== order) {
                selectEl.value = order;
            }

            updateSortIcons(order);
            sortWalletTable('#tabTransactionsContent tbody', '.wallet-tx-row', order);
            sortWalletTable('#tabPayoutsContent tbody', '.wallet-po-row', order);

            currentTxPage = 1;
            currentPoPage = 1;
            renderWalletPagination();

            // Update URL query parameter smoothly without page reload
            try {
                const url = new URL(window.location);
                url.searchParams.set('sort', order);
                window.history.replaceState({}, '', url);
            } catch (e) {}
        }

        function toggleWalletSort() {
            const newOrder = currentSortOrder === 'newest' ? 'oldest' : 'newest';
            handleWalletSort(newOrder);
        }

        document.addEventListener("DOMContentLoaded", function() {
            updateSortIcons(currentSortOrder);
            renderWalletPagination();
        });

        // Check for session flash messages
        <c:if test="${not empty sessionScope.message}">
            Toastify({
                text: "${sessionScope.message}",
                duration: 4000,
                close: true,
                gravity: "top",
                position: "right",
                backgroundColor: "${sessionScope.messageType == 'error' ? '#ef4444' : '#10b981'}"
            }).showToast();
            <c:remove var="message" scope="session" />
            <c:remove var="messageType" scope="session" />
        </c:if>
    </script>
</body>
</html>
