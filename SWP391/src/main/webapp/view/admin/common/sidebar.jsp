<aside class="sidebar">
    <nav class="sidebar-menu">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="${contentPage == 'dashboard.jsp' || empty contentPage ? 'active' : ''}">Dashboard</a>
        <a href="${pageContext.request.contextPath}/admin/accounts" class="${contentPage == 'accounts.jsp' ? 'active' : ''}">Account Management</a>
        <a href="${pageContext.request.contextPath}/admin/courses" class="${contentPage == 'courses.jsp' && param.status != 'pending' ? 'active' : ''}">Course Management</a>
        <a href="${pageContext.request.contextPath}/admin/courses?status=pending" class="${contentPage == 'courses.jsp' && param.status == 'pending' ? 'active' : ''}">Course Approval</a>

        <a href="${pageContext.request.contextPath}/admin/blog-categories" class="${contentPage == 'blog_categories.jsp' ? 'active' : ''}">Blog Category Management</a>


        <a href="${pageContext.request.contextPath}/admin/course-content">Course Content</a>
        <a href="${pageContext.request.contextPath}/admin/enrollment">Enrollment Management</a>
        <a href="${pageContext.request.contextPath}/admin/student">Student Management</a>
        <a href="${pageContext.request.contextPath}/admin/payouts">Payout Management</a>
        <a href="${pageContext.request.contextPath}/admin/settings">System Administration</a>
        <!-- <a href="${pageContext.request.contextPath}/view/admin/contact-help/faqManager.jsp">FAQ Management</a>
        <a href="${pageContext.request.contextPath}/view/admin/contact-help/Contact-respond.jsp">Contact Response</a> -->

        <a href="${pageContext.request.contextPath}/admin/registrations" class="${contentPage == 'registrations.jsp' ? 'active' : ''}">Course Registration</a>

        <a href="${pageContext.request.contextPath}/admin/course-content" class="${contentPage == 'course_content.jsp' ? 'active' : ''}">Course Content</a>
        <a href="${pageContext.request.contextPath}/admin/enrollment" class="${contentPage == 'enrollment.jsp' ? 'active' : ''}">Enrollment Management</a>
        <a href="${pageContext.request.contextPath}/admin/student" class="${contentPage == 'student.jsp' ? 'active' : ''}">Student Management</a>
        <a href="${pageContext.request.contextPath}/admin/payouts" class="${contentPage == 'payouts.jsp' ? 'active' : ''}">Payout Management</a>
        <a href="${pageContext.request.contextPath}/admin/settings" class="${contentPage == 'settings.jsp' ? 'active' : ''}">System Administration</a>


    </nav>
</aside>