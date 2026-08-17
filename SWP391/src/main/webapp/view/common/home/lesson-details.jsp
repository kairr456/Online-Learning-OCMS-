<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html class="no-js" lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>${lesson.title} - Online Learning</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <!-- Inherit common styles -->
    <style>
        .lesson-container {
            max-width: 900px;
            margin: 40px auto;
            background: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
        }
        .lesson-title {
            font-size: 32px;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        .lesson-content img {
            max-width: 100%;
            border-radius: 8px;
            margin: 20px 0;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .lesson-content iframe {
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.15);
            margin: 20px 0;
            width: 100%;
        }
        .lesson-content p {
            font-size: 17px;
            line-height: 1.8;
            color: #444;
            margin-bottom: 15px;
        }
        .back-to-course {
            display: inline-block;
            margin-bottom: 20px;
            color: #666;
            text-decoration: none;
            font-weight: 500;
        }
        .back-to-course:hover {
            color: #ffc107;
        }
        .lesson-content {
            font-family: 'Inter', sans-serif;
        }
    </style>
</head>

<body>
    <!-- header-area -->
    <jsp:include page="/view/common/header.jsp" />
    <!-- header-area-end -->

    <main class="main-area" style="background-color: #f8f9fa; min-height: 80vh; padding: 20px 0;">
        <div class="container">
            <div class="lesson-container">
                <a href="${pageContext.request.contextPath}/course?id=${courseId}" class="back-to-course"><i class="fas fa-arrow-left me-2"></i>Back to Course</a>
                
                <h1 class="lesson-title">${lesson.title}</h1>
                
                <div class="lesson-content">
                    <c:choose>
                        <c:when test="${not empty lessonContent}">
                            ${lessonContent}
                        </c:when>
                        <c:otherwise>
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle me-2"></i> This lesson has no content yet.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>
</body>
</html>
