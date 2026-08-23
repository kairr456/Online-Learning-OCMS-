<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section class="dashboard horizon-dashboard">

    <!-- =========================
         HEADER
    ========================== -->
    <div class="dashboard-topbar">
        <div>
            <h1 class="dashboard-page-title">Dashboard</h1>
            <p class="dashboard-page-subtitle">
                Tổng quan hệ thống và hoạt động kinh doanh
            </p>
        </div>

        <form method="get"
              action="${pageContext.request.contextPath}/admin/dashboard"
              class="dashboard-period">

            <label for="period">Thời gian</label>

            <select id="period"
                    name="period"
                    onchange="this.form.submit()">

                <option value="today"
                    ${period == 'today' ? 'selected' : ''}>
                    Hôm nay
                </option>

                <option value="week"
                    ${period == 'week' ? 'selected' : ''}>
                    Tuần này
                </option>

                <option value="month"
                    ${period == 'month' ? 'selected' : ''}>
                    Tháng này
                </option>

                <option value="quarter"
                    ${period == 'quarter' ? 'selected' : ''}>
                    Quý này
                </option>

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
                <span>👥</span>
            </div>

            <div class="horizon-kpi-content">
                <span class="horizon-kpi-label">
                    Total Users
                </span>

                <strong class="horizon-kpi-value">
                    ${totalUsers}
                </strong>

                <span class="horizon-kpi-description">
                    Người dùng trong hệ thống
                </span>
            </div>

        </div>


        <!-- Courses -->
        <div class="horizon-kpi-card">

            <div class="horizon-kpi-icon horizon-icon-orange">
                <span>📚</span>
            </div>

            <div class="horizon-kpi-content">
                <span class="horizon-kpi-label">
                    Total Courses
                </span>

                <strong class="horizon-kpi-value">
                    ${totalCourses}
                </strong>

                <span class="horizon-kpi-description">
                    Khóa học trên hệ thống
                </span>
            </div>

        </div>


        <!-- Registrations -->
        <div class="horizon-kpi-card">

            <div class="horizon-kpi-icon horizon-icon-green">
                <span>📝</span>
            </div>

            <div class="horizon-kpi-content">
                <span class="horizon-kpi-label">
                    Registrations
                </span>

                <strong class="horizon-kpi-value">
                    ${totalRegistrations}
                </strong>

                <span class="horizon-kpi-description">
                    Lượt đăng ký khóa học
                </span>
            </div>

        </div>


        <!-- Revenue -->
        <div class="horizon-kpi-card">

            <div class="horizon-kpi-icon horizon-icon-blue">
                <span>₫</span>
            </div>

            <div class="horizon-kpi-content">

                <span class="horizon-kpi-label">
                    Total Revenue
                </span>

                <strong class="horizon-kpi-value horizon-revenue">
                    <fmt:formatNumber
                            value="${totalRevenue}"
                            groupingUsed="true"/>₫
                </strong>

                <c:choose>

                    <c:when test="${revenueGrowthAvailable}">
                        <span class="horizon-kpi-growth
                            ${revenueGrowth >= 0
                                ? 'growth-up'
                                : 'growth-down'}">

                            ${revenueGrowth >= 0 ? '↑' : '↓'}
                            <fmt:formatNumber
                                    value="${revenueGrowth}"
                                    maxFractionDigits="1"/>%

                            so với kỳ trước
                        </span>
                    </c:when>

                    <c:otherwise>
                        <span class="horizon-kpi-description">
                            Chưa có dữ liệu kỳ trước
                        </span>
                    </c:otherwise>

                </c:choose>

            </div>
        </div>

    </div>


    <!-- =========================
         QUICK OPERATIONS
    ========================== -->
    <div class="horizon-section-title">
        <div>
            <h2>Quick Overview</h2>
            <p>Các hoạt động cần xử lý</p>
        </div>
    </div>

    <div class="horizon-operation-grid">

        <div class="horizon-operation-card">
            <div class="operation-icon">
                👨‍🏫
            </div>

            <div class="operation-content">
                <span>Teacher chờ duyệt</span>
                <strong>${pendingTeacherApprovals}</strong>
            </div>

            <div class="operation-arrow">
                →
            </div>
        </div>


        <div class="horizon-operation-card">
            <div class="operation-icon">
                📖
            </div>

            <div class="operation-content">
                <span>Course chờ duyệt</span>
                <strong>${pendingCourseApprovals}</strong>
            </div>

            <div class="operation-arrow">
                →
            </div>
        </div>

    </div>


    <!-- =========================
         MAIN ANALYTICS
    ========================== -->
    <div class="horizon-main-grid">

        <!-- Revenue chart -->
        <section class="horizon-panel horizon-chart-panel">

            <div class="horizon-panel-header">

                <div>
                    <h2>Revenue Overview</h2>

                    <p>
                        Doanh thu và lượt đăng ký trong ${periodLabel}
                    </p>
                </div>

                <div class="horizon-legend">

                    <span>
                        <i class="legend-revenue"></i>
                        Revenue
                    </span>

                    <span>
                        <i class="legend-registration"></i>
                        Registrations
                    </span>

                </div>

            </div>

            <div class="horizon-chart-wrapper">

                <svg id="revenueRegistrationChart"
                     class="line-chart"
                     viewBox="0 0 760 280"
                     role="img"
                     aria-label="Revenue and registrations chart"
                     data-trend='[
                        <c:forEach
                            var="point"
                            items="${monthlyTrend}"
                            varStatus="loop">

                            {
                                "period":"${point.period}",
                                "registrations":${point.registrations},
                                "revenue":${point.revenue}
                            }

                            ${!loop.last ? ',' : ''}

                        </c:forEach>
                     ]'>
                </svg>

            </div>

            <div id="lineChartEmpty"
                 class="horizon-empty"
                 hidden>
                Chưa có dữ liệu trong kỳ này.
            </div>

        </section>


        <!-- Learning quality -->
        <section class="horizon-panel">

            <div class="horizon-panel-header">

                <div>
                    <h2>Learning Quality</h2>
                    <p>
                        Hiệu quả học tập của học viên
                    </p>
                </div>

            </div>


            <div class="horizon-donut-container">

                <div class="horizon-donut-item">

                    <div class="horizon-donut horizon-donut-green"
                         style="--donut-value:${quizPassRate};">

                        <span>
                            ${quizPassRate}%
                        </span>

                    </div>

                    <strong>Quiz đạt</strong>

                    <small>
                        Tỷ lệ học viên vượt qua quiz
                    </small>

                </div>


                <div class="horizon-donut-item">

                    <div class="horizon-donut horizon-donut-purple"
                         style="--donut-value:${lessonCompletionRate};">

                        <span>
                            ${lessonCompletionRate}%
                        </span>

                    </div>

                    <strong>Hoàn thành bài</strong>

                    <small>
                        Tỷ lệ hoàn thành lesson
                    </small>

                </div>

            </div>

        </section>

    </div>


    <!-- =========================
         SECONDARY ANALYTICS
    ========================== -->
    <div class="horizon-secondary-grid">

        <!-- Course status -->
        <section class="horizon-panel">

            <div class="horizon-panel-header">

                <div>
                    <h2>Course Statistics</h2>
                    <p>
                        Phân bổ khóa học theo trạng thái
                    </p>
                </div>

            </div>


            <c:set var="courseStatusTotal" value="0"/>

            <c:forEach
                    var="entry"
                    items="${courseCountsByStatus}">

                <c:set
                        var="courseStatusTotal"
                        value="${courseStatusTotal + entry.value}"/>

            </c:forEach>


            <div class="horizon-status-bar">

                <c:forEach
                        var="entry"
                        items="${courseCountsByStatus}">

                    <div
                        class="horizon-status-segment
                               status-${entry.key.toLowerCase()}"
                        style="width:${courseStatusTotal > 0
                            ? entry.value * 100 / courseStatusTotal
                            : 0}%"
                        title="${entry.key}: ${entry.value}">
                    </div>

                </c:forEach>

            </div>


            <div class="horizon-status-list">

                <c:forEach
                        var="entry"
                        items="${courseCountsByStatus}">

                    <div class="horizon-status-item">

                        <span>
                            <i class="status-dot
                                status-${entry.key.toLowerCase()}">
                            </i>

                            ${entry.key}
                        </span>

                        <strong>
                            ${entry.value}
                        </strong>

                    </div>

                </c:forEach>

            </div>

        </section>


        <!-- Top courses -->
        <section class="horizon-panel">

            <div class="horizon-panel-header">

                <div>
                    <h2>Top Courses</h2>
                    <p>
                        Khóa học có nhiều lượt đăng ký nhất
                    </p>
                </div>

                <span class="horizon-view-all">
                    View all →
                </span>

            </div>


            <c:choose>

                <c:when test="${not empty topSellingCourses}">

                    <div class="horizon-course-list">

                        <c:forEach
                                var="course"
                                items="${topSellingCourses}"
                                varStatus="loop">

                            <div class="horizon-course-item">

                                <div class="course-rank">
                                    ${loop.index + 1}
                                </div>

                                <div class="course-info">

                                    <strong>
                                        ${course.name}
                                    </strong>

                                    <span>
                                        ${course.sales} lượt đăng ký
                                    </span>

                                </div>

                                <div class="course-revenue">

                                    <fmt:formatNumber
                                            value="${course.revenue}"
                                            groupingUsed="true"/>₫

                                </div>

                            </div>

                        </c:forEach>

                    </div>

                </c:when>

                <c:otherwise>

                    <div class="horizon-empty">
                        Chưa có dữ liệu trong kỳ này.
                    </div>

                </c:otherwise>

            </c:choose>

        </section>

    </div>


    <script src="${pageContext.request.contextPath}/assets/js/admin/dashboard.js"></script>

</section>