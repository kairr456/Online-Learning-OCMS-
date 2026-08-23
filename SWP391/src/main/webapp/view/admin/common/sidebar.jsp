<aside class="sidebar">
    <nav class="sidebar-menu">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="${contentPage == 'dashboard.jsp' || empty contentPage ? 'active' : ''}">Dashboard</a>
        <a href="${pageContext.request.contextPath}/admin/accounts" class="${contentPage == 'accounts.jsp' ? 'active' : ''}">Account Management</a>
        <a href="${pageContext.request.contextPath}/admin/teacher-approvals" class="${contentPage == 'teacher_approval_list.jsp' ? 'active' : ''}">Teacher Approval</a>
        <a href="${pageContext.request.contextPath}/admin/courses" class="${contentPage == 'courses.jsp' && param.status != 'pending' ? 'active' : ''}">Course Management</a>
        <a href="${pageContext.request.contextPath}/admin/courses?status=pending" class="${contentPage == 'courses.jsp' && param.status == 'pending' ? 'active' : ''}">Course Approval</a>
        <a href="${pageContext.request.contextPath}/admin/blog-approval" class="${contentPage == 'blog_approval.jsp' ? 'active' : ''}">Blog Approval</a>
        <a href="${pageContext.request.contextPath}/admin/blog-categories" class="${contentPage == 'blog_categories.jsp' ? 'active' : ''}">Blog Category Management</a>
        <a href="${pageContext.request.contextPath}/admin/registrations" class="${contentPage == 'registrations.jsp' ? 'active' : ''}">Course Registration</a>
        <a href="${pageContext.request.contextPath}/admin/payouts" class="${contentPage == 'payouts.jsp' ? 'active' : ''}">Payout Management</a>
    </nav>
</aside>