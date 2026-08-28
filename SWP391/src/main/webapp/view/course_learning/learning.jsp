<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${currentLesson.title} | ${course.name}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_learning.css">
    
    
</head>
<body data-ctx="${pageContext.request.contextPath}">

    <!-- Common Header (project-wide) -->
    <jsp:include page="/view/common/header.jsp" />

    <c:set var="fromVal" value="${not empty param.from ? param.from : fromParam}" />
    <c:set var="fromQuery" value="${not empty fromVal ? '&from='.concat(fromVal) : ''}" />

    <!-- Learning-specific Topbar -->
    <div class="learn-topbar">
        <div class="tb-nav">
            <c:choose>
                <c:when test="${fromVal == 'archived'}">
                    <a href="${pageContext.request.contextPath}/archived"><i class="fa-solid fa-arrow-left"></i> Archived</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/all-courses"><i class="fa-solid fa-arrow-left"></i> All Courses</a>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="tb-title">${course.name}</div>
        <div class="tb-nav">
            <c:if test="${not empty prevLesson}">
                <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${prevLesson.id}${fromQuery}"><i class="fa-solid fa-chevron-left"></i> Previous</a>
            </c:if>
            <c:if test="${not empty nextLesson}">
                <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${nextLesson.id}${fromQuery}">Next <i class="fa-solid fa-chevron-right"></i></a>
            </c:if>
        </div>
    </div>

    <div class="learn-wrap">

        <!-- Sidebar curriculum -->
        <aside class="learn-sidebar">
            <div class="sb-title">Course content</div>
            <c:forEach var="section" items="${sections}">
                <div class="section-item">
                    <button class="section-header" type="button" data-bs-toggle="collapse" data-bs-target="#sec-${section.id}" aria-expanded="true">
                        <span>${section.title}</span>
                        <i class="fa-solid fa-chevron-down"></i>
                    </button>
                    <div id="sec-${section.id}" class="collapse show">
                        <ul class="section-lessons">
                            <c:forEach var="lesson" items="${lessonsMap[section.id]}">
                                <li>
                                    <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${lesson.id}${fromQuery}"
                                       class="${lesson.id == currentLesson.id ? 'active' : ''}">
                                        <span class="les-icon">
                                            <c:choose>
                                                <c:when test="${lesson.type == 'video'}"><i class="fa-solid fa-circle-play"></i></c:when>
                                                <c:when test="${lesson.type == 'quiz'}"><i class="fa-solid fa-clipboard-question"></i></c:when>
                                                <c:when test="${lesson.type == 'file'}"><i class="fa-solid fa-paperclip"></i></c:when>
                                                <c:otherwise><i class="fa-solid fa-book-open"></i></c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span>${lesson.title}</span>
                                        <c:if test="${completedLessons.contains(lesson.id)}">
                                            <span class="les-check"><i class="fa-solid fa-circle-check les-check-icon"></i></span>
                                        </c:if>
                                        <c:if test="${lesson.durationMinutes != null and lesson.durationMinutes > 0 and not completedLessons.contains(lesson.id)}">
                                            <span class="les-duration">${lesson.durationMinutes} min</span>
                                        </c:if>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </div>
            </c:forEach>
        </aside>

        <!-- Main content -->
        <main class="learn-main">
            <div class="learn-content-box">

                <c:choose>
                    <c:when test="${noContent}">
                        <div class="empty-state-box">
                            <div class="empty-state-title">Course has no lessons yet</div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <h1 class="lesson-title">${currentLesson.title}</h1>

                        <c:choose>
                            <%-- VIDEO --%>
                            <c:when test="${currentLesson.type == 'video'}">
                                <c:if test="${not empty lessonVideos}">
                                    <c:forEach var="v" items="${lessonVideos}" varStatus="vs">
                                        <c:if test="${v.videoUrl != null and v.videoUrl != '' and v.videoProvider != null}">
                                            <div class="video-wrap">
                                                <c:choose>
                                                    <c:when test="${v.videoProvider == 'youtube'}">
                                                        <c:set var="ytUrl" value="${v.videoUrl}"/>
                                                        <c:if test="${fn:contains(v.videoUrl, 'enablejsapi')}">
                                                            <c:set var="ytUrl" value="${v.videoUrl}"/>
                                                        </c:if>
                                                        <c:if test="${!fn:contains(v.videoUrl, 'enablejsapi')}">
                                                            <c:set var="ytUrl" value="${v.videoUrl}${fn:contains(v.videoUrl, '?') ? '&' : '?'}enablejsapi=1"/>
                                                        </c:if>
                                                        <iframe id="lessonVideo_${vs.index}" class="lesson-video-youtube" 
                                                                src="${ytUrl}" 
                                                                data-lesson-id="${currentLesson.id}"
                                                                data-video-id="${v.id}"
                                                                data-video-provider="youtube"
                                                                allow="autoplay; encrypted-media" allowfullscreen></iframe>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <video id="lessonVideo_${vs.index}" class="lesson-video-html5" 
                                                               controls 
                                                               data-lesson-id="${currentLesson.id}"
                                                               data-video-id="${v.id}"
                                                               data-video-provider="html5">
                                                            <source src="${v.videoUrl}" type="video/mp4">Your browser does not support video.
                                                        </video>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                                <c:if test="${empty lessonVideos}">
                                    <div class="resource-box">No video found for this lesson.</div>
                                </c:if>
                            </c:when>

                            <%-- TEXT --%>
                            <c:when test="${currentLesson.type == 'text'}">
                                <div class="lesson-content">
                                    <c:choose>
                                        <c:when test="${not empty lessonContent}">${lessonContent}</c:when>
                                        <c:otherwise><div class="resource-box">This lesson has no content yet.</div></c:otherwise>
                                    </c:choose>
                                </div>
                            </c:when>

                            <%-- DOCUMENT --%>
                            <c:when test="${currentLesson.type == 'document'}">
                                <c:if test="${not empty lessonContent}">
                                    <div class="lesson-content">${lessonContent}</div>
                                </c:if>
                                <c:if test="${not empty lessonDocument}">
                                    <div class="resource-box">
                                        <a href="${lessonDocument.documentUrl}" target="_blank" class="btn-purple"><i class="fa-solid fa-file"></i> Open document</a>
                                    </div>
                                    <c:if test="${lessonDocument.documentType == 'pdf'}">
                                        <iframe class="doc-preview" src="${lessonDocument.documentUrl}"></iframe>
                                    </c:if>
                                </c:if>
                            </c:when>

                            <%-- FILE --%>
                            <c:when test="${currentLesson.type == 'file'}">
                                <div class="resource-box">
                                    <a href="${lessonFileUrl}" class="btn-purple" download><i class="fa-solid fa-download"></i> Download attachment</a>
                                </div>
                            </c:when>

                            <%-- QUIZ --%>
                            <c:when test="${currentLesson.type == 'quiz'}">
                                <c:if test="${hasPassedQuiz}">
                                    <div class="quiz-result pass"><i class="fa-solid fa-circle-check"></i> Quiz passed (best score: ${bestQuizScore}/${quizTotalPoints})</div>
                                </c:if>
                                <c:if test="${not empty quizQuestions}">
                                    <form id="quizForm">
                                        <input type="hidden" name="quizId" value="${quizId}">
                                        <input type="hidden" name="servedQuestionIds" value="${servedQuestionIds}">
                                        <c:forEach var="q" items="${quizQuestions}" varStatus="qs">
                                            <div class="quiz-question">
                                                <div class="quiz-question-title">${qs.index + 1}. ${q.questionText}</div>
                                                <c:set var="isMulti" value="${quizQuestionMultipleChoiceMap[q.id]}" />
                                                <c:forEach var="a" items="${quizAnswers[q.id]}">
                                                    <label class="quiz-answer">
                                                        <c:choose>
                                                            <c:when test="${isMulti}">
                                                                <input type="checkbox" name="answer_${q.id}" value="${a.id}">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <input type="radio" name="answer_${q.id}" value="${a.id}">
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <span>${a.answerText}</span>
                                                    </label>
                                                </c:forEach>
                                            </div>
                                        </c:forEach>
                                        <button type="submit" class="btn-purple">Submit Quiz</button>
                                    </form>
                                    <div id="quizResult"></div>
                                </c:if>
                                <c:if test="${empty quizQuestions}">
                                    <div class="resource-box">This quiz has no questions yet.</div>
                                </c:if>
                            </c:when>

                            <c:otherwise>
                                <div class="resource-box">This lesson type is not supported yet.</div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Actions -->
                        <div class="mt-4 d-flex justify-content-between align-items-center">
                            <c:if test="${currentLesson.type != 'quiz' and not completedLessons.contains(currentLesson.id)}">
                                <button type="button" class="btn-purple" onclick="markComplete(${currentLesson.id})"><i class="fa-solid fa-check"></i> Mark as Complete</button>
                            </c:if>
                            <c:if test="${currentLesson.type != 'quiz' and completedLessons.contains(currentLesson.id)}">
                                <span class="quiz-result pass"><i class="fa-solid fa-circle-check"></i> Completed</span>
                            </c:if>
                            <c:if test="${not empty nextLesson}">
                                <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${nextLesson.id}${fromQuery}" class="btn-outline">Next: ${nextLesson.title} <i class="fa-solid fa-chevron-right"></i></a>
                            </c:if>
                        </div>
                    </c:otherwise>
                </c:choose>

            </div>
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/course_learning/learning.js"></script>
</body>
</html>
