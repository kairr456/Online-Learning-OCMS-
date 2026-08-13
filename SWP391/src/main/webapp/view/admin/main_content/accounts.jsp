<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="account-manager-container">
    
    <!-- Top Filter Bar: Search, Dropdowns Filter, Add Button -->
    <form action="${pageContext.request.contextPath}/admin/accounts" method="GET" class="toolbar-section">
        <div class="search-box">
            <input type="text" name="keyword" value="${param.keyword}" placeholder="Search..." />
            <button type="submit" class="btn-search">
                <i class="fa fa-search"></i>
            </button>
        </div>

        <div class="filter-group">
            <!-- Filter Role -->
            <select name="roleId" class="filter-select" onchange="this.form.submit()">
                <option value="">Role</option>
                <option value="1" ${param.roleId == '1' ? 'selected' : ''}>Admin</option>
                <option value="2" ${param.roleId == '2' ? 'selected' : ''}>Instructor</option>
                <option value="3" ${param.roleId == '3' ? 'selected' : ''}>Student</option>
                <option value="4" ${param.roleId == '4' ? 'selected' : ''}>Manager</option>
            </select>

            <!-- Filter Status (Active/Inactive) -->
            <select name="status" class="filter-select" onchange="this.form.submit()">
                <option value="">Status</option>
                <option value="1" ${param.status == '1' ? 'selected' : ''}>Active</option>
                <option value="0" ${param.status == '0' ? 'selected' : ''}>Inactive</option>
            </select>
        </div>

        <div class="action-btn-group">
            <a href="${pageContext.request.contextPath}/admin/accounts/add" class="btn-add-user">
                + Add User
            </a>
        </div>
    </form>

    <!-- Account Data Table -->
    <div class="table-responsive">
        <table class="account-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Full Name</th>
                    <th>Gender</th>
                    <th>Status</th>
                    <th>Role</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${userList}">
                    <tr>
                        <td>${u.id}</td>
                        <td>${u.username}</td>
                        <td>${u.email}</td>
                        <td>${u.phone != null ? u.phone : 'N/A'}</td>
                        <td>${u.fullName != null ? u.fullName : 'N/A'}</td>
                        
                        <!-- Transform Gender: 1 -> Male, 0 -> Female -->
                        <td>
                            <c:choose>
                                <c:when test="${u.gender}">Male</c:when>
                                <c:otherwise>Female</c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Transform Active: 1 -> Active, 0 -> Inactive -->
                        <td>
                            <c:choose>
                                <c:when test="${u.isActive}">
                                    <span class="badge active">Active</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge inactive">Inactive</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Transform Role ID to Role Name -->
                        <td>
                            <c:choose>
                                <c:when test="${u.roleId == 1}">Admin</c:when>
                                <c:when test="${u.roleId == 2}">Instructor</c:when>
                                <c:when test="${u.roleId == 3}">Student</c:when>
                                <c:when test="${u.roleId == 4}">Manager</c:when>
                                <c:otherwise>User</c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Action Icons -->
                        <td class="action-cell">
                            <a href="${pageContext.request.contextPath}/admin/accounts/edit?id=${u.id}" 
                               class="btn-action edit" title="Edit">
                                <i class="fa-regular fa-pen-to-square"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/accounts/delete?action=delete&id=${u.id}" 
                               class="btn-action delete" 
                               onclick="return confirm('Are you sure?')" 
                               title="Delete">
                                <i class="fa-regular fa-trash-can"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>