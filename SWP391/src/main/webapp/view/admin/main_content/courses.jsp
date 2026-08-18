<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="account-manager-container">
    <div class="dashboard-title">Manage Courses</div>

    <!-- ===== Thanh lọc phía trên (search + filter + nút Add) =====
         Form submit theo GET → trả về chính /admin/courses với query params.
         Lưu ý: có input hidden "page" để phân trang giữ được filter đang chọn. -->
    <form id="filterForm"
          action="${pageContext.request.contextPath}/admin/courses"
          method="GET"
          class="toolbar-section">

        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">

        <!-- Ô tìm kiếm theo tên / mô tả khóa học -->
        <div class="search-box">
            <input type="text" name="keyword" value="${param.keyword}" placeholder="Search courses..."/>
            <button type="submit" class="btn-search" title="Search">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <div class="filter-group">
            <!-- Lọc theo trạng thái (active / inactive / draft) -->
            <select name="status" class="filter-select" onchange="submitFilter()">
                <option value="">All Status</option>
                <option value="active" ${param.status == 'active' ? 'selected' : ''}>Active</option>
                <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                <option value="draft" ${param.status == 'draft' ? 'selected' : ''}>Draft</option>
            </select>

            <!-- Lọc theo danh mục (lấy từ CategoryDAO.findAll()) -->
            <select name="categoryId" class="filter-select" onchange="submitFilter()">
                <option value="">All Categories</option>
                <c:forEach var="cat" items="${categoryList}">
                    <option value="${cat.id}" ${param.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                </c:forEach>
            </select>
        </div>

        </form>

    <!-- ===== Bảng danh sách khóa học =====
         Cột Actions giống hệt trang Account Management:
         - Edit   : mở modal, dữ liệu đổ từ data-* (đã fn:escapeXml để chống vỡ HTML).
         - Delete : soft delete (status -> inactive), có hộp thoại xác nhận. -->
    <div class="table-responsive">
        <table class="account-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Rating</th>
                    <th>Price</th>
                    <th>Status</th>
                    <th>Created By</th>
                    <th>Category</th>
                    <th>Created Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="course" items="${courseList}">
                    <tr>
                        <td>${course.id}</td>
                        <td>${course.name}</td>
                        <td>${course.rating} <i class="fa-solid fa-star admin-star-icon"></i></td>
                        <td>$<fmt:formatNumber value="${course.price}" minFractionDigits="0" maxFractionDigits="2"/></td>

                        <!-- Badge trạng thái: active xanh / inactive đỏ / draft xám -->
                        <td>
                            <c:choose>
                                <c:when test="${course.status == 'active'}">
                                    <span class="badge active">Active</span>
                                </c:when>
                                <c:when test="${course.status == 'inactive'}">
                                    <span class="badge inactive">Inactive</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge draft">Draft</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td>${course.teacherName != null ? course.teacherName : 'N/A'}</td>
                        <td>${course.categoryName != null ? course.categoryName : 'N/A'}</td>
                        <td>${course.createdDate}</td>

                        <td class="action-cell">
                            <button type="button" class="btn-action edit" title="Edit"
                                    onclick="openEdit(this)"
                                    data-id="${course.id}"
                                    data-name="${fn:escapeXml(course.name)}"
                                    data-description="${fn:escapeXml(course.description)}"
                                    data-price="${course.price}"
                                    data-rating="${course.rating}"
                                    data-status="${course.status}"
                                    data-category="${course.categoryId}">
                                <i class="fa-regular fa-pen-to-square"></i>
                            </button>

                            <a href="${pageContext.request.contextPath}/admin/courses?action=delete&id=${course.id}"
                               class="btn-action delete"
                               onclick="return confirm('Are you sure you want to deactivate this course?')"
                               title="Deactivate">
                                <i class="fa-regular fa-trash-can"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>

                <!-- Trường hợp không có khóa học nào -->
                <c:if test="${empty courseList}">
                    <tr>
                        <td colspan="9" class="td-empty">No courses found.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- ===== Phân trang =====
         Gọi goToPage(i) -> set lại input hidden "page" rồi submit filterForm (giữ nguyên search/filter). -->
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

<<<<<<< Updated upstream
=======
    <!-- ===== Bảng thay đổi khóa học (course_approval_log) =====
         Chỉ hiển thị ở view Course Approval (status=pending).
         Hiển thị các thay đổi gần nhất (SUBMIT/APPROVE/REJECT), mới nhất trên cùng. -->
    <c:if test="${param.status == 'pending'}">
        <div class="change-log-section">
            <div class="dashboard-title">Course Change Log</div>
            <div class="table-responsive">
                <table class="account-table">
                    <thead>
                        <tr>
                            <th>Time</th>
                            <th>Course</th>
                            <th>Action</th>
                            <th>Change</th>
                            <th>Actor</th>
                            <th>Note</th>
                            <th>IP</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${courseApprovalLogs}">
                            <tr>
                                <td>${log.createdDate}</td>
                                <td>${log.courseName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${log.action == 'APPROVE'}">
                                            <span class="badge approve">APPROVE</span>
                                        </c:when>
                                        <c:when test="${log.action == 'REJECT'}">
                                            <span class="badge reject">REJECT</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge submit">SUBMIT</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${log.oldStatus} <i class="fa-solid fa-arrow-right admin-status-arrow"></i> ${log.newStatus}</td>
                                <td>${log.actorName}</td>
                                <td>${log.note}</td>
                                <td>${log.ipAddress}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty courseApprovalLogs}">
                            <tr>
                                <td colspan="7" class="td-empty">No changes yet.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>

>>>>>>> Stashed changes
</div>

<!-- ===== Modal Edit khóa học =====
     - openEdit() : đổ dữ liệu từ data-* của nút Edit vào form, action='edit'.
     - Submit qua fetch POST -> /admin/courses, trả JSON {success, error}. -->
<div id="courseModal" class="modal modal-hidden">
    <div class="modal-content">
        <span class="modal-close" onclick="closeModal()">&times;</span>
        <h3 id="modalTitle">Edit Course</h3>

        <form id="courseForm" action="${pageContext.request.contextPath}/admin/courses" method="POST" enctype="multipart/form-data">
            <input type="hidden" id="formAction" name="action">
            <input type="hidden" id="courseId" name="id">

            <label>Name</label>
            <input type="text" id="f_name" name="name" required>

            <label>Description</label>
            <textarea id="f_description" name="description" rows="3"></textarea>

            <label>Thumbnail Image (Upload)</label>
            <input type="file" id="f_thumbnail" name="thumbnail" accept="image/*">

            <label>Price</label>
            <input type="number" id="f_price" name="price" step="0.01" min="0" required>

            <label>Rating (0-5)</label>
            <input type="number" id="f_rating" name="rating" min="0" max="5" value="0">

            <label>Status</label>
            <select id="f_status" name="status">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
                <option value="draft">Draft</option>
            </select>

            <label>Category</label>
            <select id="f_categoryId" name="categoryId" required>
                <c:forEach var="cat" items="${categoryList}">
                    <option value="${cat.id}">${cat.name}</option>
                </c:forEach>
            </select>

            <p id="modalError" class="modal-error"></p>
            <button type="submit">Save</button>
            <button type="button" onclick="closeModal()">Cancel</button>
        </form>
    </div>
</div>

<<<<<<< Updated upstream
=======
<!-- ===== Modal Từ chối khóa học ===== -->
<div id="rejectModal" class="modal modal-hidden">
    <div class="modal-content">
        <span class="modal-close" onclick="closeReject()">&times;</span>
        <h3>Reject Course</h3>
        <form id="rejectForm">
            <input type="hidden" id="rejectId" name="id">
            <label>Reason (required)</label>
            <textarea id="rejectNote" name="note" rows="3" required></textarea>
            <p id="rejectError" class="modal-error"></p>
            <button type="submit">Reject</button>
            <button type="button" onclick="closeReject()">Cancel</button>
        </form>
    </div>
</div>

>>>>>>> Stashed changes
<script>
    const CONTEXT_PATH = '${pageContext.request.contextPath}';
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
</script>
