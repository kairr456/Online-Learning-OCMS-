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
            <h1>Archived</h1>
        </div>
    </div>

    <main class="py-4">
        <div class="container py-2">
            <c:choose>
                <c:when test="${not empty archivedCourses}">
                    <div class="course-grid">
                        <c:forEach var="item" items="${archivedCourses}">
                            <div class="course-card">
                                <img src="${not empty item.thumbnail ? item.thumbnail : pageContext.request.contextPath.concat('/assets/img/courses/default-course.jpg')}" alt="${item.name}">
                                <div class="course-card-body">
                                    <h3 class="course-card-title">${item.name}</h3>
                                    <div class="btn-action-group">
                                        <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}&from=archived" class="btn-purple">View Course</a>
                                        <button type="button" class="btn btn-outline-primary btn-sm" onclick="unarchiveCourse(${item.id}, '${item.name}')">Unarchive</button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state-box">
                        <div class="empty-state-title">Focus on your current goals</div>
                        <div class="empty-state-desc">Courses you archive will appear here so you can access them whenever you need.</div>
                        <a href="${pageContext.request.contextPath}/courses" class="btn-purple">Explore Courses</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <!-- ==================== MODAL: CONFIRM UNARCHIVE ==================== -->
    <div class="custom-modal-backdrop" id="unarchiveConfirmModal">
        <div class="custom-modal-content">
            <div class="custom-modal-header">
                <h5 class="fw-bold mb-0">Unarchive Course</h5>
                <button type="button" class="btn-close" onclick="closeUnarchiveConfirmModal()"></button>
            </div>
            <div class="custom-modal-body">
                <p id="unarchiveConfirmMessage" class="mb-0"></p>
            </div>
            <div class="custom-modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeUnarchiveConfirmModal()">Cancel</button>
                <button type="button" class="btn btn-danger fw-bold" onclick="confirmUnarchiveAction()">Unarchive</button>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/course_learning/archived.js"></script>

</body>

</html>
