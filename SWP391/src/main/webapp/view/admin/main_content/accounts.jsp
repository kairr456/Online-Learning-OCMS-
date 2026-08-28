<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="account-manager-container">
    <div class="dashboard-title">Manage Accounts</div>

    <!-- Top Filter Bar -->
    <form id="filterForm"
          action="${pageContext.request.contextPath}/admin/accounts"
          method="GET"
          class="toolbar-section">

        <!-- Trang hiện tại (phân trang) -->
        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">

        <div class="search-box">
            <input type="text" name="keyword" value="${param.keyword}" placeholder="Search..."/>
            <button type="submit" class="btn-search" title="Search">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <div class="filter-group">
            <!-- Filter Role -->
            <select name="roleId" class="filter-select" onchange="submitFilter()">
                <option value="">All Roles</option>
                <option value="1" ${param.roleId == '1' ? 'selected' : ''}>Admin</option>
                <option value="2" ${param.roleId == '2' ? 'selected' : ''}>Teacher</option>
                <option value="3" ${param.roleId == '3' ? 'selected' : ''}>Student</option>
            </select>

            <!-- Filter Status -->
            <select name="status" class="filter-select" onchange="submitFilter()">
                <option value="">All Status</option>
                <option value="1" ${param.status == '1' ? 'selected' : ''}>Active</option>
                <option value="0" ${param.status == '0' ? 'selected' : ''}>Inactive</option>
            </select>
        </div>

        <!-- Add User -->
        <div class="action-btn-group">
            <button type="button" class="btn-add-user" onclick="openAdd()">+ Add User</button>
        </div>

    </form>

    <!-- Account Data Table -->
    <div class="table-responsive">
        <table class="account-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Full Name</th>
                    <th>Gender</th>
                    <th>Status</th>
                    <th>Role</th>
                    <th class="action-cell">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${userList}">
                    <tr>
                        <td>${u.id}</td>
                        <td>${u.username}</td>
                        <td>${u.email}</td>
                        <td>${u.phone != null ? u.phone : 'N/A'}</td>
                        <td>${u.fullName != null ? u.fullName : 'N/A'}</td>

                        <!-- Gender -->
                        <td>
                            <c:choose>
                                <c:when test="${u.gender}">Male</c:when>
                                <c:otherwise>Female</c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Status -->
                        <td>
                            <c:choose>
                                <c:when test="${u.active}">
                                    <span class="badge active">Active</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge inactive">Inactive</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Role -->
                        <td>
                            <c:choose>
                                <c:when test="${u.roleId == 1}">Admin</c:when>
                                <c:when test="${u.roleId == 2}">Instructor</c:when>
                                <c:when test="${u.roleId == 3}">Student</c:when>
                                <c:when test="${u.roleId == 4}">Manager</c:when>
                                <c:otherwise>User</c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Actions -->
                        <td class="action-cell">
                            <!-- View (Preview Modal) -->
                            <button type="button" class="btn-action view" title="View"
                                    onclick="openPreview(${u.id})">
                                <i class="fa-regular fa-eye"></i>
                            </button>

                            <!-- Edit (mở modal, dữ liệu đổ từ data-*) -->
                            <button type="button" class="btn-action edit" title="Edit"
                                    onclick="openEdit(this)"
                                    data-id="${u.id}" data-username="${u.username}"
                                    data-email="${u.email}" data-phone="${u.phone}"
                                    data-fullname="${u.fullName}" data-gender="${u.gender}"
                                    data-role="${u.roleId}" data-active="${u.active}">
                                <i class="fa-regular fa-pen-to-square"></i>
                            </button>

                            <!-- Deactivate -->
                            <a href="${pageContext.request.contextPath}/admin/accounts?action=delete&id=${u.id}"
                               class="btn-action delete"
                               onclick="return confirm('Are you sure you want to deactivate this account?')"
                               title="Deactivate">
                                <i class="fa-regular fa-trash-can"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>

                <!-- Empty -->
                <c:if test="${empty userList}">
                    <tr>
                        <td colspan="9" class="td-empty">No accounts found.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${currentPage > 1}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage - 1}')"><i class="fa-solid fa-angle-left"></i></a>
                </c:if>
                <c:forEach var="i" begin="1" end="${totalPages}">
                <a href="javascript:void(0)" class="page-link ${currentPage == i ? 'active' : ''}" onclick="goToPage('${i}')">${i}</a>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
                <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage + 1}')"><i class="fa-solid fa-angle-right"></i></a>
                </c:if>
        </div>
    </c:if>

