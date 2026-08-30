<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
                                        <c:if test="${not isEnrolled and lesson.id != firstLessonId}">
                                            <span class="les-lock ms-auto"><i class="fa-solid fa-lock text-muted" title="Locked - Purchase course to unlock"></i></span>
                                        </c:if>
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

                    <c:when test="${isLockedLesson}">
                        <h1 class="lesson-title">${currentLesson.title}</h1>
                        <div class="resource-box text-center p-5" style="background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); margin: 30px 0;">
                            <i class="fa-solid fa-lock text-warning mb-3" style="font-size: 48px;"></i>
                            <h3 class="fw-bold mb-2">Lesson Locked</h3>
                            <p class="text-muted mb-4">You must purchase this course to access this lesson and its quizzes.</p>
                            <a href="${pageContext.request.contextPath}/course?id=${course.id}" class="btn-purple px-4 py-2 text-decoration-none fw-bold" style="display: inline-block;">
                                <i class="fa-solid fa-cart-shopping me-2"></i> Enroll / Buy Course Now
                            </a>
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
                                <c:choose>
                                    <%-- QUIZ MODE: ATTEMPT OVERVIEW --%>
                                    <c:when test="${quizMode == 'attempt'}">
                                        <div class="resource-box text-center p-4 mb-4" style="background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
                                            <h3 class="fw-bold mb-3"><i class="fa-solid fa-file-signature text-primary me-2"></i> Quiz: ${currentLesson.title}</h3>
                                            
                                            <c:if test="${hasPassedQuiz}">
                                                <div class="quiz-result pass d-inline-block mb-3 px-3 py-2"><i class="fa-solid fa-circle-check"></i> Đã vượt qua bài Quiz (Điểm cao nhất: <fmt:formatNumber value="${bestQuizScore}" maxFractionDigits="0"/>%)</div>
                                            </c:if>

                                            <div class="mb-4 text-muted fs-6">
                                                <c:if test="${not empty lessonQuiz and lessonQuiz.time_limit_minutes != null and lessonQuiz.time_limit_minutes > 0}">
                                                    <span><i class="fa-solid fa-clock me-1 text-primary"></i> Thời gian: <strong>${lessonQuiz.time_limit_minutes} phút</strong></span>
                                                    <span class="mx-2">|</span>
                                                </c:if>
                                                <span><i class="fa-solid fa-clock-rotate-left me-1"></i> Số lượt đã làm: <strong>${userAttemptsCount}</strong></span>
                                                <span class="mx-2">|</span>
                                                <span><i class="fa-solid fa-rotate me-1"></i> Giới hạn: <strong>${maxRetakes == -1 ? 'Không giới hạn' : maxRetakes}</strong></span>
                                                <c:if test="${maxRetakes != -1}">
                                                    <span class="mx-2">|</span>
                                                    <span class="${isExhausted ? 'text-danger fw-bold' : 'text-success'}">
                                                        <i class="fa-solid fa-circle-info me-1"></i> ${isExhausted ? 'Hết lượt làm bài' : 'Còn '.concat(maxRetakes - userAttemptsCount).concat(' lượt')}
                                                    </span>
                                                </c:if>
                                            </div>

                                            <div class="d-flex justify-content-center gap-3">
                                                <c:choose>
                                                    <c:when test="${isExhausted}">
                                                        <button class="btn btn-secondary px-4 py-2 fw-bold" disabled>
                                                            <i class="fa-solid fa-lock me-2"></i> Quiz Đã Khóa (Hết Lượt)
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${currentLesson.id}&quizMode=take${fromQuery}" class="btn-purple px-4 py-2 text-decoration-none fw-bold">
                                                            <i class="fa-solid fa-play me-2"></i> ${userAttemptsCount > 0 ? 'Làm lại bài' : 'Bắt đầu làm bài'}
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <%-- Lịch sử làm bài --%>
                                        <c:if test="${not empty userAttemptsList}">
                                            <div class="mt-4 p-4" style="background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.06);">
                                                <div class="d-flex justify-content-between align-items-center mb-3">
                                                    <h5 class="fw-bold m-0 text-dark"><i class="fa-solid fa-history me-2 text-primary"></i> Lịch Sử Làm Bài</h5>
                                                    <c:if test="${not canViewHistory}">
                                                        <small class="text-muted"><i class="fa-solid fa-circle-info me-1 text-warning"></i> Chi tiết đáp án sẽ mở khi làm hết ${maxRetakes} lượt.</small>
                                                    </c:if>
                                                </div>

                                                <div class="table-responsive">
                                                    <table class="table table-hover align-middle mb-0">
                                                        <thead class="table-light">
                                                            <tr>
                                                                <th>Lần</th>
                                                                <th>Thời Gian Nộp</th>
                                                                <th class="text-center">% Điểm Làm Bài</th>
                                                                <th class="text-center">Trạng Thái</th>
                                                                <th class="text-end">Chi Tiết Đáp Án</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:forEach var="att" items="${userAttemptsList}" varStatus="status">
                                                                <tr>
                                                                    <td><strong>#${userAttemptsList.size() - status.index}</strong></td>
                                                                    <td><fmt:formatDate value="${att.end_time}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                                                    <td class="text-center fw-bold"><fmt:formatNumber value="${att.score}" maxFractionDigits="1"/>%</td>
                                                                    <td class="text-center">
                                                                        <c:choose>
                                                                            <c:when test="${att.passed}">
                                                                                <span class="badge bg-success px-3 py-2"><i class="fa-solid fa-check me-1"></i> Đạt</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge bg-danger px-3 py-2"><i class="fa-solid fa-xmark me-1"></i> Chưa Đạt</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td class="text-end">
                                                                        <c:choose>
                                                                            <c:when test="${canViewHistory}">
                                                                                <a href="${pageContext.request.contextPath}/quiz-result?lessonId=${currentLesson.id}&attemptId=${att.id}" class="btn btn-sm btn-outline-primary fw-bold">
                                                                                    <i class="fa-solid fa-eye me-1"></i> Xem bài làm
                                                                                </a>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge bg-light text-secondary border px-3 py-2" title="Chưa hết lượt làm bài">
                                                                                    <i class="fa-solid fa-lock me-1"></i> Bị khóa
                                                                                </span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </c:if>
                                    </c:when>

                                    <%-- QUIZ MODE: ACTIVE QUIZ QUESTIONS --%>
                                    <c:otherwise>
                                        <div class="card p-4 mb-4 border-0 shadow-sm" style="border-radius: 12px; background: #fff;">
                                            <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-3 pb-3 border-bottom">
                                                <div>
                                                    <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${currentLesson.id}&quizMode=attempt${fromQuery}" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                                                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại Lịch sử Quiz
                                                    </a>
                                                    <span class="badge bg-primary px-3 py-2 ms-2 rounded-pill fs-6">
                                                        <i class="fa-solid fa-flag me-1"></i> Lần làm bài #${currentAttemptNo}
                                                    </span>
                                                </div>

                                                <c:if test="${timeLimitSeconds != null and timeLimitSeconds > 0}">
                                                    <div class="bg-light border border-warning px-3 py-2 rounded-pill d-flex align-items-center" id="quizTimerBox">
                                                        <i class="fa-solid fa-stopwatch text-warning me-2 fs-5"></i>
                                                        <span class="fw-bold me-1 text-dark">Thời gian: </span>
                                                        <span id="timerCountdown" class="fw-bold text-danger fs-5" data-seconds="${timeLimitSeconds}">
                                                            ${timeLimitMinutes}:00
                                                        </span>
                                                    </div>
                                                    <script>
                                                    (function() {
                                                        var timerElem = document.getElementById('timerCountdown');
                                                        if (!timerElem) return;
                                                        var secondsLeft = parseInt(timerElem.getAttribute('data-seconds'), 10) || 0;
                                                        if (secondsLeft <= 0) return;

                                                        function formatTime(sec) {
                                                            var m = Math.floor(sec / 60);
                                                            var s = sec % 60;
                                                            return (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s);
                                                        }

                                                        timerElem.textContent = formatTime(secondsLeft);

                                                        if (window.quizTimerInterval) {
                                                            clearInterval(window.quizTimerInterval);
                                                        }

                                                        window.quizTimerInterval = setInterval(function() {
                                                            secondsLeft--;
                                                            if (secondsLeft >= 0) {
                                                                timerElem.textContent = formatTime(secondsLeft);
                                                                if (secondsLeft <= 10) {
                                                                    timerElem.style.color = '#dc3545';
                                                                    timerElem.style.fontWeight = 'bold';
                                                                }
                                                            }
                                                            if (secondsLeft < 0) {
                                                                clearInterval(window.quizTimerInterval);
                                                                window.quizTimerInterval = null;
                                                                alert('⏰ Hết thời gian làm bài! Hệ thống đang tự động nộp bài.');
                                                                var qForm = document.getElementById('quizForm');
                                                                if (qForm) {
                                                                    qForm.setAttribute('data-is-auto-submit', 'true');
                                                                    qForm.requestSubmit();
                                                                }
                                                            }
                                                        }, 1000);
                                                    })();
                                                    </script>
                                                </c:if>
                                            </div>

                                            <c:if test="${hasPassedQuiz}">
                                                <div class="quiz-result pass mb-3"><i class="fa-solid fa-circle-check me-2"></i> Bạn đã từng vượt qua bài Quiz này (Điểm cao nhất: <fmt:formatNumber value="${bestQuizScore}" maxFractionDigits="0"/>%)</div>
                                            </c:if>

                                            <c:if test="${not empty quizQuestions}">
                                                <form id="quizForm" data-next-url="${not empty nextLesson ? pageContext.request.contextPath.concat('/learning?courseId=').concat(course.id).concat('&lessonId=').concat(nextLesson.id).concat(fromQuery) : ''}"
                                                      data-history-url="${pageContext.request.contextPath}/quiz-result?lessonId=${currentLesson.id}"
                                                      data-attempt-url="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${currentLesson.id}&quizMode=attempt${fromQuery}">
                                                    <input type="hidden" name="quizId" value="${quizId}">
                                                    <input type="hidden" name="servedQuestionIds" value="${servedQuestionIds}">
                                                    
                                                    <c:forEach var="q" items="${quizQuestions}" varStatus="qs">
                                                        <div class="quiz-question mb-4 p-3 border rounded" style="background: #fafafa; border-radius: 10px;">
                                                            <div class="quiz-question-title d-flex justify-content-between align-items-center mb-3">
                                                                <span class="fw-bold text-dark fs-6">Câu ${qs.index + 1}: ${q.questionText}</span>
                                                                <span class="badge bg-light text-secondary border px-2 py-1">(${q.points != null ? q.points : 1} điểm)</span>
                                                            </div>
                                                            <c:set var="isMulti" value="${quizQuestionMultipleChoiceMap[q.id]}" />
                                                            <div class="d-flex flex-column gap-2">
                                                                <c:forEach var="a" items="${quizAnswers[q.id]}">
                                                                    <label class="quiz-answer p-3 rounded border d-flex align-items-center bg-white cursor-pointer" style="transition: all 0.2s; cursor: pointer;">
                                                                        <c:choose>
                                                                            <c:when test="${isMulti}">
                                                                                <input type="checkbox" name="answer_${q.id}" value="${a.id}" class="form-check-input me-3 mt-0">
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <input type="radio" name="answer_${q.id}" value="${a.id}" class="form-check-input me-3 mt-0">
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                        <span class="text-dark">${a.answerText}</span>
                                                                    </label>
                                                                </c:forEach>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                    
                                                    <div class="text-start mt-4">
                                                        <button type="submit" class="btn btn-purple btn-lg px-5 rounded-pill shadow-sm fw-bold">
                                                            <i class="fa-solid fa-paper-plane me-2"></i> Nộp Bài Quiz
                                                        </button>
                                                    </div>
                                                </form>
                                                <div id="quizResult" class="mt-4"></div>
                                            </c:if>
                                            <c:if test="${empty quizQuestions}">
                                                <div class="resource-box">Bài kiểm tra này chưa có câu hỏi nào.</div>
                                            </c:if>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
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
    <script src="${pageContext.request.contextPath}/assets/js/course_learning/learning.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
