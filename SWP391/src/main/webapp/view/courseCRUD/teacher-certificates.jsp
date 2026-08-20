<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Course Certificate | OCMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --primary-dark: #1a1a2e; --bg-color: #f4f6f9; --white: #fff; --text-main: #333; --text-muted: #6c757d; --border-light: #e9ecef; }
        body { background-color: var(--bg-color); font-family: 'Inter','Segoe UI',sans-serif; margin: 0; padding: 0; }
        .dashboard-container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
        .dashboard-container h1 { color: var(--primary-dark); font-size: 26px; margin-bottom: 8px; }
        .status-text { font-size: 13px; color: var(--text-muted); margin-bottom: 24px; }
        .table-card { background: var(--white); border-radius: 12px; padding: 20px 24px; box-shadow: 0 2px 8px rgba(0,0,0,.06); }
        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 12px 14px; border-bottom: 1px solid var(--border-light); font-size: 14px; color: var(--text-main); }
        th { background: #fafbfc; color: var(--text-muted); font-weight: 600; }
        tr:last-child td { border-bottom: none; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .badge-yes { background: #e8f5e9; color: #2e7d32; }
        .badge-no { background: #fce4ec; color: #c62828; }
        .btn-sm { padding: 6px 14px; font-size: 13px; border-radius: 8px; border: none; cursor: pointer; }
        .btn-add { background: #5d3fd3; color: #fff; }
        .btn-edit { background: #fff; color: #5d3fd3; border: 1px solid #5d3fd3; }
        .btn-del { background: #fff; color: #c62828; border: 1px solid #e57373; }
        .btn-cancel { background: #eee; color: var(--text-main); }
        .btn-save { background: #5d3fd3; color: #fff; }
        .btn-sm:disabled { opacity: .45; cursor: not-allowed; }
        .thumb { width: 70px; height: 46px; object-fit: cover; border-radius: 6px; vertical-align: middle; margin-right: 8px; }
        .modal-backdrop { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 1000; align-items: center; justify-content: center; }
        .modal-backdrop.show { display: flex; }
        .modal-box { background: #fff; border-radius: 14px; padding: 26px; width: 440px; max-width: 92vw; box-shadow: 0 10px 40px rgba(0,0,0,.2); }
        .modal-box h3 { margin: 0 0 16px; color: var(--primary-dark); }
        .modal-box label { font-size: 13px; font-weight: 600; color: var(--text-main); display: block; margin-bottom: 6px; }
        .modal-box input[type=text], .modal-box input[type=file] { width: 100%; padding: 10px 12px; border: 1px solid var(--border-light); border-radius: 8px; margin-bottom: 14px; font-size: 14px; box-sizing: border-box; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; }
        .f-error { background: #fdecea; color: #c62828; padding: 8px 12px; border-radius: 8px; margin-bottom: 12px; font-size: 13px; word-break: break-word; }
        .toast { position: fixed; top: 16px; left: 50%; transform: translateX(-50%); z-index: 2000; padding: 12px 22px; border-radius: 8px; font-size: 14px; box-shadow: 0 4px 16px rgba(0,0,0,.15); transition: opacity .3s; }
        .toast-success { background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; }
        .toast-error { background: #fdecea; color: #c62828; border: 1px solid #ef9a9a; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div id="toast" class="toast" style="display:none;"></div>

    <div class="dashboard-container">
        <h1>Course Certificate</h1>
        <p class="status-text">Tạo template chứng chỉ cho khóa học đã được duyệt. Học viên đạt 100% tiến độ sẽ tự động được cấp chứng chỉ.</p>

        <div class="table-card">
            <table>
                <thead>
                    <tr><th>Course</th><th>Status</th><th>Certificate</th><th style="text-align:right;">Action</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="course" items="${courses}">
                        <tr>
                            <td>
                                <c:if test="${not empty course.thumbnail}"><img class="thumb" src="${course.thumbnail}" alt=""></c:if>
                                ${course.name}
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${course.status == 'active'}"><span class="badge badge-yes">Approved</span></c:when>
                                    <c:otherwise><span class="badge badge-no">${course.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${templateCourseIds.contains(course.id)}"><span class="badge badge-yes">Has certificate</span></c:when>
                                    <c:otherwise><span class="badge badge-no">No certificate</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align:right;">
                                <c:choose>
                                    <c:when test="${course.status == 'active' and not templateCourseIds.contains(course.id)}">
                                        <button class="btn-sm btn-add" onclick="openModal(${course.id}, '${course.name}', 'add')">Add Certificate</button>
                                    </c:when>
                                    <c:when test="${templateCourseIds.contains(course.id)}">
                                        <button class="btn-sm btn-edit" onclick="openModal(${course.id}, '${course.name}', 'edit')">Edit</button>
                                        <button class="btn-sm btn-del" onclick="deleteTemplate(${course.id})">Delete</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn-sm btn-add" disabled title="Course must be approved first">Add Certificate</button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty courses}">
                        <tr><td colspan="4" style="text-align:center;">No courses yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal: Add/Edit template -->
    <div class="modal-backdrop" id="templateModal">
        <div class="modal-box">
            <h3 id="modalTitle">Add Certificate</h3>
            <div id="fError" class="f-error" style="display:none;"></div>
            <form id="templateForm" enctype="multipart/form-data" method="post" action="${pageContext.request.contextPath}/teacher-certificates">
                <input type="hidden" name="action" id="fAction">
                <input type="hidden" name="courseId" id="fCourseId">
                <label for="fTitle">Certificate Title</label>
                <input type="text" id="fTitle" name="title" value="Certificate of Completion">
                <label for="fBackground">Background Image</label>
                <input type="file" id="fBackground" name="background" accept="image/*">
                <div class="modal-actions">
                    <button type="button" class="btn-sm btn-cancel" onclick="closeModal()">Cancel</button>
                    <button type="submit" class="btn-sm btn-save">Save</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        var CONTEXT_PATH = '${pageContext.request.contextPath}';

        function openModal(courseId, courseName, action) {
            hideError();
            document.getElementById('fAction').value = action;
            document.getElementById('fCourseId').value = courseId;
            document.getElementById('modalTitle').textContent = (action === 'add' ? 'Add Certificate' : 'Edit Certificate') + ' - ' + courseName;
            document.getElementById('fBackground').value = '';
            document.getElementById('templateModal').classList.add('show');
        }

        function closeModal() {
            hideError();
            document.getElementById('templateModal').classList.remove('show');
        }

        function showError(msg) {
            var el = document.getElementById('fError');
            el.textContent = msg;
            el.style.display = 'block';
        }

        function hideError() {
            document.getElementById('fError').style.display = 'none';
        }

        function showToast(msg, isError) {
            var el = document.getElementById('toast');
            el.textContent = msg;
            el.className = 'toast ' + (isError ? 'toast-error' : 'toast-success');
            el.style.display = 'block';
            el.style.opacity = '1';
            clearTimeout(el._timer);
            el._timer = setTimeout(function () {
                el.style.opacity = '0';
                setTimeout(function () { el.style.display = 'none'; }, 300);
            }, 3000);
        }

        // Hiện thông báo thành công sau reload (thêm/sửa/xóa template)
        (function () {
            var msg = sessionStorage.getItem('certMsg');
            if (msg) {
                sessionStorage.removeItem('certMsg');
                showToast(msg, false);
            }
        })();

        function deleteTemplate(courseId) {
            if (!confirm('Delete this certificate template?')) return;
            fetch(CONTEXT_PATH + '/teacher-certificates', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=delete&courseId=' + courseId
            })
                .then(function (res) { return res.json(); })
                .then(function (json) {
                    if (json.success) {
                        sessionStorage.setItem('certMsg', 'Certificate template deleted successfully!');
                        location.reload();
                    } else {
                        showToast(json.error || 'Delete failed.', true);
                    }
                })
                .catch(function () { showToast('Network error. Please try again.', true); });
        }

        document.getElementById('templateForm').addEventListener('submit', function (e) {
            e.preventDefault();
            var file = document.getElementById('fBackground').files[0];
            if (file && file.size > 50 * 1024 * 1024) {
                showError('Image too large (max 50MB).');
                return;
            }
            hideError();
            var btn = this.querySelector('button[type=submit]');
            btn.disabled = true;
            fetch(CONTEXT_PATH + '/teacher-certificates', { method: 'POST', body: new FormData(this) })
                .then(function (res) { return res.json(); })
                .then(function (json) {
                    if (json.success) {
                        sessionStorage.setItem('certMsg',
                            document.getElementById('fAction').value === 'add'
                                ? 'Certificate template created successfully!'
                                : 'Certificate template updated successfully!');
                        closeModal();
                        location.reload();
                    } else {
                        showError(json.error || 'Operation failed');
                        btn.disabled = false;
                    }
                })
                .catch(function () {
                    showError('Network error. Please try again.');
                    btn.disabled = false;
                });
        });
    </script>
</body>
</html>