<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.List" %>
<%@ page import="com.entity.TeacherProfile" %>

<div class="account-manager-container">
    <div class="dashboard-title">Duyệt tài khoản Giảng viên</div>

    <!-- Alert Messages -->
    <%
        String approved = request.getParameter("approved");
        String rejected = request.getParameter("rejected");
        if ("1".equals(approved)) {
    %>
    <div class="approval-notice approval-notice--success" role="status">
        <span class="approval-notice__icon" aria-hidden="true"><i class="fa-solid fa-check"></i></span>
        <span><strong>Đã duyệt tài khoản</strong><small>Tài khoản giảng viên đã được kích hoạt và email thông báo đã được gửi.</small></span>
    </div>
    <%
        } else if ("1".equals(rejected)) {
    %>
    <div class="approval-notice approval-notice--danger" role="status">
        <span class="approval-notice__icon" aria-hidden="true"><i class="fa-solid fa-xmark"></i></span>
        <span><strong>Đã từ chối tài khoản</strong><small>Hồ sơ giảng viên đã được cập nhật và email thông báo đã được gửi.</small></span>
    </div>
    <%
        }
    %>

    <!-- Search & Filter -->
    <form method="get" action="${pageContext.request.contextPath}/admin/teacher-approvals" class="toolbar-section" style="margin-bottom:20px;">
        <input type="hidden" name="page" value="1">
        <div class="search-box" style="max-width:400px;">
            <input type="text" name="keyword" value="${keyword}" placeholder="Tìm username, email, họ tên, chuyên môn..." style="width:100%; padding:10px 14px; border:1.5px solid #CBD5E1; border-radius:8px; font-size:14px; outline:none; box-sizing:border-box;">
        </div>
    </form>

    <!-- Table -->
    <div class="table-responsive" style="overflow-x:auto; border:1px solid #E2E8F0; border-radius:12px; background:#fff;">
        <table class="admin-table" style="width:100%; border-collapse:collapse; font-size:14px;">
            <thead>
                <tr style="background:#FAFAFA; border-bottom:1px solid #E2E8F0;">
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">STT</th>
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">Thông tin tài khoản</th>
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">Chuyên môn</th>
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">Kinh nghiệm</th>
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">CV</th>
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">Portfolio</th>
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">Ngày đăng ký</th>
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">Trạng thái</th>
                    <th style="padding:14px 16px; text-align:left; font-weight:600; color:#475569;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <%
                    List<TeacherProfile> profiles = (List<TeacherProfile>) request.getAttribute("profiles");
                    int currentPage = (Integer) request.getAttribute("currentPage");
                    int startIndex = (currentPage - 1) * 10;
                    if (profiles != null && !profiles.isEmpty()) {
                        for (int i = 0; i < profiles.size(); i++) {
                            TeacherProfile p = profiles.get(i);
                            request.setAttribute("teacherProfile", p);
                %>
                <tr style="border-bottom:1px solid #F1F5F9;">
                    <td style="padding:14px 16px; color:#0F172A;"><%= startIndex + i + 1 %></td>
                    <td style="padding:14px 16px;">
                        <div class="teacher-info" style="display:flex; flex-direction:column; gap:4px;">
                            <strong style="color:#0F172A;">${teacherProfile.fullName}</strong>
                            <small style="color:#64748B;">@${teacherProfile.username}</small>
                            <small style="color:#64748B;">${teacherProfile.email}</small>
                        </div>
                    </td>
                    <td style="padding:14px 16px; color:#0F172A; max-width:250px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                        ${teacherProfile.specialization}
                    </td>
                    <td style="padding:14px 16px;">
                        <span class="badge badge--info" style="display:inline-flex; align-items:center; padding:4px 10px; font-size:12px; font-weight:600; border-radius:9999px; background:#EFF6FF; color:#1E40AF;">${teacherProfile.experienceYears} năm</span>
                    </td>
                    <td style="padding:14px 16px;">
                        <c:choose>
                            <c:when test="${not empty teacherProfile.cvUrl}">
                                <a href="${teacherProfile.cvUrl}" target="_blank" style="display:inline-flex; align-items:center; gap:6px; padding:8px 14px; border-radius:8px; border:1px solid #CBD5E1; background:#fff; color:#D8A24A; font-weight:500; font-size:13px; text-decoration:none;">
                                    <i class="fa-regular fa-file"></i> Xem CV
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span style="color:#94A3B8; font-size:13px;">Chưa có</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td style="padding:14px 16px;">
                        <c:choose>
                            <c:when test="${not empty teacherProfile.portfolioUrl}">
                                <a href="${teacherProfile.portfolioUrl}" target="_blank" style="display:inline-flex; align-items:center; gap:6px; padding:8px 14px; border-radius:8px; border:1px solid #CBD5E1; background:#fff; color:#D8A24A; font-weight:500; font-size:13px; text-decoration:none;">
                                    <i class="fa-solid fa-globe"></i> Xem
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span style="color:#94A3B8; font-size:13px;">Chưa có</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td style="padding:14px 16px; color:#0F172A; font-size:13px;">
                        ${teacherProfile.createdAt != null ? teacherProfile.createdAt.toString().substring(0, 16).replace('T', ' ') : ''}
                    </td>
                    <td style="padding:14px 16px;">
                        <span class="badge badge--warning" style="display:inline-flex; align-items:center; padding:4px 10px; font-size:12px; font-weight:600; border-radius:9999px; background:#FEF3C7; color:#B45309;">Chờ duyệt</span>
                    </td>
                    <td style="padding:14px 16px; text-align:center;">
                        <a href="${pageContext.request.contextPath}/admin/teacher-approvals?action=detail&id=${teacherProfile.id}"
                           style="display:inline-flex; align-items:center; gap:6px; padding:10px 18px; border-radius:8px; background:#D8A24A; color:#fff; font-weight:600; font-size:13px; text-decoration:none; transition:background 0.15s;"
                           onmouseover="this.style.background='#C48635'" onmouseout="this.style.background='#D8A24A'">
                            <i class="fa-regular fa-eye"></i> Xem & Duyệt
                        </a>
                    </td>
                </tr>
                <%
                        }
                    } else {
                %>
                <tr>
                    <td colspan="9" style="padding:40px; text-align:center; color:#64748B;">Không có tài khoản giảng viên nào chờ duyệt.</td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <%
        int totalPages = (Integer) request.getAttribute("totalPages");
        String keyword = (String) request.getAttribute("keyword");
        if (totalPages > 1) {
    %>
    <nav class="pagination" style="display:flex; justify-content:center; margin-top:24px; gap:6px;">
        <c:if test="${currentPage > 1}">
            <a href="${pageContext.request.contextPath}/admin/teacher-approvals?page=${currentPage - 1}${not empty keyword ? '&keyword=' + keyword : ''}" style="display:flex; align-items:center; justify-content:center; min-width:40px; height:40px; border-radius:8px; color:#475569; text-decoration:none; font-weight:500; font-size:14px; border:1px solid #CBD5E1; background:#fff;">
                &laquo; Trước
            </a>
        </c:if>

        <c:forEach begin="1" end="${totalPages}" var="i">
            <c:choose>
                <c:when test="${i == currentPage}">
                    <span style="display:flex; align-items:center; justify-content:center; min-width:40px; height:40px; border-radius:8px; background:#D8A24A; color:#fff; font-weight:600; font-size:14px;">${i}</span>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/admin/teacher-approvals?page=${i}${not empty keyword ? '&keyword=' + keyword : ''}" style="display:flex; align-items:center; justify-content:center; min-width:40px; height:40px; border-radius:8px; color:#475569; text-decoration:none; font-weight:500; font-size:14px; border:1px solid #CBD5E1; background:#fff;">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <c:if test="${currentPage < totalPages}">
            <a href="${pageContext.request.contextPath}/admin/teacher-approvals?page=${currentPage + 1}${not empty keyword ? '&keyword=' + keyword : ''}" style="display:flex; align-items:center; justify-content:center; min-width:40px; height:40px; border-radius:8px; color:#475569; text-decoration:none; font-weight:500; font-size:14px; border:1px solid #CBD5E1; background:#fff;">
                Sau &raquo;
            </a>
        </c:if>
    </nav>
    <%
        }
    %>
</div>

<style>
.approval-notice {
    display:flex;
    align-items:flex-start;
    gap:12px;
    margin-bottom:20px;
    padding:14px 16px;
    border-radius:10px;
    border:1px solid;
}
.approval-notice__icon {
    display:flex;
    align-items:center;
    justify-content:center;
    width:24px;
    height:24px;
    border-radius:50%;
    flex-shrink:0;
    color:#fff;
    font-size:12px;
}
.approval-notice strong,
.approval-notice small {
    display:block;
}
.approval-notice strong {
    margin-bottom:3px;
    font-size:14px;
}
.approval-notice small {
    font-size:13px;
    line-height:1.45;
}
.approval-notice--success { background:#F0FDF4; border-color:#86EFAC; color:#166534; }
.approval-notice--success .approval-notice__icon { background:#16A34A; }
.approval-notice--danger { background:#FFF7F7; border-color:#FCA5A5; color:#991B1B; }
.approval-notice--danger .approval-notice__icon { background:#DC2626; }
</style>