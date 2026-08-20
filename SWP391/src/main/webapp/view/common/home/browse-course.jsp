<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Browse Courses</title>
    <!-- css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <!-- FontAwesome cho các icon ngôi sao, mũi tên -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course/browse-course.css">
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />
    
    <form id="filterForm" action="${pageContext.request.contextPath}/courses" method="get" class="browse-container">
        <input type="hidden" name="page" id="pageInput" value="${currentPage != null ? currentPage : 1}">
        
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="filter-group">
                <h3>Categories</h3>
                <c:forEach var="cat" items="${allCategories}">
                    <label class="filter-item">
                        <input type="checkbox" name="category" value="${cat.id}" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();"
                               ${selectedCategories != null && selectedCategories.contains(cat.id) ? 'checked' : ''}> ${cat.name}
                    </label>
                </c:forEach>
            </div>
            
            <div class="filter-group">
                <h3>Ratings</h3>
                <label class="filter-item">
                    <input type="checkbox" name="rating" value="5" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();"
                           ${selectedRatings != null && selectedRatings.contains(5) ? 'checked' : ''}> 
                    <span class="star-rating">
                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                    </span>
                </label>
                <label class="filter-item">
                    <input type="checkbox" name="rating" value="4" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();"
                           ${selectedRatings != null && selectedRatings.contains(4) ? 'checked' : ''}> 
                    <span class="star-rating">
                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star empty"></i>
                    </span>
                </label>
                <label class="filter-item">
                    <input type="checkbox" name="rating" value="3" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();"
                           ${selectedRatings != null && selectedRatings.contains(3) ? 'checked' : ''}> 
                    <span class="star-rating">
                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star empty"></i><i class="fa-regular fa-star empty"></i>
                    </span>
                </label>
                <label class="filter-item">
                    <input type="checkbox" name="rating" value="2" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();"
                           ${selectedRatings != null && selectedRatings.contains(2) ? 'checked' : ''}> 
                    <span class="star-rating">
                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star empty"></i><i class="fa-regular fa-star empty"></i><i class="fa-regular fa-star empty"></i>
                    </span>
                </label>
                <label class="filter-item">
                    <input type="checkbox" name="rating" value="1" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();"
                           ${selectedRatings != null && selectedRatings.contains(1) ? 'checked' : ''}> 
                    <span class="star-rating">
                        <i class="fa-solid fa-star"></i><i class="fa-regular fa-star empty"></i><i class="fa-regular fa-star empty"></i><i class="fa-regular fa-star empty"></i><i class="fa-regular fa-star empty"></i>
                    </span>
                </label>
            </div>
            
            <div class="search-teacher-box">
                <label>search teacher by name</label>
                <div class="search-input-wrapper">
                    <input type="text" name="teacherName" value="${teacherName != null ? teacherName : ''}" onkeydown="if(event.key === 'Enter'){ document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit(); }">
                    <i class="fa-solid fa-magnifying-glass search-submit-icon" onclick="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();"></i>
                </div>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="main-content">
            
            <div class="top-bar">
                <div class="results-count">
                    Showing <c:out value="${totalRecords != null ? totalRecords : 0}" /> Total Results
                </div>
                <div class="sort-by">
                    Sort By:
                    <select name="sort" onchange="document.getElementById('pageInput').value=1; document.getElementById('filterForm').submit();">
                        <option value="">Default</option>
                        <option value="Average Rating (High To Low)" ${sort == 'Average Rating (High To Low)' ? 'selected' : ''}>Average Rating (High To Low)</option>
                        <option value="Average Rating (Low To High)" ${sort == 'Average Rating (Low To High)' ? 'selected' : ''}>Average Rating (Low To High)</option>
                        <option value="Latest" ${sort == 'Latest' ? 'selected' : ''}>Latest</option>
                        <option value="Earliest" ${sort == 'Earliest' ? 'selected' : ''}>Earliest</option>
                    </select>
                </div>
            </div>
            
            <c:if test="${empty courses}">
                <p class="no-courses-msg">No courses available right now.</p>
            </c:if>
            
            <div class="course-grid">
                <c:forEach var="course" items="${courses}">
                    <div class="course-card">
                        <a href="${pageContext.request.contextPath}/course?id=${course.id}">
                            <img src="${course.thumbnail != null ? course.thumbnail : 'https://via.placeholder.com/300x150.png?text=img'}" alt="Course Image" class="course-image">
                        </a>
                        <div class="course-body">
                            <div class="course-meta">
                                <span class="course-teacher">
                                    <a href="teacher-detail.jsp?id=${course.createdBy}">${authorNames[course.createdBy]}</a>
                                </span>
                                <span class="course-rating">
                                    <i class="fa-solid fa-star" style="color: #ffc107;"></i> rating ${course.rating}
                                </span>
                            </div>
                            
                            <a href="${pageContext.request.contextPath}/course?id=${course.id}" class="course-title">
                                ${course.name}
                            </a>
                            
                                <div class="course-footer">
                                    <c:choose>
                                        <c:when test="${not empty enrolledCourseIds and enrolledCourseIds.contains(course.id)}">
                                            <a href="${pageContext.request.contextPath}/course?id=${course.id}" class="enroll-btn enroll-btn--learn-now">LEARNING NOW</a>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="enroll-btn enroll-btn--plain"
                                                    data-course-id="${course.id}"
                                                    data-price="<fmt:formatNumber value='${course.price}' pattern='#0.00' groupingUsed='false'/>"
                                                    onclick="submitAddToCart(this);">ENROLL NOW</button>
                                            <span class="course-price"><fmt:formatNumber value='${course.price}' pattern='#0.00' groupingUsed='false'/>₫</span>
                                        </c:otherwise>
                                    </c:choose>
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
            
        </main>
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
        
        function submitAddToCart(btn) {
            var courseId = btn.getAttribute('data-course-id');
            var price    = btn.getAttribute('data-price');
            document.getElementById('cartCourseId').value = courseId;
            document.getElementById('cartPrice').value    = price;
            document.getElementById('addToCartForm').submit();
        }
    </script>
    
    <form id="addToCartForm" action="${pageContext.request.contextPath}/cart" method="post" class="hidden-form">
        <input type="hidden" name="action" value="add">
        <input type="hidden" name="courseId" id="cartCourseId">
        <input type="hidden" name="price" id="cartPrice">
    </form>
</body>
</html>
