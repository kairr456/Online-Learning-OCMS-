<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OCMS - Login</title>

    <!-- Global CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/styles.css">

    <!-- Login CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/authen/login.css">
</head>

<body>

<div class="login-screen">

    <div class="login-decoration login-decoration--one"></div>
    <div class="login-decoration login-decoration--two"></div>

    <main class="login-card">

        <!-- Brand -->
        <div class="login-brand">
            <div class="login-brand__icon" aria-hidden="true">
                <span class="dot"></span>
            </div>

            <div>
                <span class="login-brand__name">OCMS</span>
                <span class="login-brand__tagline">
                    Online Course Management System
                </span>
            </div>
        </div>

        <!-- Heading -->
        <div class="login-heading">
            <h1>Welcome back</h1>
            <p>Sign in to continue to your dashboard.</p>
        </div>

        <!-- Error message -->
        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="login-error" role="alert">
                <span class="login-error__icon">&#9888;</span>
                <span>
                    <%= request.getAttribute("errorMessage") %>
                </span>
            </div>
        <% } %>

        <!-- Success message for registration -->
        <%
            String registered = request.getParameter("registered");
            String pendingApproval = request.getParameter("pendingApproval");
            if ("true".equals(registered)) {
        %>
            <div class="login-success" role="status">
                <span class="login-success__icon">&#10003;</span>
                <span>Đăng ký thành công! Vui lòng đăng nhập.</span>
            </div>
        <% } else if ("true".equals(pendingApproval)) { %>
            <div class="login-info" role="status">
                <span class="login-info__icon">&#128279;</span>
                <span>Đăng ký giảng viên thành công! Tài khoản đang chờ admin duyệt. Bạn sẽ nhận email khi có kết quả.</span>
            </div>
        <% } %>

        <!-- Login form -->
        <form id="loginForm" method="post" action="${pageContext.request.contextPath}/login">

            <!-- Username -->
            <div class="login-field">

                <label for="username">
                    Username or email
                </label>

                <div class="login-input-wrap">

                    <span class="login-input-icon" aria-hidden="true">
                        &#64;
                    </span>

                    <input
                        type="text"
                        id="username"
                        name="username"
                        placeholder="Enter your username or email"
                        value="<%= request.getAttribute("rememberedUsername") != null
                            ? request.getAttribute("rememberedUsername")
                            : "" %>"
                        autocomplete="username"
                        required
                        autofocus
                    >

                </div>
            </div>


            <!-- Password -->
            <div class="login-field">

                <label for="password">
                    Password
                </label>

                <div class="login-field__wrap">

                    <span class="login-input-icon" aria-hidden="true">
                        &#8226;
                    </span>

                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder="Enter your password"
                        autocomplete="current-password"
                        required
                    >

                    <!-- Show / hide password -->
                    <button
                        type="button"
                        class="login-eye"
                        data-password-target="password"
                        aria-label="Show password"
                    >
                        &#128065;
                    </button>

                </div>
            </div>


            <!-- Remember / Forgot password -->
            <div class="login-row">

                <label class="login-remember">

                    <input
                        type="checkbox"
                        name="remember"
                        value="true"
                        <%= request.getAttribute("rememberChecked") != null && (Boolean) request.getAttribute("rememberChecked") ? "checked" : "" %>
                    >

                    <span>Remember me</span>

                </label>


                <a
                    class="login-forgot"
                    href="${pageContext.request.contextPath}/view/authen/forgot-password.jsp"
                >
                    Forgot password?
                </a>

            </div>


            <!-- Submit -->
            <button
                type="submit"
                class="login-submit"
            >
                <span>Sign in</span>
                <span
                    class="login-submit__arrow"
                    aria-hidden="true"
                >
                    &rarr;
                </span>
            </button>

        </form>


        <!-- Register -->
        <div class="login-register">

            <span>Don't have an account?</span>

            <a href="${pageContext.request.contextPath}/view/authen/register.jsp">
                Create an account
            </a>

        </div>

    </main>

</div>


<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>

</body>
</html>