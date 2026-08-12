<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Browse Courses</title>
    <!-- css -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />
    
    <div style="padding: 20px;">
        <h1>Browse Courses</h1>
        
    <c:if test="${empty courses}">
        <p>No courses available right now.</p>
    </c:if>
    
    <ul>
        <c:forEach var="course" items="${courses}">
            <li>${course.name} - ${course.description}</li>
        </c:forEach>
    </ul>
    </div>
</body>
</html>
