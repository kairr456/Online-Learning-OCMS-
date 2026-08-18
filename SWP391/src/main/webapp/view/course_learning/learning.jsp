<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${currentLesson.title} | ${course.name}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_learning.css">
    <style>
        body { margin: 0; background: #fff; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }

        /* Top bar */
        .learn-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #1f1f1f;
            color: #fff;
            padding: 0 20px;
            height: 56px;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
        }
        .learn-topbar a { color: #fff; text-decoration: none; font-size: 14px; }
        .learn-topbar a:hover { color: #a435f0; }
        .learn-topbar .tb-title { font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 40vw; }
        .learn-topbar .tb-nav { display: flex; gap: 16px; align-items: center; }

        /* Layout */
        .learn-wrap { display: flex; margin-top: 56px; min-height: calc(100vh - 56px); }

        /* Sidebar */
        .learn-sidebar {
            width: 340px;
            flex-shrink: 0;
            border-right: 1px solid #d1d7dc;
            background: #fff;
            overflow-y: auto;
            max-height: calc(100vh - 56px);
            position: sticky;
            top: 56px;
        }
        .learn-sidebar .sb-title { padding: 16px; font-weight: 700; font-size: 15px; border-bottom: 1px solid #eee; }
        .section-item { border-bottom: 1px solid #f0f0f0; }
        .section-header {
            width: 100%;
            background: none;
            border: none;
            text-align: left;
            padding: 14px 16px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #1c1d1f;
        }
        .section-header:hover { background: #f7f9fa; }
        .section-lessons { list-style: none; margin: 0; padding: 0 0 8px 0; }
        .section-lessons li a {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 16px 8px 34px;
            font-size: 13.5px;
            color: #2d2f31;
            text-decoration: none;
        }
        .section-lessons li a:hover { background: #f7f9fa; }
        .section-lessons li a.active { background: #f5efff; color: #401b9c; border-left: 3px solid #5624d0; }
        .section-lessons li a .les-icon { color: #6a6f73; width: 16px; text-align: center; flex-shrink: 0; }
        .section-lessons li a.active .les-icon { color: #5624d0; }
        .section-lessons li a .les-check { margin-left: auto; flex-shrink: 0; }
        .section-lessons li a .les-duration { margin-left: auto; color: #6a6f73; font-size: 12px; flex-shrink: 0; }

        /* Main content */
        .learn-main { flex: 1; padding: 32px 40px 60px; }
        .learn-main .learn-content-box { max-width: 860px; margin: 0 auto; }
        .lesson-title { font-size: 26px; font-weight: 700; color: #1c1d1f; margin-bottom: 24px; }
        .lesson-content { font-size: 16px; line-height: 1.7; color: #333; }
        .lesson-content img { max-width: 100%; border-radius: 8px; }
        .lesson-content p { margin-bottom: 14px; }

        .video-wrap { position: relative; width: 100%; aspect-ratio: 16/9; background: #000; border-radius: 8px; overflow: hidden; margin-bottom: 16px; }
        .video-wrap iframe, .video-wrap video { width: 100%; height: 100%; border: 0; }

        .resource-box { background: #f7f9fa; border: 1px solid #d1d7dc; border-radius: 8px; padding: 20px; }
        .doc-preview { width: 100%; height: 640px; border: 1px solid #d1d7dc; border-radius: 8px; margin-top: 16px; }

        /* Quiz */
        .quiz-question { margin-bottom: 24px; }
        .quiz-question-title { font-weight: 600; font-size: 15px; margin-bottom: 8px; }
        .quiz-answer {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 14px;
            border: 1px solid #d1d7dc;
            border-radius: 6px;
            margin-bottom: 8px;
            cursor: pointer;
            font-size: 14px;
        }
        .quiz-answer:hover { background: #f5efff; border-color: #5624d0; }
        .quiz-answer input { accent-color: #5624d0; }
        .quiz-result { margin-top: 16px; padding: 14px; border-radius: 8px; font-weight: 600; }
        .quiz-result.pass { background: #e6f4ea; color: #1e7e34; border: 1px solid #1e7e34; }
        .quiz-result.fail { background: #fdecea; color: #b3261e; border: 1px solid #b3261e; }

        .btn-purple { background-color: #a435f0; color: #fff; font-weight: 700; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
        .btn-purple:hover { background-color: #8710d8; }
        .btn-outline { border: 1px solid #1c1d1f; background: transparent; color: #1c1d1f; font-weight: 700; padding: 10px 20px; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-outline:hover { background: #f7f9fa; }
    </style>
</head>
<body>

    <!-- Top bar -->
    <div class="learn-topbar">
        <div class="tb-nav">
            <a href="${pageContext.request.contextPath}/all-courses"><i class="fa-solid fa-arrow-left"></i> All Courses</a>
        </div>
        <div class="tb-title">${course.name}</div>
        <div class="tb-nav">
            <c:if test="${not empty prevLesson}">
                <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${prevLesson.id}"><i class="fa-solid fa-chevron-left"></i> Previous</a>
            </c:if>
            <c:if test="${not empty nextLesson}">
                <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${nextLesson.id}">Next <i class="fa-solid fa-chevron-right"></i></a>
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
                                    <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${lesson.id}"
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
                                            <span class="les-check"><i class="fa-solid fa-circle-check" style="color:#1e7e34;"></i></span>
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
                                    <c:forEach var="v" items="${lessonVideos}">
                                        <div class="video-wrap">
                                            <c:choose>
                                                <c:when test="${v.videoProvider == 'youtube'}">
                                                    <iframe src="${v.videoUrl}" allow="autoplay; encrypted-media" allowfullscreen></iframe>
                                                </c:when>
                                                <c:otherwise>
                                                    <video controls><source src="${v.videoUrl}" type="video/mp4">Your browser does not support video.</video>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
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
                                        <c:forEach var="q" items="${quizQuestions}" varStatus="qs">
                                            <div class="quiz-question">
                                                <div class="quiz-question-title">${qs.index + 1}. ${q.questionText}</div>
                                                <c:forEach var="a" items="${quizAnswers[q.id]}">
                                                    <label class="quiz-answer">
                                                        <input type="radio" name="answer_${q.id}" value="${a.id}">
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
                                <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${nextLesson.id}" class="btn-outline">Next: ${nextLesson.title} <i class="fa-solid fa-chevron-right"></i></a>
                            </c:if>
                        </div>
                    </c:otherwise>
                </c:choose>

            </div>
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const CTX = '${pageContext.request.contextPath}';

        function markComplete(lessonId) {
            const body = new URLSearchParams();
            body.append('action', 'markComplete');
            body.append('lessonId', lessonId);
            fetch(CTX + '/learning', { method: 'POST', body: body })
                .then(r => r.json())
                .then(d => {
                    if (d.status === 'success') {
                        location.reload();
                    } else {
                        alert('Error: ' + d.message);
                    }
                })
                .catch(() => alert('Connection error!'));
        }

        const quizForm = document.getElementById('quizForm');
        if (quizForm) {
            quizForm.addEventListener('submit', function (e) {
                e.preventDefault();
                const body = new URLSearchParams(new FormData(quizForm));
                body.append('action', 'submitQuiz');
                fetch(CTX + '/learning', { method: 'POST', body: body })
                    .then(r => r.json())
                    .then(d => {
                        const res = document.getElementById('quizResult');
                        if (d.status === 'success') {
                            res.innerHTML = '<div class="quiz-result ' + (d.passed ? 'pass' : 'fail') + '">'
                                + 'Your score: <strong>' + d.score + ' / ' + d.total + '</strong>'
                                + (d.passed ? ' — Passed!' : ' — Not passed. Please try again.')
                                + '</div>';
                            if (d.passed) {
                                setTimeout(() => location.reload(), 1200);
                            }
                        } else {
                            res.innerHTML = '<div class="quiz-result fail">Error: ' + d.message + '</div>';
                        }
                    })
                    .catch(() => alert('Connection error!'));
            });
        }
    </script>
</body>
</html>