</div>

<!-- ===== Modal Add/Edit ===== -->
<div id="accountModal" class="modal modal-hidden">
    <div class="modal-content">
        <span class="modal-close" onclick="closeModal()">&times;</span>
        <h3 id="modalTitle">Add Account</h3>

        <form id="accountForm" action="${pageContext.request.contextPath}/admin/accounts" method="POST">
            <input type="hidden" id="formAction" name="action">
            <input type="hidden" id="accountId" name="id">

            <label>Username</label>
            <input type="text" id="f_username" name="username" required>

            <label>Password (chỉ khi Add)</label>
            <input type="password" id="f_password" name="password">

            <label>Email</label>
            <input type="email" id="f_email" name="email" required>

            <label>Phone</label>
            <input type="text" id="f_phone" name="phone">

            <label>Full Name</label>
            <input type="text" id="f_fullName" name="fullName" required>

            <label>Gender</label>
            <select id="f_gender" name="gender">
                <option value="male">Male</option>
                <option value="female">Female</option>
            </select>

            <label>Role</label>
            <select id="f_roleId" name="roleId">
                <option value="1">Admin</option>
                <option value="2">Instructor</option>
                <option value="3">Student</option>
                <option value="4">Manager</option>
            </select>

            <label>Status</label>
            <select id="f_isActive" name="isActive">
                <option value="1">Active</option>
                <option value="0">Inactive</option>
            </select>

            <p id="modalError" class="modal-error"></p>
            <button type="submit">Save</button>
            <button type="button" onclick="closeModal()">Cancel</button>
        </form>
    </div>
</div>

