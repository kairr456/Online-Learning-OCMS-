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
    
    <style>
        :root {
            --primary-dark: #1a1a2e;
            --accent-yellow: #ffc107;
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
        
        .dashboard-container {
            max-width: 1300px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .filter-bar {
            background: var(--white);
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            flex-wrap: wrap;
        }

        .search-wrapper {
            flex: 1;
            min-width: 300px;
            position: relative;
            display: flex;
            align-items: center;
        }

        .search-wrapper input {
            width: 100%;
            padding: 12px 40px 12px 20px;
            border: 1px solid var(--border-light);
            border-radius: 30px;
            outline: none;
            font-size: 14px;
            transition: all 0.3s ease;
            box-shadow: inset 0 1px 3px rgba(0,0,0,0.02);
        }

        .search-wrapper input:focus {
            border-color: var(--primary-dark);
            box-shadow: 0 0 0 3px rgba(26, 26, 46, 0.1);
        }

        .search-wrapper i {
            position: absolute;
            right: 20px;
            color: var(--text-muted);
            font-size: 14px;
            cursor: pointer;
        }

        .filter-controls {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .filter-select {
            padding: 10px 15px;
            border: 1px solid var(--border-light);
            border-radius: 8px;
            outline: none;
            background: var(--bg-color);
            color: var(--primary-dark);
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: border-color 0.2s ease;
        }

        .filter-select:focus {
            border-color: var(--primary-dark);
        }

        .results-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
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
        
        /* Course Grid - 4x2 */
        .course-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
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
            border-color: rgba(255, 193, 7, 0.3);
        }
        
        .course-image {
            width: 100%;
            height: 140px;
            object-fit: cover;
            border-bottom: 1px solid var(--border-light);
        }
        
        .course-body {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            padding: 15px;
        }
        .course-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            font-size: 12px;
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
            font-size: 16px;
            font-weight: 700;
            color: var(--primary-dark);
            margin: 0 0 12px 0;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-decoration: none;
            line-height: 1.4;
            transition: color 0.2s ease;
        }
        .course-title:hover {
            color: #2a2a4e;
        }
        
        .course-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
            padding-top: 12px;
            border-top: 1px dashed var(--border-light);
            gap: 10px;
        }
        .action-btn {
            border: none;
            padding: 6px 12px;
            font-size: 12px;
            font-weight: 700;
            border-radius: 15px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            text-transform: uppercase;
            flex: 1;
            text-align: center;
        }
        .btn-edit {
            background-color: #e0f2fe;
            color: #0284c7;
        }
        .btn-edit:hover {
            background-color: #bae6fd;
        }
        .btn-delete {
            background-color: #fee2e2;
            color: #dc2626;
        }
        .btn-delete:hover {
            background-color: #fecaca;
        }
        
        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 40px;
            gap: 10px;
            margin-bottom: 40px;
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
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />
    
    <c:if test="${not empty sessionScope.msg}">
        <script>
            alert('${sessionScope.msg}');
        </script>
        <c:remove var="msg" scope="session"/>
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
                <p style="text-align:center; padding: 40px;">You haven't created any courses yet.</p>
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
                                <span class="fw-bold text-success me-2" style="font-size: 0.9rem;">
                                    <c:choose>
                                        <c:when test="${course.price == 0}">Free</c:when>
                                        <c:otherwise>$${course.price}</c:otherwise>
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
                            
                            <div class="text-muted small mb-3" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; height: 40px;">
                                ${course.description}
                            </div>
                            
                            <div class="course-footer">
                                <a href="${pageContext.request.contextPath}/lesson?courseId=${course.id}" class="action-btn btn-edit"><i class="fas fa-edit"></i> Edit</a>
                                <a href="${pageContext.request.contextPath}/course-delete-preview?id=${course.id}" class="action-btn btn-delete"><i class="fas fa-trash"></i> Delete</a>
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
