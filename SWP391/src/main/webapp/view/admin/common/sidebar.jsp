<aside class="sidebar">

    <nav class="sidebar-menu">

        <!-- OVERVIEW -->
        <span class="sidebar-section-label">Overview</span>

        <a href="${pageContext.request.contextPath}/admin/dashboard"
           class="${contentPage == 'dashboard.jsp' || empty contentPage ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-chart-pie"></i></span>
            <span class="nav-label">Dashboard</span>
        </a>

        <!-- MANAGEMENT -->
        <span class="sidebar-section-label">Management</span>

        <a href="${pageContext.request.contextPath}/admin/accounts"
           class="${contentPage == 'accounts.jsp' ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-users"></i></span>
            <span class="nav-label">Accounts</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/teacher-approvals"
           class="${contentPage == 'teacher_approval_list.jsp' ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-chalkboard-user"></i></span>
            <span class="nav-label">Teacher Approval</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/courses"
           class="${contentPage == 'courses.jsp' && param.status != 'pending' ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-book-open"></i></span>
            <span class="nav-label">Courses</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/courses?status=pending"
           class="${contentPage == 'courses.jsp' && param.status == 'pending' ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-clipboard-check"></i></span>
            <span class="nav-label">Course Approval</span>
        </a>

        <!-- CONTENT -->
        <span class="sidebar-section-label">Content</span>

        <a href="${pageContext.request.contextPath}/admin/blog-approval"
           class="${contentPage == 'blog_approval.jsp' ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-newspaper"></i></span>
            <span class="nav-label">Blog Approval</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/blog-categories"
           class="${contentPage == 'blog_categories.jsp' ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-tags"></i></span>
            <span class="nav-label">Blog Categories</span>
        </a>

        <!-- FINANCE -->
        <span class="sidebar-section-label">Finance</span>

        <a href="${pageContext.request.contextPath}/admin/registrations"
           class="${contentPage == 'registrations.jsp' ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-file-signature"></i></span>
            <span class="nav-label">Registrations</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/payouts"
           class="${contentPage == 'payouts.jsp' ? 'active' : ''}">
            <span class="nav-icon"><i class="fa-solid fa-money-bill-transfer"></i></span>
            <span class="nav-label">Payouts</span>
        </a>

    </nav>

    <!-- Sidebar footer -->
    <div class="sidebar-footer">
        <i class="fa-solid fa-shield-halved" style="color:#D8A24A; font-size:14px;"></i>
        <span class="sidebar-footer-text">OCMS v1.0 &mdash; Admin Panel</span>
    </div>

</aside>