<!-- ===== Modal Preview (View Account) ===== -->
<div id="previewModal" class="modal modal-hidden" style="display:none; align-items:center; justify-content:center; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:10000; backdrop-filter: blur(4px);">
    <div class="modal-preview-dialog" style="max-width:1100px; width:95%; max-height:90vh; background:#fff; border-radius:16px; overflow:hidden; display:flex; flex-direction:column; box-shadow:0 25px 50px -12px rgba(0,0,0,0.25); animation:modalSlideIn 0.25s ease;">
        <!-- Header -->
        <div class="preview-header" style="padding:20px 24px; border-bottom:1px solid #E2E8F0; background:#FAFAFA; border-radius:16px 16px 0 0; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px;">
            <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
                <div id="previewAvatar" style="width:48px; height:48px; border-radius:12px; background:linear-gradient(135deg, #D8A24A 0%, #C48635 100%); display:flex; align-items:center; justify-content:center; color:#fff; font-weight:700; font-size:18px; flex-shrink:0;"></div>
                <div>
                    <h2 id="previewFullName" style="margin:0; font-size:20px; font-weight:700; color:#0F172A;">Loading...</h2>
                    <p id="previewUsername" style="margin:2px 0 0; font-size:13px; color:#64748B;">@username</p>
                </div>
            </div>
            <button type="button" class="modal-close" onclick="closePreview()" style="width:36px; height:36px; border-radius:10px; border:none; background:#F1F5F9; color:#64748B; font-size:20px; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:all 0.15s;" onmouseover="this.style.background='#E2E8F0'; this.style.color='#0F172A'" onmouseout="this.style.background='#F1F5F9'; this.style.color='#64748B'">&times;</button>
        </div>

        <!-- Body -->
        <div class="preview-body" style="flex:1; overflow-y:auto; padding:24px; display:flex; gap:24px;">
            <!-- Main: Account and teacher profile details -->
            <main class="preview-main" style="flex:1; min-width:0;">
                <!-- Tabs -->
                <div class="preview-tabs" style="display:flex; border-bottom:1px solid #E2E8F0; margin-bottom:24px; gap:4px;">
                    <button type="button" class="preview-tab active" data-tab="accountTab" style="padding:12px 20px; background:none; border:none; cursor:pointer; font-weight:600; color:#475569; border-bottom:3px solid #D8A24A; margin-bottom:-1px; font-size:14px; white-space:nowrap;">
                        <i class="fa-regular fa-user"></i> <span style="margin-left:6px;">Thông tin tài khoản</span>
                    </button>
                    <button type="button" id="teacherProfileTab" class="preview-tab" data-tab="teacherProfileTabContent" style="padding:12px 20px; background:none; border:none; cursor:pointer; font-weight:600; color:#94A3B8; border-bottom:3px solid transparent; margin-bottom:-1px; font-size:14px; white-space:nowrap; display:none;">
                        <i class="fa-regular fa-id-badge"></i> <span style="margin-left:6px;">Hồ sơ chuyên môn</span>
                    </button>
                </div>

                <!-- Tab 1: Account Info -->
                <div id="accountTab" class="preview-tab-content" style="display:block;">
                    <div class="detail-card" style="background:#fff; border:1px solid #E2E8F0; border-radius:12px; padding:24px;">
                        <h3 style="margin:0 0 20px; font-size:16px; font-weight:700; color:#0F172A;">Thông tin tài khoản</h3>
                        <div class="detail-grid" style="display:grid; grid-template-columns:repeat(2, 1fr); gap:20px 32px;">
                            <div><label class="preview-label">Họ và tên</label><span class="preview-value" id="prevFullName"></span></div>
                            <div><label class="preview-label">Tên đăng nhập</label><span class="preview-value preview-value--mono" id="prevUsername2"></span></div>
                            <div><label class="preview-label">Email</label><span class="preview-value" id="prevEmail2"></span></div>
                            <div><label class="preview-label">Số điện thoại</label><span class="preview-value" id="prevPhone2"></span></div>
                            <div><label class="preview-label">Giới tính</label><span class="preview-value" id="prevGender2"></span></div>
                            <div><label class="preview-label">Vai trò</label><span class="preview-value" id="prevRole2"></span></div>
                            <div><label class="preview-label">Trạng thái</label><span class="preview-value" id="prevStatus2"></span></div>
                        </div>
                    </div>
                </div>

                <!-- Tab 2: Teacher Profile -->
                <div id="teacherProfileTabContent" class="preview-tab-content" style="display:none;">
                    <div class="detail-grid" style="display:grid; grid-template-columns:repeat(2, 1fr); gap:20px;">
                        <!-- Specialization -->
                        <div class="detail-card detail-card--full" style="background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px; padding:20px; grid-column:1/-1;">
                            <h4 style="margin:0 0 12px; font-size:13px; font-weight:700; color:#64748B;">Chuyên môn / Tiêu đề</h4>
                            <p id="prevSpecialization" style="margin:0; font-size:15px; color:#0F172A; font-weight:500;"></p>
                        </div>
                        
                        <!-- Bio -->
                        <div class="detail-card detail-card--full" style="background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px; padding:20px; grid-column:1/-1;">
                            <h4 style="margin:0 0 12px; font-size:13px; font-weight:700; color:#64748B;">Giới thiệu bản thân</h4>
                            <div id="prevBio" style="margin:0; font-size:14px; color:#0F172A; line-height:1.7; white-space:pre-wrap;"></div>
                        </div>

                        <!-- Experience Years -->
                        <div class="detail-card" style="background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px; padding:20px;">
                            <h4 style="margin:0 0 12px; font-size:13px; font-weight:700; color:#64748B;">Số năm kinh nghiệm</h4>
                            <p id="prevExperienceYears" style="margin:0; font-size:24px; font-weight:700; color:#D8A24A;"></p>
                        </div>

                        <!-- Approval Status -->
                        <div class="detail-card" style="background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px; padding:20px;">
                            <h4 style="margin:0 0 12px; font-size:13px; font-weight:700; color:#64748B;">Trạng thái duyệt</h4>
                            <span id="prevApprovalStatus" style="font-size:14px; font-weight:600;"></span>
                        </div>

                        <!-- CV File -->
                        <div class="detail-card detail-card--full" style="background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px; padding:20px; grid-column:1/-1;">
                            <h4 style="margin:0 0 12px; font-size:13px; font-weight:700; color:#64748B;">File CV</h4>
                            <div id="prevCvUrl" style="font-size:14px; color:#0F172A;"></div>
                        </div>

                        <!-- Portfolio -->
                        <div class="detail-card detail-card--full" style="background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px; padding:20px; grid-column:1/-1;">
                            <h4 style="margin:0 0 12px; font-size:13px; font-weight:700; color:#64748B;">Portfolio / Website</h4>
                            <div id="prevPortfolioUrl" style="font-size:14px; color:#0F172A;"></div>
                        </div>

                        <!-- Rejected Reason -->
                        <div class="detail-card detail-card--full" style="background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px; padding:20px; grid-column:1/-1;" id="rejectedReasonCard" style="display:none;">
                            <h4 style="margin:0 0 12px; font-size:13px; font-weight:700; color:#64748B;">Lý do từ chối</h4>
                            <div id="prevRejectedReason" style="font-size:14px; color:#DC2626; white-space:pre-wrap; background:#FEF2F2; padding:12px; border-radius:8px; border:1px solid #FECACA;"></div>
                        </div>

                        <!-- Created Date -->
                        <div class="detail-card" style="background:#FAFAFA; border:1px solid #E2E8F0; border-radius:12px; padding:20px;">
                            <h4 style="margin:0 0 12px; font-size:13px; font-weight:700; color:#64748B;">Ngày tạo hồ sơ</h4>
                            <p id="prevProfileCreatedDate" style="margin:0; font-size:14px; color:#0F172A;"></p>
                        </div>
                    </div>
                </div>
            </main>
        </div>

    </div>
