<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Page</title>
    </head>
    <body>

<div class="dashboard-container">

    <!-- =========================
         SIDEBAR
         ========================= -->

    <aside class="sidebar">

        <div class="logo-container">
            <div class="logo">
                Logo
            </div>
        </div>

        <nav class="sidebar-menu">

            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="active">
                Dashboard
            </a>

            <a href="${pageContext.request.contextPath}/admin/accounts">
                Account Management
            </a>

            <a href="${pageContext.request.contextPath}/admin/courses">
                Course Management
            </a>

            <a href="${pageContext.request.contextPath}/admin/courses/approval">
                Course Approval
            </a>

            <a href="${pageContext.request.contextPath}/admin/course-content">
                Course Content
            </a>

            <a href="${pageContext.request.contextPath}/admin/registrations">
                Enrollment Management
            </a>

            <a href="${pageContext.request.contextPath}/admin/students">
                Student Management
            </a>

            <a href="${pageContext.request.contextPath}/admin/settings">
                System Administration
            </a>

        </nav>

    </aside>


    <!-- =========================
         MAIN
         ========================= -->

    <main class="main">

        <!-- HEADER -->

        <header class="header">

            <div class="search-box">

                <input
                    type="text"
                    placeholder="Search"
                >

                <div class="search-icon">
                    🔍
                </div>

            </div>

            <div class="profile-icon">
                ♙
            </div>

        </header>


        <!-- CONTENT -->

        <section class="content">


            <!-- =========================
                 KPI
                 ========================= -->

            <div class="kpi-container">


                <!-- USER -->

                <div class="kpi-card">

                    <div class="kpi-number">
                        1
                    </div>

                    <div class="kpi-info">

                        <div class="kpi-title">
                            Number of<br>User
                        </div>

                        <div class="kpi-value">
                            ${empty totalUsers ? 1520 : totalUsers}
                        </div>

                    </div>

                </div>


                <!-- COURSE -->

                <div class="kpi-card">

                    <div class="kpi-number">
                        2
                    </div>

                    <div class="kpi-info">

                        <div class="kpi-title">
                            Number of<br>Course
                        </div>

                        <div class="kpi-value">
                            ${empty totalCourses ? 80 : totalCourses}
                        </div>

                    </div>

                </div>


                <!-- REGISTRATION -->

                <div class="kpi-card">

                    <div class="kpi-number">
                        3
                    </div>

                    <div class="kpi-info">

                        <div class="kpi-title">
                            Registrations
                        </div>

                        <div class="kpi-value">
                            ${empty totalRegistrations ? 1248 : totalRegistrations}
                        </div>

                    </div>

                </div>


                <!-- REVENUE -->

                <div class="kpi-card">

                    <div class="kpi-number">
                        4
                    </div>

                    <div class="kpi-info">

                        <div class="kpi-title">
                            Revenue
                        </div>

                        <div class="kpi-value">
                            $${empty totalRevenue ? '45,680' : totalRevenue}
                        </div>

                    </div>

                </div>

            </div>


            <!-- =========================
                 STATISTICS
                 ========================= -->

            <div class="statistics-grid">


                <!-- USERS BY ROLE -->

                <div class="stat-box">

                    <div class="stat-title">
                        Users by Role
                    </div>

                    <div class="stat-row">
                        <span>Student</span>
                        <span>
                            ${empty totalStudents ? 1350 : totalStudents}
                        </span>
                    </div>

                    <div class="stat-row">
                        <span>Instructor</span>
                        <span>
                            ${empty totalInstructors ? 120 : totalInstructors}
                        </span>
                    </div>

                    <div class="stat-row">
                        <span>Admin</span>
                        <span>
                            ${empty totalAdmins ? 50 : totalAdmins}
                        </span>
                    </div>

                </div>


                <!-- COURSES BY STATUS -->

                <div class="stat-box">

                    <div class="stat-title">
                        Courses by Status
                    </div>

                    <div class="stat-row">
                        <span>Published</span>
                        <span>
                            ${empty publishedCourses ? 60 : publishedCourses}
                        </span>
                    </div>

                    <div class="stat-row">
                        <span>Pending</span>
                        <span>
                            ${empty pendingCourses ? 8 : pendingCourses}
                        </span>
                    </div>

                    <div class="stat-row">
                        <span>Draft</span>
                        <span>
                            ${empty draftCourses ? 12 : draftCourses}
                        </span>
                    </div>

                </div>


                <!-- COURSE COMPLETION -->

                <div class="circle-stat">

                    <div class="circle-title">
                        Course Completion Rate
                    </div>

                    <div class="circle">

                        ${empty courseCompletionRate
                            ? 68
                            : courseCompletionRate}

                        <span class="percentage">%</span>

                    </div>

                </div>


                <!-- REGISTRATION BY MONTH -->

                <div class="stat-box">

                    <div class="stat-title">
                        Registrations by Month
                    </div>

                    <div class="registration-chart">

                        <div class="chart-row">

                            <div class="month">
                                Jan
                            </div>

                            <div class="bar-container">
                                <div
                                    class="bar"
                                    style="width: 35%;">
                                </div>
                            </div>

                            <div class="bar-value">
                                120
                            </div>

                        </div>


                        <div class="chart-row">

                            <div class="month">
                                Feb
                            </div>

                            <div class="bar-container">
                                <div
                                    class="bar"
                                    style="width: 50%;">
                                </div>
                            </div>

                            <div class="bar-value">
                                180
                            </div>

                        </div>


                        <div class="chart-row">

                            <div class="month">
                                Mar
                            </div>

                            <div class="bar-container">
                                <div
                                    class="bar"
                                    style="width: 65%;">
                                </div>
                            </div>

                            <div class="bar-value">
                                230
                            </div>

                        </div>


                        <div class="chart-row">

                            <div class="month">
                                Apr
                            </div>

                            <div class="bar-container">
                                <div
                                    class="bar"
                                    style="width: 80%;">
                                </div>
                            </div>

                            <div class="bar-value">
                                290
                            </div>

                        </div>

                    </div>

                </div>


                <!-- PAYMENT STATUS -->

                <div class="stat-box">

                    <div class="stat-title">
                        Payment by Status
                    </div>

                    <div class="stat-row">
                        <span>Success</span>
                        <span>
                            ${empty successfulPayments
                                ? 1100
                                : successfulPayments}
                        </span>
                    </div>

                    <div class="stat-row">
                        <span>Failed</span>
                        <span>
                            ${empty failedPayments
                                ? 80
                                : failedPayments}
                        </span>
                    </div>

                    <div class="stat-row">
                        <span>Cancelled</span>
                        <span>
                            ${empty cancelledPayments
                                ? 68
                                : cancelledPayments}
                        </span>
                    </div>

                </div>


                <!-- QUIZ PASS RATE -->

                <div class="circle-stat">

                    <div class="circle-title">
                        Quiz Pass Rate
                    </div>

                    <div class="circle">

                        ${empty quizPassRate
                            ? 68
                            : quizPassRate}

                        <span class="percentage">%</span>

                    </div>

                </div>


            </div>

        </section>

    </main>

</div>

</body>
</html>
