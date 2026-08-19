<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>My Certificates | OCMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <style>
        body { background: #f4f6f9; font-family: 'Inter','Segoe UI',sans-serif; margin: 0; padding: 0; }
        .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
        h1 { color: #1a1a2e; font-size: 26px; margin-bottom: 24px; }
        .cert-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 20px; }
        .cert-card { background: #fff; border-radius: 14px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,.06); }
        .cert-card img { width: 100%; height: 150px; object-fit: cover; }
        .cert-body { padding: 16px; }
        .cert-body h3 { margin: 0 0 6px; font-size: 16px; color: #1a1a2e; }
        .cert-meta { font-size: 13px; color: #6c757d; margin-bottom: 6px; }
        .cert-code { font-size: 12px; color: #5d3fd3; font-weight: 600; margin-bottom: 12px; }
        .btn-purple { display: inline-block; background: #5d3fd3; color: #fff; padding: 8px 18px; border-radius: 8px; text-decoration: none; font-size: 14px; }
        .empty { background: #fff; border-radius: 14px; padding: 40px; text-align: center; color: #6c757d; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container">
        <h1>My Certificates</h1>
        <c:choose>
            <c:when test="${not empty certificates}">
                <div class="cert-grid">
                    <c:forEach var="cert" items="${certificates}">
                        <div class="cert-card">
                            <a href="${pageContext.request.contextPath}/certificate?code=${cert.certificateCode}">
                                <img src="${not empty cert.backgroundUrl ? cert.backgroundUrl : pageContext.request.contextPath.concat('/assets/css/img/default-certificate.jpg')}" alt="Certificate">
                            </a>
                            <div class="cert-body">
                                <h3>${cert.courseName}</h3>
                                <div class="cert-meta">Issued: <fmt:formatDate value="${cert.issuedDateAsDate}" pattern="dd/MM/yyyy" /></div>
                                <div class="cert-code">${cert.certificateCode}</div>
                                <a class="btn-purple" href="${pageContext.request.contextPath}/certificate?code=${cert.certificateCode}">View Certificate</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty">
                    <h3>You don't have any certificates yet</h3>
                    <p>Complete a course that has a certificate to earn it.</p>
                    <a class="btn-purple" href="${pageContext.request.contextPath}/all-courses">Go to My Learning</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>