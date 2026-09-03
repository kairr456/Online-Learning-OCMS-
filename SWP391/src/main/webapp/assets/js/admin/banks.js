/**
 * OCMS - Admin Supported Bank Management JavaScript (banks.js)
 * Quản lý Modal, Fetch API thêm/sửa và Phân trang ngân hàng nhận tiền
 */

(function () {
    const contextPath = window.CONTEXT_PATH || '';
    const modal = document.getElementById('bankModal');
    const form = document.getElementById('bankForm');
    const modalError = document.getElementById('modalError');

    function updateCounters() {
        const fCode = document.getElementById('f_code');
        const codeCounter = document.getElementById('codeCharCount');
        const codeErr = document.getElementById('codeFieldError');
        if (fCode && codeCounter) {
            // Tự động loại bỏ dấu cách vì mã ngân hàng không được chứa khoảng trắng
            if (fCode.value && /\s/.test(fCode.value)) {
                fCode.value = fCode.value.replace(/\s/g, '').toUpperCase();
            }
            const cleanCode = fCode.value ? fCode.value.replace(/\s/g, '').toUpperCase() : '';
            const len = cleanCode.length;
            codeCounter.textContent = len + '/50 ký tự';
            codeCounter.style.color = len > 50 ? '#DC2626' : '#64748B';

            // Kiểm tra không được ghi số vào mã ngân hàng
            if (/\d/.test(cleanCode)) {
                if (codeErr) codeErr.style.display = 'block';
                fCode.style.borderColor = '#DC2626';
            } else {
                if (codeErr) codeErr.style.display = 'none';
                fCode.style.borderColor = '';
            }
        }

        const fName = document.getElementById('f_name');
        const nameCounter = document.getElementById('nameCharCount');
        const nameErr = document.getElementById('nameFieldError');
        if (fName && nameCounter) {
            // Nếu chỉ chứa toàn dấu cách thì không tính (0 ký tự)
            const rawVal = fName.value || '';
            const trimmed = rawVal.trim();
            const len = trimmed.length === 0 ? 0 : rawVal.length;
            nameCounter.textContent = len + '/255 ký tự';
            nameCounter.style.color = len > 255 ? '#DC2626' : '#64748B';

            // Kiểm tra không được ghi số vào tên đầy đủ ngân hàng
            if (/\d/.test(rawVal)) {
                if (nameErr) nameErr.style.display = 'block';
                fName.style.borderColor = '#DC2626';
            } else {
                if (nameErr) nameErr.style.display = 'none';
                fName.style.borderColor = '';
            }
        }

        const fShort = document.getElementById('f_short');
        const shortCounter = document.getElementById('shortCharCount');
        const shortErr = document.getElementById('shortFieldError');
        if (fShort && shortCounter) {
            // Nếu chỉ chứa toàn dấu cách thì không tính (0 ký tự)
            const rawVal = fShort.value || '';
            const trimmed = rawVal.trim();
            const len = trimmed.length === 0 ? 0 : rawVal.length;
            shortCounter.textContent = len + '/255 ký tự';
            shortCounter.style.color = len > 255 ? '#DC2626' : '#64748B';

            // Kiểm tra không được ghi số vào tên hiển thị rút gọn
            if (/\d/.test(rawVal)) {
                if (shortErr) shortErr.style.display = 'block';
                fShort.style.borderColor = '#DC2626';
            } else {
                if (shortErr) shortErr.style.display = 'none';
                fShort.style.borderColor = '';
            }
        }
    }

    function openAdd() {
        if (!form || !modal) return;
        form.reset();
        const formAction = document.getElementById('formAction');
        const bankId = document.getElementById('bankId');
        const modalTitle = document.getElementById('modalTitle');
        const fCode = document.getElementById('f_code');
        const fStatus = document.getElementById('f_status');

        if (formAction) formAction.value = 'add';
        if (bankId) bankId.value = '';
        if (modalTitle) modalTitle.textContent = 'Add Supported Bank';
        if (modalError) modalError.textContent = '';
        if (fStatus) fStatus.value = 'active';

        const codeErr = document.getElementById('codeFieldError');
        const nameErr = document.getElementById('nameFieldError');
        const shortErr = document.getElementById('shortFieldError');
        const fNameInput = document.getElementById('f_name');
        const fShortInput = document.getElementById('f_short');
        if (codeErr) codeErr.style.display = 'none';
        if (nameErr) nameErr.style.display = 'none';
        if (shortErr) shortErr.style.display = 'none';
        if (fCode) fCode.style.borderColor = '';
        if (fNameInput) fNameInput.style.borderColor = '';
        if (fShortInput) fShortInput.style.borderColor = '';

        updateCounters();
        modal.style.display = 'flex';
        if (fCode) setTimeout(() => fCode.focus(), 50);
    }

    function openEdit(btn) {
        if (!form || !modal || !btn) return;
        const d = btn.dataset;
        form.reset();

        const formAction = document.getElementById('formAction');
        const bankId = document.getElementById('bankId');
        const fCode = document.getElementById('f_code');
        const fName = document.getElementById('f_name');
        const fShort = document.getElementById('f_short');
        const fStatus = document.getElementById('f_status');
        const modalTitle = document.getElementById('modalTitle');

        if (formAction) formAction.value = 'edit';
        if (bankId) bankId.value = d.id || '';
        if (fCode) fCode.value = d.code || '';
        if (fName) fName.value = d.name || '';
        if (fShort) fShort.value = d.short || '';
        if (fStatus) fStatus.value = d.status || 'active';
        if (modalTitle) modalTitle.textContent = 'Edit Supported Bank';
        if (modalError) modalError.textContent = '';

        const codeErr = document.getElementById('codeFieldError');
        const nameErr = document.getElementById('nameFieldError');
        const shortErr = document.getElementById('shortFieldError');
        if (codeErr) codeErr.style.display = 'none';
        if (nameErr) nameErr.style.display = 'none';
        if (shortErr) shortErr.style.display = 'none';
        if (fCode) fCode.style.borderColor = '';
        if (fName) fName.style.borderColor = '';
        if (fShort) fShort.style.borderColor = '';

        updateCounters();
        modal.style.display = 'flex';
        if (fCode) setTimeout(() => fCode.focus(), 50);
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

            const fCode = document.getElementById('f_code');
            const cleanCode = fCode ? fCode.value.replace(/\s/g, '').toUpperCase() : '';
            if (!cleanCode) {
                if (modalError) modalError.textContent = 'Mã ngân hàng (Bank Code) không được để trống hoặc chỉ chứa dấu cách!';
                if (fCode) fCode.focus();
                return;
            }
            if (cleanCode.length > 50) {
                if (modalError) modalError.textContent = 'Mã ngân hàng không được vượt quá 50 ký tự!';
                if (fCode) fCode.focus();
                return;
            }
            if (/\d/.test(cleanCode)) {
                if (modalError) modalError.textContent = 'Mã ngân hàng không được ghi số vào (chỉ được chứa chữ cái A-Z)!';
                if (fCode) {
                    fCode.focus();
                    fCode.style.borderColor = '#DC2626';
                }
                const codeErr = document.getElementById('codeFieldError');
                if (codeErr) codeErr.style.display = 'block';
                return;
            }

            const fName = document.getElementById('f_name');
            const trimmedName = fName ? fName.value.trim() : '';
            if (!trimmedName) {
                if (modalError) modalError.textContent = 'Tên đầy đủ ngân hàng không được để trống hoặc chỉ chứa dấu cách!';
                if (fName) fName.focus();
                return;
            }
            if (trimmedName.length > 255) {
                if (modalError) modalError.textContent = 'Tên ngân hàng không được vượt quá 255 ký tự!';
                if (fName) fName.focus();
                return;
            }
            if (/\d/.test(trimmedName)) {
                if (modalError) modalError.textContent = 'Tên đầy đủ ngân hàng không được ghi số vào (chỉ được chứa chữ cái)!';
                if (fName) {
                    fName.focus();
                    fName.style.borderColor = '#DC2626';
                }
                const nameErr = document.getElementById('nameFieldError');
                if (nameErr) nameErr.style.display = 'block';
                return;
            }

            const fShort = document.getElementById('f_short');
            const trimmedShort = fShort ? fShort.value.trim() : '';
            if (!trimmedShort) {
                if (modalError) modalError.textContent = 'Tên hiển thị của ngân hàng không được để trống hoặc chỉ chứa dấu cách!';
                if (fShort) fShort.focus();
                return;
            }
            if (trimmedShort.length > 255) {
                if (modalError) modalError.textContent = 'Tên hiển thị không được vượt quá 255 ký tự!';
                if (fShort) fShort.focus();
                return;
            }
            if (/\d/.test(trimmedShort)) {
                if (modalError) modalError.textContent = 'Tên hiển thị ngân hàng không được ghi số vào (chỉ được chứa chữ cái)!';
                if (fShort) {
                    fShort.focus();
                    fShort.style.borderColor = '#DC2626';
                }
                const shortErr = document.getElementById('shortFieldError');
                if (shortErr) shortErr.style.display = 'block';
                return;
            }

            const btnSave = document.getElementById('btnSaveBank');
            if (btnSave) {
                btnSave.disabled = true;
                btnSave.textContent = 'Saving...';
            }

            const body = new URLSearchParams(new FormData(form)).toString();
            const postUrl = (contextPath ? contextPath : '') + '/admin/banks';

            fetch(postUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body
            })
                .then(res => res.json())
                .then(data => {
                    if (btnSave) {
                        btnSave.disabled = false;
                        btnSave.textContent = 'Save Bank';
                    }
                    if (data.success) {
                        closeModal();
                        location.reload();
                    } else {
                        if (modalError) {
                            modalError.textContent = data.error || 'Đã xảy ra lỗi khi lưu thông tin ngân hàng.';
                        }
                    }
                })
                .catch(err => {
                    if (btnSave) {
                        btnSave.disabled = false;
                        btnSave.textContent = 'Save Bank';
                    }
                    if (modalError) {
                        modalError.textContent = 'Lỗi kết nối mạng hoặc máy chủ. Vui lòng thử lại!';
                    }
                });
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        const fCode = document.getElementById('f_code');
        const fName = document.getElementById('f_name');
        const fShort = document.getElementById('f_short');

        if (fCode) {
            fCode.addEventListener('keydown', function (e) {
                if (e.key === ' ' || e.code === 'Space') {
                    e.preventDefault(); // Chặn phím space không cho nhập vào mã ngân hàng
                }
            });
            fCode.addEventListener('input', function () {
                this.value = this.value.replace(/\s/g, '').toUpperCase();
                updateCounters();
            });
        }
        if (fName) fName.addEventListener('input', updateCounters);
        if (fShort) fShort.addEventListener('input', updateCounters);
    });

    // Gắn vào window scope để các hàm onclick/data attributes hoạt động
    window.openAdd = openAdd;
    window.openEdit = openEdit;
    window.closeModal = closeModal;
    window.goToPage = goToPage;
})();
