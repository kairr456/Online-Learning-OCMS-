<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>

<div class="account-manager-container">
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; flex-wrap:wrap; gap:12px;">
        <a href="${pageContext.request.contextPath}/admin/teacher-approvals" style="display:inline-flex; align-items:center; gap:6px; padding:10px 16px; border-radius:8px; border:1px solid #CBD5E1; background:#fff; color:#475569; font-weight:600; font-size:14px; text-decoration:none; transition:all 0.15s;" onmouseover="this.style.background='#F8FAFC'" onmouseout="this.style.background='#fff'">
            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
        </a>
        <h1 style="margin:0; font-size:24px; font-weight:700; color:#0F172A;">Chi tiết duyệt Giảng viên</h1>
    </div>

    <div class="teacher-approval-detail" style="display:flex; flex-direction:column; gap:24px;">

        <!-- Account Info Card -->
        <div class="detail-card" style="background:#fff; border:1px solid #E2E8F0; border-radius:12px; overflow:hidden;">
            <div style="padding:16px 20px; background:#FAFAFA; border-bottom:1px solid #E2E8F0;">
                <h2 style="margin:0; font-size:16px; font-weight:700; color:#0F172A;">Thông tin tài khoản</h2>
            </div>
            <div class="detail-grid" style="display:grid; grid-template-columns:repeat(auto-fit, minmax(280px, 1fr)); gap:20px; padding:20px;">
                <div class="detail-field" style="display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Họ tên</label>
                    <span style="font-size:15px; color:#0F172A; font-weight:500;">${account.fullName}</span>
                </div>
                <div class="detail-field" style="display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Username</label>
                    <span style="font-size:14px; color:#0F172A; font-family:monospace;">@${account.username}</span>
                </div>
                <div class="detail-field" style="display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Email</label>
                    <span style="font-size:14px; color:#0F172A;">${account.email}</span>
                </div>
                <div class="detail-field" style="display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Số điện thoại</label>
                    <span style="font-size:14px; color:#0F172A;">${account.phone != null ? account.phone : 'Chưa cung cấp'}</span>
                </div>
                <div class="detail-field" style="display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Giới tính</label>
                    <span style="font-size:14px; color:#0F172A;">${account.gender ? 'Nam' : 'Nữ'}</span>
                </div>
                <div class="detail-field" style="display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Trạng thái</label>
                    <span>
                        <c:choose>
                            <c:when test="${account.active}">
                                <span class="badge badge--success" style="display:inline-flex; align-items:center; padding:4px 10px; font-size:12px; font-weight:600; border-radius:9999px; background:#E7F5EC; color:#1E7A4A;">Đang hoạt động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge--danger" style="display:inline-flex; align-items:center; padding:4px 10px; font-size:12px; font-weight:600; border-radius:9999px; background:#FEE2E2; color:#DC2626;">Chưa kích hoạt</span>
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>
        </div>

        <!-- Profile Info Card -->
        <div class="detail-card" style="background:#fff; border:1px solid #E2E8F0; border-radius:12px; overflow:hidden;">
            <div style="padding:16px 20px; background:#FAFAFA; border-bottom:1px solid #E2E8F0;">
                <h2 style="margin:0; font-size:16px; font-weight:700; color:#0F172A;">Hồ sơ chuyên môn</h2>
            </div>
            <div class="detail-grid" style="display:grid; grid-template-columns:repeat(auto-fit, minmax(300px, 1fr)); gap:20px; padding:20px;">
                <div class="detail-field detail-field--full" style="grid-column:1/-1; display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Chuyên môn / Tiêu đề</label>
                    <span style="font-size:15px; color:#0F172A; font-weight:500;">${profile.specialization}</span>
                </div>
                <div class="detail-field detail-field--full" style="grid-column:1/-1; display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Giới thiệu bản thân</label>
                    <div style="font-size:14px; color:#0F172A; line-height:1.7; white-space:pre-wrap;">${profile.bio}</div>
                </div>
                <div class="detail-field" style="display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Số năm kinh nghiệm</label>
                    <span style="font-size:14px; color:#0F172A;">${profile.experienceYears} năm</span>
                </div>
                <div class="detail-field" style="display:flex; flex-direction:column; gap:6px;">
                    <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Trạng thái duyệt</label>
                    <c:choose>
                        <c:when test="${profile.approvalStatus == 'PENDING'}">
                            <span class="badge badge--warning" style="display:inline-flex; align-items:center; padding:4px 10px; font-size:13px; font-weight:600; border-radius:9999px; background:#FEF3C7; color:#B45309;">Chờ duyệt</span>
                        </c:when>
                        <c:when test="${profile.approvalStatus == 'APPROVED'}">
                            <span class="badge badge--success" style="display:inline-flex; align-items:center; padding:4px 10px; font-size:13px; font-weight:600; border-radius:9999px; background:#E7F5EC; color:#1E7A4A;">Đã duyệt</span>
                        </c:when>
                        <c:when test="${profile.approvalStatus == 'REJECTED'}">
                            <span class="badge badge--danger" style="display:inline-flex; align-items:center; padding:4px 10px; font-size:13px; font-weight:600; border-radius:9999px; background:#FEE2E2; color:#DC2626;">Đã từ chối</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge--info" style="display:inline-flex; align-items:center; padding:4px 10px; font-size:13px; font-weight:600; border-radius:9999px; background:#EFF6FF; color:#1E40AF;">${profile.approvalStatus}</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- CV File -->
            <div class="detail-field detail-field--full" style="grid-column:1/-1; display:flex; flex-direction:column; gap:6px; padding:0 20px;">
                <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">File CV</label>
                <c:choose>
                    <c:when test="${not empty profile.cvUrl}">
                        <a href="${profile.cvUrl}" target="_blank" style="display:inline-flex; align-items:center; gap:8px; padding:10px 16px; border-radius:8px; border:1px solid #CBD5E1; background:#fff; color:#D8A24A; font-weight:500; font-size:14px; text-decoration:none; transition:all 0.15s;" onmouseover="this.style.background='#FEFCE8'" onmouseout="this.style.background='#fff'">
                            <i class="fa-regular fa-file"></i> Tải xuống / Xem CV
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span style="color:#94A3B8; font-size:14px;">Không có file CV</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Portfolio URL -->
            <div class="detail-field detail-field--full" style="grid-column:1/-1; display:flex; flex-direction:column; gap:6px; padding:0 20px;">
                <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Portfolio / Website</label>
                <c:choose>
                    <c:when test="${not empty profile.portfolioUrl}">
                        <a href="${profile.portfolioUrl}" target="_blank" style="display:inline-flex; align-items:center; gap:8px; color:#D8A24A; font-weight:500; font-size:14px; text-decoration:none;">
                            <i class="fa-solid fa-globe"></i> ${profile.portfolioUrl}
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span style="color:#94A3B8; font-size:14px;">Chưa cung cấp</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="detail-field detail-field--full" style="grid-column:1/-1; display:flex; flex-direction:column; gap:6px; padding:0 20px;">
                <label style="font-size:11px; font-weight:600; color:#64748B; text-transform:uppercase; letter-spacing:0.5px;">Ngày tạo hồ sơ</label>
                <span style="font-size:14px; color:#0F172A;">${profile.createdAt != null ? profile.createdAt.toString().substring(0, 19).replace('T', ' ') : ''}</span>
            </div>
        </div>

        <!-- Action Buttons for PENDING -->
        <c:if test="${profile.approvalStatus == 'PENDING'}">
        <div style="display:flex; justify-content:flex-end; gap:12px; padding:0 20px 20px;">
            <form method="post" action="${pageContext.request.contextPath}/admin/teacher-approvals" onsubmit="return confirm('Xác nhận DUYỆT tài khoản giảng viên này?');">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="id" value="${profile.id}">
                <button type="submit" style="display:inline-flex; align-items:center; gap:8px; padding:12px 24px; border-radius:8px; border:none; background:#2F9E64; color:#fff; font-weight:600; font-size:14px; cursor:pointer; transition:background 0.15s;" onmouseover="this.style.background='#1E7A4A'" onmouseout="this.style.background='#2F9E64'">
                    <i class="fa-solid fa-check"></i> Duyệt tài khoản
                </button>
            </form>

            <button type="button" style="display:inline-flex; align-items:center; gap:8px; padding:12px 24px; border-radius:8px; border:none; background:#DC2626; color:#fff; font-weight:600; font-size:14px; cursor:pointer; transition:background 0.15s;" onmouseover="this.style.background='#B91C1C'" onmouseout="this.style.background='#DC2626'" onclick="openRejectModal(${profile.id}, '${account.fullName}')">
                <i class="fa-solid fa-xmark"></i> Từ chối
            </button>
        </div>
        </c:if>

        <!-- Status Display for non-PENDING -->
        <c:if test="${profile.approvalStatus != 'PENDING'}">
        <div style="padding:20px; background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px;">
            <div class="status-badge" style="display:inline-flex; align-items:center; gap:8px; padding:12px 18px; border-radius:8px; font-weight:600; font-size:14px; ${profile.approvalStatus == 'APPROVED' ? 'background:#E7F5EC; color:#1E7A4A;' : 'background:#FEE2E2; color:#DC2626;'}">
                <span class="status-badge__icon">${profile.approvalStatus == 'APPROVED' ? '&#10003;' : '&#10007;'}</span>
                <span>Đã ${profile.approvalStatus == 'APPROVED' ? 'DUYỆT' : 'TỪ CHỐI'}</span>
            </div>
            <c:if test="${not empty profile.rejectedReason}">
                <div style="margin-top:16px; padding:16px; background:#fff; border:1px solid #E2E8F0; border-radius:8px;">
                    <strong style="display:block; margin-bottom:8px; font-size:13px; color:#0F172A;">Lý do từ chối:</strong>
                    <p style="margin:0; font-size:14px; color:#DC2626; white-space:pre-wrap;">${profile.rejectedReason}</p>
                </div>
            </c:if>
            <div style="margin-top:16px; font-size:12px; color:#64748B;">
                Xử lý bởi Admin ID: ${profile.reviewedBy} lúc ${profile.reviewedAt != null ? profile.reviewedAt.toString().substring(0, 19).replace('T', ' ') : ''}
            </div>
        </div>
        </c:if>

    </div>
