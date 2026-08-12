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

        <!-- Login form -->
        <form id="loginForm" method="post" action="login">

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
                        data-toggle-password
                        aria-pressed="false"
                        aria-label="Show password"
                    >

                        <svg
                            class="icon-eye"
                            viewBox="0 0 22 16"
                            fill="none"
                            aria-hidden="true"
                        >
                            <path
                                d="M1 8C1 8 4.6 1.5 11 1.5S21 8 21 8s-3.6 6.5-10 6.5S1 8 1 8Z"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linejoin="round"
                            />

                            <circle
                                cx="11"
                                cy="8"
                                r="3"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />
                        </svg>


                        <svg
                            class="icon-eye-off"
                            viewBox="0 0 22 16"
                            fill="none"
                            aria-hidden="true"
                        >
                            <path
                                d="M1 8C1 8 4.6 1.5 11 1.5S21 8 21 8s-3.6 6.5-10 6.5S1 8 1 8Z"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linejoin="round"
                            />

                            <circle
                                cx="11"
                                cy="8"
                                r="3"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />

                            <path
                                d="M2 14 20 2"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                            />
                        </svg>

                    </button>

                </div>
            </div>


            <!-- Remember / Forgot password -->
            <div class="login-row">

                <label class="login-remember">

                    <input
                        type="checkbox"
                        name="remember"
                    >

                    <span>Remember me</span>

                </label>


                <a
                    class="login-forgot"
                    href="forgot-password"
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

            <a href="register">
                Create an account
            </a>

        </div>

    </main>

</div>


<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>

</body>
</html>