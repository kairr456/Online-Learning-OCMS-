<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Take Quiz - ${lesson.title}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_learning.css">
</head>
<body class="take-quiz-page" data-ctx="${pageContext.request.contextPath}" data-duration-minutes="${lesson.durationMinutes}">
    <jsp:include page="/view/common/header.jsp" />

    <main class="container">
        <div class="quiz-container">
            <div class="quiz-header text-center">
                <h1 class="mb-3">${lesson.title}</h1>
                <p class="text-muted">${lesson.description}</p>
                <div class="d-flex justify-content-center gap-4 mt-3">
                    <span class="badge bg-info p-2"><i class="fas fa-bullseye me-1"></i> Passing Score: ${lessonQuiz.passing_score}%</span>
                    <span class="badge bg-secondary p-2">
                        <i class="far fa-clock me-1"></i> 
                        <c:choose>
                            <c:when test="${lesson.durationMinutes > 0}">
                                Time Remaining: <span id="timerDisplay">${lesson.durationMinutes}:00</span>
                            </c:when>
                            <c:otherwise>
                                Duration: No Limit
                            </c:otherwise>
                        </c:choose>
                    </span>
                    <c:choose>
                        <c:when test="${maxRetakes != null && maxRetakes != -1}">
                            <span class="badge bg-warning text-dark p-2"><i class="fas fa-redo me-1"></i> Attempt: ${userAttempts + 1} / ${maxRetakes}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-success p-2"><i class="fas fa-redo me-1"></i> Unlimited Attempts</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <form id="quizForm">
                <input type="hidden" name="quizId" value="${lessonQuiz.id}">
                <input type="hidden" name="lessonId" value="${lesson.id}">
                
                <c:forEach var="question" items="${questions}" varStatus="status">
                    <div class="question-card">
                        <div class="question-title">
                            ${status.index + 1}. ${question.question_text} <span class="text-muted small ms-2">(${question.points} pts)</span>
                        </div>
                        <div class="answers-list">
                            <c:forEach var="answer" items="${questionAnswersMap[question.id]}">
                                <label class="answer-option">
                                    <input type="radio" name="q_${question.id}" value="${answer.id}" required>
                                    <span class="answer-label">${answer.answer_text}</span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>
                </c:forEach>
                
                <div class="text-center mt-5">
                    <button type="submit" class="btn btn-submit border-0" id="btnSubmitQuiz">
                        <i class="fas fa-paper-plane me-2"></i> Submit Quiz
                    </button>
                </div>
            </form>
        </div>
    </main>

    <!-- Result Modal -->
    <div class="modal fade" id="resultModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content text-center p-4">
                <div class="modal-body">
                    <div id="resultIcon" class="mb-4">
                        <!-- Icon injected via JS -->
                    </div>
                    <h2 class="mb-3" id="resultTitle">Quiz Completed!</h2>
                    
                    <div class="display-4 fw-bold mb-2 score-display" id="scoreDisplay">
                        0%
                    </div>
                    <p class="text-muted fs-5 mb-4" id="correctCountDisplay">
                        You answered 0 / 0 questions correctly.
                    </p>
                    
                    <div class="d-flex justify-content-center gap-3">
                        <button type="button" class="btn btn-outline-secondary px-4 py-2" onclick="window.location.reload();">
                            <i class="fas fa-redo me-2"></i> Retry
                        </button>
                        <a href="${pageContext.request.contextPath}/quiz-result?lessonId=${lesson.id}" class="btn btn-info px-4 py-2 text-white" id="viewHistoryBtn">
                            <i class="fas fa-history me-2"></i> Xem lịch sử
                        </a>
                        <a href="${pageContext.request.contextPath}/course?id=${courseId}" class="btn btn-primary px-4 py-2 quiz-back-btn">
                            <i class="fas fa-arrow-left me-2"></i> Back to Course
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/course_learning/take-quiz.js"></script>
</body>
</html>
