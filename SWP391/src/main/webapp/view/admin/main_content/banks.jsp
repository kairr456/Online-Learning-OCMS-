<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="account-manager-container">
    <div class="dashboard-title">Manage Supported Banks</div>

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${param.msg == 'deleted'}">
        <div class="alert-box alert-success">
            <i class="fa-solid fa-circle-check"></i> Xóa ngân hàng thành công!
        </div>
    </c:if>
    <c:if test="${param.error == 'in_use'}">
        <div class="alert-box alert-danger">
            <i class="fa-solid fa-triangle-exclamation"></i> Không thể xóa ngân hàng này vì hiện đang có <strong>${param.count}</strong> tài khoản giảng viên liên kết nhận tiền! Bạn có thể chuyển trạng thái sang "Tạm dừng" (Inactive).
        </div>
    </c:if>
    <c:if test="${param.error == 'delete_failed'}">
        <div class="alert-box alert-danger">
            <i class="fa-solid fa-triangle-exclamation"></i> Xóa ngân hàng thất bại. Vui lòng thử lại!
        </div>
    </c:if>
    <c:if test="${param.error == 'invalid_id'}">
        <div class="alert-box alert-danger">
            <i class="fa-solid fa-triangle-exclamation"></i> ID ngân hàng không hợp lệ.
        </div>
    </c:if>

    <!-- ===== Toolbar (Search + Nút Thêm mới) ===== -->
    <form id="filterForm"
          action="${pageContext.request.contextPath}/admin/banks"
          method="GET"
          class="toolbar-section">

        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">

        <!-- Ô tìm kiếm theo mã, tên ngân hàng hoặc tên hiển thị -->
        <div class="search-box">
            <input type="text" name="keyword" value="${fn:escapeXml(param.keyword)}" placeholder="Search banks by code or name..."/>
            <button type="submit" class="btn-search" title="Search">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <!-- Nút Thêm mới ngân hàng -->
        <div class="action-btn-group">
            <button type="button" class="btn-add-user" onclick="openAdd()">
                <i class="fa-solid fa-plus"></i> Add Bank
            </button>
        </div>
    </form>

    <!-- ===== Bảng danh sách Ngân hàng ===== -->
    <div class="table-responsive">
        <table class="account-table">
            <thead>
                <tr>
                    <th class="col-bank-id">ID</th>
                    <th class="col-bank-code">Code</th>
                    <th class="col-bank-name">Bank Full Name</th>
                    <th class="col-bank-short">Display Name</th>
                    <th class="col-bank-accounts">Linked</th>
                    <th class="col-bank-status">Status</th>
                    <th class="col-bank-date">Created Date</th>
                    <th class="col-bank-date">Updated Date</th>
                    <th class="col-bank-actions">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="b" items="${bankList}">
                    <tr>
                        <td><strong>${b.id}</strong></td>
                        <td>
                            <span class="badge bank-code-badge">${b.bankCode}</span>
                        </td>
                        <td class="bank-name-cell" title="${fn:escapeXml(b.bankName)}">
                            <c:out value="${b.bankName}" />
                        </td>
                        <td class="bank-short-cell" title="${fn:escapeXml(b.shortName)}">
                            <c:out value="${b.shortName}" />
                        </td>
                        <td class="text-center">
                            <span class="badge cat-badge-count">${b.accountCount} STK</span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${b.status == 'active'}">
                                    <span class="badge active" style="background:#dcfce7; color:#15803d;">
                                        <i class="fa-solid fa-circle-check" style="font-size:10px;"></i> Active
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge inactive" style="background:#f1f5f9; color:#64748b;">
                                        <i class="fa-solid fa-circle-pause" style="font-size:10px;"></i> Inactive
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><fmt:formatDate value="${b.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                        <td><fmt:formatDate value="${b.updatedAt}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                        <td class="action-cell">
                            <!-- Nút Sửa (Mở modal Edit) -->
                            <button type="button" class="btn-action edit" title="Edit"
                                    onclick="openEdit(this)"
                                    data-id="${b.id}"
                                    data-code="${fn:escapeXml(b.bankCode)}"
                                    data-name="${fn:escapeXml(b.bankName)}"
                                    data-short="${fn:escapeXml(b.shortName)}"
                                    data-status="${b.status}">
                                <i class="fa-regular fa-pen-to-square"></i>
                            </button>

                            <!-- Nút Xóa (Chỉ cho phép xóa khi tài khoản liên kết = 0) -->
                            <c:choose>
                                <c:when test="${b.accountCount == 0}">
                                    <a href="${pageContext.request.contextPath}/admin/banks?action=delete&id=${b.id}"
                                       class="btn-action delete"
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa ngân hàng \'${fn:escapeXml(b.bankCode)} - ${fn:escapeXml(b.shortName)}\'?')"
                                       title="Delete">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button type="button"
                                            class="btn-action delete disabled"
                                            disabled
                                            title="Không thể xóa: Ngân hàng đang có ${b.accountCount} tài khoản liên kết">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>

                <!-- Trống danh sách -->
                <c:if test="${empty bankList}">
                    <tr>
                        <td colspan="9" class="cat-empty-state">
                            <i class="fa-solid fa-building-columns cat-empty-icon"></i>
                            Không tìm thấy ngân hàng nào phù hợp với bộ lọc.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- ===== Phân trang ===== -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <!-- Trang đầu (<<) -->
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('1')" title="First page">
                    <i class="fa-solid fa-angles-left"></i>
                </a>
            </c:if>

            <!-- Trang trước (<) -->
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage - 1}')" title="Previous page">
                    <i class="fa-solid fa-angle-left"></i>
                </a>
            </c:if>

            <!-- Danh sách số trang -->
            <c:forEach var="i" begin="1" end="${totalPages}">
                <a href="javascript:void(0)" class="page-link ${currentPage == i ? 'active' : ''}" onclick="goToPage('${i}')">${i}</a>
            </c:forEach>

            <!-- Trang sau (>) -->
            <c:if test="${currentPage < totalPages}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage + 1}')" title="Next page">
                    <i class="fa-solid fa-angle-right"></i>
                </a>
            </c:if>

            <!-- Trang cuối (>>) -->
            <c:if test="${currentPage < totalPages}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${totalPages}')" title="Last page">
                    <i class="fa-solid fa-angles-right"></i>
                </a>
            </c:if>
        </div>
    </c:if>
