<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Dashboard - Teacher Center</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root { --primary-dark: #1a1a2e; --accent-yellow: #ffc107; --bg-color: #f4f6f9; }
        body { background-color: var(--bg-color); font-family: 'Inter', 'Segoe UI', sans-serif; }
        .kpi-card { border-radius: 12px; border: none; box-shadow: 0 4px 10px rgba(0,0,0,0.05); transition: transform 0.2s; }
        .kpi-card:hover { transform: translateY(-5px); }
        .kpi-icon { font-size: 2.5rem; opacity: 0.8; }
        .kpi-title { font-size: 0.9rem; text-transform: uppercase; font-weight: 700; color: #6c757d; }
        .kpi-value { font-size: 2rem; font-weight: 800; color: var(--primary-dark); }
        
        .table-container { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .table thead th { background-color: #f8f9fa; color: var(--primary-dark); font-weight: 600; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 0.5px; border-bottom: 2px solid #dee2e6; }
        .table tbody td { vertical-align: middle; color: #495057; font-size: 0.95rem; }
        
        .status-badge { padding: 5px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
        .status-active { background-color: #d1e7dd; color: #0f5132; }
        .status-inactive { background-color: #f8d7da; color: #842029; }
        
        .btn-action { width: 32px; height: 32px; padding: 0; line-height: 32px; text-align: center; border-radius: 50%; margin: 0 2px; }
        .btn-create { background-color: var(--accent-yellow); color: var(--primary-dark); font-weight: bold; }
        .btn-create:hover { background-color: #e0a800; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container-fluid px-5 my-4">
        
        <c:if test="${not empty sessionScope.message}">
            <div class="alert alert-${sessionScope.messageType == 'error' ? 'danger' : 'success'} alert-dismissible fade show" role="alert">
                ${sessionScope.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="message" scope="session"/>
            <c:remove var="messageType" scope="session"/>
        </c:if>

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold" style="color: var(--primary-dark);"><i class="fas fa-tasks me-2"></i> Quiz Dashboard</h2>
                <p class="text-muted mb-0">Manage your course quizzes, questions, and view student performance.</p>
            </div>
            <a href="${pageContext.request.contextPath}/quiz-builder" class="btn btn-create px-4 rounded-pill shadow-sm">
                <i class="fas fa-plus-circle me-1"></i> Create Quick Quiz
            </a>
        </div>

        <!-- 1. KPI Cards Row -->
        <div class="row g-4 mb-5">
            <div class="col-xl-3 col-md-6">
                <div class="card kpi-card h-100">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <div class="kpi-title mb-1">Total Quizzes</div>
                            <div class="kpi-value">${summary.totalQuizzes}</div>
                        </div>
                        <div class="kpi-icon text-primary"><i class="fas fa-file-alt"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="card kpi-card h-100">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <div class="kpi-title mb-1">Total Questions</div>
                            <div class="kpi-value">${summary.totalQuestions}</div>
                        </div>
                        <div class="kpi-icon text-warning"><i class="fas fa-question-circle"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="card kpi-card h-100">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <div class="kpi-title mb-1">Student Attempts</div>
                            <div class="kpi-value">${summary.totalAttempts}</div>
                        </div>
                        <div class="kpi-icon text-success"><i class="fas fa-users"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="card kpi-card h-100">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <div class="kpi-title mb-1">Pass Rate</div>
                            <div class="kpi-value">${summary.passRate}%</div>
                        </div>
                        <div class="kpi-icon text-info"><i class="fas fa-chart-line"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Left Column: Filter & Quiz Data Table -->
            <div class="col-lg-8">
                <div class="table-container mb-4">
                    <!-- 2. Toolbar & Filter -->
                    <form action="dashboard-quiz" method="GET" class="row g-3 mb-4 align-items-end">
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-muted">Search Quiz</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white"><i class="fas fa-search text-muted"></i></span>
                                <input type="text" name="search" class="form-control" placeholder="Search by name..." value="${search}">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-bold text-muted">Filter by Course</label>
                            <select name="courseId" class="form-select">
                                <option value="-1">All Courses</option>
                                <c:forEach var="c" items="${courses}">
                                    <option value="${c.id}" ${c.id == selectedCourseId ? 'selected' : ''}>${c.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label small fw-bold text-muted">Status</label>
                            <select name="status" class="form-select">
                                <option value="-1">All</option>
                                <option value="active" ${selectedStatus == 'active' ? 'selected' : ''}>Active</option>
                                <option value="inactive" ${selectedStatus == 'inactive' ? 'selected' : ''}>Inactive</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-dark w-100">Filter</button>
                        </div>
                    </form>

                    <!-- 3. Quiz Data Table -->
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Quiz Name</th>
                                    <th>Course</th>
                                    <th class="text-center">Questions</th>
                                    <th class="text-center">Attempts</th>
                                    <th class="text-center">Avg Score</th>
                                    <th class="text-center">Status</th>
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="q" items="${quizzes}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold" style="color: var(--primary-dark);">${q.lesson_title}</div>
                                            <div class="small text-muted"><i class="far fa-clock"></i> ${q.duration_minutes} mins • ${q.total_points} pts</div>
                                        </td>
                                        <td><span class="badge bg-light text-dark border">${q.course_name}</span></td>
                                        <td class="text-center fw-bold text-primary">${q.question_count}</td>
                                        <td class="text-center fw-bold text-success">${q.attempt_count}</td>
                                        <td class="text-center fw-bold">${q.average_score}</td>
                                        <td class="text-center">
                                            <span class="status-badge ${q.status == 'active' ? 'status-active' : 'status-inactive'}">${q.status}</span>
                                        </td>
                                        <td class="text-end">
                                            <button class="btn btn-outline-primary btn-action" title="Manage Questions" onclick="alert('Manage Questions for Quiz ID: ${q.quiz_id}')">
                                                <i class="fas fa-list"></i>
                                            </button>
                                            <button class="btn btn-outline-success btn-action" title="View Results" onclick="alert('View Results for Quiz ID: ${q.quiz_id}')">
                                                <i class="fas fa-chart-bar"></i>
                                            </button>
                                            <button class="btn btn-outline-secondary btn-action" title="Edit Settings">
                                                <i class="fas fa-cog"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty quizzes}">
                                    <tr>
                                        <td colspan="7" class="text-center py-4 text-muted">
                                            <i class="fas fa-inbox fa-3x mb-3 text-light"></i>
                                            <p>No quizzes found matching your criteria.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Right Column: Recent Activity -->
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm" style="border-radius: 12px; overflow: hidden;">
                    <div class="card-header bg-dark text-white py-3 border-0">
                        <h5 class="card-title mb-0 fw-bold"><i class="fas fa-bolt text-warning me-2"></i> Recent Submissions</h5>
                    </div>
                    <div class="card-body p-0">
                        <ul class="list-group list-group-flush">
                            <c:forEach var="a" items="${recentAttempts}">
                                <li class="list-group-item p-3 border-bottom">
                                    <div class="d-flex w-100 justify-content-between align-items-center mb-1">
                                        <h6 class="mb-0 fw-bold text-dark">${a.student_name}</h6>
                                        <small class="text-muted"><fmt:formatDate value="${a.end_time}" pattern="dd/MM HH:mm"/></small>
                                    </div>
                                    <p class="mb-1 small text-muted text-truncate" style="max-width: 250px;"><i class="fas fa-file-alt text-primary me-1"></i> ${a.quiz_name}</p>
                                    <div class="d-flex justify-content-between align-items-center mt-2">
                                        <span class="badge ${a.passed ? 'bg-success' : 'bg-danger'}">${a.passed ? 'PASSED' : 'FAILED'}</span>
                                        <span class="fw-bold" style="color: var(--primary-dark);">Score: ${a.score}</span>
                                    </div>
                                </li>
                            </c:forEach>
                            <c:if test="${empty recentAttempts}">
                                <li class="list-group-item p-4 text-center text-muted">
                                    No recent quiz attempts found.
                                </li>
                            </c:if>
                        </ul>
                        <c:if test="${not empty recentAttempts}">
                            <div class="card-footer bg-white text-center py-2 border-0">
                                <a href="#" class="text-decoration-none small fw-bold text-primary">View All History <i class="fas fa-arrow-right ms-1"></i></a>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
