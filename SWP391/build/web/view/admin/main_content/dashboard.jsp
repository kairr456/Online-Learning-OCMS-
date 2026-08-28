<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section class="dashboard horizon-dashboard">

    <!-- =========================
         HEADER / TOPBAR
    ========================== -->
    <div class="dashboard-topbar">
        <div>
            <h1 class="dashboard-page-title">Dashboard</h1>
            <p class="dashboard-page-subtitle">Tổng quan hệ thống và hoạt động kinh doanh</p>
        </div>

        <form method="get"
              action="${pageContext.request.contextPath}/admin/dashboard"
              class="dashboard-period">

            <label for="period"><i class="fa-regular fa-calendar"></i> Thời gian</label>

            <select id="period" name="period" onchange="this.form.submit()">
                <option value="today"   ${period == 'today'   ? 'selected' : ''}>Hôm nay</option>
                <option value="week"    ${period == 'week'    ? 'selected' : ''}>Tuần này</option>
                <option value="month"   ${period == 'month'   ? 'selected' : ''}>Tháng này</option>
                <option value="quarter" ${period == 'quarter' ? 'selected' : ''}>Quý này</option>
            </select>
        </form>
    </div>


    <!-- =========================
         KPI CARDS
    ========================== -->
    <div class="horizon-kpi-grid">

        <!-- Users -->
        <div class="horizon-kpi-card">
            <div class="horizon-kpi-icon horizon-icon-purple">
                <i class="fa-solid fa-users" style="color:#6366f1;"></i>
            </div>
            <div class="horizon-kpi-content">
                <span class="horizon-kpi-label">Total Users</span>
                <strong class="horizon-kpi-value">${totalUsers}</strong>
                <span class="horizon-kpi-description">Người dùng trong hệ thống</span>
            </div>
        </div>

        <!-- Courses -->
        <div class="horizon-kpi-card">
            <div class="horizon-kpi-icon horizon-icon-orange">
                <i class="fa-solid fa-book-open" style="color:#f97316;"></i>
            </div>
            <div class="horizon-kpi-content">
                <span class="horizon-kpi-label">Total Courses</span>
                <strong class="horizon-kpi-value">${totalCourses}</strong>
                <span class="horizon-kpi-description">Khóa học trên hệ thống</span>
            </div>
        </div>

        <!-- Registrations -->
        <div class="horizon-kpi-card">
            <div class="horizon-kpi-icon horizon-icon-green">
                <i class="fa-solid fa-file-signature" style="color:#10b981;"></i>
            </div>
            <div class="horizon-kpi-content">
                <span class="horizon-kpi-label">Registrations</span>
                <strong class="horizon-kpi-value">${totalRegistrations}</strong>
                <span class="horizon-kpi-description">Lượt đăng ký khóa học</span>
            </div>
        </div>

        <!-- Revenue -->
        <div class="horizon-kpi-card">
            <div class="horizon-kpi-icon horizon-icon-blue">
                <i class="fa-solid fa-circle-dollar-to-slot" style="color:#3b82f6;"></i>
            </div>
            <div class="horizon-kpi-content">
                <span class="horizon-kpi-label">Total Revenue</span>
                <strong class="horizon-kpi-value horizon-revenue">
                    <fmt:formatNumber value="${totalRevenue}" groupingUsed="true"/>₫
                </strong>
                <c:choose>
                    <c:when test="${revenueGrowthAvailable}">
                        <span class="horizon-kpi-growth ${revenueGrowth >= 0 ? 'growth-up' : 'growth-down'}">
                            <i class="fa-solid fa-arrow-${revenueGrowth >= 0 ? 'up' : 'down'}"></i>
                            <fmt:formatNumber value="${revenueGrowth}" maxFractionDigits="1"/>%
                            so với kỳ trước
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="horizon-kpi-description">Chưa có dữ liệu kỳ trước</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

    </div>


    <!-- =========================
         QUICK OVERVIEW
    ========================== -->
    <div class="horizon-section-title">
        <div>
            <h2>Quick Overview</h2>
            <p>Các hoạt động cần xử lý</p>
        </div>
    </div>

    <div class="horizon-operation-grid">

        <a href="${pageContext.request.contextPath}/admin/teacher-approvals"
           class="horizon-operation-card" style="text-decoration:none; color:inherit;">
            <div class="operation-icon">👨‍🏫</div>
            <div class="operation-content">
                <span>Teacher chờ duyệt</span>
                <strong>${pendingTeacherApprovals}</strong>
            </div>
            <div class="operation-arrow">→</div>
        </a>

        <a href="${pageContext.request.contextPath}/admin/courses?status=pending"
           class="horizon-operation-card" style="text-decoration:none; color:inherit;">
            <div class="operation-icon">📖</div>
            <div class="operation-content">
                <span>Course chờ duyệt</span>
                <strong>${pendingCourseApprovals}</strong>
            </div>
            <div class="operation-arrow">→</div>
        </a>

    </div>


    <!-- =========================
         MAIN ANALYTICS
    ========================== -->
    <div class="horizon-main-grid">

        <!-- Revenue & Registrations Line Chart -->
        <section class="horizon-panel horizon-chart-panel">
            <div class="horizon-panel-header">
                <div>
                    <h2>Revenue Overview</h2>
                    <p>Doanh thu và lượt đăng ký trong ${periodLabel}</p>
                </div>
                <div class="horizon-legend">
                    <span><i class="legend-revenue"></i> Revenue</span>
                    <span><i class="legend-registration"></i> Registrations</span>
                </div>
            </div>

            <div class="horizon-chart-wrapper">
                <!-- Chart.js will render here -->
                <canvas id="revenueLineChart"></canvas>

                <!-- Old SVG (hidden by CSS) — kept for data attribute -->
                <svg id="revenueRegistrationChart"
                     class="line-chart"
                     data-trend='[<c:forEach var="point" items="${monthlyTrend}" varStatus="loop">{"period":"${point.period}","registrations":${point.registrations},"revenue":${point.revenue}}${!loop.last ? "," : ""}</c:forEach>]'>
                </svg>
            </div>

            <div id="lineChartEmpty" class="horizon-empty" hidden>
                <i class="fa-regular fa-chart-bar" style="font-size:28px; margin-bottom:8px;"></i>
                Chưa có dữ liệu trong kỳ này.
            </div>
        </section>


        <!-- Learning Quality Doughnut Charts -->
        <section class="horizon-panel">
            <div class="horizon-panel-header">
                <div>
                    <h2>Learning Quality</h2>
                    <p>Hiệu quả học tập của học viên</p>
                </div>
            </div>

            <div class="horizon-donut-container">

                <!-- Quiz pass rate -->
                <div class="horizon-donut-item">
                    <div class="horizon-donut-canvas-wrap">
                        <canvas id="quizPassChart"
                                data-value="${quizPassRate}"></canvas>
                        <div class="horizon-donut-center-label" id="quizPassLabel">
                            ${quizPassRate}%
                        </div>
                    </div>
                    <strong>Quiz đạt</strong>
                    <small>Tỷ lệ học viên vượt qua quiz</small>
                </div>

                <!-- Lesson completion rate -->
                <div class="horizon-donut-item">
                    <div class="horizon-donut-canvas-wrap">
                        <canvas id="lessonCompChart"
                                data-value="${lessonCompletionRate}"></canvas>
                        <div class="horizon-donut-center-label" id="lessonCompLabel">
                            ${lessonCompletionRate}%
                        </div>
                    </div>
                    <strong>Hoàn thành bài</strong>
                    <small>Tỷ lệ hoàn thành khóa học</small>
                </div>

            </div>
        </section>

    </div>


    <!-- =========================
         SECONDARY ANALYTICS
    ========================== -->
    <div class="horizon-secondary-grid">

        <!-- Course Status Bar Chart -->
        <section class="horizon-panel">
            <div class="horizon-panel-header">
                <div>
                    <h2>Course Statistics</h2>
                    <p>Phân bổ khóa học theo trạng thái</p>
                </div>
            </div>

            <!-- Bar chart -->
            <div class="horizon-bar-chart-wrap">
                <canvas id="courseStatusChart"
                        data-labels='[<c:forEach var="entry" items="${courseCountsByStatus}" varStatus="loop">"${entry.key}"${!loop.last ? "," : ""}</c:forEach>]'
                        data-values='[<c:forEach var="entry" items="${courseCountsByStatus}" varStatus="loop">${entry.value}${!loop.last ? "," : ""}</c:forEach>]'>
                </canvas>
            </div>

            <!-- Legend dots -->
            <div class="horizon-status-list">
                <c:forEach var="entry" items="${courseCountsByStatus}">
                    <div class="horizon-status-item">
                        <span>
                            <i class="status-dot status-${entry.key.toLowerCase()}"></i>
                            ${entry.key}
                        </span>
                        <strong>${entry.value}</strong>
                    </div>
                </c:forEach>
            </div>
        </section>


        <!-- Top Courses -->
        <section class="horizon-panel">
            <div class="horizon-panel-header">
                <div>
                    <h2>Top Courses</h2>
                    <p>Khóa học có nhiều lượt đăng ký nhất</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/courses"
                   class="horizon-view-all">View all <i class="fa-solid fa-arrow-right" style="font-size:10px;"></i></a>
            </div>

            <c:choose>
                <c:when test="${not empty topSellingCourses}">
                    <div class="horizon-course-list">
                        <c:forEach var="course" items="${topSellingCourses}" varStatus="loop">
                            <div class="horizon-course-item">
                                <div class="course-rank">${loop.index + 1}</div>
                                <div class="course-info">
                                    <strong>${course.name}</strong>
                                    <span><i class="fa-regular fa-user"></i> ${course.sales} lượt đăng ký</span>
                                </div>
                                <div class="course-revenue">
                                    <fmt:formatNumber value="${course.revenue}" groupingUsed="true"/>₫
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="horizon-empty">
                        <i class="fa-regular fa-folder-open" style="font-size:28px; margin-bottom:8px;"></i>
                        Chưa có dữ liệu trong kỳ này.
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

    </div>


    <script src="${pageContext.request.contextPath}/assets/js/admin/dashboard_charts.js?v=1"></script>

</section>