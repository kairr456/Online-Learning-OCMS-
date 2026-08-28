<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>OCMS - Register</title>

    <!-- Global CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/styles.css">

    <!-- Login theme CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/authen/login.css">

    <!-- Register CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/authen/register.css">

</head>

<body>

<div class="login-screen register-screen">

    <!-- Background decorations -->
    <div class="login-decoration login-decoration--one"></div>
    <div class="login-decoration login-decoration--two"></div>


    <main class="login-card register-card">

        <!-- =====================================================
             BRAND
        ====================================================== -->

        <div class="login-brand">

            <div class="login-brand__icon">
                <span class="dot"></span>
            </div>

            <div>

                <span class="login-brand__name">
                    OCMS
                </span>

                <span class="login-brand__tagline">
                    Online Course Management System
                </span>

            </div>

        </div>


        <!-- =====================================================
             HEADING
        ====================================================== -->

        <div class="login-heading register-heading">

            <h1>
                Create an account
            </h1>

            <p>
                Register to start learning with OCMS.
            </p>

        </div>


        <!-- =====================================================
             ERROR MESSAGE
        ====================================================== -->

        <%
            String errorMessage =
                    (String) request.getAttribute("errorMessage");

            if (errorMessage != null) {
        %>

            <div class="login-error" role="alert">

                <span class="login-error__icon">
                    &#9888;
                </span>

                <span>
                    <%= errorMessage %>
                </span>

            </div>

        <%
            }
        %>


        <!-- =====================================================
             REGISTER FORM
        ====================================================== -->

        <form
            id="registerForm"
            method="post"
            action="${pageContext.request.contextPath}/register"
        >


            <!-- =================================================
                 USERNAME
            ================================================== -->

            <div class="register-field">

                <label for="username">
                    User Name *
                </label>

                <input
                    type="text"
                    id="username"
                    name="username"
                    maxlength="20"
                    spellcheck="false"
                    placeholder="Enter your username (max 20 chars)"
                    value="<%= request.getParameter("username") != null
                        ? request.getParameter("username")
                        : "" %>"
                    autocomplete="username"
                    required
                >

            </div>


            <!-- =================================================
                 FULL NAME
            ================================================== -->

            <div class="register-field">

                <label for="fullName">
                    Full Name *
                </label>

                <input
                    type="text"
                    id="fullName"
                    name="fullName"
                    maxlength="100"
                    spellcheck="false"
                    placeholder="Enter your full name (max 100 chars)"
                    value="<%= request.getParameter("fullName") != null
                        ? request.getParameter("fullName")
                        : "" %>"
                    required
                >

            </div>


            <!-- =================================================
                 EMAIL
            ================================================== -->

            <div class="register-field">

                <label for="email">
                    Email *
                </label>

                <input
                    type="email"
                    id="email"
                    name="email"
                    maxlength="100"
                    spellcheck="false"
                    placeholder="Enter your email (max 100 chars)"
                    value="<%= request.getParameter("email") != null
                        ? request.getParameter("email")
                        : "" %>"
                    autocomplete="email"
                    required
                >

            </div>


            <!-- =================================================
                 PHONE
            ================================================== -->

            <div class="register-field">

                <label for="phone">
                    Phone *
                </label>

                <input
                    type="tel"
                    id="phone"
                    name="phone"
                    maxlength="11"
                    spellcheck="false"
                    placeholder="Enter your phone number (10-11 digits)"
                    value="<%= request.getParameter("phone") != null
                        ? request.getParameter("phone")
                        : "" %>"
                    autocomplete="tel"
                    required
                >

            </div>


            <!-- =================================================
                 PASSWORD
            ================================================== -->

            <div class="register-field">

                <label for="password">
                    Password *
                </label>

                <div class="register-password-wrap">

                    <input
                        type="password"
                        id="password"
                        name="password"
                        maxlength="20"
                        placeholder="Create a password (6-20 chars)"
                        autocomplete="new-password"
                        required
                    >

                    <button
                        type="button"
                        class="register-eye"
                        data-password-target="password"
                        aria-label="Show password"
                    >
                        &#128065;
                    </button>

                </div>

            </div>


            <!-- =================================================
                 CONFIRM PASSWORD
            ================================================== -->

            <div class="register-field">

                <label for="confirmPassword">
                    Confirm Password *
                </label>

                <div class="register-password-wrap">

                    <input
                        type="password"
                        id="confirmPassword"
                        name="confirmPassword"
                        maxlength="20"
                        placeholder="Confirm your password (6-20 chars)"
                        autocomplete="new-password"
                        required
                    >

                    <button
                        type="button"
                        class="register-eye"
                        data-password-target="confirmPassword"
                        aria-label="Show password"
                    >
                        &#128065;
                    </button>

                </div>

            </div>


            <!-- =================================================
                 ROLE
            ================================================== -->

            <div class="register-field">

                <label for="role">
                    Register as *
                </label>

                <select
                    id="role"
                    name="role"
                    required
                >

                    <option value="">
                        Select your role
                    </option>

                    <option
                        value="teacher"
                        <%= "teacher".equals(request.getParameter("role"))
                            ? "selected"
                            : "" %>
                    >
                        Teacher
                    </option>

                    <option
                        value="student"
                        <%= "student".equals(request.getParameter("role"))
                            ? "selected"
                            : "" %>
                    >
                        Student / User
                    </option>

                </select>

            </div>


            <!-- =================================================
                 GENDER
            ================================================== -->

            <div class="register-field">

                <label for="gender">
                    Gender *
                </label>

                <select
                    id="gender"
                    name="gender"
                    required
                >

                    <option value="">
                        Select your gender
                    </option>

                    <option
                        value="male"
                        <%= "male".equals(request.getParameter("gender"))
                            ? "selected"
                            : "" %>
                    >
                        Male
                    </option>

                    <option
                        value="female"
                        <%= "female".equals(request.getParameter("gender"))
                            ? "selected"
                            : "" %>
                    >
                        Female
                    </option>

                </select>

            </div>


            <!-- =================================================
                 REGISTER BUTTON
            ================================================== -->

            <button
                type="submit"
                class="login-submit register-submit"
            >

                <span>
                    Create account
                </span>

                <span class="login-submit__arrow">
                    &rarr;
                </span>

            </button>

        </form>


        <!-- =====================================================
             LOGIN LINK
        ====================================================== -->

        <div class="login-register">

            <span>
                Already have an account?
            </span>

            <a
                href="${pageContext.request.contextPath}/login"
            >
                Sign in
            </a>

        </div>

    </main>

