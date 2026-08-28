<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Builder - OCMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_crud/quiz-builder.css">
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container my-4 builder-container">
        <h2 class="fw-bold mb-1 dark-text"><i class="fas fa-magic me-2"></i> Quiz Builder</h2>
        <p class="text-muted mb-4">Create dynamic, interactive quizzes to evaluate your students.</p>

        <form id="quizForm" action="quiz-builder" method="POST">
            <input type="hidden" name="quizId" value="${quizInfo != null ? quizInfo['id'] : ''}">
            
            <!-- Part 1: General Settings -->
            <div class="section-card">
                <div class="section-title"><i class="fas fa-cog me-2"></i> 1. General Settings</div>
                
                <!-- Hidden Course & Section removed for Quiz Bank mode -->
                
                <div class="mb-3">
                    <label class="form-label fw-bold small">Quiz Title <span class="text-danger">*</span></label>
                    <input type="text" name="title" class="form-control" value="${lesson != null ? lesson.title : ''}" placeholder="e.g. Midterm Java Examination" required>
                </div>
                
                <div class="mb-3">
                    <label class="form-label fw-bold small">Description / Instructions</label>
                    <textarea name="description" class="form-control" rows="3" placeholder="Provide rules or instructions...">${lesson != null ? lesson.description : ''}</textarea>
                </div>
                
                <div class="row mb-3">
                    <div class="col-md-4">
                        <label class="form-label">Duration (Minutes)</label>
                        <input type="number" class="form-control" name="durationMinutes" min="1" value="${lesson != null ? lesson.durationMinutes : '15'}" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Max Retakes</label>
                        <input type="number" class="form-control" name="maxRetakes" min="-1" value="${quizInfo != null ? quizInfo['max_retakes'] : '-1'}" placeholder="-1 for unlimited" required>
                        <small class="text-muted helper-note">Set to -1 for unlimited.</small>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Passing Score (%)</label>
                        <input type="number" class="form-control" name="passingScore" min="1" max="100" value="${quizInfo != null ? quizInfo['passing_score'] : '80'}" required>
                    </div>
                </div>
            </div>

            <!-- Part 2: Question Builder -->
            <div class="section-card">
                <div class="section-title d-flex justify-content-between align-items-center">
                    <span><i class="fas fa-list-ul me-2"></i> 2. Questions</span>
                    <button type="button" class="btn btn-sm btn-outline-primary" onclick="addQuestion()">
                        <i class="fas fa-plus"></i> Add Question
                    </button>
                </div>
                
                <div id="questionsContainer">
                    <!-- Questions will be dynamically added here -->
                </div>
                
                <div class="text-center mt-4">
                    <button type="button" class="btn btn-add-q px-4 py-2" onclick="addQuestion()">
                        <i class="fas fa-plus-circle me-1"></i> Add Another Question
                    </button>
                </div>
            </div>
            
            <!-- Hidden inputs to store action -->
            <input type="hidden" name="action" id="formAction" value="draft">
        </form>
    </div>

    <!-- Part 3: Sticky Footer Summary -->
    <div class="sticky-footer">
        <div class="container builder-container">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h5 class="mb-0 fw-bold dark-text">Summary</h5>
                    <div class="text-muted small">
                        <span id="sumQuestions" class="fw-bold text-dark">0</span> Questions • 
                        <span id="sumPoints" class="fw-bold text-dark">0</span> Total Points
                    </div>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/dashboard-quiz" class="btn btn-light border me-2">Cancel</a>
                    <button type="button" class="btn btn-outline-secondary me-2" onclick="submitForm('draft')">
                        <i class="fas fa-save me-1"></i> Save Draft
                    </button>
                    <button type="button" class="btn btn-dark" onclick="submitForm('publish')">
                        <i class="fas fa-paper-plane me-1"></i> Publish Quiz
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteQuestionModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
          <div class="modal-header border-bottom-0">
            <h5 class="modal-title fw-bold"><i class="fas fa-exclamation-triangle text-warning me-2"></i> Confirm Deletion</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body py-0">
            Are you sure you want to delete this question? This action cannot be undone.
          </div>
          <div class="modal-footer border-top-0">
            <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Cancel</button>
            <button type="button" class="btn btn-danger rounded-pill px-4" id="confirmDeleteBtn">Delete Question</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Data injected from backend
        const courseSections = ${courseSectionsJson};
        
        let questionCounter = 0;
        
        // Populate sections based on course (auto-trigger for hidden selects)
        // Initial calculations
        updateSummary();
        
        function addQuestion() {
            questionCounter++;
            var qId = questionCounter;
            
            var html = '<div class="question-card" id="q_card_' + qId + '">' +
                '<input type="hidden" name="qIds" value="' + qId + '">' +
                '<div class="question-header">' +
                    '<div class="question-number"><i class="fas fa-grip-vertical drag-handle"></i> Question ' + qId + '</div>' +
                    '<div>' +
                        '<div class="input-group input-group-sm d-inline-flex points-input-group">' +
                            '<span class="input-group-text bg-light">Points</span>' +
                            '<input type="number" name="q_points_' + qId + '" class="form-control text-center point-input" value="1" min="1" onchange="updateSummary()" required>' +
                        '</div>' +
                        '<button type="button" class="btn btn-sm btn-outline-danger ms-2" onclick="removeQuestion(' + qId + ')"><i class="fas fa-trash"></i></button>' +
                    '</div>' +
                '</div>' +
                '<textarea name="q_text_' + qId + '" class="form-control mb-3" rows="2" placeholder="Type your question here..." required></textarea>' +
                '<div class="answers-container mb-2" id="answers_container_' + qId + '">' +
                    generateAnswerRow(qId, 1, true) +
                    generateAnswerRow(qId, 2, false) +
                    generateAnswerRow(qId, 3, false) +
                    generateAnswerRow(qId, 4, false) +
                '</div>' +
                '<button type="button" class="btn btn-sm btn-link text-decoration-none" onclick="addAnswer(' + qId + ')">' +
                    '<i class="fas fa-plus"></i> Add Answer Option' +
                '</button>' +
            '</div>';
            
            document.getElementById('questionsContainer').insertAdjacentHTML('beforeend', html);
            updateSummary();
        }
        
        function generateAnswerRow(qId, aId, isChecked) {
            var checkedAttr = isChecked ? 'checked' : '';
            var correctClass = isChecked ? 'correct' : '';
            return '<div class="answer-row ' + correctClass + '" id="a_row_' + qId + '_' + aId + '">' +
                '<input type="hidden" name="aIds_' + qId + '" value="' + aId + '">' +
                '<input class="form-check-input mt-0" type="radio" name="a_correct_' + qId + '" value="' + aId + '" ' + checkedAttr + ' onchange="highlightCorrect(' + qId + ', ' + aId + ')" required>' +
                '<input type="text" name="a_text_' + qId + '_' + aId + '" class="answer-text" placeholder="Answer option..." required>' +
                '<button type="button" class="btn btn-sm text-danger" onclick="removeAnswer(' + qId + ', ' + aId + ')"><i class="fas fa-times"></i></button>' +
            '</div>';
        }
        
        function addAnswer(qId) {
            var container = document.getElementById('answers_container_' + qId);
            var aId = container.children.length + 1 + Math.floor(Math.random() * 1000);
            container.insertAdjacentHTML('beforeend', generateAnswerRow(qId, aId, false));
        }
        
        let questionToDelete = null;
        function removeQuestion(qId) {
            questionToDelete = qId;
            var deleteModal = new bootstrap.Modal(document.getElementById('deleteQuestionModal'));
            deleteModal.show();
        }

        document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
            if (questionToDelete) {
                document.getElementById('q_card_' + questionToDelete).remove();
                updateSummary();
                questionToDelete = null;
                var deleteModal = bootstrap.Modal.getInstance(document.getElementById('deleteQuestionModal'));
                deleteModal.hide();
            }
        });
        
        function removeAnswer(qId, aId) {
            const row = document.getElementById(`a_row_\${qId}_\${aId}`);
            // Don't allow deleting if it's the checked one or if there's only 2 left
            const container = document.getElementById(`answers_container_\${qId}`);
            if(container.children.length <= 2) {
                alert("A question must have at least 2 answers.");
                return;
            }
            if(row.querySelector('input[type="radio"]').checked) {
                alert("Cannot delete the correct answer. Select another correct answer first.");
                return;
            }
            row.remove();
        }
        
        function highlightCorrect(qId, aId) {
            // Remove correct class from all rows in this question
            const container = document.getElementById(`answers_container_\${qId}`);
            Array.from(container.children).forEach(row => row.classList.remove('correct'));
            // Add to selected
            document.getElementById(`a_row_\${qId}_\${aId}`).classList.add('correct');
        }
        
        function updateSummary() {
            const qCards = document.querySelectorAll('.question-card');
            document.getElementById('sumQuestions').innerText = qCards.length;
            
            let totalPoints = 0;
            document.querySelectorAll('.point-input').forEach(input => {
                totalPoints += parseInt(input.value) || 0;
            });
            document.getElementById('sumPoints').innerText = totalPoints;
        }
        
        function submitForm(action) {
            const form = document.getElementById('quizForm');
            
            // Basic Client Validation
            if(!form.checkValidity()) {
                form.reportValidity();
                return;
            }
            
            const qCards = document.querySelectorAll('.question-card');
            if(qCards.length === 0) {
                alert("Please add at least one question to the quiz.");
                return;
            }
            
            document.getElementById('formAction').value = action;
            form.submit();
        }
        
        // Init
        const isEdit = ${isEdit != null ? isEdit : false};
        
        if (isEdit) {
            const editQuestions = ${questionsJson != null ? questionsJson : '[]'};
            const editAnswers = ${answersJson != null ? answersJson : '{}'};
            
            editQuestions.forEach((q, qIndex) => {
                questionCounter++;
                const qId = questionCounter;
                
                let answersHtml = '';
                const qAnswers = editAnswers[q.id] || [];
                qAnswers.forEach((a, aIndex) => {
                    const aId = aIndex + 1;
                    const checkedAttr = a.is_correct ? 'checked' : '';
                    const correctClass = a.is_correct ? 'correct' : '';
                    
                    // Escape quotes for answer text
                    const safeAnswerText = a.answer_text ? a.answer_text.replace(/"/g, '&quot;') : '';
                    
                    answersHtml += '<div class="answer-row ' + correctClass + '" id="a_row_' + qId + '_' + aId + '">' +
                        '<input type="hidden" name="aIds_' + qId + '" value="' + aId + '">' +
                        '<input class="form-check-input mt-0" type="radio" name="a_correct_' + qId + '" value="' + aId + '" ' + checkedAttr + ' onchange="highlightCorrect(' + qId + ', ' + aId + ')" required>' +
                        '<input type="text" name="a_text_' + qId + '_' + aId + '" class="answer-text" value="' + safeAnswerText + '" placeholder="Answer option..." required>' +
                        '<button type="button" class="btn btn-sm text-danger" onclick="removeAnswer(' + qId + ', ' + aId + ')"><i class="fas fa-times"></i></button>' +
                    '</div>';
                });
                
                const safeQuestionText = q.question_text ? q.question_text.replace(/</g, '&lt;').replace(/>/g, '&gt;') : '';
                
                const html = '<div class="question-card" id="q_card_' + qId + '">' +
                    '<input type="hidden" name="qIds" value="' + qId + '">' +
                    '<div class="question-header">' +
                        '<div class="question-number"><i class="fas fa-grip-vertical drag-handle"></i> Question ' + qId + '</div>' +
                        '<div>' +
                            '<div class="input-group input-group-sm d-inline-flex points-input-group">' +
                                '<span class="input-group-text bg-light">Points</span>' +
                                '<input type="number" name="q_points_' + qId + '" class="form-control text-center point-input" value="' + (q.points || 1) + '" min="1" onchange="updateSummary()" required>' +
                            '</div>' +
                            '<button type="button" class="btn btn-sm btn-outline-danger ms-2" onclick="removeQuestion(' + qId + ')"><i class="fas fa-trash"></i></button>' +
                        '</div>' +
                    '</div>' +
                    '<textarea name="q_text_' + qId + '" class="form-control mb-3" rows="2" placeholder="Type your question here..." required>' + safeQuestionText + '</textarea>' +
                    '<div class="answers-container mb-2" id="answers_container_' + qId + '">' +
                        answersHtml +
                    '</div>' +
                    '<button type="button" class="btn btn-sm btn-link text-decoration-none" onclick="addAnswer(' + qId + ')">' +
                        '<i class="fas fa-plus"></i> Add Answer Option' +
                    '</button>' +
                '</div>';
                
                document.getElementById('questionsContainer').insertAdjacentHTML('beforeend', html);
            });
            updateSummary();
        } else {
            addQuestion();
        }
    </script>
</body>
</html>
