<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Question Bank - ${course.name}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .group-item { cursor: pointer; border-radius: 8px; padding: 10px 14px; margin-bottom: 6px; display: flex; align-items: center; justify-content: space-between; transition: background 0.15s; }
        .group-item:hover { background: #e9ecef; }
        .group-item.active { background: #dbeafe; border-left: 4px solid #0d6efd; font-weight: 600; }
        .question-card { background: #fff; border-radius: 10px; border: 1px solid #e9ecef; padding: 16px; margin-bottom: 14px; }
        .answer-option { padding: 6px 12px; border-radius: 20px; margin: 4px 4px 4px 0; font-size: 0.875rem; display: inline-flex; align-items: center; gap: 6px; }
        .answer-option.correct { background: #d1fae5; color: #065f46; }
        .answer-option.wrong { background: #f3f4f6; color: #6b7280; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container-fluid px-5 my-4">
        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <a href="${pageContext.request.contextPath}/lesson?courseId=${course.id}" class="text-decoration-none text-muted small">
                    <i class="fas fa-arrow-left me-1"></i> Back to Course Workspace
                </a>
                <h2 class="fw-bold mb-0 mt-1">
                    <i class="fas fa-layer-group text-primary me-2"></i>Question Bank: ${course.name}
                </h2>
            </div>
            <div class="d-flex align-items-center gap-3">
                <select class="form-select w-auto border-0 shadow-sm"
                        onchange="window.location.href='${pageContext.request.contextPath}/question-bank?courseId=' + this.value;">
                    <c:forEach var="tc" items="${teacherCourses}">
                        <option value="${tc.id}" <c:if test="${tc.id == course.id}">selected</c:if>>${tc.name}</option>
                    </c:forEach>
                </select>
                <button class="btn btn-primary px-4" data-bs-toggle="modal" data-bs-target="#addGroupModal">
                    <i class="fas fa-plus me-1"></i> New Group
                </button>
            </div>
        </div>

        <!-- Alert messages -->
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                <strong>Lỗi:</strong> <c:out value="${sessionScope.errorMsg}" />
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="errorMsg" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <c:out value="${sessionScope.successMsg}" />
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="successMsg" scope="session" />
        </c:if>

        <div class="row g-4">
            <!-- Left: Group List -->
            <div class="col-md-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-header bg-white border-0 pt-3 pb-0">
                        <h6 class="fw-bold text-muted text-uppercase mb-3" style="letter-spacing:1px; font-size: 0.75rem;">
                            <i class="fas fa-tags me-1"></i> Question Groups
                        </h6>
                    </div>
                    <div class="card-body pt-1">
                        <c:choose>
                            <c:when test="${empty groups}">
                                <div class="text-center text-muted py-4">
                                    <i class="fas fa-folder-open mb-2" style="font-size:2rem;"></i>
                                    <p class="small">No groups yet. Create one!</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="g" items="${groups}">
                                    <div class="group-item <c:if test="${g.id == activeGroupId}">active</c:if>"
                                         onclick="window.location.href='${pageContext.request.contextPath}/question-bank?courseId=${course.id}&groupId=${g.id}'">
                                        <span><i class="fas fa-folder me-2 text-warning"></i>${g.name}</span>
                                        <form action="${pageContext.request.contextPath}/question-bank-action" method="POST" class="d-inline"
                                              onsubmit="return confirm('Delete group and all its questions?');">
                                            <input type="hidden" name="action" value="delete_group">
                                            <input type="hidden" name="courseId" value="${course.id}">
                                            <input type="hidden" name="groupId" value="${g.id}">
                                            <button type="submit" class="btn btn-sm text-danger border-0 bg-transparent p-0">
                                                <i class="fas fa-trash-alt"></i>
                                            </button>
                                        </form>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Right: Questions Panel -->
            <div class="col-md-9">
                <c:choose>
                    <c:when test="${activeGroupId != null}">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                                <h5 class="mb-0 fw-bold">
                                    <i class="fas fa-list-ul me-2 text-primary"></i>
                                    Questions
                                    <c:if test="${not empty questions}">
                                        <span class="badge bg-primary ms-1">${fn:length(questions)}</span>
                                    </c:if>
                                </h5>
                                <button class="btn btn-success btn-sm px-3" data-bs-toggle="modal" data-bs-target="#addQuestionModal">
                                    <i class="fas fa-plus me-1"></i> Add Question
                                </button>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty questions}">
                                        <div class="text-center text-muted py-5">
                                            <i class="fas fa-question-circle mb-3" style="font-size:3rem;"></i>
                                            <p>No questions in this group. Add one to get started!</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="q" items="${questions}" varStatus="st">
                                            <c:set var="correctCount" value="0" />
                                            <c:forEach var="ans" items="${answersMap[q.id]}">
                                                <c:if test="${ans.is_correct}">
                                                    <c:set var="correctCount" value="${correctCount + 1}" />
                                                </c:if>
                                            </c:forEach>
                                            <div class="question-card">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <div class="d-flex align-items-center flex-wrap gap-2">
                                                        <span class="badge bg-secondary">Q${st.index + 1}</span>
                                                        <c:choose>
                                                            <c:when test="${correctCount > 1}">
                                                                <span class="badge bg-warning text-dark"><i class="fas fa-check-double me-1"></i>Multiple Choice</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-primary"><i class="fas fa-dot-circle me-1"></i>Single Choice</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <span class="badge bg-info text-dark">${q.points} pts</span>
                                                    </div>
                                                    <form action="${pageContext.request.contextPath}/question-bank-action" method="POST" class="d-inline"
                                                          onsubmit="return confirm('Delete this question?');">
                                                        <input type="hidden" name="action" value="delete_question">
                                                        <input type="hidden" name="courseId" value="${course.id}">
                                                        <input type="hidden" name="groupId" value="${activeGroupId}">
                                                        <input type="hidden" name="questionId" value="${q.id}">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                                <p class="fw-bold mt-2 mb-2">${q.questionText}</p>
                                                <div>
                                                    <c:forEach var="ans" items="${answersMap[q.id]}">
                                                        <span class="answer-option ${ans.is_correct ? 'correct' : 'wrong'}">
                                                            <c:choose>
                                                                <c:when test="${ans.is_correct}">
                                                                    <i class="fas fa-check-circle text-success"></i>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="fas fa-circle text-muted"></i>
                                                                </c:otherwise>
                                                            </c:choose>
                                                            ${ans.answer_text}
                                                        </span>
                                                    </c:forEach>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body d-flex flex-column justify-content-center align-items-center py-5 text-center">
                                <i class="fas fa-hand-point-left text-muted mb-3" style="font-size:4rem;"></i>
                                <h4 class="text-muted">Select a Question Group</h4>
                                <p class="text-muted">Or create a new one on the left to start adding questions.</p>
                                <button class="btn btn-primary mt-2" data-bs-toggle="modal" data-bs-target="#addGroupModal">
                                    <i class="fas fa-plus me-1"></i> Create First Group
                                </button>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Modal: Add Group -->
    <div class="modal fade" id="addGroupModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/question-bank-action" method="POST" onsubmit="return validateGroupForm(this)">
                    <input type="hidden" name="action" value="add_group">
                    <input type="hidden" name="courseId" value="${course.id}">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fas fa-folder-plus me-2 text-primary"></i>New Question Group</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Group Name / Tag <span class="text-danger">*</span></label>
                            <input type="text" name="name" id="groupNameInput" class="form-control" required
                                   placeholder="e.g. Chapter 1, Hard Questions, Midterm Pool">
                            <div class="form-text">Tên nhóm câu hỏi không được trùng lặp trong cùng khóa học.</div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Create Group</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal: Add Question -->
    <div class="modal fade" id="addQuestionModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/question-bank-action" method="POST" onsubmit="return validateQuestionForm(this)">
                    <input type="hidden" name="action" value="add_question">
                    <input type="hidden" name="courseId" value="${course.id}">
                    <input type="hidden" name="groupId" value="${activeGroupId}">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fas fa-plus-circle me-2 text-success"></i>Add New Question</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Question Text <span class="text-danger">*</span></label>
                            <textarea name="questionText" id="questionTextInput" class="form-control" rows="3" required
                                      placeholder="Enter your question here..."></textarea>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Question Type</label>
                                <select name="questionType" id="questionTypeSelect" class="form-select" onchange="toggleQuestionType(this.value)">
                                    <option value="single" selected>Single Choice (1 correct answer)</option>
                                    <option value="multiple">Multiple Choice (Multiple correct answers)</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Points</label>
                                <input type="number" name="points" class="form-control" value="1" min="1" required>
                            </div>
                        </div>
                        <h6 class="fw-bold border-bottom pb-2">
                            <i class="fas fa-list me-1 text-success"></i> Answer Options
                        </h6>
                        <div class="alert alert-info py-2 small mb-3" id="questionTypeInfo">
                            <i class="fas fa-info-circle me-1"></i>
                            Select the radio button (&#9679;) next to the <strong>correct answer</strong>. Leave unused fields blank.
                        </div>
                        <div id="answersContainer">
                            <c:forEach begin="0" end="3" var="i">
                                <div class="input-group mb-2">
                                    <div class="input-group-text bg-white">
                                        <input class="form-check-input mt-0 answer-check" type="radio" name="correctAnswers" value="${i}"
                                               <c:if test="${i == 0}">checked</c:if>>
                                    </div>
                                    <input type="text" name="answers" class="form-control answer-input"
                                           placeholder="Answer option ${i + 1}">
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success">Save Question</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Danh sách tên các group hiện có trong khóa học để check trùng
        const existingGroupNames = [
            <c:forEach var="g" items="${groups}" varStatus="loop">
                "${fn:escapeXml(g.name)}"<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        // Danh sách nội dung các câu hỏi hiện có trong group hiện tại để check trùng
        const existingQuestionTexts = [
            <c:forEach var="q" items="${questions}" varStatus="loop">
                "${fn:escapeXml(q.questionText)}"<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        function validateGroupForm(form) {
            const nameInput = form.querySelector('input[name="name"]');
            const nameVal = nameInput ? nameInput.value.trim() : '';
            if (!nameVal) {
                alert('Vui lòng nhập tên nhóm câu hỏi!');
                if (nameInput) nameInput.focus();
                return false;
            }

            // Check trùng tên group (không phân biệt hoa thường và khoảng trắng thừa)
            const isDuplicate = existingGroupNames.some(g => g.trim().toLowerCase() === nameVal.toLowerCase());
            if (isDuplicate) {
                alert('Tên nhóm câu hỏi "' + nameVal + '" đã tồn tại trong khóa học này! Vui lòng đặt tên khác.');
                if (nameInput) nameInput.focus();
                return false;
            }

            return true;
        }

        function toggleQuestionType(type) {
            const isMultiple = (type === 'multiple');
            const inputs = document.querySelectorAll('#answersContainer .answer-check');
            const infoText = document.getElementById('questionTypeInfo');
            
            inputs.forEach((input, idx) => {
                input.type = isMultiple ? 'checkbox' : 'radio';
                if (!isMultiple) {
                    const hasChecked = Array.from(inputs).some(i => i.checked);
                    if (!hasChecked && idx === 0) {
                        input.checked = true;
                    }
                }
            });

            if (infoText) {
                if (isMultiple) {
                    infoText.innerHTML = '<i class="fas fa-info-circle me-1"></i> Select checkbox (<i class="fas fa-check-square"></i>) next to <strong>all correct answers</strong>. Leave unused fields blank.';
                } else {
                    infoText.innerHTML = '<i class="fas fa-info-circle me-1"></i> Select the radio button (&#9679;) next to the <strong>correct answer</strong>. Leave unused fields blank.';
                }
            }
        }

        function validateQuestionForm(form) {
            const qTextInput = form.querySelector('textarea[name="questionText"]');
            const qText = qTextInput ? qTextInput.value.trim() : '';

            // 1. Kiểm tra nội dung câu hỏi trống
            if (!qText) {
                alert('Vui lòng nhập nội dung câu hỏi!');
                if (qTextInput) qTextInput.focus();
                return false;
            }

            // 2. Check trùng câu hỏi trong cùng 1 group
            const isDuplicateQuestion = existingQuestionTexts.some(q => q.trim().toLowerCase() === qText.toLowerCase());
            if (isDuplicateQuestion) {
                alert('Câu hỏi này đã tồn tại trong nhóm hiện tại! Vui lòng không tạo trùng câu hỏi.');
                if (qTextInput) qTextInput.focus();
                return false;
            }

            // 3. Kiểm tra các câu trả lời
            const answerInputs = form.querySelectorAll('.answer-input');
            const checks = form.querySelectorAll('.answer-check');
            const qType = form.querySelector('#questionTypeSelect').value;
            
            let filledAnswers = [];
            let checkedIndices = [];
            let duplicateAnswer = null;

            answerInputs.forEach((inp, idx) => {
                const val = inp.value ? inp.value.trim() : '';
                if (val !== '') {
                    // Check trùng câu trả lời trong cùng 1 câu hỏi
                    const lower = val.toLowerCase();
                    if (filledAnswers.some(a => a.toLowerCase() === lower)) {
                        duplicateAnswer = val;
                    }
                    filledAnswers.push(val);

                    if (checks[idx].checked) {
                        checkedIndices.push(idx);
                    }
                }
            });

            // 3.1 Check trùng lặp câu trả lời
            if (duplicateAnswer !== null) {
                alert('Các phương án trả lời không được trùng lặp nội dung ("' + duplicateAnswer + '")! Vui lòng chỉnh sửa lại.');
                return false;
            }

            // 3.2 Tối thiểu 2 phương án trả lời
            if (filledAnswers.length < 2) {
                alert('Vui lòng nhập ít nhất 2 phương án trả lời khác nhau!');
                return false;
            }

            // 3.3 Ít nhất 1 đáp án đúng
            if (checkedIndices.length === 0) {
                alert('Vui lòng chọn ít nhất một đáp án đúng trong số các phương án đã nhập!');
                return false;
            }

            // 3.4 Nếu là Single choice nhưng lại chọn nhiều hơn 1 đáp án đúng
            if (qType === 'single' && checkedIndices.length > 1) {
                alert('Câu hỏi dạng Single Choice chỉ được chọn đúng 1 đáp án!');
                return false;
            }

            return true;
        }
    </script>
</body>
</html>
