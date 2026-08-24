/**
 * OCMS - Admin Blog Category Management JavaScript (blog_categories.js)
 * Tách biệt hoàn toàn logic JavaScript xử lý Modal, Fetch API thêm/sửa và Phân trang danh mục blog
 */

(function () {
    const contextPath = window.CONTEXT_PATH || '';
    const modal = document.getElementById('categoryModal');
    const form = document.getElementById('categoryForm');
    const modalError = document.getElementById('modalError');

    function openAdd() {
        if (!form || !modal) return;
        form.reset();
        const formAction = document.getElementById('formAction');
        const categoryId = document.getElementById('categoryId');
        const modalTitle = document.getElementById('modalTitle');
        const fName = document.getElementById('f_name');

        if (formAction) formAction.value = 'add';
        if (categoryId) categoryId.value = '';
        if (modalTitle) modalTitle.textContent = 'Add Blog Category';
        if (modalError) modalError.textContent = '';

        modal.style.display = 'flex';
        if (fName) setTimeout(() => fName.focus(), 50);
    }

    function openEdit(btn) {
        if (!form || !modal || !btn) return;
        const d = btn.dataset;
        form.reset();

        const formAction = document.getElementById('formAction');
        const categoryId = document.getElementById('categoryId');
        const fName = document.getElementById('f_name');
        const fDesc = document.getElementById('f_description');
        const modalTitle = document.getElementById('modalTitle');

        if (formAction) formAction.value = 'edit';
        if (categoryId) categoryId.value = d.id || '';
        if (fName) fName.value = d.name || '';
        if (fDesc) fDesc.value = d.description || '';
        if (modalTitle) modalTitle.textContent = 'Edit Blog Category';
        if (modalError) modalError.textContent = '';

        modal.style.display = 'flex';
        if (fName) setTimeout(() => fName.focus(), 50);
    }

    function closeModal() {
        if (modal) {
            modal.style.display = 'none';
        }
    }

    function goToPage(page) {
        const pageInput = document.getElementById('pageInput');
        const filterForm = document.getElementById('filterForm');
        if (pageInput && filterForm) {
            pageInput.value = page;
            filterForm.submit();
        }
    }

    // Đóng modal khi click ra ngoài vùng modal-content
    window.addEventListener('click', function (e) {
        if (modal && e.target === modal) {
            closeModal();
        }
    });

    // Xử lý submit form thêm/sửa qua fetch POST
    if (form) {
        form.addEventListener('submit', function (e) {
            e.preventDefault();
            if (modalError) modalError.textContent = '';

            const fName = document.getElementById('f_name');
            if (fName && !fName.value.trim()) {
                if (modalError) modalError.textContent = 'Vui lòng nhập tên danh mục (không được để trống hoặc chỉ chứa dấu cách)!';
                fName.focus();
                return;
            }

            const btnSave = document.getElementById('btnSaveCategory');
            if (btnSave) {
                btnSave.disabled = true;
                btnSave.textContent = 'Saving...';
            }

            const body = new URLSearchParams(new FormData(form)).toString();
            const postUrl = (contextPath ? contextPath : '') + '/admin/blog-categories';

            fetch(postUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body
            })
                .then(res => res.json())
                .then(data => {
                    if (btnSave) {
                        btnSave.disabled = false;
                        btnSave.textContent = 'Save Category';
                    }
                    if (data.success) {
                        closeModal();
                        location.reload();
                    } else {
                        if (modalError) {
                            modalError.textContent = data.error || 'An error occurred while saving category.';
                        }
                    }
                })
                .catch(err => {
                    if (btnSave) {
                        btnSave.disabled = false;
                        btnSave.textContent = 'Save Category';
                    }
                    if (modalError) {
                        modalError.textContent = 'Network error or server error. Please try again.';
                    }
                });
        });
    }

    // Gắn vào window scope để các hàm onclick/data attributes hoạt động
    window.openAdd = openAdd;
    window.openEdit = openEdit;
    window.closeModal = closeModal;
    window.goToPage = goToPage;
})();
