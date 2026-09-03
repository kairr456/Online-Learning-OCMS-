<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:useBean id="now" class="java.util.Date"/>

<!-- ===== Trang Quản lý đăng ký khóa học (admin) =====
     - Toolbar: tìm kiếm (học viên/email/tên khóa) + lọc theo status.
     - Bảng liệt kê thông tin đăng ký: học viên, khóa học, package, chi phí, status, thời hạn.
     - Phân trang giữ nguyên filter (input hidden "page"). -->
<div class="account-manager-container">
    <div class="dashboard-title">Registration Management</div>

    <!-- Form lọc: submit GET → chính /admin/registrations với query params -->
    <form id="filterForm"
          action="${pageContext.request.contextPath}/admin/registrations"
          method="GET"
          class="toolbar-section">

        <!-- Input hidden "page" để phân trang giữ được filter đang chọn -->
        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">

        <!-- Ô tìm kiếm theo tên học viên / email / tên khóa học -->
        <div class="search-box">
            <input type="text" name="keyword" value="${param.keyword}" placeholder="Search student, email or course..."/>
            <button type="submit" class="btn-search" title="Search">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <!-- Lọc theo trạng thái đăng ký -->
        <div class="filter-group">
            <select name="status" class="filter-select" onchange="submitFilter()">
                <option value="">All Status</option>
                <option value="Approved" ${param.status == 'Approved' ? 'selected' : ''}>Approved</option>
                <option value="Active" ${param.status == 'Active' ? 'selected' : ''}>Active</option>
                <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Pending</option>
                <option value="Success" ${param.status == 'Success' ? 'selected' : ''}>Success</option>
                <option value="Failed" ${param.status == 'Failed' ? 'selected' : ''}>Failed</option>
            </select>
        </div>
    </form>

    <!-- ===== Bảng danh sách đăng ký ===== -->
    <div class="table-responsive">
        <table class="account-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Student</th>
                    <th>Course</th>
                    <th>Package</th>
                    <th>Total Cost</th>
                    <th>Status</th>
                    <th>Registration Time</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="reg" items="${registrationList}">
                    <tr>
                        <td>${reg.id}</td>
                        <!-- Học viên: tên (dòng chính) + email (dòng phụ màu nhạt) -->
                        <td>
                            ${reg.studentName != null ? reg.studentName : 'N/A'}
                            <br><span style="color:#9CA3AF; font-size:12px;">${reg.email}</span>
                        </td>
                        <td>${reg.courseName != null ? reg.courseName : 'N/A'}</td>
                        <td>${reg.packages != null ? reg.packages : '-'}</td>
                        <td><fmt:formatNumber value="${reg.totalCost}" pattern="#,##0"/>₫</td>
                        <!-- Badge màu theo trạng thái: xanh lá (ok) / vàng (chờ) / đỏ (lỗi) -->
                        <td>
                            <c:choose>
                                <c:when test="${reg.status == 'Approved' || reg.status == 'Active' || reg.status == 'Success'}">
                                    <span class="badge active">${reg.status}</span>
                                </c:when>
                                <c:when test="${reg.status == 'Pending'}">
                                    <span class="badge pending">${reg.status}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge inactive">${reg.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${reg.registrationTime}</td>
                    </tr>
                </c:forEach>
                <!-- Trường hợp không có dữ liệu khớp filter -->
                <c:if test="${empty registrationList}">
                    <tr>
                        <td colspan="8" style="text-align:center;">No registrations found.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- ===== Phân trang (giữ nguyên search/filter khi chuyển trang) ===== -->
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

<!-- JS của trang: submitFilter() / goToPage() (đặt trong assets/js) -->
<script src="${pageContext.request.contextPath}/assets/js/registrations.js"></script>