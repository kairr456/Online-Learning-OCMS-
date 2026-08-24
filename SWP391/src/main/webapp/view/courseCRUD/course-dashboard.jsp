<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>My Course Dashboard</title>
    <!-- css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_crud/course-dashboard.css">
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />
    
    <c:if test="${not empty sessionScope.msg || not empty sessionScope.message}">
        <script>
            alert('${not empty sessionScope.msg ? sessionScope.msg : sessionScope.message}');
        </script>
        <c:remove var="msg" scope="session"/>
        <c:remove var="message" scope="session"/>
    </c:if>

    <form id="filterForm" action="${pageContext.request.contextPath}/course-dashboard" method="get" class="dashboard-container">
        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">
        
        <div class="filter-bar">
            <div class="search-wrapper">
                <input type="text" name="courseName" placeholder="Search course by name..." value="${courseName != null ? courseName : ''}" onkeydown="if(event.key === 'Enter'){ document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit(); }">
                <i class="fa-solid fa-magnifying-glass" onclick="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();"></i>
            </div>
            
            <div class="filter-controls">
                <select name="category" class="filter-select" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();">
                    <option value="">All Categories</option>
                    <c:forEach var="cat" items="${allCategories}">
                        <option value="${cat.id}" ${selectedCategory != null && selectedCategory == cat.id ? 'selected' : ''}>${cat.name}</option>
                    </c:forEach>
                </select>
                
                <select name="sort" class="filter-select" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();">
                    <option value="">Sort by Default</option>
                    <option value="Average Rating (High To Low)" ${sort == 'Average Rating (High To Low)' ? 'selected' : ''}>Average Rating (High To Low)</option>
                    <option value="Average Rating (Low To High)" ${sort == 'Average Rating (Low To High)' ? 'selected' : ''}>Average Rating (Low To High)</option>
                    <option value="Latest" ${sort == 'Latest' ? 'selected' : ''}>Latest Courses</option>
                    <option value="Earliest" ${sort == 'Earliest' ? 'selected' : ''}>Earliest Courses</option>
                </select>
            </div>
        </div>

        <div class="results-info">
            <div class="results-count">
                Showing <c:out value="${totalRecords != null ? totalRecords : 0}" /> Total Results
            </div>
        </div>
            
            <c:if test="${empty courses}">
                <p class="dashboard-empty-state">You haven't created any courses yet.</p>
            </c:if>
            
            <div class="course-grid">
                <c:forEach var="course" items="${courses}">
                    <div class="course-card">
                        <a href="${pageContext.request.contextPath}/lesson?courseId=${course.id}">
                            <img src="${course.thumbnail != null ? course.thumbnail : 'https://via.placeholder.com/300x150.png?text=img'}" alt="Course Image" class="course-image">
                        </a>
                        <div class="course-body">
                            <div class="course-meta d-flex align-items-center mb-2">
                                <span class="course-rating me-2">
                                    <i class="fas fa-star text-warning"></i> ${course.rating}
                                </span>
                                <span class="fw-bold text-success me-2 price-label">
                                    <c:choose>
                                        <c:when test="${course.price == 0}">Free</c:when>
                                        <c:otherwise>${course.price}₫</c:otherwise>
                                    </c:choose>
                                </span>
                                <span class="badge ${course.status == 'active' ? 'bg-success' : 'bg-secondary'} ms-auto">
                                    ${course.status}
                                </span>
                            </div>
                            
                            <a href="${pageContext.request.contextPath}/lesson?courseId=${course.id}" class="course-title d-block mb-1">
                                ${course.name}
                            </a>
                            
                            <c:if test="${not empty course.categoryName}">
                                <div class="text-muted small mb-2"><i class="fas fa-tag"></i> ${course.categoryName}</div>
                            </c:if>
                            
                            <div class="text-muted small mb-3 course-desc-clamp">
                                ${course.description}
                            </div>
                            
                            <div class="course-footer">
                                <a href="${pageContext.request.contextPath}/lesson?courseId=${course.id}" class="action-btn btn-edit"><i class="fas fa-edit"></i> Edit</a>
                                <a href="${pageContext.request.contextPath}/course-manager?action=deletePreview&id=${course.id}" class="action-btn btn-delete"><i class="fas fa-trash"></i> Delete</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            
            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="pagination">
                    <!-- First Page -->
                    <c:if test="${totalPages > 2 && currentPage > 1}">
                        <a href="#" class="page-link" onclick="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit(); return false;"><i class="fa-solid fa-angles-left"></i></a>
                    </c:if>
                    
                    <!-- Previous Page -->
                    <c:if test="${currentPage > 1}">
                        <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage - 1}')"><i class="fa-solid fa-angle-left"></i></a>
                    </c:if>

                    <!-- Page Numbers -->
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <a href="javascript:void(0)" class="page-link ${currentPage == i ? 'active' : ''}" onclick="goToPage('${i}')">${i}</a>
                    </c:forEach>

                    <!-- Next Page -->
                    <c:if test="${currentPage < totalPages}">
                        <a href="javascript:void(0)" class="page-link" onclick="goToPage('${currentPage + 1}')"><i class="fa-solid fa-angle-right"></i></a>
                    </c:if>

                    <!-- Last Page -->
                    <c:if test="${totalPages > 2 && currentPage < totalPages}">
                        <a href="javascript:void(0)" class="page-link" onclick="goToPage('${totalPages}')"><i class="fa-solid fa-angles-right"></i></a>
                    </c:if>
                </div>
            </c:if>
            
        
    </form>
    <script>
        function goToPage(page) {
            var pageInput = document.getElementById('pageInput');
            var filterForm = document.getElementById('filterForm');
            if (pageInput && filterForm) {
                pageInput.value = page;
                filterForm.submit();
            }
        }
    </script>
</body>
</html>
