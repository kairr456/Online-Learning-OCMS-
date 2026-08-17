<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Results - Teacher Center</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root { --primary-dark: #1a1a2e; --accent-yellow: #ffc107; --bg-color: #f4f6f9; }
        body { background-color: var(--bg-color); font-family: 'Inter', 'Segoe UI', sans-serif; }
        
        .result-card { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); margin-bottom: 25px; }
        .table thead th { background-color: #f8f9fa; color: var(--primary-dark); font-weight: 600; text-transform: uppercase; font-size: 0.85rem; border-bottom: 2px solid #dee2e6; }
        .status-badge { padding: 5px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
        .status-passed { background-color: #d1e7dd; color: #0f5132; }
        .status-failed { background-color: #f8d7da; color: #842029; }
        
        .answer-box { border: 1px solid #dee2e6; border-radius: 8px; padding: 15px; margin-bottom: 15px; }
        .answer-correct { border-left: 5px solid #198754; background-color: #f8fff9; }
        .answer-incorrect { border-left: 5px solid #dc3545; background-color: #fffafa; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container-fluid px-5 my-4">
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <a href="${pageContext.request.contextPath}/dashboard-quiz" class="btn btn-sm btn-outline-secondary mb-2"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
                <h2 class="fw-bold" style="color: var(--primary-dark);"><i class="fas fa-chart-bar me-2"></i> Results: ${quizInfo.lesson_title}</h2>
                <p class="text-muted mb-0">Passing Score: ${quizInfo.passing_score}% | Max Retakes: ${quizInfo.max_retakes == -1 ? 'Unlimited' : quizInfo.max_retakes}</p>
            </div>
        </div>

        <div class="row">
            <!-- Left Column: Attempts Table -->
            <div class="col-lg-6">
                <div class="result-card">
                    <h5 class="fw-bold mb-4">Student Attempts</h5>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Student Name</th>
                                    <th>Date</th>
                                    <th class="text-center">Score</th>
                                    <th class="text-center">Status</th>
                                    <th class="text-end">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="a" items="${attempts}">
                                    <tr class="${selectedAttemptId == a.id ? 'table-active' : ''}">
                                        <td class="fw-bold">${a.student_name}</td>
                                        <td class="small text-muted"><fmt:formatDate value="${a.end_time}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td class="text-center fw-bold">${a.score}%</td>
                                        <td class="text-center">
                                            <span class="status-badge ${a.passed ? 'status-passed' : 'status-failed'}">${a.passed ? 'PASSED' : 'FAILED'}</span>
                                        </td>
                                        <td class="text-end">
                                            <a href="${pageContext.request.contextPath}/quiz-results?quizId=${quizInfo.id}&attemptId=${a.id}" class="btn btn-sm btn-outline-primary">
                                                View Details
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty attempts}">
                                    <tr>
                                        <td colspan="5" class="text-center py-4 text-muted">
                                            <i class="fas fa-info-circle fa-2x mb-2"></i>
                                            <p>No attempts recorded for this quiz yet.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Right Column: Detailed View -->
            <div class="col-lg-6">
                <c:choose>
                    <c:when test="${not empty selectedAttemptId}">
                        <div class="result-card" id="detailView">
                            <h5 class="fw-bold mb-4">Attempt Breakdown</h5>
                            <c:forEach var="q" items="${questions}" varStatus="status">
                                <c:set var="userAns" value="${userAnswersMap[q.id]}" />
                                
                                <div class="answer-box ${userAns != null && userAns.is_correct ? 'answer-correct' : 'answer-incorrect'}">
                                    <div class="fw-bold mb-2">Q${status.index + 1}: ${q.question_text}</div>
                                    <div class="small">
                                        <c:choose>
                                            <c:when test="${userAns == null}">
                                                <span class="text-danger"><i class="fas fa-times-circle"></i> Unanswered</span>
                                            </c:when>
                                            <c:when test="${userAns.is_correct}">
                                                <span class="text-success"><i class="fas fa-check-circle"></i> Answered Correctly</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-danger"><i class="fas fa-times-circle"></i> Answered Incorrectly</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="result-card d-flex align-items-center justify-content-center flex-column" style="min-height: 300px;">
                            <i class="fas fa-hand-pointer fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">Select an attempt to view details</h5>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        if(document.getElementById('detailView')) {
            document.getElementById('detailView').scrollIntoView({ behavior: 'smooth' });
        }
    </script>
</body>
</html>
