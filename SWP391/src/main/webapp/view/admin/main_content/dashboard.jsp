<section class="dashboard">
    <!-- KPI -->
    <div class="kpi-container">
        <div class="kpi-card">
            <div class="kpi-number">1</div>
            <div class="kpi-info">
                <div class="kpi-title">Number of<br>User</div>
                <div class="kpi-value">${totalUsers != null ? totalUsers : 1520}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-number">2</div>
            <div class="kpi-info">
                <div class="kpi-title">Number of<br>Course</div>
                <div class="kpi-value">${totalCourses != null ? totalCourses : 80}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-number">3</div>
            <div class="kpi-info">
                <div class="kpi-title">Registrations</div>
                <div class="kpi-value">${totalRegistrations != null ? totalRegistrations : 1248}</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-number">4</div>
            <div class="kpi-info">
                <div class="kpi-title">Revenue</div>
                <div class="kpi-value">$45,680</div>
            </div>
        </div>
    </div>

    <!-- Statistics Grid -->
    <div class="statistics-grid">
        <div class="stat-box">
            <div class="stat-title">Users by Role</div>
            <div class="stat-row"><span>Student</span><span>1350</span></div>
            <div class="stat-row"><span>Instructor</span><span>120</span></div>
            <div class="stat-row"><span>Admin</span><span>50</span></div>
        </div>

        <div class="stat-box">
            <div class="stat-title">Courses by Status</div>
            <div class="stat-row"><span>Published</span><span>60</span></div>
            <div class="stat-row"><span>Pending</span><span>8</span></div>
            <div class="stat-row"><span>Draft</span><span>12</span></div>
        </div>

        <div class="circle-stat">
            <div class="circle-title">Course Completion Rate</div>
            <div class="circle">68%</div>
        </div>

        <div class="stat-box">
            <div class="stat-title">Registrations by Month</div>
            <div class="chart-row">
                <span>Jan</span>
                <div class="bar-container"><div class="bar" style="width:40%"></div></div>
            </div>
            <div class="chart-row">
                <span>Feb</span>
                <div class="bar-container"><div class="bar" style="width:60%"></div></div>
            </div>
        </div>

        <div class="stat-box">
            <div class="stat-title">Payment by Status</div>
            <div class="stat-row"><span>Success</span><span>1100</span></div>
            <div class="stat-row"><span>Failed</span><span>80</span></div>
            <div class="stat-row"><span>Cancelled</span><span>68</span></div>
        </div>

        <div class="circle-stat">
            <div class="circle-title">Quiz Pass Rate</div>
            <div class="circle">68%</div>
        </div>
    </div>
</section>