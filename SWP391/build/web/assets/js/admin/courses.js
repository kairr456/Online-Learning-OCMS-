// OCMS — admin: trang Quản lý khóa học (courses.jsp)
// Modal Edit, Approve/Reject, submit qua fetch POST, lọc & phân trang.
// Cần window.CONTEXT_PATH được định nghĩa trong JSP (pageContext.contextPath).

(function () {
    const CONTEXT_PATH = window.CONTEXT_PATH || '';
    const modal = document.getElementById('courseModal');

    // Mở modal ở chế độ Edit: đổ dữ liệu từ data-* của nút Edit
    function openEdit(btn) {
        const d = btn.dataset;
        document.getElementById('courseForm').reset();
        document.getElementById('formAction').value = 'edit';
        document.getElementById('courseId').value = d.id;
        document.getElementById('f_name').value = d.name;
        document.getElementById('f_description').value = d.description || '';
        document.getElementById('f_price').value = d.price;
        document.getElementById('f_rating').value = d.rating;
        document.getElementById('f_status').value = d.status;
        document.getElementById('f_categoryId').value = d.category;
        document.getElementById('modalTitle').textContent = 'Edit Course';
        document.getElementById('modalError').textContent = '';
        modal.style.display = 'flex';
    }

    function closeModal() {
        modal.style.display = 'none';
    }

    // Submit form qua fetch -> POST /admin/courses, nhận JSON {success, error}
    document.getElementById('courseForm').addEventListener('submit', function (e) {
        e.preventDefault();
        fetch(CONTEXT_PATH + '/admin/courses', {
            method: 'POST',
            body: new FormData(this)
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

    // Đổi filter -> về trang 1 rồi submit
    function submitFilter() {
        document.getElementById('pageInput').value = 1;
        document.getElementById('filterForm').submit();
    }

    // Chuyển trang: set input hidden "page" rồi submit (giữ nguyên search/filter)
    function goToPage(page) {
        document.getElementById('pageInput').value = page;
        document.getElementById('filterForm').submit();
    }

    // ===== Approve / Reject =====
    function openReject(id, name) {
        document.getElementById('rejectForm').reset();
        document.getElementById('rejectId').value = id;
        document.getElementById('rejectError').textContent = '';
        document.getElementById('rejectModal').style.display = 'flex';
    }
    function closeReject() {
        document.getElementById('rejectModal').style.display = 'none';
    }
    document.getElementById('rejectForm').addEventListener('submit', function (e) {
        e.preventDefault();
        fetch(CONTEXT_PATH + '/admin/courses', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=reject&id=' + encodeURIComponent(document.getElementById('rejectId').value)
                + '&note=' + encodeURIComponent(document.getElementById('rejectNote').value)
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                closeReject();
                location.reload();
            } else {
                document.getElementById('rejectError').textContent = data.error || 'Something went wrong.';
            }
        })
        .catch(() => {
            document.getElementById('rejectError').textContent = 'Network error.';
        });
    });

    // Expose ra global cho onclick trong JSP
    window.openEdit = openEdit;
    window.closeModal = closeModal;
    window.submitFilter = submitFilter;
    window.goToPage = goToPage;
    window.openReject = openReject;
    window.closeReject = closeReject;
})();