</div>

<!-- Reject Modal -->
<div class="modal" id="rejectModal" style="display:none; align-items:center; justify-content:center; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:10000; backdrop-filter: blur(4px);">
    <div style="max-width:520px; width:95%; background:#fff; border-radius:16px; overflow:hidden; box-shadow:0 25px 50px -12px rgba(0,0,0,0.25); animation:modalSlideIn 0.25s ease;">
        <div style="padding:20px 24px; border-bottom:1px solid #E2E8F0; display:flex; align-items:center; justify-content:space-between;">
            <div style="display:flex; align-items:center; gap:12px;">
                <div style="width:40px; height:40px; border-radius:10px; background:#FEE2E2; color:#DC2626; display:flex; align-items:center; justify-content:center; font-size:18px; flex-shrink:0;">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>
                <div>
                    <h3 style="margin:0; font-size:18px; font-weight:700; color:#0F172A;">Từ chối tài khoản giảng viên</h3>
                    <p id="rejectTeacherName" style="margin:2px 0 0; font-size:13px; color:#64748B;"></p>
                </div>
            </div>
            <button type="button" onclick="closeRejectModal()" style="width:32px; height:32px; border-radius:8px; border:none; background:#F1F5F9; color:#64748B; font-size:20px; cursor:pointer; display:flex; align-items:center; justify-content:center;" onmouseover="this.style.background='#E2E8F0'" onmouseout="this.style.background='#F1F5F9'">&times;</button>
        </div>
        <form id="rejectForm" onsubmit="submitReject(event)">
            <input type="hidden" id="rejectProfileId" name="id">
            <div style="padding:24px;">
                <p style="margin:0 0 16px; font-size:13.5px; color:#64748B;">Hành động này sẽ từ chối tài khoản giảng viên. Tài khoản sẽ bị xóa khỏi hệ thống.</p>
                <div style="margin-bottom:18px;">
                    <label for="rejectReasonInput" style="display:block; font-size:13px; font-weight:600; color:#0F172A; margin-bottom:6px;">Lý do từ chối <span style="color:#DC2626;">*</span></label>
                    <textarea id="rejectReasonInput" name="rejectedReason" rows="4" style="width:100%; padding:12px 14px; border:1.5px solid #CBD5E1; border-radius:10px; font-family:inherit; font-size:13.5px; color:#0F172A; outline:none; box-sizing:border-box; resize:vertical;" placeholder="Nhập lý do từ chối..." required></textarea>
                </div>
                <div style="display:flex; justify-content:flex-end; gap:10px;">
                    <button type="button" onclick="closeRejectModal()" style="padding:10px 20px; border-radius:8px; border:1px solid #CBD5E1; background:#fff; color:#475569; font-weight:600; font-size:14px; cursor:pointer;">Hủy</button>
                    <button type="submit" style="padding:10px 20px; border-radius:8px; border:none; background:#DC2626; color:#fff; font-weight:600; font-size:14px; cursor:pointer; display:inline-flex; align-items:center; gap:6px;">
                        <i class="fa-solid fa-paper-plane"></i> Gửi & Từ chối
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<style>
@keyframes modalSlideIn {
    from { opacity:0; transform:translateY(-20px) scale(0.98); }
    to { opacity:1; transform:translateY(0) scale(1); }
}
</style>

