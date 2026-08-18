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
                <div class="circle-title">Course Completion Rate</div>
                <div class="circle">68%</div>
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
                            <div class="bar" style="width:${maxCount > 0 ? (entry.value * 100 / maxCount) : 0}%"></div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="stat-box">
                <div class="stat-title">Payment by Status</div>
                <div class="stat-row"><span>Success</span><span>1100</span></div>
                <div class="stat-row"><span>Failed</span><span>80</span></div>
                <div class="stat-row"><span>Cancelled</span><span>68</span></div>
            </div>

            <div class="circle-stat">
                <div class="circle-title">Quiz Pass Rate</div>
                <div class="circle">${quizPassRate}%</div>
            </div>
        </div>
</section>