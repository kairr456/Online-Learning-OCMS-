<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | OCMS</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<%
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String username = (String) session.getAttribute("loggedUser");
%>
<div class="page-shell">
    <header class="hero">
        <nav class="top-nav">
            <div class="brand">OCMS</div>
            <div class="nav-links">
                <a href="index.html">Home</a>
                <a href="dashboard.jsp">Dashboard</a>
                <a href="authen?action=logout">Logout</a>
            </div>
        </nav>
        <div class="hero-content">
            <h1>Welcome back, <%= username %>!</h1>
            <p>Here is your dashboard overview.</p>
        </div>
    </header>

    <main class="features dashboard-grid">
        <section class="feature-card">
            <h3>My Courses</h3>
            <p>See your enrolled courses and continue learning where you left off.</p>
        </section>
        <section class="feature-card">
            <h3>Progress</h3>
            <p>Track your course completion and upcoming deadlines.</p>
        </section>
        <section class="feature-card">
            <h3>Messages</h3>
            <p>Review announcements from your instructors and advisors.</p>
        </section>
        <section class="feature-card">
            <h3>Settings</h3>
            <p>Update your profile and account preferences.</p>
        </section>
    </main>
</div>
</body>
</html>
