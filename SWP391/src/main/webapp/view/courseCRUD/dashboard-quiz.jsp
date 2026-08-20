<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Question Bank Hub - Teacher Center</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .stat-card {
            background: #fff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .stat-icon {
            font-size: 2.5rem;
            color: #e9ecef;
        }
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: #2b3452;
        }
        .stat-label {
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #6c757d;
        }
    </style>
</head>
<body style="background-color: #f8f9fa;">
    <jsp:include page="/view/common/header.jsp" />

    <div class="container my-5">
        
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold dark-text"><i class="fas fa-layer-group text-primary me-2"></i> Question Bank Hub</h2>
                <p class="text-muted mb-0">Select a course to manage its question bank and tags.</p>
            </div>
            <a href="${pageContext.request.contextPath}/course-dashboard" class="btn btn-outline-primary px-4 rounded-pill">
                <i class="fas fa-arrow-left me-1"></i> Back to Courses
            </a>
        </div>

        <!-- KPI Cards Row -->
        <div class="row g-4 mb-5">
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="stat-label">Total Courses</div>
                        <div class="stat-value">${totalCourses}</div>
                    </div>
                    <i class="fas fa-book stat-icon text-primary"></i>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="stat-label">Total Question Tags</div>
                        <div class="stat-value">${totalGroups}</div>
                    </div>
                    <i class="fas fa-tags stat-icon text-success"></i>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="stat-label">Total Questions</div>
                        <div class="stat-value">${totalQuestions}</div>
                    </div>
                    <i class="fas fa-question-circle stat-icon text-warning"></i>
                </div>
            </div>
        </div>

        <!-- Course List -->
        <div class="card shadow-sm border-0">
            <div class="card-header bg-white border-0 pt-4 pb-0">
                <h5 class="fw-bold mb-0">Your Courses</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Course Name</th>
                                <th>Tags/Groups</th>
                                <th>Total Questions</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="stat" items="${courseBankStats}">
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="bg-light rounded d-flex align-items-center justify-content-center me-3" style="width: 48px; height: 48px;">
                                                <i class="fas fa-book text-muted"></i>
                                            </div>
                                            <span class="fw-bold">${stat.courseName}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-info text-dark rounded-pill px-3 py-2">${stat.groupCount} Tags</span>
                                    </td>
                                    <td>
                                        <span class="badge bg-secondary rounded-pill px-3 py-2">${stat.questionCount} Questions</span>
                                    </td>
                                    <td class="text-end">
                                        <a href="${pageContext.request.contextPath}/question-bank?courseId=${stat.courseId}" class="btn btn-primary btn-sm rounded-pill px-3">
                                            Manage Question Bank <i class="fas fa-arrow-right ms-1"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty courseBankStats}">
                                <tr>
                                    <td colspan="4" class="text-center py-5 text-muted">
                                        <i class="fas fa-folder-open mb-3" style="font-size: 3rem;"></i>
                                        <p>You haven't created any courses yet.</p>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
