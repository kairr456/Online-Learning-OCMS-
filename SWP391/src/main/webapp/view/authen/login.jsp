<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | OCMS</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="page-shell">
    <header class="hero">
        <nav class="top-nav">
            <div class="brand">OCMS</div>
            <div class="nav-links">
                <a href="index.html">Home</a>
                <a href="#">Courses</a>
            </div>
        </nav>
        <div class="hero-content">
            <h1>Login to your account</h1>
            <p>Enter your credentials to access your dashboard and course progress.</p>
        </div>
    </header>

    <main class="features">
        <section class="login-card">
            <h2>Sign In</h2>
            <c:if test="${not empty error}">
                <div class="alert error">${error}</div>
            </c:if>
            <form action="authen?action=login" method="post" class="login-form">
                <label for="username">Username</label>
                <input id="username" name="username" type="text" placeholder="Username">

                <label for="password">Password</label>
                <input id="password" name="password" type="password" placeholder="Password">

                <button type="submit" class="btn primary">Sign In</button>
            </form>
            <div class="login-footer">
                <p>Use <strong>admin/password123</strong> or <strong>student/student123</strong></p>
            </div>
        </section>
    </main>
</div>
</body>
</html>
