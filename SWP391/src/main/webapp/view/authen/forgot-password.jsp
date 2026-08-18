<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Which of the 3 steps to show is driven entirely by session state that
    // ForgotPasswordController sets -- this page has no logic of its own
    // beyond reading that state. See ForgotPasswordController for what sets
    // fpOtpEmail / fpOtpVerified.
    String pendingEmail = (String) session.getAttribute("fpOtpEmail");
    boolean otpVerified = Boolean.TRUE.equals(session.getAttribute("fpOtpVerified"));

    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password · OCMS</title>
    <link rel="stylesheet" href="../../assets/css/styles.css">
    <link rel="stylesheet" href="../../assets/css/authen/forgot-password.css">
</head>
<body>

<div class="fp-screen">
    <div class="fp-card">

        <div class="fp-card__header">
            <span class="fp-card__mark"><span class="dot"></span></span>
            <h1>Forgot password</h1>
        </div>

        <% if (successMessage != null) { %>
        <div class="fp-alert fp-alert--success"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="fp-alert fp-alert--error"><%= errorMessage %></div>
        <% } %>

        <% if (otpVerified) { %>

            <!-- ===== Step 3: new password ===== -->
            <form method="post" action="<%= ctx %>/forgot-password/reset">
                <div class="fp-field">
                    <label for="fpPassword">Password<span class="fp-field__required">*</span></label>
                    <input type="password" id="fpPassword" name="password" placeholder="••••••••" required>
                </div>
                <div class="fp-field">
                    <label for="fpConfirmPassword">Re-enter Password<span class="fp-field__required">*</span></label>
                    <input type="password" id="fpConfirmPassword" name="confirmPassword" placeholder="••••••••" required>
                </div>
                <div class="fp-actions">
                    <button type="submit" class="fp-btn fp-btn--primary">Change</button>
                </div>
            </form>

        <% } else if (pendingEmail != null) { %>

            <!-- ===== Step 2: OTP ===== -->
            <p class="fp-note">Code sent to <strong><%= pendingEmail %></strong></p>

            <form method="post" action="<%= ctx %>/forgot-password/verify-otp">
                <div class="fp-field">
                    <label for="fpOtp">OTP</label>
                    <input type="text" id="fpOtp" name="otp" inputmode="numeric" maxlength="6" required>
                </div>
                <div class="fp-actions">
                    <button type="submit" class="fp-btn fp-btn--primary">Validate</button>
                </div>
            </form>

            <form method="post" action="<%= ctx %>/forgot-password/send-otp">
                <input type="hidden" name="email" value="<%= pendingEmail %>">
                <p class="fp-resend">Didn't receive it? <button type="submit" class="fp-resend__link">Resend OTP</button></p>
            </form>

        <% } else { %>

            <!-- ===== Step 1: email ===== -->
            <form method="post" action="<%= ctx %>/forgot-password/send-otp">
                <div class="fp-field">
                    <label for="fpEmail">Email<span class="fp-field__required">*</span></label>
                    <input type="email" id="fpEmail" name="email" placeholder="you@example.com" required>
                </div>
                <div class="fp-actions">
                    <button type="submit" class="fp-btn fp-btn--primary">Validate</button>
                </div>
            </form>

        <% } %>

    </div>
</div>

</body>
</html>
