<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign in · OCMS</title>
    <link rel="stylesheet" href="../../assets/css/styles.css">
</head>
<body>

<div class="auth-screen">

    <!-- Brand panel -->
    <div class="auth-brand">
        <div class="auth-brand__mark"><span class="dot"></span>OCMS</div>
        <div class="auth-brand__body">
            <h1>Welcome back to your control center.</h1>
            <p>Sign in to manage accounts, review activity, and keep everything on track.</p>
        </div>
        <div class="auth-brand__foot">SECURE ACCESS · SESSION-BASED AUTH</div>
    </div>

    <!-- Form panel -->
    <div class="auth-panel">
        <div class="auth-card">
            <p class="auth-card__eyebrow">Account</p>
            <h2>Sign in</h2>
            <p class="auth-card__sub">Enter your credentials to continue.</p>

            <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="auth-error">
                <span>&#9888;</span>
                <span><%= request.getAttribute("errorMessage") %></span>
            </div>
            <% } %>

            <form id="loginForm" method="post" action="login">
                <div class="field">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="e.g. jane.doe" required autofocus>
                </div>

                <div class="field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="••••••••" required>
                </div>

                <div class="field-row">
                    <label class="checkbox-inline">
                        <input type="checkbox" name="remember"> Remember me
                    </label>
                    <button type="button" data-toggle-password aria-pressed="false" style="background:none;border:none;color:var(--slate-600);cursor:pointer;font-size:13px;">Show</button>
                </div>

                <button type="submit" class="btn-primary">Sign in</button>
            </form>

            <p class="auth-footnote">Trouble signing in? Contact your administrator.</p>
        </div>
    </div>

</div>

<script src="../../assets/js/app.js"></script>
</body>
</html>
