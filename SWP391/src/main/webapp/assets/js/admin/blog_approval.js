/**
 * OCMS - Admin Blog Approval JavaScript
 * Handles AJAX approvals (Inactive -> Active), rejection (-> Inactive), preview modal, filter, pagination.
 */

(function () {
    const CONTEXT_PATH = window.CONTEXT_PATH || '';
    const previewModal = document.getElementById('previewModal');
    const rejectModal = document.getElementById('rejectModal');

    // Toast notification
    function showToast(message, type = 'success') {
        const existingToast = document.querySelector('.blog-toast');
        if (existingToast) existingToast.remove();

        const toast = document.createElement('div');
        toast.className = `blog-toast ${type}`;
        toast.innerHTML = `<i class="fa-solid ${type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation'}"></i> <span>${message}</span>`;
        document.body.appendChild(toast);

        setTimeout(() => {
            toast.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(-20px)';
            setTimeout(() => toast.remove(), 400);
        }, 3000);
    }

    // ==========================================
    // 1. QUICK PREVIEW MODAL
    // ==========================================
    function openPreview(id) {
        if (!id) return;

        document.getElementById('previewTitle').textContent = 'Đang tải nội dung bài viết...';
        document.getElementById('previewCategory').textContent = '...';
        document.getElementById('previewAuthorName').textContent = '...';
        document.getElementById('previewAuthorEmail').textContent = '...';
        document.getElementById('previewDate').textContent = '...';
        document.getElementById('previewBrief').textContent = '...';
        document.getElementById('previewBody').innerHTML = '<div style="text-align:center; padding:30px; color:#64748B;"><i class="fa-solid fa-spinner fa-spin fa-2x"></i><p style="margin-top:10px;">Đang tải chi tiết...</p></div>';
        document.getElementById('previewThumb').style.display = 'none';

        const rejectReasonBox = document.getElementById('previewRejectReasonBox');
        if (rejectReasonBox) rejectReasonBox.style.display = 'none';

        if (previewModal) previewModal.style.display = 'flex';

        fetch(CONTEXT_PATH + '/admin/blog-approval?action=preview&id=' + encodeURIComponent(id))
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('previewTitle').textContent = data.title || 'Không có tiêu đề';
                    document.getElementById('previewCategory').innerHTML = `<i class="fa-solid fa-tag"></i> ${data.categoryName || 'Chung'}`;
                    document.getElementById('previewAuthorName').textContent = data.authorName || 'Tác giả';
                    document.getElementById('previewAuthorEmail').textContent = data.authorEmail ? `(${data.authorEmail})` : '';
                    document.getElementById('previewDate').textContent = data.createdDate || '';

                    // Status Badge in Preview
                    const statusEl = document.getElementById('previewStatusBadge');
                    if (statusEl) {
                        const isActive = (data.status === 'Active');
                        const isRejected = (data.status === 'Reject' || data.status === 'Rejected');
                        statusEl.className = `badge-blog-status ${isActive ? 'active' : (isRejected ? 'inactive' : 'pending')}`;
                        statusEl.style.background = '';
                        statusEl.style.color = '';
                        statusEl.style.border = '';
                        if (isActive) {
                            statusEl.innerHTML = '<span class="badge-dot active"></span> Đã duyệt';
                        } else if (isRejected) {
                            statusEl.innerHTML = '<span class="badge-dot" style="background:#DC2626;"></span> Bị từ chối';
                        } else {
                            statusEl.innerHTML = '<span class="badge-dot pending"></span> Chưa phê duyệt';
                        }
                    }

                    // Rejection Reason Box
                    if (data.rejectReason && data.rejectReason.trim() !== '') {
                        const reasonText = document.getElementById('previewRejectReasonText');
                        if (reasonText && rejectReasonBox) {
                            reasonText.textContent = data.rejectReason;
                            rejectReasonBox.style.display = 'block';
                        }
                    }

                    // Brief Info
                    document.getElementById('previewBrief').textContent = data.briefInfo || '';

                    // Thumbnail
                    const thumbImg = document.getElementById('previewThumb');
                    if (data.thumbnail && data.thumbnail.trim() !== '') {
                        thumbImg.src = data.thumbnail;
                        thumbImg.style.display = 'block';
                    } else {
                        thumbImg.style.display = 'none';
                    }

                    // Content Body
                    document.getElementById('previewBody').innerHTML = data.content || '<p>Không có nội dung.</p>';

                    // Footer action buttons (chỉ hiện khi bài viết đang chờ phê duyệt, không hiện khi Đã duyệt hoặc Bị từ chối)
                    const isPending = (data.status !== 'Active' && data.status !== 'Reject' && data.status !== 'Rejected');
                    const btnApprove = document.getElementById('btnApproveInPreview');
                    if (btnApprove) {
                        btnApprove.style.display = isPending ? 'inline-flex' : 'none';
                        btnApprove.onclick = function () {
                            closePreview();
                            approveBlog(data.id, data.title);
                        };
                    }

                    const btnReject = document.getElementById('btnRejectInPreview');
                    if (btnReject) {
                        btnReject.style.display = isPending ? 'inline-flex' : 'none';
                        btnReject.onclick = function () {
                            closePreview();
                            openRejectModal(data.id, data.title);
                        };
                    }
                } else {
                    document.getElementById('previewTitle').textContent = 'Lỗi tải bài viết';
                    document.getElementById('previewBody').innerHTML = `<p style="color:#DC2626;">${data.error || 'Không thể tải bài viết.'}</p>`;
                }
            })
            .catch(err => {
                console.error(err);
                document.getElementById('previewTitle').textContent = 'Lỗi kết nối';
                document.getElementById('previewBody').innerHTML = '<p style="color:#DC2626;">Đã xảy ra lỗi mạng khi tải chi tiết bài viết.</p>';
            });
    }

    function closePreview() {
        if (previewModal) {
            previewModal.style.display = 'none';
        }
    }

    // ==========================================
    // 2. APPROVE BLOG
    // ==========================================
    function approveBlog(id, title) {
        var blogName = title ? `"${title}"` : `bài viết #${id}`;
        if (!confirm(`Bạn có chắc chắn muốn duyệt ${blogName}?`)) {
            return;
        }

        fetch(CONTEXT_PATH + '/admin/blog-approval', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: 'action=approve&id=' + encodeURIComponent(id)
        })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast('Đã duyệt bài viết thành công!', 'success');
                    setTimeout(() => location.reload(), 700);
                } else {
                    showToast(data.error || 'Duyệt bài viết thất bại!', 'error');
                }
            })
            .catch(err => {
                console.error(err);
                showToast('Lỗi kết nối máy chủ!', 'error');
            });
    }

    // ==========================================
    // 3. REJECT BLOG (WITH REASON MODAL)
    // ==========================================
    window.validateBlogRejectReason = function(el) {
        const input = el || document.getElementById('rejectReasonInput');
        if (!input) return true;
        const maxChars = 300;
        const rawVal = input.value || '';
        const count = rawVal.length;
        const trimmedCount = rawVal.trim().length;
        const err = document.getElementById('blogRejectReasonError');
        const counter = document.getElementById('rejectReasonCount');

        if (counter) {
            counter.innerText = count + '/' + maxChars + ' ký tự';
            if (count > maxChars) {
                counter.style.color = '#DC2626';
                counter.style.fontWeight = 'bold';
            } else {
                counter.style.color = '#64748B';
                counter.style.fontWeight = '600';
            }
        }

        if (trimmedCount === 0) {
            if (rawVal.length > 0) {
                if (err) {
                    err.innerText = "Lý do từ chối không được chỉ chứa khoảng trắng.";
                    err.style.display = "block";
                }
                input.classList.add('is-invalid');
            } else {
                if (err) {
                    err.style.display = "none";
                    err.innerText = "";
                }
                input.classList.remove('is-invalid');
            }
            return false;
        } else if (count > maxChars) {
            if (err) {
                err.innerText = "Lý do từ chối không được vượt quá " + maxChars + " ký tự (hiện tại: " + count + " ký tự).";
                err.style.display = "block";
            }
            input.classList.add('is-invalid');
            return false;
        } else {
            if (err) {
                err.style.display = "none";
                err.innerText = "";
            }
            input.classList.remove('is-invalid');
            return true;
        }
    };

    function openRejectModal(id, title) {
        const idInput = document.getElementById('rejectBlogId');
        const titleEl = document.getElementById('rejectBlogTitle');
        const reasonInput = document.getElementById('rejectReasonInput');
        const err = document.getElementById('blogRejectReasonError');
        const counter = document.getElementById('rejectReasonCount');

        if (idInput) idInput.value = id || '';
        if (titleEl) titleEl.textContent = title ? `Bài viết: "${title}"` : `Bài viết #${id}`;
        
        if (reasonInput) {
            reasonInput.value = '';
            reasonInput.classList.remove('is-invalid');
        }
        if (err) {
            err.style.display = 'none';
            err.innerText = '';
        }
        if (counter) {
            counter.innerText = '0/300 ký tự';
            counter.style.color = '#64748B';
            counter.style.fontWeight = '500';
        }

        if (rejectModal) {
            rejectModal.style.display = 'flex';
            setTimeout(() => {
                if (reasonInput) reasonInput.focus();
            }, 100);
        }
    }

    function closeRejectModal() {
        if (rejectModal) {
            rejectModal.style.display = 'none';
        }
    }

    function submitReject(e) {
        if (e && e.preventDefault) e.preventDefault();

        const idInput = document.getElementById('rejectBlogId');
        const reasonInput = document.getElementById('rejectReasonInput');
        const btnSubmit = document.getElementById('btnConfirmReject');
        const err = document.getElementById('blogRejectReasonError');

        const id = idInput ? idInput.value : '';
        const reason = reasonInput ? reasonInput.value.trim() : '';

        if (!id) {
            showToast('ID bài viết không hợp lệ!', 'error');
            return false;
        }

        if (!reason) {
            if (err) {
                if ((reasonInput ? reasonInput.value : '').length > 0) {
                    err.innerText = "Lý do từ chối không được chỉ chứa khoảng trắng.";
                } else {
                    err.innerText = "Vui lòng nhập lý do từ chối bài viết.";
                }
                err.style.display = 'block';
            }
            if (reasonInput) {
                reasonInput.classList.add('is-invalid');
                reasonInput.focus();
            }
            return false;
        }

        // Bắt lỗi rỗng / khoảng trắng / quá ký tự trực tiếp dưới khung
        if (!window.validateBlogRejectReason(reasonInput)) {
            if (reasonInput) reasonInput.focus();
            return false;
        }

        if (btnSubmit) {
            btnSubmit.disabled = true;
            btnSubmit.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';
        }

        const params = 'action=reject&id=' + encodeURIComponent(id) + '&reason=' + encodeURIComponent(reason);

        fetch(CONTEXT_PATH + '/admin/blog-approval', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params
        })
            .then(res => res.json())
            .then(data => {
                if (btnSubmit) {
                    btnSubmit.disabled = false;
                    btnSubmit.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Gửi lý do &amp; Từ chối';
                }
                if (data.success) {
                    showToast('Đã từ chối bài viết thành công!', 'success');
                    closeRejectModal();
                    setTimeout(() => location.reload(), 700);
                } else {
                    // Hiển thị lỗi từ backend trực tiếp dưới khung
                    if (err) {
                        err.innerText = data.error || 'Từ chối bài viết thất bại!';
                        err.style.display = 'block';
                    }
                    if (reasonInput) {
                        reasonInput.classList.add('is-invalid');
                        reasonInput.focus();
                    }
                }
            })
            .catch(errFetch => {
                console.error(errFetch);
                if (btnSubmit) {
                    btnSubmit.disabled = false;
                    btnSubmit.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Gửi lý do &amp; Từ chối';
                }
                if (err) {
                    err.innerText = 'Lỗi kết nối máy chủ, vui lòng thử lại!';
                    err.style.display = 'block';
                }
            });

        return false;
    }

    // ==========================================
    // 4. FILTER & PAGINATION
    // ==========================================
    function submitFilter() {
        const pageInput = document.getElementById('pageInput');
        if (pageInput) pageInput.value = 1;
        const form = document.getElementById('blogFilterForm');
        if (form) form.submit();
    }

    function filterByStatus(status) {
        const statusSelect = document.getElementById('statusSelect');
        if (statusSelect) {
            statusSelect.value = status;
        }
        submitFilter();
    }

    function goToPage(page) {
        const pageInput = document.getElementById('pageInput');
        if (pageInput) pageInput.value = page;
        const form = document.getElementById('blogFilterForm');
        if (form) form.submit();
    }

    // Ngăn đóng modal khi bấm ra vùng bên ngoài (Static Backdrop)
    window.addEventListener('click', function (e) {
        if (previewModal && e.target === previewModal) {
            const content = previewModal.querySelector('.modal-preview-dialog, .modal-content');
            if (content) {
                content.classList.remove('modal-static-shake');
                void content.offsetWidth;
                content.classList.add('modal-static-shake');
            }
        }
        if (rejectModal && e.target === rejectModal) {
            const content = rejectModal.querySelector('.modal-preview-dialog, .modal-content');
            if (content) {
                content.classList.remove('modal-static-shake');
                void content.offsetWidth;
                content.classList.add('modal-static-shake');
            }
        }
    });

    // Event listeners for real-time validation and character counting
    document.addEventListener('DOMContentLoaded', function () {
        const reasonInput = document.getElementById('rejectReasonInput');
        if (reasonInput) {
            reasonInput.addEventListener('input', function () {
                window.validateBlogRejectReason(this);
            });
            reasonInput.addEventListener('keyup', function () {
                window.validateBlogRejectReason(this);
            });
            reasonInput.addEventListener('paste', function () {
                setTimeout(() => window.validateBlogRejectReason(this), 10);
            });
        }
    });

    // Expose functions globally for JSP inline onclick handlers
    window.validateBlogRejectReason = validateBlogRejectReason;
    window.openPreview = openPreview;
    window.closePreview = closePreview;
    window.approveBlog = approveBlog;
    window.openRejectModal = openRejectModal;
    window.closeRejectModal = closeRejectModal;
    window.submitReject = submitReject;
    window.submitFilter = submitFilter;
    window.filterByStatus = filterByStatus;
    window.goToPage = goToPage;
})();
