<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="account-manager-container">

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
                <option value="2" ${param.roleId == '2' ? 'selected' : ''}>Instructor</option>
                <option value="3" ${param.roleId == '3' ? 'selected' : ''}>Student</option>
                <option value="4" ${param.roleId == '4' ? 'selected' : ''}>Manager</option>
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
                    <th>Actions</th>
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
                        <td colspan="9" style="text-align:center;">No accounts found.</td>
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
<div id="accountModal" class="modal" style="display:none;">
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

            <p id="modalError" style="color:#dc3545;"></p>
            <button type="submit">Save</button>
            <button type="button" onclick="closeModal()">Cancel</button>
        </form>
    </div>
</div>

<script>
    const CONTEXT_PATH = '${pageContext.request.contextPath}';
    const modal = document.getElementById('accountModal');

    function openAdd() {
        document.getElementById('accountForm').reset();
        document.getElementById('formAction').value = 'add';
        document.getElementById('accountId').value = '';
        document.getElementById('modalTitle').textContent = 'Add Account';
        document.getElementById('f_password').style.display = 'block';
        document.getElementById('f_username').readOnly = false;
        document.getElementById('f_isActive').value = '1';
        document.getElementById('modalError').textContent = '';
        modal.style.display = 'flex';
    }

    function openEdit(btn) {
        const d = btn.dataset;
        document.getElementById('accountForm').reset();
        document.getElementById('formAction').value = 'edit';
        document.getElementById('accountId').value = d.id;
        document.getElementById('f_username').value = d.username;
        document.getElementById('f_username').readOnly = true;   // edit không sửa username
        document.getElementById('f_password').style.display = 'none'; // giữ mật khẩu cũ
        document.getElementById('f_email').value = d.email;
        document.getElementById('f_phone').value = d.phone || '';
        document.getElementById('f_fullName').value = d.fullname || '';
        document.getElementById('f_gender').value = d.gender === 'true' ? 'male' : 'female';
        document.getElementById('f_roleId').value = d.role;
        document.getElementById('f_isActive').value = d.active === 'true' ? '1' : '0';
        document.getElementById('modalTitle').textContent = 'Edit Account';
        document.getElementById('modalError').textContent = '';
        modal.style.display = 'flex';
    }

    function closeModal() {
        modal.style.display = 'none';
    }

    document.getElementById('accountForm').addEventListener('submit', function (e) {
        e.preventDefault();
        const body = new URLSearchParams(new FormData(this)).toString();
        fetch(CONTEXT_PATH + '/admin/accounts', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body
        })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        closeModal();
                        location.reload();
                    } else {
                        document.getElementById('modalError').textContent = data.error || 'Something went wrong.';
                    }
                })
                .catch(() => {
                    document.getElementById('modalError').textContent = 'Network error.';
                });
    });

    function submitFilter() {
        document.getElementById('pageInput').value = 1;   // đổi filter → về trang 1
        document.getElementById('filterForm').submit();
    }

    function goToPage(page) {
        document.getElementById('pageInput').value = page;
        document.getElementById('filterForm').submit();
    }
</script>