</div>
    </div>
</div>

<style>
@keyframes modalSlideIn {
    from { opacity:0; transform:translateY(-20px) scale(0.98); }
    to { opacity:1; transform:translateY(0) scale(1); }
}

.preview-tab {
    position:relative;
    transition:color 0.15s, border-color 0.15s;
}
.preview-tab:hover:not(.active) {
    color:#0F172A;
}
.preview-tab.active {
    color:#D8A24A !important;
}
.preview-label {
    display:block;
    margin-bottom:6px;
    color:#64748B;
    font-size:12px;
    font-weight:500;
}
.preview-value {
    display:block;
    color:#0F172A;
    font-size:15px;
    font-weight:600;
    overflow-wrap:anywhere;
}
.preview-value--mono {
    font-family:monospace;
    font-size:14px;
}
.preview-tab-content {
    animation:fadeIn 0.2s ease;
}
@keyframes fadeIn {
    from { opacity:0; transform:translateY(4px); }
    to { opacity:1; transform:translateY(0); }
}

@media (max-width: 900px) {
    .preview-body {
        flex-direction:column;
    }
    .preview-sidebar {
        width:100%; position:static;
    }
    .detail-grid {
        grid-template-columns:1fr !important;
    }
}
</style>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/admin/accounts.js"></script>

