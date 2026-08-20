/**
 * OCMS - Admin Blog Approval JavaScript
 * Handles AJAX approvals (Inactive -> Active), rejection (-> Inactive), preview modal, filter, pagination.
 */

(function () {
    const CONTEXT_PATH = window.CONTEXT_PATH || '';
    const previewModal = document.getElementById('previewModal');

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
                        statusEl.className = `badge-blog-status ${isActive ? 'active' : 'pending'}`;
                        statusEl.style.background = '';
                        statusEl.style.color = '';
                        statusEl.style.border = '';
                        if (isActive) {
                            statusEl.innerHTML = '<span class="badge-dot active"></span> Đã duyệt';
                        } else {
                            statusEl.innerHTML = '<span class="badge-dot pending"></span> Chưa phê duyệt';
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

                    // Footer action buttons
                    const btnApprove = document.getElementById('btnApproveInPreview');
                    if (btnApprove) {
                        btnApprove.style.display = (data.status !== 'Active') ? 'inline-flex' : 'none';
                        btnApprove.onclick = function () {
                            closePreview();
                            approveBlog(data.id, data.title);
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
    // 3. REJECT BLOG
    // ==========================================
    function rejectBlogAdmin(id, title) {
        var blogName = title ? `"${title}"` : `bài viết #${id}`;
        if (!confirm(`Bạn có chắc chắn muốn từ chối ${blogName}?`)) {
            return;
        }

        fetch(CONTEXT_PATH + '/admin/blog-approval', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: 'action=reject&id=' + encodeURIComponent(id)
        })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast('Đã từ chối bài viết thành công!', 'success');
                    setTimeout(() => location.reload(), 700);
                } else {
                    showToast(data.error || 'Thao tác thất bại!', 'error');
                }
            })
            .catch(err => {
                console.error(err);
                showToast('Lỗi kết nối máy chủ!', 'error');
            });
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

    // Close preview modal on clicking overlay
    window.addEventListener('click', function (e) {
        if (previewModal && e.target === previewModal) {
            closePreview();
        }
    });

    // Expose functions globally for JSP inline onclick handlers
    window.openPreview = openPreview;
    window.closePreview = closePreview;
    window.approveBlog = approveBlog;
    window.rejectBlogAdmin = rejectBlogAdmin;
    window.submitFilter = submitFilter;
    window.filterByStatus = filterByStatus;
    window.goToPage = goToPage;
})();
