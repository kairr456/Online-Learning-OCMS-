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

<body>

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
                    <div class="course-grid">
                        <c:forEach var="item" items="${wishlistCourses}">
                            <div class="course-card">
                                <img src="${item.thumbnail}" alt="${item.name}">
                                <div class="course-card-body">
                                    <h3 class="course-card-title">${item.name}</h3>
                                    <a href="${pageContext.request.contextPath}/course-detail?id=${item.id}" class="btn-purple">View Course</a>
                                </div>
                            </div>
                        </c:forEach>
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

</body>

</html>
