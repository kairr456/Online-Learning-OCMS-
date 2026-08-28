<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="account-manager-container"
     data-flash-message="${flashMessage != null ? flashMessage : sessionScope.message}"
     data-flash-type="${flashType != null ? flashType : sessionScope.messageType}">
    <div class="dashboard-title">Quản lý Yêu cầu Rút tiền (Payout Management)</div>

    <!-- Quick Stats Cards -->
    <div class="payout-stats-grid">
        <div class="payout-stat-box">
            <div>
                <div class="stat-label">Chờ duyệt</div>
                <div class="stat-val stat-val--pending">
                    <fmt:formatNumber value="${pendingTotal != null ? pendingTotal : 0}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                </div>
            </div>
            <div class="payout-stat-icon pending">
                <i class="fa-solid fa-hourglass-half"></i>
            </div>
        </div>

        <div class="payout-stat-box">
            <div>
                <div class="stat-label">Đã chi trả</div>
                <div class="stat-val stat-val--completed">
                    <fmt:formatNumber value="${completedTotal != null ? completedTotal : 0}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                </div>
            </div>
            <div class="payout-stat-icon success">
                <i class="fa-solid fa-circle-check"></i>
            </div>
        </div>

        <div class="payout-stat-box">
            <div>
                <div class="stat-label">Tổng yêu cầu</div>
                <div class="stat-val stat-val--total">
                    ${totalRequests != null ? totalRequests : 0}
                </div>
            </div>
            <div class="payout-stat-icon total">
                <i class="fa-solid fa-money-bill-transfer"></i>
            </div>
        </div>
    </div>

    <!-- Top Filter Bar -->
    <form id="payoutFilterForm" action="${pageContext.request.contextPath}/admin/payouts" method="GET" class="toolbar-section">
        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">

        <div class="search-box">
            <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm tên GV, email, STK..."/>
            <button type="submit" class="btn-search" title="Search">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <div class="filter-group">
            <select name="status" class="filter-select" onchange="document.getElementById('pageInput').value='1'; this.form.submit()">
                <option value="">Tất cả trạng thái</option>
                <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Chờ duyệt (Pending)</option>
                <option value="completed" ${param.status == 'completed' ? 'selected' : ''}>Đã chuyển tiền (Completed)</option>
                <option value="rejected" ${param.status == 'rejected' ? 'selected' : ''}>Đã từ chối (Rejected)</option>
            </select>
        </div>
    </form>

    <!-- Payout Data Table -->
    <div class="table-responsive">
        <table class="account-table">
            <thead>
                <tr>
                    <th>Mã đơn</th>
                    <th>Giảng viên</th>
                    <th>Số tiền rút</th>
                    <th>Thông tin ngân hàng</th>
                    <th>Thời gian gửi</th>
                    <th>Trạng thái</th>
                    <th style="text-align: center;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty payoutList}">
                        <c:forEach var="p" items="${payoutList}">
                            <tr>
                                <td><strong>#PO-${p.id}</strong></td>
                                <td>
                                    <strong>${p.teacherName}</strong><br/>
                                    <small class="payout-muted-text">${p.teacherEmail}</small>
                                </td>
                                <td>
                                    <strong class="payout-amount-text">
                                        <fmt:formatNumber value="${p.amount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </strong>
                                </td>
                                <td>
                                    <span class="payout-bank-text"><i class="fa-solid fa-building-columns"></i> ${p.bankName} (${p.bankCode})</span><br/>
                                    <span>STK: <strong class="payout-stk-text">${p.accountNumber}</strong></span><br/>
                                    <small class="payout-muted-text">Chủ TK: ${p.accountHolder}</small>
                                </td>
                                <td>
                                    <fmt:formatDate value="${p.createdAt}" pattern="dd/MM/yyyy"/><br/>
                                    <small class="payout-muted-text"><fmt:formatDate value="${p.createdAt}" pattern="HH:mm"/></small>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.status == 'pending'}">
                                            <span class="badge pending"><i class="fa-solid fa-hourglass-half"></i> Chờ duyệt</span>
                                        </c:when>
                                        <c:when test="${p.status == 'completed' || p.status == 'approved'}">
                                            <span class="badge active"><i class="fa-solid fa-circle-check"></i> Đã chuyển</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge inactive"><i class="fa-solid fa-circle-xmark"></i> Bị từ chối</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="action-cell">
                                        <c:if test="${p.status == 'pending'}">
                                            <button type="button" class="btn-qr-action"
                                                    onclick="openProcessModal('${p.id}', '${p.teacherName}', '${p.amount}', '${p.bankCode}', '${p.bankName}', '${p.accountNumber}', '${p.accountHolder}')">
                                                <i class="fa-solid fa-qrcode"></i> Quét QR & Duyệt
                                            </button>
                                            <button type="button" class="btn-action delete" title="Từ chối"
                                                    onclick="openRejectModal('${p.id}', '${p.teacherName}', '${p.amount}')">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </c:if>
                                        <c:if test="${p.status != 'pending'}">
                                            <small class="payout-muted-text">Mã GD: ${p.transactionCode != null ? p.transactionCode : 'Không có'}</small>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="payout-empty-state">
                                <i class="fa-solid fa-money-bill-wave payout-empty-icon"></i>
                                Không có yêu cầu rút tiền nào.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <!-- Phân trang (Pagination) -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage - 1}')" title="Trang trước">
                    <i class="fa-solid fa-angle-left"></i>
                </a>
            </c:if>
            <c:forEach var="i" begin="1" end="${totalPages}">
                <a href="javascript:void(0)" class="page-link ${currentPage == i ? 'active' : ''}" onclick="goToPage('${i}')">${i}</a>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage + 1}')" title="Trang sau">
                    <i class="fa-solid fa-angle-right"></i>
                </a>
            </c:if>
        </div>
    </c:if>