<script>
    // Preview Modal Functions
    function openPreview(accountId) {
        const modal = document.getElementById('previewModal');
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        
        // Show loading state
        document.getElementById('previewFullName').textContent = 'Loading...';
        
        // Fetch account details
        fetch(window.CONTEXT_PATH + '/admin/accounts?action=preview&id=' + accountId)
            .then(response => response.json())
            .then(data => {
                if (!data.success) {
                    alert('Error: ' + (data.error || 'Unknown error'));
                    closePreview();
                    return;
                }
                populatePreview(data);
            })
            .catch(err => {
                console.error('Preview fetch error:', err);
                alert('Failed to load account details.');
                closePreview();
            });
    }

    function closePreview() {
        const modal = document.getElementById('previewModal');
        modal.style.display = 'none';
        document.body.style.overflow = '';
    }

    function populatePreview(data) {
        // Reset rejected reason card
        document.getElementById('rejectedReasonCard').style.display = 'none';

        // ---- Header / Sidebar ----
        // Avatar initial
        const name = data.fullName || data.username || 'User';
        document.getElementById('previewAvatar').textContent = name.charAt(0).toUpperCase();
        document.getElementById('previewFullName').textContent = data.fullName || '';
        document.getElementById('previewUsername').textContent = '@' + (data.username || '');
        
        // Account labels are shown once in the account card below.
        const roleMap = {1: 'Admin', 2: 'Instructor', 3: 'Student', 4: 'Manager'};
        const roleName = roleMap[data.roleId] || 'User';
        // ---- Account tab ----
        document.getElementById('prevFullName').textContent = data.fullName || '';
        document.getElementById('prevUsername2').textContent = data.username || '';
        document.getElementById('prevEmail2').textContent = data.email || '';
        document.getElementById('prevPhone2').textContent = data.phone || 'N/A';
        document.getElementById('prevGender2').textContent = data.gender ? 'Male' : 'Female';
        document.getElementById('prevRole2').textContent = roleName;
        document.getElementById('prevStatus2').textContent = data.active ? 'Active' : 'Inactive';

        // ---- Teacher Profile Tab ----
        const teacherProfileTab = document.getElementById('teacherProfileTab');
        const teacherProfileTabContent = document.getElementById('teacherProfileTabContent');
        
        if (data.roleId === 2 && data.teacherProfile) {
            teacherProfileTab.style.display = 'block';
            
            const tp = data.teacherProfile;
            document.getElementById('prevSpecialization').textContent = tp.specialization || '';
            document.getElementById('prevBio').textContent = tp.bio || '';
            document.getElementById('prevExperienceYears').textContent = tp.experienceYears + ' năm';
            document.getElementById('prevApprovalStatus').innerHTML = getApprovalStatusBadge(tp.approvalStatus);
            document.getElementById('prevProfileCreatedDate').textContent = tp.createdDate || '';
            
            // CV URL
            const cvDiv = document.getElementById('prevCvUrl');
            if (tp.cvUrl) {
                cvDiv.innerHTML = '<a href="' + tp.cvUrl + '" target="_blank" class="link-external" style="display:inline-flex; align-items:center; gap:6px; color:#D8A24A; font-weight:500;"><i class="fa-regular fa-file"></i> Xem/Tải CV</a>';
            } else {
                cvDiv.textContent = 'Chưa có';
            }
            
            // Portfolio URL
            const portfolioDiv = document.getElementById('prevPortfolioUrl');
            if (tp.portfolioUrl) {
                portfolioDiv.innerHTML = '<a href="' + tp.portfolioUrl + '" target="_blank" class="link-external" style="display:inline-flex; align-items:center; gap:6px; color:#D8A24A; font-weight:500;"><i class="fa-solid fa-globe"></i> ' + tp.portfolioUrl + '</a>';
            } else {
                portfolioDiv.textContent = 'Chưa có';
            }
            
            // Rejected Reason
            if (tp.rejectedReason) {
                document.getElementById('rejectedReasonCard').style.display = 'block';
                document.getElementById('prevRejectedReason').textContent = tp.rejectedReason;
            }
        } else {
            teacherProfileTab.style.display = 'none';
            teacherProfileTabContent.style.display = 'none';
        }
        
        // Default to account tab
        switchTab('accountTab');
    }

    function getApprovalStatusBadge(status) {
        if (!status) return '<span style="color:#64748B;">N/A</span>';
        const badges = {
            'PENDING': '<span class="badge badge--warning" style="font-size:13px; padding:4px 10px;">Chờ duyệt</span>',
            'APPROVED': '<span class="badge badge--success" style="font-size:13px; padding:4px 10px;">Đã duyệt</span>',
            'REJECTED': '<span class="badge badge--danger" style="font-size:13px; padding:4px 10px;">Đã từ chối</span>'
        };
        return badges[status] || '<span class="badge badge--info" style="font-size:13px; padding:4px 10px;">' + status + '</span>';
    }

    function switchTab(tabId) {
        document.querySelectorAll('.preview-tab').forEach(t => {
            t.classList.remove('active');
            t.style.color = '#94A3B8';
            t.style.borderBottomColor = 'transparent';
        });
        document.querySelectorAll('.preview-tab-content').forEach(c => c.style.display = 'none');
        
        const activeTab = document.querySelector('.preview-tab[data-tab="' + tabId + '"]');
        if (activeTab) {
            activeTab.classList.add('active');
            activeTab.style.color = '#0F172A';
            activeTab.style.borderBottomColor = '#D8A24A';
        }
        document.getElementById(tabId).style.display = 'block';
    }

    // Tab switching
    document.querySelectorAll('.preview-tab').forEach(tab => {
        tab.addEventListener('click', function() {
            switchTab(this.dataset.tab);
        });
    });

    // Close modal on backdrop click
    document.getElementById('previewModal').addEventListener('click', function(e) {
        if (e.target === this) closePreview();
    });

    // Close on Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closePreview();
        }
    });
</script>