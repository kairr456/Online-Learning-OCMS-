<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Quiz Result - ${lesson.title}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz-result.css">
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <main class="container">
        <div class="result-container">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>Kết quả: ${lesson.title}</h2>
                <a href="${pageContext.request.contextPath}/lesson-details?id=${lesson.id}" class="btn btn-outline-secondary">
                    <i class="fas fa-arrow-left me-2"></i> Quay lại bài học
                </a>
            </div>

            <!-- Attempt Selector -->
            <div class="mb-4">
                <label class="form-label fw-bold">Chọn lần làm bài:</label>
                <div class="dropdown">
                    <button class="btn btn-light border dropdown-toggle w-100 text-start d-flex justify-content-between align-items-center" type="button" id="attemptDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <span>
                            Lần ${selectedAttempt.attempt_number} 
                            - <fmt:formatDate value="${selectedAttempt.end_time}" pattern="dd/MM/yyyy HH:mm" />
                            - <span class="${selectedAttempt.passed ? 'text-success' : 'text-danger'} fw-bold">
                                ${selectedAttempt.passed ? 'ĐẠT' : 'CHƯA ĐẠT'}
                              </span>
                        </span>
                    </button>
                    <ul class="dropdown-menu w-100" aria-labelledby="attemptDropdown">
                        <c:forEach var="att" items="${userAttempts}">
                            <li>
                                <a class="dropdown-item ${att.id == selectedAttempt.id ? 'active' : ''}" 
                                   href="?lessonId=${lesson.id}&attemptId=${att.id}">
                                    Lần ${att.attempt_number} 
                                    - <fmt:formatDate value="${att.end_time}" pattern="dd/MM/yyyy HH:mm" />
                                    - <span class="${att.passed ? 'text-success' : 'text-danger'} fw-bold">
                                        ${att.passed ? 'ĐẠT' : 'CHƯA ĐẠT'}
                                      </span>
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </div>

            <!-- Summary -->
            <div class="summary-card text-center">
                <h1 class="display-4 fw-bold ${selectedAttempt.passed ? 'text-success' : 'text-danger'}">
                    ${selectedAttempt.score}%
                </h1>
                <p class="fs-5 mb-0">Điểm tối thiểu để qua: <strong>${lessonQuiz.passing_score}%</strong></p>
            </div>

            <!-- Review Questions -->
            <c:set var="maxRetakes" value="${lessonQuiz.max_retakes}" />
            
            <h4 class="mb-4">
                Chi tiết bài làm:
            </h4>
            
            <c:forEach var="question" items="${questions}" varStatus="status">
                <div class="question-card shadow-sm">
                    <div class="fw-bold mb-3">
                        ${status.index + 1}. ${question.question_text} <span class="text-muted small">(${question.points} điểm)</span>
                    </div>
                    
                    <c:forEach var="answer" items="${question.answers}">
                        <c:set var="isUserChoice" value="false" />
                        <c:forEach var="sId" items="${question.selectedAnswerIds}">
                            <c:if test="${sId == answer.id}">
                                <c:set var="isUserChoice" value="true" />
                            </c:if>
                        </c:forEach>
                        <c:choose>
                            <%-- User selected this answer, and it is CORRECT --%>
                            <c:when test="${isUserChoice && answer.is_correct}">
                                <div class="answer-option bg-light border-success fw-bold">
                                    <div class="answer-icon text-success"><i class="fas fa-check-circle"></i></div>
                                    <div class="ms-2">${answer.answer_text} <span class="badge bg-success ms-2">Lựa chọn của bạn (Đúng)</span></div>
                                </div>
                            </c:when>
                            
                            <%-- User selected this answer, and it is INCORRECT --%>
                            <c:when test="${isUserChoice && !answer.is_correct}">
                                <div class="answer-option bg-light border-danger fw-bold">
                                    <div class="answer-icon text-danger"><i class="fas fa-times-circle"></i></div>
                                    <div class="ms-2">${answer.answer_text} <span class="badge bg-danger ms-2">Lựa chọn của bạn (Sai)</span></div>
                                </div>
                            </c:when>
                            
                            <%-- User DID NOT select this answer, but it is the CORRECT answer --%>
                            <c:when test="${!isUserChoice && answer.is_correct}">
                                <div class="answer-option bg-light border-success">
                                    <div class="answer-icon text-success"><i class="fas fa-check"></i></div>
                                    <div class="ms-2">${answer.answer_text} <span class="badge bg-outline-success text-success border border-success ms-2">Đáp án đúng</span></div>
                                </div>
                            </c:when>
                            
                            <%-- User DID NOT select this answer, and it is INCORRECT (normal option) --%>
                            <c:otherwise>
                                <div class="answer-option">
                                    <div class="answer-icon text-muted"><i class="far fa-circle"></i></div>
                                    <div class="ms-2">${answer.answer_text}</div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
            </c:forEach>

        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
