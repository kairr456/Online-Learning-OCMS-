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
    
    <style>
        :root {
            --primary-dark: #1a1a2e; /* Dark Blue */
            --accent-yellow: #ffc107; /* Yellow */
            --bg-color: #f4f6f9;
            --white: #ffffff;
            --text-main: #333333;
            --text-muted: #6c757d;
            --border-light: #e9ecef;
        }

        body {
            background-color: var(--bg-color);
            font-family: 'Inter', 'Segoe UI', sans-serif; 
            margin: 0;
            padding: 0;
        }
        
        .browse-container {
            max-width: 1200px;
            margin: 40px auto;
            display: flex;
            gap: 30px;
            padding: 0 20px;
        }
        
        /* Sidebar */
        .sidebar {
            width: 260px;
            flex-shrink: 0;
        }
        .filter-group {
            background: var(--white);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            border: 1px solid rgba(0,0,0,0.03);
        }
        .filter-group h3 {
            font-size: 18px;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 18px;
            margin-top: 0;
            position: relative;
            padding-bottom: 10px;
        }
        .filter-group h3::after {
            content: '';
            position: absolute;
            left: 0;
            bottom: 0;
            width: 40px;
            height: 3px;
            background-color: var(--accent-yellow);
            border-radius: 2px;
        }
        .filter-item {
            display: flex;
            align-items: center;
            margin-bottom: 12px;
            font-size: 15px;
            color: var(--text-main);
            cursor: pointer;
            transition: color 0.2s ease;
        }
        .filter-item:hover {
            color: var(--primary-dark);
            font-weight: 500;
        }
        .filter-item input[type="checkbox"] {
            margin-right: 12px;
            cursor: pointer;
            width: 18px;
            height: 18px;
            accent-color: var(--primary-dark);
        }
        .star-rating i {
            color: var(--accent-yellow); 
            font-size: 14px;
            margin-right: 2px;
        }
        .star-rating .fa-star.empty {
            color: #e4e5e9;
        }
        
        .search-teacher-box {
            margin-top: 24px;
        }
        .search-teacher-box label {
            display: block;
            font-size: 15px;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 12px;
        }
        .search-input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }
        .search-input-wrapper input {
            width: 100%;
            padding: 10px 35px 10px 15px;
            border: 1px solid var(--border-light);
            border-radius: 25px;
            outline: none;
            font-size: 14px;
            transition: all 0.3s ease;
            box-shadow: inset 0 1px 3px rgba(0,0,0,0.02);
        }
        .search-input-wrapper input:focus {
            border-color: var(--primary-dark);
            box-shadow: 0 0 0 3px rgba(26, 26, 46, 0.1);
        }
        .search-input-wrapper i {
            position: absolute;
            right: 15px;
            color: var(--text-muted);
            font-size: 14px;
        }
        
        /* Main Content */
        .main-content {
            flex-grow: 1;
        }
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            background: var(--white);
            padding: 15px 24px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
        }
        .results-count {
            color: var(--text-main);
            font-size: 15px;
            font-weight: 500;
        }
        .sort-by {
            display: flex;
            align-items: center;
            font-size: 14px;
            color: var(--text-main);
            font-weight: 500;
        }
        .sort-by select {
            margin-left: 12px;
            padding: 8px 16px;
            border: 1px solid var(--border-light);
            border-radius: 6px;
            outline: none;
            background: var(--bg-color);
            color: var(--primary-dark);
            font-weight: 600;
            cursor: pointer;
            transition: border-color 0.2s ease;
        }
        .sort-by select:focus {
            border-color: var(--primary-dark);
        }
        
        /* Course Grid */
        .course-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }
        .course-card {
            background: var(--white);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            display: flex;
            flex-direction: column;
            border: 1px solid transparent;
        }
        .course-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            border-color: rgba(255, 193, 7, 0.3); /* Subtle yellow glow */
        }
        
        .course-image {
            width: 100%;
            height: 180px;
            object-fit: cover;
            border-bottom: 1px solid var(--border-light);
        }
        
        .course-body {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            padding: 20px;
        }
        .course-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
            font-size: 13px;
        }
        .course-teacher a {
            color: var(--text-muted);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s ease;
        }
        .course-teacher a:hover {
            color: var(--primary-dark);
        }
        .course-rating {
            color: var(--text-muted);
            display: flex;
            align-items: center;
            font-weight: 500;
        }
        .course-rating i {
            color: var(--accent-yellow);
            margin-right: 4px;
        }
        .course-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--primary-dark);
            margin: 0 0 15px 0;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-decoration: none;
            line-height: 1.4;
            transition: color 0.2s ease;
        }
        .course-title:hover {
            color: #2a2a4e; /* Slightly lighter dark blue */
        }
        
        .course-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
            padding-top: 15px;
            border-top: 1px dashed var(--border-light);
        }
        .enroll-btn {
            background-color: var(--accent-yellow);
            color: var(--primary-dark);
            border: none;
            padding: 8px 20px;
            font-size: 14px;
            font-weight: 700;
            border-radius: 20px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .enroll-btn:hover {
            background-color: #e0a800; /* Darker yellow */
            transform: translateY(-2px);
        }
        .course-price {
            font-size: 20px;
            font-weight: 800;
            color: var(--primary-dark);
        }
        
        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 50px;
            gap: 10px;
            margin-bottom: 50px;
        }
        .page-link {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--white);
            color: var(--primary-dark);
            text-decoration: none;
            font-size: 15px;
            font-weight: 600;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            border: 1px solid transparent;
        }
        .page-link:hover {
            background: var(--accent-yellow);
            color: var(--primary-dark);
            transform: translateY(-2px);
        }
        .page-link.active {
            background: var(--primary-dark);
            color: var(--white);
            box-shadow: 0 4px 12px rgba(26, 26, 46, 0.3);
        }
    </style>
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
                                    rating ${course.rating}
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
                                            <span class="course-price"><fmt:formatNumber value='${course.price}' pattern='#0.00' groupingUsed='false'/>$</span>
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
