<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Student Quiz Scores & Analytics - Teacher Center | OCMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        .site-header svg {
            width: 20px !important;
            height: 20px !important;
            max-width: 20px !important;
            max-height: 20px !important;
            display: inline-block !important;
        }
        .site-header__search-btn svg { width: 17px !important; height: 17px !important; }
        .site-header__icon-btn svg { width: 18px !important; height: 18px !important; }

        body {
            background-color: #f8fafc;
            color: #1e293b;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .page-header {
            background: #fff;
            border-bottom: 1px solid #e2e8f0;
            padding: 24px 0;
            margin-bottom: 30px;
        }

        .stat-card {
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
        }

        .stat-icon.blue { background: #eff6ff; color: #2563eb; }
        .stat-icon.green { background: #f0fdf4; color: #16a34a; }
        .stat-icon.amber { background: #fffbeb; color: #d97706; }
        .stat-icon.purple { background: #faf5ff; color: #9333ea; }

        .stat-value {
            font-size: 1.5rem;
            font-weight: 700;
            line-height: 1.2;
            color: #0f172a;
        }

        .stat-label {
            font-size: 0.85rem;
            color: #64748b;
            margin-bottom: 0;
        }

        .result-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            padding: 24px;
            margin-bottom: 24px;
        }

        .status-badge {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 5px 12px;
            border-radius: 20px;
            display: inline-block;
        }

        .status-passed {
            background: #dcfce7;
            color: #15803d;
        }

        .status-failed {
            background: #fee2e2;
            color: #b91c1c;
        }

        .filter-box {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            padding: 20px;
            margin-bottom: 24px;
        }

        .quiz-item-row {
            transition: all 0.2s ease;
        }

        .quiz-item-row:hover {
            background-color: #f1f5f9;
        }

        .answer-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 500;
            margin-top: 4px;
        }

        .answer-correct {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .answer-wrong {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <!-- Page Header -->
    <div class="page-header">
        <div class="container-fluid px-5">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h2 class="fw-bold mb-1 text-dark">
                        <i class="fas fa-chart-line text-primary me-2"></i> 
                        <c:choose>
                            <c:when test="${not empty quizInfo}">
                                Điểm Bài Quiz: ${quizInfo.lesson_title}
                            </c:when>
                            <c:otherwise>
                                Quản Lý & Xem Điểm Quiz Của Học Sinh
                            </c:otherwise>
                        </c:choose>
                    </h2>
                    <p class="text-muted mb-0">
                        <c:choose>
                            <c:when test="${not empty quizInfo}">
                                Khóa học: <strong>${quizInfo.course_name}</strong> | Điểm qua: <strong>${quizInfo.passing_score}%</strong>
                            </c:when>
                            <c:otherwise>
                                Chọn khóa học và bài kiểm tra để theo dõi điểm số và bài làm chi tiết của từng học sinh.
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <c:if test="${not empty quizInfo}">
                        <a href="${pageContext.request.contextPath}/quiz-results" class="btn btn-outline-secondary">
                            <i class="fas fa-list me-1"></i> Danh Sách Tất Cả Quiz
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/dashboard-quiz" class="btn btn-outline-primary">
                        <i class="fas fa-layer-group me-1"></i> Quiz Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid px-5 pb-5">

        <!-- OVERVIEW MODE: List of all Teacher's Quizzes to Select From -->
        <c:if test="${isOverview == true || empty quizInfo}">
            
            <!-- Filters Bar -->
            <div class="filter-box shadow-sm">
                <form action="${pageContext.request.contextPath}/quiz-results" method="get" class="row g-3 align-items-center">
                    <div class="col-md-5">
                        <label class="form-label fw-bold text-secondary mb-1">Lọc theo Khóa học:</label>
                        <select name="courseId" class="form-select" onchange="this.form.submit()">
                            <option value="">-- Tất cả các khóa học của tôi --</option>
                            <c:forEach var="c" items="${courses}">
                                <option value="${c.id}" ${selectedCourseId == c.id ? 'selected' : ''}>${c.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-5">
                        <label class="form-label fw-bold text-secondary mb-1">Tìm kiếm bài Quiz:</label>
                        <div class="input-group">
                            <input type="text" name="search" class="form-control" placeholder="Nhập tên bài quiz..." value="${fn:escapeXml(searchKeyword)}">
                            <button class="btn btn-primary" type="submit"><i class="fas fa-search"></i> Tìm</button>
                        </div>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <a href="${pageContext.request.contextPath}/quiz-results" class="btn btn-outline-secondary w-100 mt-4">
                            <i class="fas fa-redo me-1"></i> Đặt lại
                        </a>
                    </div>
                </form>
            </div>

            <!-- Quizzes List Table -->
            <div class="result-card shadow-sm">
                <h5 class="fw-bold mb-4 text-dark">
                    <i class="fas fa-clipboard-list text-primary me-2"></i> Danh Sách Bài Kiểm Tra (${fn:length(teacherQuizzes)})
                </h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th style="width: 30%;">Tên Bài Quiz</th>
                                <th style="width: 25%;">Thuộc Khóa Học</th>
                                <th class="text-center">Thời Gian</th>
                                <th class="text-center">Điểm Đỗ</th>
                                <th class="text-center">Số Câu Hỏi</th>
                                <th class="text-center">Số Bài Đã Nộp</th>
                                <th class="text-end">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="q" items="${teacherQuizzes}">
                                <tr class="quiz-item-row">
                                    <td>
                                        <span class="fw-bold text-dark fs-6">${q.lesson_title}</span>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-secondary border px-2 py-1">${q.course_name}</span>
                                    </td>
                                    <td class="text-center">${q.duration_minutes} phút</td>
                                    <td class="text-center"><span class="badge bg-info text-dark">${q.passing_score}%</span></td>
                                    <td class="text-center"><span class="badge bg-secondary">${q.question_count} câu</span></td>
                                    <td class="text-center">
                                        <span class="fw-bold text-primary fs-6">${q.attempts_count}</span> lượt làm
                                    </td>
                                    <td class="text-end">
                                        <a href="${pageContext.request.contextPath}/quiz-results?quizId=${q.quiz_id}" class="btn btn-sm btn-primary">
                                            <i class="fas fa-eye me-1"></i> Xem Điểm Học Sinh
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty teacherQuizzes}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="fas fa-inbox fa-3x mb-3 text-secondary opacity-50"></i>
                                        <h5>Không tìm thấy bài Quiz nào</h5>
                                        <p class="small text-muted">Bạn chưa tạo bài quiz nào hoặc không có bài quiz nào phù hợp với bộ lọc.</p>
                                        <a href="${pageContext.request.contextPath}/quiz-builder" class="btn btn-sm btn-primary mt-2">
                                            <i class="fas fa-plus me-1"></i> Tạo Bài Quiz Mới
                                        </a>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </c:if>

        <!-- SPECIFIC QUIZ RESULTS MODE: When a quiz is selected -->
        <c:if test="${not empty quizInfo}">

            <!-- Summary KPI Statistics Cards -->
            <div class="row g-4 mb-4">
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card">
                        <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                        <div>
                            <div class="stat-value">${totalAttempts}</div>
                            <div class="stat-label">Tổng Số Lượt Làm Bài</div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card green">
                        <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                        <div>
                            <div class="stat-value">${passedCount}</div>
                            <div class="stat-label">Học Sinh Đạt (Passed)</div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card amber">
                        <div class="stat-icon amber"><i class="fas fa-percentage"></i></div>
                        <div>
                            <div class="stat-value">${passRate}%</div>
                            <div class="stat-label">Tỷ Lệ Đạt (Pass Rate)</div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card purple">
                        <div class="stat-icon purple"><i class="fas fa-star"></i></div>
                        <div>
                            <div class="stat-value">${avgScore}%</div>
                            <div class="stat-label">Điểm Số Trung Bình</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Results Layout (Attempts List & Answer Detail) -->
            <div class="row g-4">
                <!-- Left Column: Student Submissions Table -->
                <div class="col-lg-6">
                    <div class="result-card shadow-sm h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0 text-dark">
                                <i class="fas fa-user-graduate text-primary me-2"></i> Danh Sách Bài Nộp (${fn:length(attempts)})
                            </h5>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Tên Học Sinh</th>
                                        <th>Thời Gian Nộp</th>
                                        <th class="text-center">Điểm</th>
                                        <th class="text-center">Kết Quả</th>
                                        <th class="text-end">Chi Tiết</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="a" items="${attempts}">
                                        <tr class="${selectedAttemptId == a.id ? 'table-primary' : ''}">
                                            <td class="fw-bold text-dark">
                                                <i class="fas fa-user-circle text-muted me-1"></i> ${a.student_name}
                                            </td>
                                            <td class="small text-muted">
                                                <fmt:formatDate value="${a.end_time}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td class="text-center fw-bold fs-6 ${a.passed ? 'text-success' : 'text-danger'}">
                                                ${a.score}%
                                            </td>
                                            <td class="text-center">
                                                <span class="status-badge ${a.passed ? 'status-passed' : 'status-failed'}">
                                                    <i class="fas fa-${a.passed ? 'check' : 'times'} me-1"></i>
                                                    ${a.passed ? 'ĐẠT' : 'KHÔNG ĐẠT'}
                                                </span>
                                            </td>
                                            <td class="text-end">
                                                <a href="${pageContext.request.contextPath}/quiz-results?quizId=${quizInfo.id}&attemptId=${a.id}" class="btn btn-sm ${selectedAttemptId == a.id ? 'btn-primary' : 'btn-outline-primary'}">
                                                    <i class="fas fa-file-alt me-1"></i> Xem Bài Làm
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty attempts}">
                                        <tr>
                                            <td colspan="5" class="text-center py-5 text-muted">
                                                <i class="fas fa-user-clock fa-2x mb-2 text-secondary opacity-50"></i>
                                                <p class="mb-0">Chưa có học sinh nào nộp bài kiểm tra này.</p>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Question by Question Answer Review -->
                <div class="col-lg-6">
                    <div class="result-card shadow-sm h-100">
                        <c:choose>
                            <c:when test="${not empty selectedAttemptId}">
                                <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                                    <i class="fas fa-tasks text-success me-2"></i> Chi Tiết Bài Làm Của Học Sinh
                                </h5>
                                
                                <div class="accordion" id="answersAccordion">
                                    <c:forEach var="q" items="${questions}" varStatus="status">
                                        <c:set var="userAns" value="${q.userAns}" />
                                        <c:set var="isCorrect" value="${not empty userAns && userAns.is_correct == true}" />
                                        <div class="card border mb-3 shadow-none">
                                            <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                                                <span class="fw-bold text-dark">Câu ${status.count} (${q.points} điểm)</span>
                                                <c:choose>
                                                    <c:when test="${isCorrect}">
                                                        <span class="badge bg-success"><i class="fas fa-check"></i> Đúng</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-danger"><i class="fas fa-times"></i> Sai</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="card-body py-3">
                                                <p class="fw-bold text-dark mb-2">${fn:escapeXml(q.question_text)}</p>
                                                <div class="small">
                                                    <div>
                                                        <strong>Lựa chọn của học sinh:</strong>
                                                        <c:choose>
                                                            <c:when test="${not empty userAns && not empty userAns.selected_answer_text}">
                                                                <span class="answer-badge ${isCorrect ? 'answer-correct' : 'answer-wrong'}">
                                                                    ${fn:escapeXml(userAns.selected_answer_text)}
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">Chưa trả lời</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5 text-muted my-auto">
                                    <i class="fas fa-mouse-pointer fa-3x mb-3 text-secondary opacity-50"></i>
                                    <h5>Chưa chọn bài nộp</h5>
                                    <p class="small text-muted">Bấm vào nút <strong>"Xem Bài Làm"</strong> ở danh sách bên trái để xem chi tiết câu trả lời của từng học sinh.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

        </c:if>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
