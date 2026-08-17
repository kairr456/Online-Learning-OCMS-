<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!--
    NOT WIRED UP YET. Every field/button here is inert -- no form action,
    no servlet behind it. This is layout/markup only, matching the mockup,
    for someone to wire up later (OTP request + validate + password reset).
-->
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

        <p class="fp-note">This page is a visual placeholder -- not wired up to a servlet yet.</p>

        <div class="fp-field">
            <label for="fpEmail">Email<span class="fp-field__required">*</span></label>
            <input type="email" id="fpEmail" name="email" placeholder="you@example.com">
        </div>

        <div class="fp-field">
            <label for="fpOtp">OTP</label>
            <input type="text" id="fpOtp" name="otp" inputmode="numeric" maxlength="6">
        </div>

        <div class="fp-actions">
            <button type="button" class="fp-btn fp-btn--primary">Validate</button>
        </div>

        <p class="fp-resend">Didn't receive it? <a href="#">Resend OTP</a></p>

        <hr class="fp-divider">

        <div class="fp-field">
            <label for="fpPassword">Password<span class="fp-field__required">*</span></label>
            <input type="password" id="fpPassword" name="password" placeholder="••••••••">
        </div>

        <div class="fp-field">
            <label for="fpConfirmPassword">Re-enter Password<span class="fp-field__required">*</span></label>
            <input type="password" id="fpConfirmPassword" name="confirmPassword" placeholder="••••••••">
        </div>

        <div class="fp-actions">
            <button type="button" class="fp-btn fp-btn--primary">Change</button>
        </div>

    </div>
</div>

</body>
</html>
