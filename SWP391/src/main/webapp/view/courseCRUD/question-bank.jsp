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
                                            <div class="question-card">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <div>
                                                        <span class="badge bg-secondary me-2">Q${st.index + 1}</span>
                                                        <span class="badge bg-info text-dark me-2">${q.points} pts</span>
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
                <form action="${pageContext.request.contextPath}/question-bank-action" method="POST">
                    <input type="hidden" name="action" value="add_group">
                    <input type="hidden" name="courseId" value="${course.id}">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fas fa-folder-plus me-2"></i>New Question Group</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Group Name / Tag</label>
                            <input type="text" name="name" class="form-control" required
                                   placeholder="e.g. Chapter 1, Hard Questions, Midterm Pool">
                            <div class="form-text">This name will be used when assigning quiz lessons.</div>
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
                <form action="${pageContext.request.contextPath}/question-bank-action" method="POST">
                    <input type="hidden" name="action" value="add_question">
                    <input type="hidden" name="courseId" value="${course.id}">
                    <input type="hidden" name="groupId" value="${activeGroupId}">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fas fa-plus-circle me-2"></i>Add New Question</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Question Text <span class="text-danger">*</span></label>
                            <textarea name="questionText" class="form-control" rows="3" required
                                      placeholder="Enter your question here..."></textarea>
                        </div>
                        <div class="mb-4 w-25">
                            <label class="form-label fw-bold">Points</label>
                            <input type="number" name="points" class="form-control" value="1" min="1" required>
                        </div>
                        <h6 class="fw-bold border-bottom pb-2">
                            <i class="fas fa-list me-1 text-success"></i> Answer Options
                        </h6>
                        <div class="alert alert-info py-2 small mb-3">
                            <i class="fas fa-info-circle me-1"></i>
                            Select the radio button (&#9679;) next to the <strong>correct answer</strong>. Leave unused fields blank.
                        </div>
                        <c:forEach begin="0" end="3" var="i">
                            <div class="input-group mb-2">
                                <div class="input-group-text bg-white">
                                    <input class="form-check-input mt-0" type="radio" name="correctAnswer" value="${i}"
                                           <c:if test="${i == 0}">checked</c:if>>
                                </div>
                                <input type="text" name="answers" class="form-control"
                                       placeholder="Answer option ${i + 1}">
                            </div>
                        </c:forEach>
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
</body>
</html>
