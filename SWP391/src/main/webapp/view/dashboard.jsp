<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Account" %>
<%
    Account currentAccount = (Account) session.getAttribute("currentAccount");
    if (currentAccount == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String initials = "?";
    if (currentAccount.getFullName() != null && !currentAccount.getFullName().isEmpty()) {
        String[] parts = currentAccount.getFullName().trim().split("\\s+");
        initials = parts.length > 1
                ? ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
                : parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
    }
    String roleName;
    switch (currentAccount.getRoleId()) {
        case 1: roleName = "Administrator"; break;
        case 2: roleName = "Staff"; break;
        default: roleName = "Member";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard · OCMS</title>
    <link rel="stylesheet" href="../../assets/css/styles.css">
</head>
<body>

<div class="app-shell">

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar__mark"><span class="dot"></span>OCMS</div>

        <nav>
            <p class="nav-group__label">Overview</p>
            <a class="nav-link is-active" href="dashboard.jsp"><span class="ico"></span>Dashboard</a>
            <a class="nav-link" href="#"><span class="ico"></span>Accounts</a>
            <a class="nav-link" href="#"><span class="ico"></span>Activity</a>

            <p class="nav-group__label">Manage</p>
            <a class="nav-link" href="#"><span class="ico"></span>Settings</a>
            <a class="nav-link" href="#"><span class="ico"></span>Profile</a>
        </nav>

        <div class="sidebar__footer">
            <a class="logout-link" href="logout">&#8592; Sign out</a>
        </div>
    </aside>

    <!-- Main -->
    <div class="main">
        <header class="topbar">
            <div>
                <h1>Dashboard</h1>
                <p class="topbar__sub">Here's what's happening with your account today.</p>
            </div>

            <div class="profile-chip">
                <div class="avatar">
                    <% if (currentAccount.getAvatar() != null && !currentAccount.getAvatar().isEmpty()) { %>
                        <img src="<%= currentAccount.getAvatar() %>" alt="">
                    <% } else { %>
                        <%= initials %>
                    <% } %>
                </div>
                <div class="profile-chip__meta">
                    <div class="profile-chip__name"><%= currentAccount.getFullName() != null ? currentAccount.getFullName() : currentAccount.getUsername() %></div>
                    <div class="profile-chip__role"><%= roleName %></div>
                </div>
            </div>
        </header>

        <div class="content">

            <!-- Stat cards -->
            <div class="stat-grid">
                <div class="stat-card" style="--bar-color:var(--amber);">
                    <p class="stat-card__label">Account status</p>
                    <p class="stat-card__value"><%= currentAccount.isActive() ? "Active" : "Inactive" %></p>
                    <p class="stat-card__delta"><%= currentAccount.isActive() ? "Good standing" : "Needs attention" %></p>
                </div>
                <div class="stat-card" style="--bar-color:#2F9E64;">
                    <p class="stat-card__label">Role</p>
                    <p class="stat-card__value"><%= roleName %></p>
                    <p class="stat-card__delta" style="color:var(--slate-600);">Role ID #<%= currentAccount.getRoleId() %></p>
                </div>
                <div class="stat-card" style="--bar-color:#5B6B82;">
                    <p class="stat-card__label">Sessions this week</p>
                    <p class="stat-card__value">1</p>
                    <p class="stat-card__delta" style="color:var(--slate-600);">Current session started now</p>
                </div>
            </div>

            <!-- Panels -->
            <div class="panel-grid">
                <div class="panel">
                    <div class="panel__head">
                        <h2>Recent activity</h2>
                    </div>
                    <div class="panel__body">
                        <table class="simple-table">
                            <thead>
                                <tr><th>Event</th><th>Detail</th><th>Status</th></tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Signed in</td>
                                    <td>Session created for <%= currentAccount.getUsername() %></td>
                                    <td><span class="badge badge--success">Success</span></td>
                                </tr>
                                <tr>
                                    <td>Profile loaded</td>
                                    <td>Account details fetched</td>
                                    <td><span class="badge badge--muted">Info</span></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel__head">
                        <h2>Your profile</h2>
                    </div>
                    <div class="panel__body">
                        <ul class="profile-list">
                            <li><span class="k">Username</span><span class="v"><%= currentAccount.getUsername() %></span></li>
                            <li><span class="k">Email</span><span class="v"><%= currentAccount.getEmail() != null ? currentAccount.getEmail() : "—" %></span></li>
                            <li><span class="k">Phone</span><span class="v"><%= currentAccount.getPhone() != null ? currentAccount.getPhone() : "—" %></span></li>
                            <li><span class="k">Gender</span><span class="v"><%= currentAccount.isGender() ? "Male" : "Female" %></span></li>
                        </ul>
                    </div>
                </div>
            </div>

        </div>
    </div>

</div>

<script src="../../assets/js/app.js"></script>
</body>
</html>
