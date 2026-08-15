<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/java/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <!-- Tái sử dụng CSS chung của dự án -->
    <jsp:include page="home/css-home.jsp" />
</head>
<body class="bg-light">

    <!-- Header chung -->
    <jsp:include page="home/header-home.jsp" />

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
    <jsp:include page="home/footer-home.jsp" />
    <jsp:include page="home/js-home.jsp" />

</body>
</html>