</div>

<!-- ===== Modal Add / Edit Bank ===== -->
<div id="bankModal" class="modal" style="display:none;">
    <div class="modal-content bank-modal-dialog">
        <span class="modal-close" onclick="closeModal()">&times;</span>
        <h3 id="modalTitle" class="cat-modal-title">Add Supported Bank</h3>

        <form id="bankForm">
            <input type="hidden" id="formAction" name="action" value="add">
            <input type="hidden" id="bankId" name="id">

            <div class="form-group-custom">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:5px;">
                    <label for="f_code" style="margin-bottom:0;">Mã ngân hàng (Bank Code) <span class="text-danger">*</span></label>
                    <span id="codeCharCount" style="font-size:12px; color:#64748B; font-weight:600; white-space:nowrap; flex-shrink:0; margin-left:8px;">0/50 ký tự</span>
                </div>
                <input type="text" id="f_code" name="bankCode" placeholder="Ví dụ: VCB, MB, TCB (tối đa 50 ký tự, không chứa số)..." maxlength="50" required style="text-transform: uppercase;">
                <div id="codeFieldError" style="display:none; color:#DC2626; font-size:12px; margin-top:3px; font-weight:600;"><i class="fa-solid fa-circle-exclamation"></i> Mã ngân hàng không được ghi số vào (chỉ chứa chữ cái)!</div>
                <div class="form-field-hint">Tối đa 50 ký tự. Chỉ chứa chữ cái (A-Z), không được ghi số vào và không chứa dấu cách.</div>
            </div>

            <div class="form-group-custom">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:5px;">
                    <label for="f_name" style="margin-bottom:0;">Tên đầy đủ ngân hàng (Bank Full Name) <span class="text-danger">*</span></label>
                    <span id="nameCharCount" style="font-size:12px; color:#64748B; font-weight:600; white-space:nowrap; flex-shrink:0; margin-left:8px;">0/255 ký tự</span>
                </div>
                <input type="text" id="f_name" name="bankName" placeholder="Ví dụ: Ngân hàng Ngoại Thương Việt Nam (Vietcombank) (không chứa số)..." maxlength="255" required>
                <div id="nameFieldError" style="display:none; color:#DC2626; font-size:12px; margin-top:3px; font-weight:600;"><i class="fa-solid fa-circle-exclamation"></i> Tên ngân hàng không được ghi số vào!</div>
                <div class="form-field-hint">Tối đa 255 ký tự. Chỉ chứa chữ cái, không được ghi số vào.</div>
            </div>

            <div class="form-group-custom">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:5px;">
                    <label for="f_short" style="margin-bottom:0;">Tên hiển thị rút gọn (Display Name) <span class="text-danger">*</span></label>
                    <span id="shortCharCount" style="font-size:12px; color:#64748B; font-weight:600; white-space:nowrap; flex-shrink:0; margin-left:8px;">0/255 ký tự</span>
                </div>
                <input type="text" id="f_short" name="shortName" placeholder="Ví dụ: Vietcombank - Ngân hàng Ngoại Thương VN (không chứa số)..." maxlength="255" required>
                <div id="shortFieldError" style="display:none; color:#DC2626; font-size:12px; margin-top:3px; font-weight:600;"><i class="fa-solid fa-circle-exclamation"></i> Tên hiển thị không được ghi số vào!</div>
                <div class="form-field-hint">Tối đa 255 ký tự. Tên hiển thị không được ghi số vào (không được để trống hoặc chỉ chứa dấu cách).</div>
            </div>

            <div class="form-group-custom">
                <label for="f_status">Trạng thái hoạt động</label>
                <select id="f_status" name="status" class="bank-select-custom">
                    <option value="active">Hoạt động (Active - Hiển thị trong danh sách chọn của ví)</option>
                    <option value="inactive">Tạm dừng (Inactive - Tạm ẩn khỏi danh sách)</option>
                </select>
            </div>

            <p id="modalError" class="cat-modal-error"></p>

            <div class="cat-modal-actions">
                <button type="button" class="btn-cat-cancel" onclick="closeModal()">Cancel</button>
                <button type="submit" id="btnSaveBank" class="btn-cat-save">Save Bank</button>
            </div>
        </form>
    </div>
</div>

<!-- JavaScript xử lý Modal, Fetch API và Phân trang -->
<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/admin/banks.js?v=1.1"></script>
