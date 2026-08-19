<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Learning | OCMS</title>

    <!-- System CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_learning.css">
</head>

<body data-ctx="${pageContext.request.contextPath}">

    <!-- Common Header -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Navigation Header -->
    <div class="my-learning-header">
        <div class="container">
            <h1>Wishlist</h1>
        </div>
    </div>

    <main class="py-4">
        <div class="container py-2">
            <c:choose>
                <c:when test="${not empty wishlistCourses}">
                    <div class="learning-controls">
                        <div class="learning-filters">
                            <select class="filter-select" id="sortBy" onchange="filterCourses()">
                                <option value="title-asc" selected>Sort by: Title A to Z</option>
                                <option value="title-desc">Sort by: Title Z to A</option>
                            </select>

                            <select class="filter-select" id="filterCategory" onchange="filterCourses()">
                                <option value="all">Categories: All</option>
                            </select>
                        </div>

                        <div class="learning-search">
                            <input type="text" id="courseSearchInput" placeholder="Search wishlist..." onkeydown="if(event.key==='Enter'){filterCourses();}">
                            <button type="button" onclick="filterCourses()"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
                        </div>
                    </div>

                    <div class="course-grid" id="courseGrid">
                        <c:forEach var="item" items="${wishlistCourses}">
                            <div class="course-card" id="wishlist-card-${item.id}" data-title="${item.name}" data-category="${item.categoryName}">
                                <img src="${not empty item.thumbnail ? item.thumbnail : pageContext.request.contextPath.concat('/assets/img/courses/default-course.jpg')}" alt="${item.name}">
                                <div class="course-card-body">
                                    <h3 class="course-card-title">${item.name}</h3>
                                    <div class="btn-action-group">
                                        <a href="${pageContext.request.contextPath}/course?id=${item.id}" class="btn-purple">View Course</a>
                                        <button type="button" class="wishlist-heart active" data-course-id="${item.id}" onclick="removeFromWishlist(this)" title="Remove from wishlist">
                                            <i class="fa-solid fa-heart"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="empty-state-box" id="noResults" style="display:none;">
                        <div class="empty-state-title">No courses found</div>
                        <div class="empty-state-desc">No courses match your search or filter. Try adjusting your criteria.</div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state-box">
                        <div class="empty-state-title">Your wishlist is empty</div>
                        <div class="empty-state-desc">Explore courses and add them to your wishlist to save them for later.</div>
                        <a href="${pageContext.request.contextPath}/courses" class="btn-purple">Browse Courses</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/course_learning/wishlist.js"></script>

</body>

</html>
