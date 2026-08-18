<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html class="no-js" lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>${lesson.title} - Online Learning</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
                <a href="${pageContext.request.contextPath}/course?id=${courseId}" class="btn btn-outline-secondary mb-4 rounded-pill px-4">
                    <i class="fas fa-arrow-left me-2"></i>Back to Course
                </a>
                
                <h1 class="lesson-title">${lesson.title}</h1>
                
                <div class="lesson-content mt-4">
                    <c:choose>
                        <c:when test="${lesson.type == 'video'}">
                            <% 
                                // FALLBACK: If user hasn't recompiled LessonDetails.java, fetch it directly here
                                if (request.getAttribute("videoUrl") == null) {
                                    com.entity.Lesson l = (com.entity.Lesson) request.getAttribute("lesson");
                                    if (l != null) {
                                        String vUrl = new com.DAO.LessonDAO().getLessonYoutube(l.getId());
                                        request.setAttribute("videoUrl", vUrl);
                                    }
                                }
                            %>
                            <c:if test="${not empty videoUrl}">
                                <c:set var="displayVideoUrl" value="${videoUrl}" />
                                <c:if test="${fn:startsWith(videoUrl, '/SWP391_OCMS')}">
                                    <c:set var="displayVideoUrl" value="${pageContext.request.contextPath}${fn:substringAfter(videoUrl, '/SWP391_OCMS')}" />
                                </c:if>
                                <c:if test="${fn:startsWith(videoUrl, '/SWP391/')}">
                                    <c:set var="displayVideoUrl" value="${pageContext.request.contextPath}${fn:substringAfter(videoUrl, '/SWP391')}" />
                                </c:if>
                                
                                <div class="ratio ratio-16x9 mb-4" style="border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.15);">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(fn:trim(displayVideoUrl), '<iframe')}">
                                            <c:out value="${displayVideoUrl}" escapeXml="false" />
                                        </c:when>
                                        <c:when test="${fn:contains(displayVideoUrl, 'youtube.com') || fn:contains(displayVideoUrl, 'youtu.be') || (!fn:contains(displayVideoUrl, '.') && !fn:contains(displayVideoUrl, '/'))}">
                                            <c:set var="embedUrl" value="${displayVideoUrl}" />
                                            <c:choose>
                                                <c:when test="${fn:contains(displayVideoUrl, 'youtube.com') || fn:contains(displayVideoUrl, 'youtu.be')}">
                                                    <c:if test="${fn:contains(displayVideoUrl, 'watch?v=')}">
                                                        <c:set var="embedUrl" value="${fn:replace(displayVideoUrl, 'watch?v=', 'embed/')}" />
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="embedUrl" value="https://www.youtube.com/embed/${displayVideoUrl}" />
                                                </c:otherwise>
                                            </c:choose>
                                            <iframe src="${embedUrl}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen style="width: 100%; height: 500px;"></iframe>
                                        </c:when>
                                        <c:otherwise>
                                            <video controls style="width: 100%; max-height: 500px; background: #000;">
                                                <source src="${displayVideoUrl}" type="video/mp4">
                                                Your browser does not support the video tag.
                                            </video>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:if>
                            <c:if test="${not empty lessonContent}">
                                <div><c:out value="${lessonContent}" escapeXml="false" /></div>
                            </c:if>
                        </c:when>
                        
                        <c:when test="${lesson.type == 'quiz'}">
                            <div class="text-center p-5 bg-white rounded border shadow-sm">
                                <h3 class="mb-3"><i class="fas fa-file-alt text-primary me-2"></i> Quiz: ${lesson.title}</h3>
                                <p class="text-muted mb-4 fs-5">${lesson.description}</p>
                                
                                <c:choose>
                                    <c:when test="${maxRetakes != null && maxRetakes != -1 && userAttempts >= maxRetakes}">
                                        <button class="btn btn-secondary btn-lg px-5 rounded-pill shadow-sm" disabled>
                                            <i class="fas fa-lock me-2"></i> Quiz Đã Khóa (Hết Lượt)
                                        </button>
                                        <p class="text-danger mt-3 mb-2">Bạn đã sử dụng hết ${maxRetakes} lượt làm bài.</p>
                                        <a href="${pageContext.request.contextPath}/quiz-result?lessonId=${lesson.id}" class="btn btn-outline-primary mt-2 rounded-pill px-4">
                                            <i class="fas fa-history me-2"></i> Xem lịch sử làm bài
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/take-quiz?lessonId=${lesson.id}" class="btn btn-primary btn-lg px-5 rounded-pill shadow-sm" style="background-color: #5624d0; border-color: #5624d0; transition: transform 0.2s;">
                                            <i class="fas fa-play-circle me-2"></i> Bắt đầu làm bài
                                            <c:if test="${maxRetakes != null && maxRetakes != -1}">
                                                <br><small class="fw-normal">(Còn ${maxRetakes - userAttempts} lượt)</small>
                                            </c:if>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <c:choose>
                                <c:when test="${not empty lessonContent}">
                                    <div class="bg-white p-4 rounded border shadow-sm">
                                        <c:out value="${lessonContent}" escapeXml="false" />
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-info shadow-sm">
                                        <i class="fas fa-info-circle me-2"></i> This lesson has no content yet.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
