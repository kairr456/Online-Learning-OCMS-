/**
 * OCMS - Admin Course Category Management JavaScript (course_categories.js)
 * Xử lý Modal, Fetch API thêm/sửa và Phân trang danh mục khóa học
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
        if (modalTitle) modalTitle.textContent = 'Add Course Category';
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
        if (modalTitle) modalTitle.textContent = 'Edit Course Category';
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
            const trimmedName = fName ? fName.value.trim() : '';
            if (!trimmedName) {
                if (modalError) modalError.textContent = 'Please enter category name!';
                if (fName) fName.focus();
                return;
            }

            if (trimmedName.length > 100) {
                if (modalError) modalError.textContent = 'Category name must not exceed 100 characters!';
                if (fName) fName.focus();
                return;
            }

            const fDesc = document.getElementById('f_description');
            const trimmedDesc = fDesc ? fDesc.value.trim() : '';
            if (trimmedDesc.length > 500) {
                if (modalError) modalError.textContent = 'Description must not exceed 500 characters!';
                if (fDesc) fDesc.focus();
                return;
            }

            const formData = new URLSearchParams(new FormData(form));

            fetch(contextPath + '/admin/course-categories', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    closeModal();
                    location.reload();
                } else {
                    if (modalError) modalError.textContent = data.message || 'An error occurred!';
                }
            })
            .catch(err => {
                console.error('Fetch error:', err);
                if (modalError) modalError.textContent = 'Connection error! Please try again.';
            });
        });
    }

    // Export hàm ra window để JSP gọi trực tiếp từ inline onclick
    window.openAdd = openAdd;
    window.openEdit = openEdit;
    window.closeModal = closeModal;
    window.goToPage = goToPage;
})();
