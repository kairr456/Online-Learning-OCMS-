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
    <style>
        :root { --primary-dark: #1a1a2e; --accent-yellow: #ffc107; --bg-color: #f4f6f9; }
        body { background-color: var(--bg-color); font-family: 'Inter', 'Segoe UI', sans-serif; padding-bottom: 80px; }
        
        .section-card { background: #fff; border-radius: 12px; padding: 25px; margin-bottom: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); border: 1px solid #e9ecef; }
        .section-title { font-size: 1.1rem; font-weight: 700; color: var(--primary-dark); margin-bottom: 20px; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 2px solid #f1f3f5; padding-bottom: 10px; }
        
        .question-card { background: #fafbfc; border-radius: 10px; padding: 20px; margin-bottom: 20px; border: 1px solid #e1e4e8; position: relative; }
        .question-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .question-number { font-weight: 700; color: #495057; font-size: 1.1rem; }
        
        .answer-row { display: flex; align-items: center; margin-bottom: 10px; background: #fff; padding: 10px; border-radius: 6px; border: 1px solid #ced4da; }
        .answer-row.correct { border-color: #198754; background-color: #f8fff9; }
        .answer-text { flex-grow: 1; border: none; background: transparent; outline: none; margin-left: 10px; color: #000; }
        
        .sticky-footer { position: fixed; bottom: 0; left: 0; right: 0; background: #fff; box-shadow: 0 -4px 15px rgba(0,0,0,0.05); z-index: 1000; padding: 15px 0; border-top: 1px solid #e9ecef; }
        
        .btn-add-q { background-color: var(--accent-yellow); color: var(--primary-dark); font-weight: bold; border-radius: 8px; border: none; }
        .btn-add-q:hover { background-color: #e0a800; }
        
        .drag-handle { cursor: grab; color: #adb5bd; margin-right: 10px; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container my-4" style="max-width: 900px;">
        <h2 class="fw-bold mb-1" style="color: var(--primary-dark);"><i class="fas fa-magic me-2"></i> Quiz Builder</h2>
        <p class="text-muted mb-4">Create dynamic, interactive quizzes to evaluate your students.</p>

        <form id="quizForm" action="quiz-builder" method="POST">
            
            <!-- Part 1: General Settings -->
            <div class="section-card">
                <div class="section-title"><i class="fas fa-cog me-2"></i> 1. General Settings</div>
                
                <!-- Hidden Course & Section -->
                <div class="row mb-3" style="display: none;">
                    <div class="col-md-6">
                        <label class="form-label">Course</label>
                        <select class="form-select" id="courseSelect" name="courseId">
                            <c:forEach var="course" items="${courses}">
                                <option value="${course.id}">${course.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Section</label>
                        <select class="form-select" id="sectionSelect" name="sectionId">
                            <!-- Populated by JS -->
                        </select>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label class="form-label fw-bold small">Quiz Title <span class="text-danger">*</span></label>
                    <input type="text" name="title" class="form-control" placeholder="e.g. Midterm Java Examination" required>
                </div>
                
                <div class="mb-3">
                    <label class="form-label fw-bold small">Description / Instructions</label>
                    <textarea name="description" class="form-control" rows="3" placeholder="Provide rules or instructions..."></textarea>
                </div>
                
                <div class="row mb-3">
                    <div class="col-md-4">
                        <label class="form-label">Duration (Minutes)</label>
                        <input type="number" class="form-control" name="durationMinutes" min="1" value="15" required>
                    </div>
                    <div class="col-md-4" style="display: none;">
                        <label class="form-label">Display Order</label>
                        <input type="number" class="form-control" name="orderNumber" min="1" value="1">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Passing Score (%)</label>
                        <input type="number" class="form-control" name="passingScore" min="1" max="100" value="80" required>
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
        <div class="container" style="max-width: 900px;">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h5 class="mb-0 fw-bold" style="color: var(--primary-dark);">Summary</h5>
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

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Data injected from backend
        const courseSections = ${courseSectionsJson};
        
        let questionCounter = 0;
        
        // Populate sections based on course (auto-trigger for hidden selects)
        document.getElementById('courseSelect').addEventListener('change', function() {
            const courseId = this.value;
            const sectionSelect = document.getElementById('sectionSelect');
            sectionSelect.innerHTML = '';
            
            if (courseId && courseSections[courseId]) {
                courseSections[courseId].forEach(section => {
                    const option = document.createElement('option');
                    option.value = section.id;
                    option.textContent = section.title;
                    sectionSelect.appendChild(option);
                });
            }
        });
        
        // Trigger change initially to populate the hidden section dropdown with the first course
        if(document.getElementById('courseSelect').options.length > 0) {
            document.getElementById('courseSelect').dispatchEvent(new Event('change'));
        }
        
        function addQuestion() {
            questionCounter++;
            var qId = questionCounter;
            
            var html = '<div class="question-card" id="q_card_' + qId + '">' +
                '<input type="hidden" name="qIds" value="' + qId + '">' +
                '<div class="question-header">' +
                    '<div class="question-number"><i class="fas fa-grip-vertical drag-handle"></i> Question ' + qId + '</div>' +
                    '<div>' +
                        '<div class="input-group input-group-sm d-inline-flex" style="width: 120px;">' +
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
        
        function removeQuestion(qId) {
            if(confirm("Delete this question?")) {
                document.getElementById(`q_card_\${qId}`).remove();
                updateSummary();
            }
        }
        
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
        
        // Init with 1 question
        addQuestion();
    </script>
</body>
</html>
