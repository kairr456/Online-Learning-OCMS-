// OCMS — admin: trang Quản lý tài khoản (accounts.jsp)
// Modal Add/Edit, submit qua fetch POST, lọc & phân trang.
// Cần window.CONTEXT_PATH được định nghĩa trong JSP (pageContext.contextPath).

(function () {
    const CONTEXT_PATH = window.CONTEXT_PATH || '';
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

    // Expose ra global cho onclick trong JSP
    window.openAdd = openAdd;
    window.openEdit = openEdit;
    window.closeModal = closeModal;
    window.submitFilter = submitFilter;
    window.goToPage = goToPage;
})();