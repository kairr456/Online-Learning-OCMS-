<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<section class="dashboard">
    <div class="dashboard-title">Dashboard</div>

    <!-- KPI -->
    <div class="kpi-container">
        <div class="kpi-card">
            <div class="kpi-number">👥</div>
            <div class="kpi-info">
                <div class="kpi-title">Number of<br>User</div>
                <div class="kpi-value">${totalUsers}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-number">📚</div>
            <div class="kpi-info">
                <div class="kpi-title">Number of<br>Course</div>
                <div class="kpi-value">${totalCourses}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-number">📝</div>
            <div class="kpi-info">
                <div class="kpi-title">Registrations</div>
                <div class="kpi-value">${totalRegistrations}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-number">💰</div>
            <div class="kpi-info">
                <div class="kpi-title">Revenue</div>
                <div class="kpi-value">
                    <fmt:formatNumber 
                        value="${totalRevenue}" 
                        groupingUsed="true"/>₫
                </div>
            </div>
        </div>
    </div>

        <!-- Statistics Grid -->
        <div class="statistics-grid">
            <div class="stat-box">
                <div class="stat-title">Users by Role</div>
                <c:forEach var="entry" items="${userCountsByRole}">
                    <div class="stat-row">
                        <span>${entry.key}</span>
                        <span>${entry.value}</span>
                    </div>
                </c:forEach>
            </div>

            <div class="stat-box">
                <div class="stat-title">Courses by Status</div>
                <c:forEach var="entry" items="${courseCountsByStatus}">
                    <div class="stat-row">
                        <span>${entry.key}</span>
                        <span>${entry.value}</span>
                    </div>
                </c:forEach>
            </div>

            <div class="circle-stat">
                <div class="circle-title">Lesson Completion Rate</div>
                <div class="circle">${lessonCompletionRate}%</div>
            </div>

            <div class="stat-box">
                <div class="stat-title">Registrations by Month</div>
                <c:set var="maxCount" value="0"/>
                <c:forEach var="entry" items="${registrationsByMonth}">
                    <c:if test="${entry.value > maxCount}">
                        <c:set var="maxCount" value="${entry.value}"/>
                    </c:if>
                </c:forEach>
                <c:forEach var="entry" items="${registrationsByMonth}">
                    <div class="chart-row">
                        <span>${entry.key}</span>
                        <div class="bar-container">
                            <div class="bar" style="--bar-width:${maxCount > 0 ? (entry.value * 100 / maxCount) : 0}%;"></div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="stat-box">
                <div class="stat-title">Registrations by Status</div>
                <c:forEach var="entry" items="${registrationCountsByStatus}">
                    <div class="stat-row">
                        <span>${entry.key}</span>
                        <span>${entry.value}</span>
                    </div>
                </c:forEach>
                <c:if test="${empty registrationCountsByStatus}">
                    <div class="stat-row">
                        <span>No data</span>
                        <span>-</span>
                    </div>
                </c:if>
            </div>

            <div class="circle-stat">
                <div class="circle-title">Quiz Pass Rate</div>
                <div class="circle">${quizPassRate}%</div>
            </div>
        </div>
</section>