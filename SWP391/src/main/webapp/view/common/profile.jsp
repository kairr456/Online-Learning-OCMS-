<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Account" %>
<%@ page import="com.DAO.AccountDAO" %>
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

    String successMessage = null;
    String errorMessage = null;

    // This page handles its own POST (the Info form submits back to itself)
    // rather than going through a separate controller servlet -- same
    // direct-DAO-in-JSP pattern already used by header.jsp for categories.
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String genderParam = request.getParameter("gender");

        if (fullName == null || fullName.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || genderParam == null || genderParam.trim().isEmpty()) {
            errorMessage = "Please fill in all fields.";
        } else {
            boolean genderValue = "male".equalsIgnoreCase(genderParam);
            boolean updated = new AccountDAO().updateBasicInfo(
                    profileAccount.getId(), fullName.trim(), phone.trim(), genderValue);

            if (updated) {
                // Keep the session copy in sync so the header/dashboard
                // reflect the change immediately, without waiting for the
                // next login.
                profileAccount.setFullName(fullName.trim());
                profileAccount.setPhone(phone.trim());
                profileAccount.setGender(genderValue);
                session.setAttribute("account", profileAccount);
                successMessage = "Profile updated successfully.";
            } else {
                errorMessage = "Could not update your profile. Please try again.";
            }
        }
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
                    <button type="button" class="profile-nav__item is-active" data-tab="info">Info</button>
                    <button type="button" class="profile-nav__item" data-tab="email">Email</button>
                    <button type="button" class="profile-nav__item" data-tab="password">Password</button>
                </nav>
            </aside>

            <main class="profile-main">

                <!-- ===================== Info tab ===================== -->
                <section class="profile-panel is-active" id="tab-info">
                    <h1>Update your Info</h1>

                    <% if (successMessage != null) { %>
                    <div class="profile-alert profile-alert--success"><%= successMessage %></div>
                    <% } %>
                    <% if (errorMessage != null) { %>
                    <div class="profile-alert profile-alert--error"><%= errorMessage %></div>
                    <% } %>

                    <form method="post" action="<%= ctx %>/view/common/profile.jsp">

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

                <!-- ===================== Password tab (placeholder) ===================== -->
                <section class="profile-panel" id="tab-password">
                    <h1>Password</h1>
                    <p class="profile-placeholder-note">
                        Not wired up to the backend yet -- this tab is a placeholder for now.
                    </p>
                    <div class="profile-field">
                        <label>Current password</label>
                        <input type="password" placeholder="••••••••" disabled>
                    </div>
                    <div class="profile-field">
                        <label>New password</label>
                        <input type="password" placeholder="••••••••" disabled>
                    </div>
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