</div>


<!-- =========================================================
     PASSWORD TOGGLE
========================================================== -->

<script>

    document
        .querySelectorAll(".register-eye")
        .forEach(function (button) {

            button.addEventListener("click", function () {

                const targetId =
                    button.getAttribute(
                        "data-password-target"
                    );

                const input =
                    document.getElementById(targetId);

                if (input.type === "password") {

                    input.type = "text";

                    button.innerHTML = "&#128064;";
                    button.setAttribute(
                        "aria-label",
                        "Hide password"
                    );

                } else {

                    input.type = "password";

                    button.innerHTML = "&#128065;";
                    button.setAttribute(
                        "aria-label",
                        "Show password"
                    );
                }

            });

        });

    function setupCharLimitFeedback(inputElem, maxLen, fieldName) {
        if (!inputElem || inputElem.dataset.charLimitBound) return;
        inputElem.dataset.charLimitBound = "true";
        inputElem.setAttribute('maxlength', maxLen);

        let fieldContainer = inputElem.closest('.register-field');
        if (!fieldContainer) fieldContainer = inputElem.parentElement;

        let counterElem = fieldContainer.querySelector('.char-limit-feedback');
        if (!counterElem) {
            counterElem = document.createElement('div');
            counterElem.className = 'char-limit-feedback';
            counterElem.style.cssText = 'display:flex; justify-content:space-between; align-items:center; font-size:0.78rem; margin-top:4px; font-family:sans-serif; width:100%;';
            fieldContainer.appendChild(counterElem);
        }

        function updateFeedback() {
            const currentLen = inputElem.value ? inputElem.value.length : 0;
            if (currentLen >= maxLen) {
                counterElem.innerHTML = '<span style="color:#dc3545; font-weight:bold;">&#9888; Đã đạt giới hạn tối đa ' + maxLen + ' ký tự cho ' + fieldName + '!</span><span style="background-color:#dc3545; color:#fff; border-radius:4px; padding:1px 6px; font-size:0.75rem; font-weight:bold;">' + currentLen + '/' + maxLen + '</span>';
            } else {
                const isNear = currentLen >= (maxLen * 0.85);
                const badgeStyle = isNear ? 'background-color:#ffc107; color:#000; font-weight:bold;' : 'background-color:#f1f3f5; color:#6c757d; border:1px solid #ced4da;';
                counterElem.innerHTML = '<span style="color:#6c757d;">' + fieldName + ' (tối đa ' + maxLen + ' ký tự)</span><span style="border-radius:4px; padding:1px 6px; font-size:0.75rem; ' + badgeStyle + '">' + currentLen + '/' + maxLen + '</span>';
            }
        }

        inputElem.addEventListener('input', updateFeedback);
        updateFeedback();
    }

    document.addEventListener('DOMContentLoaded', function() {
        setupCharLimitFeedback(document.getElementById('username'), 20, "Tên đăng nhập");
        setupCharLimitFeedback(document.getElementById('fullName'), 100, "Họ và tên");
        setupCharLimitFeedback(document.getElementById('email'), 100, "Email");
        setupCharLimitFeedback(document.getElementById('phone'), 11, "Số điện thoại");
        setupCharLimitFeedback(document.getElementById('password'), 20, "Mật khẩu");
        setupCharLimitFeedback(document.getElementById('confirmPassword'), 20, "Xác nhận mật khẩu");
    });

</script>

</body>
</html>