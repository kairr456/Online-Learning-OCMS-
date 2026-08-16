<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Account" %>
<%
    // NOTE: session key here is "account" to match what header.jsp currently
    // reads (session.getAttribute("account")). If LoginController on your
    // end still sets "currentAccount" instead, this will always be null --
    // make sure both sides agree on one key.
    Account profileAccount = (Account) session.getAttribute("account");
    if (profileAccount == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // This page is a pure view now -- both the Info and Password updates
    // are handled by ProfileController ("/profile/info" and
    // "/profile/password"), which either:
    //   - forwards back here on validation/DB failure, with "errorMessage"
    //     and "activeTab" set as request attributes, or
    //   - redirects back here on success, with ?updated=info|password
    // Either way, this page just reads whichever of those is present and
    // renders the right banner + starts on the right tab.
    String errorMessage = (String) request.getAttribute("errorMessage");
    String activeTab = (String) request.getAttribute("activeTab");
    String successMessage = null;

    if (errorMessage == null) {
        String updated = request.getParameter("updated");
        if ("password".equals(updated)) {
            activeTab = "password";
            successMessage = "Password updated successfully.";
        } else if ("info".equals(updated)) {
            activeTab = "info";
            successMessage = "Profile updated successfully.";
        }
    }

    if (activeTab == null) {
        activeTab = "info"; // default tab when there's no error/success to react to
    }

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Profile · OCMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/profile.css">
</head>
<body>

    <jsp:include page="/view/common/header.jsp" />

    <div class="profile-shell">
        <div class="profile-shell__inner">

            <aside class="profile-sidebar">
                <div class="profile-avatar">
                    <% if (profileAccount.getAvatar() != null && !profileAccount.getAvatar().isEmpty()) { %>
                        <img src="<%= profileAccount.getAvatar() %>" alt="">
                    <% } else { %>
                        <span class="profile-avatar__fallback"><span class="dot"></span></span>
                    <% } %>
                </div>
                <p class="profile-avatar__label">Profile avatar</p>

                <nav class="profile-nav">
                    <button type="button" class="profile-nav__item <%= "info".equals(activeTab) ? "is-active" : "" %>" data-tab="info">Info</button>
                    <button type="button" class="profile-nav__item" data-tab="email">Email</button>
                    <button type="button" class="profile-nav__item <%= "password".equals(activeTab) ? "is-active" : "" %>" data-tab="password">Password</button>
                </nav>
            </aside>

            <main class="profile-main">

                <% if (successMessage != null) { %>
                <div class="profile-alert profile-alert--success"><%= successMessage %></div>
                <% } %>
                <% if (errorMessage != null) { %>
                <div class="profile-alert profile-alert--error"><%= errorMessage %></div>
                <% } %>

                <!-- ===================== Info tab ===================== -->
                <section class="profile-panel <%= "info".equals(activeTab) ? "is-active" : "" %>" id="tab-info">
                    <h1>Update your Info</h1>

                    <form method="post" action="<%= ctx %>/profile/info">

                        <div class="profile-field">
                            <label for="fullName">Full Name</label>
                            <input type="text" id="fullName" name="fullName"
                                   value="<%= profileAccount.getFullName() != null ? profileAccount.getFullName() : "" %>" required>
                        </div>

                        <div class="profile-field">
                            <label for="phone">Phone</label>
                            <input type="text" id="phone" name="phone"
                                   value="<%= profileAccount.getPhone() != null ? profileAccount.getPhone() : "" %>" required>
                        </div>

                        <div class="profile-field">
                            <label for="gender">please select gender<span class="profile-field__required">*</span></label>
                            <select id="gender" name="gender" required>
                                <option value="" disabled>Select Gender</option>
                                <option value="male" <%= profileAccount.isGender() ? "selected" : "" %>>Male</option>
                                <option value="female" <%= !profileAccount.isGender() ? "selected" : "" %>>Female</option>
                            </select>
                        </div>

                        <button type="submit" class="profile-submit">Update</button>
                    </form>
                </section>

                <!-- ===================== Email tab (placeholder) ===================== -->
                <section class="profile-panel" id="tab-email">
                    <h1>Email</h1>
                    <p class="profile-placeholder-note">
                        Not wired up to the backend yet -- this tab is a placeholder for now.
                    </p>
                    <div class="profile-field">
                        <label>Current email</label>
                        <input type="email" value="<%= profileAccount.getEmail() != null ? profileAccount.getEmail() : "" %>" disabled>
                    </div>
                </section>

                <!-- ===================== Password tab ===================== -->
                <section class="profile-panel <%= "password".equals(activeTab) ? "is-active" : "" %>" id="tab-password">
                    <h1>Update Password</h1>

                    <form method="post" action="<%= ctx %>/profile/password">

                        <div class="profile-field">
                            <label for="newPassword">New password</label>
                            <input type="password" id="newPassword" name="newPassword" required>
                        </div>

                        <div class="profile-field">
                            <label for="confirmPassword">re-enter password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required>
                        </div>

                        <button type="submit" class="profile-submit">Update</button>
                    </form>
                </section>

            </main>

        </div>
    </div>

    <script>
    (function () {
        var navItems = document.querySelectorAll('.profile-nav__item');
        var panels = document.querySelectorAll('.profile-panel');

        navItems.forEach(function (btn) {
            btn.addEventListener('click', function () {
                navItems.forEach(function (b) { b.classList.remove('is-active'); });
                panels.forEach(function (p) { p.classList.remove('is-active'); });

                btn.classList.add('is-active');
                var target = document.getElementById('tab-' + btn.dataset.tab);
                if (target) target.classList.add('is-active');
            });
        });
    })();
    </script>

</body>
</html>
