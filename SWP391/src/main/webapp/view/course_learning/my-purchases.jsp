<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Purchases | OCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_learning.css">
</head>
<body>

    <jsp:include page="/view/common/header.jsp" />

    <div class="my-learning-header">
        <div class="container">
            <h1>My Purchases</h1>
        </div>
    </div>

    <main class="py-4">
        <div class="container">
            <!-- Tóm tắt mua hàng -->
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="text-muted mb-1">Courses Purchased</h6>
                            <h3 class="mb-0">${summary.totalCount}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="text-muted mb-1">Total Spent</h6>
                            <h3 class="mb-0"><fmt:formatNumber value="${summary.totalSpent}" minFractionDigits="2" maxFractionDigits="2"/>₫</h3>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bảng lịch sử mua khóa -->
            <div class="table-responsive">
                <table class="table table-bordered align-middle bg-white">
                    <thead>
                        <tr>
                            <th>Course</th>
                            <th>Package</th>
                            <th>Total Cost</th>
                            <th>Transaction Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${purchases}">
                            <tr>
                                <td>${p.courseName}</td>
                                <td>${p.packages}</td>
                                <td><fmt:formatNumber value="${p.totalCost}" minFractionDigits="2" maxFractionDigits="2"/>₫</td>
                                <td><fmt:formatDate value="${p.registrationTime}" pattern="dd/MM/yyyy"/></td>
                                <td>${p.status}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty purchases}">
                            <tr><td colspan="6" style="text-align:center;">No purchases yet.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</body>
</html>