<script>
    function openRejectModal(profileId, teacherName) {
        const modal = document.getElementById('rejectModal');
        document.getElementById('rejectProfileId').value = profileId;
        document.getElementById('rejectTeacherName').textContent = teacherName;
        document.getElementById('rejectReasonInput').value = '';
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeRejectModal() {
        const modal = document.getElementById('rejectModal');
        modal.style.display = 'none';
        document.body.style.overflow = '';
    }

    function submitReject(event) {
        event.preventDefault();
        const profileId = document.getElementById('rejectProfileId').value;
        const reason = document.getElementById('rejectReasonInput').value.trim();
        
        if (!reason) {
            alert('Vui lòng nhập lý do từ chối.');
            return;
        }
        
        const btn = event.target.querySelector('button[type="submit"]');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin" style="margin-right:6px;"></i> Đang xử lý...';
        
        fetch(window.CONTEXT_PATH + '/admin/teacher-approvals?action=reject&ajax=true', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: 'id=' + profileId + '&rejectedReason=' + encodeURIComponent(reason)
        })
        .then(r => r.json())
        .then(res => {
            if (res.success) {
                alert('Đã từ chối tài khoản giảng viên!');
                closeRejectModal();
                window.location.reload();
            } else {
                alert('Từ chối thất bại: ' + (res.error || 'Unknown error'));
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-paper-plane" style="margin-right:6px;"></i> Gửi & Từ chối';
            }
        })
        .catch(err => {
            console.error(err);
            alert('Lỗi kết nối server.');
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-paper-plane" style="margin-right:6px;"></i> Gửi & Từ chối';
        });
    }

    // Close modal on backdrop click
    document.getElementById('rejectModal').addEventListener('click', function(e) {
        if (e.target === this) closeRejectModal();
    });

    // Close on Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeRejectModal();
        }
    });
</script>