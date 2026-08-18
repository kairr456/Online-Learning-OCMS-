<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="account-manager-container">
    <div class="dashboard-title">Quản lý Yêu cầu Rút tiền (Payout Management)</div>

    <!-- Quick Stats Cards -->
    <div class="payout-stats-grid">
        <div class="payout-stat-box">
            <div>
                <div class="stat-label">Chờ duyệt</div>
                <div class="stat-val" style="color: #B45309;">
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
                <div class="stat-val" style="color: #1B8F4A;">
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
                <div class="stat-val" style="color: #5751E1;">
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
        <div class="search-box">
            <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm tên GV, email, STK..."/>
            <button type="submit" class="btn-search" title="Search">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <div class="filter-group">
            <select name="status" class="filter-select" onchange="this.form.submit()">
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
                                    <small style="color: #64748b;">${p.teacherEmail}</small>
                                </td>
                                <td>
                                    <strong style="color: #DC2626; font-size: 14.5px;">
                                        <fmt:formatNumber value="${p.amount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </strong>
                                </td>
                                <td>
                                    <span style="color: #5751E1; font-weight: 600;"><i class="fa-solid fa-building-columns"></i> ${p.bankName} (${p.bankCode})</span><br/>
                                    <span>STK: <strong style="font-family: monospace; font-size: 14px;">${p.accountNumber}</strong></span><br/>
                                    <small style="color: #64748b;">Chủ TK: ${p.accountHolder}</small>
                                </td>
                                <td>
                                    <fmt:formatDate value="${p.createdAt}" pattern="dd/MM/yyyy"/><br/>
                                    <small style="color: #64748b;"><fmt:formatDate value="${p.createdAt}" pattern="HH:mm"/></small>
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
                                            <small style="color: #64748b;">Mã GD: ${p.transactionCode != null ? p.transactionCode : 'Không có'}</small>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 40px 0; color: #64748b;">
                                <i class="fa-solid fa-money-bill-wave" style="font-size: 32px; opacity: 0.3; display: block; margin-bottom: 8px;"></i>
                                Không có yêu cầu rút tiền nào.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<!-- ================================================================= -->
<!-- MODAL 1: QUÉT VIETQR & DUYỆT RÚT TIỀN (Native Admin Modal) -->
<!-- ================================================================= -->
<div id="processModal" class="modal" style="display:none;">
    <div class="modal-content" style="width: 520px;">
        <span class="modal-close" onclick="closeProcessModal()">&times;</span>
        <h3 style="color: #5751E1; margin-bottom: 16px;"><i class="fa-solid fa-qrcode"></i> Quét QR Chuyển tiền</h3>

        <div class="vietqr-wrapper">
            <img id="vietQrImg" src="" alt="Mã VietQR">
            <div style="font-size: 12px; color: #64748b; margin-top: 8px;">
                <i class="fa-solid fa-camera"></i> Mở App Ngân hàng quét mã QR để chuyển nhanh 24/7
            </div>
        </div>

        <div class="payout-detail-row">
            <span class="label">Giảng viên:</span>
            <span class="val" id="modalTeacherName">-</span>
        </div>
        <div class="payout-detail-row">
            <span class="label">Ngân hàng:</span>
            <span class="val" id="modalBankName" style="color: #5751E1;">-</span>
        </div>
        <div class="payout-detail-row">
            <span class="label">Số tài khoản:</span>
            <span class="val" id="modalAccountNumber" style="font-family: monospace; font-size: 15px;">-</span>
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

            <div style="display: flex; gap: 10px; margin-top: 18px;">
                <button type="submit" style="flex: 2; background: #1B8F4A; border-color: #1B8F4A; color: #fff;">
                    <i class="fa-solid fa-check"></i> Xác nhận Đã chuyển tiền
                </button>
                <button type="button" onclick="closeProcessModal()" style="flex: 1;">Đóng</button>
            </div>
        </form>
    </div>
</div>

<!-- ================================================================= -->
<!-- MODAL 2: TỪ CHỐI YÊU CẦU RÚT TIỀN (Native Admin Modal) -->
<!-- ================================================================= -->
<div id="rejectModal" class="modal" style="display:none;">
    <div class="modal-content" style="width: 440px;">
        <span class="modal-close" onclick="closeRejectModal()">&times;</span>
        <h3 style="color: #DC2626; margin-bottom: 12px;"><i class="fa-solid fa-triangle-exclamation"></i> Từ chối rút tiền</h3>

        <p style="font-size: 14px; color: #333; margin-bottom: 10px;">
            Từ chối đơn rút của giảng viên: <strong id="rejectTeacherName"></strong>
        </p>

        <div style="background: #FFFBEB; border: 1px solid #FDE68A; color: #B45309; padding: 10px 12px; border-radius: 8px; font-size: 13px; margin-bottom: 14px;">
            <i class="fa-solid fa-info-circle"></i> Số tiền <strong id="rejectAmountDisplay"></strong> sẽ được <strong>hoàn trả lại ví</strong> giảng viên.
        </div>

        <form action="${pageContext.request.contextPath}/admin/payouts" method="POST">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="payoutId" id="rejectPayoutId">

            <label>Lý do từ chối *</label>
            <textarea name="adminNote" id="rejectReason" rows="3" placeholder="Ví dụ: STK không tồn tại, đơn hàng đang bị tranh chấp..." required></textarea>

            <div style="display: flex; gap: 10px; margin-top: 18px;">
                <button type="submit" style="flex: 2; background: #DC2626; border-color: #DC2626; color: #fff;">
                    <i class="fa-solid fa-ban"></i> Xác nhận Từ chối
                </button>
                <button type="button" onclick="closeRejectModal()" style="flex: 1;">Hủy</button>
            </div>
        </form>
    </div>
</div>

<script>
    const processModalEl = document.getElementById('processModal');
    const rejectModalEl = document.getElementById('rejectModal');

    function openProcessModal(id, teacherName, amount, bankCode, bankName, accountNumber, accountHolder) {
        document.getElementById('modalPayoutId').value = id;
        document.getElementById('modalTeacherName').innerText = teacherName;
        document.getElementById('modalBankName').innerText = bankName + ' (' + bankCode + ')';
        document.getElementById('modalAccountNumber').innerText = accountNumber;
        document.getElementById('modalAccountHolder').innerText = accountHolder;
        document.getElementById('modalAmountDisplay').innerText = Number(amount).toLocaleString('vi-VN') + ' ₫';
        
        // Dynamic VietQR URL
        const qrUrl = 'https://img.vietqr.io/image/' + encodeURIComponent(bankCode) + '-' + encodeURIComponent(accountNumber) + '-compact.png?amount=' + encodeURIComponent(amount) + '&addInfo=' + encodeURIComponent('PAYOUT ' + id);
        document.getElementById('vietQrImg').src = qrUrl;

        processModalEl.style.display = 'flex';
    }

    function closeProcessModal() {
        processModalEl.style.display = 'none';
    }

    function openRejectModal(id, teacherName, amount) {
        document.getElementById('rejectPayoutId').value = id;
        document.getElementById('rejectTeacherName').innerText = teacherName;
        document.getElementById('rejectAmountDisplay').innerText = Number(amount).toLocaleString('vi-VN') + ' ₫';
        
        rejectModalEl.style.display = 'flex';
    }

    function closeRejectModal() {
        rejectModalEl.style.display = 'none';
    }

    // Close modal when clicking outside of modal-content
    window.addEventListener('click', function(e) {
        if (e.target === processModalEl) {
            closeProcessModal();
        }
        if (e.target === rejectModalEl) {
            closeRejectModal();
        }
    });
</script>
