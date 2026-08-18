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
    <style>
        body { background-color: #f4f6f8; }
        .quiz-container {
            max-width: 800px;
            margin: 40px auto;
            background: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
        }
        .question-card {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 25px;
        }
        .question-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #2d2f31;
            margin-bottom: 15px;
        }
        .answer-option {
            background: #fff;
            border: 1px solid #d1d7dc;
            padding: 12px 15px;
            border-radius: 6px;
            margin-bottom: 10px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
        }
        .answer-option:hover {
            background: #f1f3f5;
        }
        .answer-option input[type="radio"] {
            margin-right: 15px;
            transform: scale(1.2);
            cursor: pointer;
        }
        .answer-label {
            margin-bottom: 0;
            cursor: pointer;
            width: 100%;
        }
        .quiz-header {
            border-bottom: 2px solid #f1f3f5;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .btn-submit {
            background-color: #5624d0;
            color: #fff;
            font-weight: 600;
            padding: 12px 30px;
            border-radius: 30px;
        }
        .btn-submit:hover {
            background-color: #401b9c;
            color: #fff;
        }
    </style>
</head>
<body>
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
                    
                    <div class="display-4 fw-bold mb-2" id="scoreDisplay" style="color: #5624d0;">
                        0%
                    </div>
                    <p class="text-muted fs-5 mb-4" id="correctCountDisplay">
                        You answered 0 / 0 questions correctly.
                    </p>
                    
                    <div class="d-flex justify-content-center gap-3">
                        <button type="button" class="btn btn-outline-secondary px-4 py-2" onclick="window.location.reload();">
                            <i class="fas fa-redo me-2"></i> Retry
                        </button>
                        <a href="${pageContext.request.contextPath}/course?id=${courseId}" class="btn btn-primary px-4 py-2" style="background-color: #5624d0; border-color: #5624d0;">
                            <i class="fas fa-arrow-left me-2"></i> Back to Course
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Timer Logic
        const durationMinutes = parseInt('${lesson.durationMinutes}');
        if (durationMinutes > 0) {
            let timeRemaining = durationMinutes * 60;
            const timerDisplay = document.getElementById('timerDisplay');
            
            const timerInterval = setInterval(function() {
                timeRemaining--;
                let m = Math.floor(timeRemaining / 60);
                let s = timeRemaining % 60;
                
                if (m < 10) m = "0" + m;
                if (s < 10) s = "0" + s;
                
                if (timerDisplay) timerDisplay.innerText = m + ":" + s;
                
                if (timeRemaining <= 0) {
                    clearInterval(timerInterval);
                    alert("Đã hết thời gian làm bài! Hệ thống sẽ tự động nộp bài.");
                    const btn = document.getElementById('btnSubmitQuiz');
                    if (btn) btn.disabled = true;
                    // Trigger form submit
                    document.getElementById('quizForm').dispatchEvent(new Event('submit'));
                }
            }, 1000);
        }

        document.getElementById('quizForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const btn = document.getElementById('btnSubmitQuiz');
            if (btn) {
                btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i> Submitting...';
                btn.disabled = true;
            }

            const formData = new FormData(this);
            const params = new URLSearchParams(formData);

            fetch('${pageContext.request.contextPath}/take-quiz', {
                method: 'POST',
                body: params,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(response => response.json())
            .then(data => {
                if(data.success) {
                    document.getElementById('scoreDisplay').innerText = data.scorePercent + '%';
                    document.getElementById('correctCountDisplay').innerText = 'You answered ' + data.totalCorrect + ' / ' + data.totalQuestions + ' questions correctly.';
                    
                    const iconDiv = document.getElementById('resultIcon');
                    if(data.passed) {
                        iconDiv.innerHTML = '<i class="fas fa-check-circle text-success" style="font-size: 80px;"></i>';
                        document.getElementById('resultTitle').innerText = "Congratulations! You Passed.";
                    } else {
                        iconDiv.innerHTML = '<i class="fas fa-times-circle text-danger" style="font-size: 80px;"></i>';
                        document.getElementById('resultTitle').innerText = "Keep Trying! You Failed.";
                    }
                    
                    var resultModal = new bootstrap.Modal(document.getElementById('resultModal'));
                    resultModal.show();
                } else {
                    alert('Error submitting quiz: ' + data.message);
                    if (btn) {
                        btn.innerHTML = '<i class="fas fa-paper-plane me-2"></i> Submit Quiz';
                        btn.disabled = false;
                    }
                }
            })
            .catch(err => {
                console.error(err);
                alert('An error occurred. Please try again.');
                if (btn) {
                    btn.innerHTML = '<i class="fas fa-paper-plane me-2"></i> Submit Quiz';
                    btn.disabled = false;
                }
            });
        });
    </script>
</body>
</html>