</div>

<!-- ================================================================= -->
<!-- MODAL 1: QUÉT VIETQR & DUYỆT RÚT TIỀN (Native Admin Modal) -->
<!-- ================================================================= -->
<div id="processModal" class="modal" style="display:none;">
    <div class="modal-content payout-modal-content--process">
        <span class="modal-close" onclick="closeProcessModal()">&times;</span>
        <h3 class="payout-modal-header--process"><i class="fa-solid fa-qrcode"></i> Quét QR Chuyển tiền</h3>

        <div class="vietqr-wrapper">
            <img id="vietQrImg" src="" alt="Mã VietQR">
            <div class="vietqr-help-text">
                <i class="fa-solid fa-camera"></i> Mở App Ngân hàng quét mã QR để chuyển nhanh 24/7
            </div>
        </div>

        <div class="payout-detail-row">
            <span class="label">Giảng viên:</span>
            <span class="val" id="modalTeacherName">-</span>
        </div>
        <div class="payout-detail-row">
            <span class="label">Ngân hàng:</span>
            <span class="val payout-bank-text" id="modalBankName">-</span>
        </div>
        <div class="payout-detail-row">
            <span class="label">Số tài khoản:</span>
            <span class="val payout-stk-text" id="modalAccountNumber">-</span>
        </div>
        <div class="payout-detail-row">
            <span class="label">Chủ tài khoản:</span>
            <span class="val" id="modalAccountHolder">-</span>
        </div>

        <div class="payout-amount-highlight">
            <span>Số tiền cần chuyển:</span>
            <span id="modalAmountDisplay">0 ₫</span>
        </div>

        <form action="${pageContext.request.contextPath}/admin/payouts" method="POST">
            <input type="hidden" name="action" value="approve">
            <input type="hidden" name="payoutId" id="modalPayoutId">

            <label>Mã giao dịch ngân hàng / Ủy nhiệm chi *</label>
            <input type="text" name="transactionCode" id="transactionCodeInput" placeholder="Ví dụ: FT24081812345678" required>

            <div class="modal-action-btn-group">
                <button type="submit" class="btn-modal-confirm-success">
                    <i class="fa-solid fa-check"></i> Xác nhận Đã chuyển tiền
                </button>
                <button type="button" class="btn-modal-cancel" onclick="closeProcessModal()">Đóng</button>
            </div>
        </form>
    </div>
</div>

<!-- ================================================================= -->
<!-- MODAL 2: TỪ CHỐI YÊU CẦU RÚT TIỀN (Native Admin Modal) -->
<!-- ================================================================= -->
<div id="rejectModal" class="modal" style="display:none;">
    <div class="modal-content payout-modal-content--reject">
        <span class="modal-close" onclick="closeRejectModal()">&times;</span>
        <h3 class="payout-modal-header--reject"><i class="fa-solid fa-triangle-exclamation"></i> Từ chối rút tiền</h3>

        <p class="mb-2">
            Từ chối đơn rút của giảng viên: <strong id="rejectTeacherName"></strong>
        </p>

        <div class="payout-refund-notice">
            <i class="fa-solid fa-info-circle"></i> Số tiền <strong id="rejectAmountDisplay"></strong> sẽ được <strong>hoàn trả lại ví</strong> giảng viên.
        </div>

        <form action="${pageContext.request.contextPath}/admin/payouts" method="POST">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="payoutId" id="rejectPayoutId">

            <label>Lý do từ chối *</label>
            <textarea name="adminNote" id="rejectReason" rows="3" placeholder="Ví dụ: STK không tồn tại, đơn hàng đang bị tranh chấp..." required></textarea>

            <div class="modal-action-btn-group">
                <button type="submit" class="btn-modal-confirm-reject">
                    <i class="fa-solid fa-ban"></i> Xác nhận Từ chối
                </button>
                <button type="button" class="btn-modal-cancel" onclick="closeRejectModal()">Hủy</button>
            </div>
        </form>
    </div>
</div>

<!-- Custom Payouts JS -->
<script src="${pageContext.request.contextPath}/assets/js/admin/payouts.js?v=1.0"></script>
