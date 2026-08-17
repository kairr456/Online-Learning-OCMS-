<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <!-- Tái sử dụng CSS chung của dự án -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <!-- Bootstrap CSS for card layout -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <div class="container my-5">
        <h2 class="mb-4 text-center text-primary">Danh Sách Bài Viết</h2>
        
        <div class="row">
            <c:forEach items="${blogList}" var="b">
                <div class="col-md-4 mb-4">
                    <div class="card h-100 shadow-sm border-0">
                        <img src="${b.thumbnail}" class="card-img-top" alt="${b.title}" 
                             style="height: 200px; object-fit: cover;"
                             onerror="this.src='https://via.placeholder.com/300x200?text=No+Image';">
                        <div class="card-body">
                            <h5 class="card-title text-dark fw-bold">${b.title}</h5>
                            <p class="card-text text-secondary">${b.briefInfo}</p>
                        </div>
                        <div class="card-footer bg-white border-0 d-flex justify-content-between align-items-center">
                            <small class="text-muted">${b.createdDate}</small>
                            <a href="blog-detail?id=${b.id}" class="btn btn-sm btn-outline-primary">Xem chi tiết</a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- Footer và JS chung -->
    <jsp:include page="/view/common/footer.jsp" />
    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
    <!-- Bootstrap JS for card/collapse components -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>