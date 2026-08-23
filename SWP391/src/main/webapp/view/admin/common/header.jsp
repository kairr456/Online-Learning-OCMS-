<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Account" %>
<%
    Account adminHeaderAccount = (Account) session.getAttribute("account");
    String adminCtx = request.getContextPath();
%>
<header class="site-header admin-glass-header">
    <div class="site-header__inner">

        <!-- Brand (mobile / collapsed) -->
        <a class="site-header__brand" href="<%= adminCtx %>/admin/dashboard">
            <span class="site-header__mark"><span class="dot"></span></span>
            <span>OCMS</span>
            <span class="admin-header-badge">Admin</span>
        </a>

        <!-- Right: user menu -->
        <div class="site-header__account">
            <div class="site-header__profile" id="adminHeaderProfile">

                <button type="button"
                        class="site-header__avatar admin-avatar-btn"
                        id="adminHeaderProfileToggle"
                        aria-haspopup="true"
                        aria-expanded="false"
                        aria-label="Account menu">

                    <% if (adminHeaderAccount != null
                            && adminHeaderAccount.getAvatar() != null
                            && !adminHeaderAccount.getAvatar().isEmpty()) { %>
                        <img src="<%= adminHeaderAccount.getAvatar() %>" alt="">
                    <% } else { %>
                        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="12" cy="8.5" r="3.4" stroke="currentColor" stroke-width="1.6"/>
                            <path d="M4.8 19.2c1.4-3.2 4.1-4.9 7.2-4.9s5.8 1.7 7.2 4.9"
                                  stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                        </svg>
                    <% } %>

                    <% if (adminHeaderAccount != null && adminHeaderAccount.getFullName() != null) { %>
                        <span class="admin-header-username"><%= adminHeaderAccount.getFullName() %></span>
                    <% } %>

                    <i class="fa-solid fa-chevron-down admin-header-caret"></i>
                </button>

                <div class="site-header__dropdown admin-header-dropdown" id="adminHeaderDropdown">
                    <div class="admin-dropdown-info">
                        <div class="admin-dropdown-avatar">
                            <% if (adminHeaderAccount != null
                                    && adminHeaderAccount.getAvatar() != null
                                    && !adminHeaderAccount.getAvatar().isEmpty()) { %>
                                <img src="<%= adminHeaderAccount.getAvatar() %>" alt="">
                            <% } else { %>
                                <i class="fa-regular fa-user"></i>
                            <% } %>
                        </div>
                        <div>
                            <div class="admin-dropdown-name">
                                <%= adminHeaderAccount != null ? adminHeaderAccount.getFullName() : "Admin" %>
                            </div>
                            <div class="admin-dropdown-role">Administrator</div>
                        </div>
                    </div>
                    <div class="admin-dropdown-divider"></div>
                    <a href="<%= adminCtx %>/" class="admin-dropdown-item">
                        <i class="fa-regular fa-globe"></i> View Website
                    </a>
                    <a href="<%= adminCtx %>/logout" class="admin-dropdown-item admin-dropdown-item--danger">
                        <i class="fa-regular fa-right-from-bracket"></i> Logout
                    </a>
                </div>
            </div>
        </div>

    </div>
</header>

<style>
/* ── Admin Glass Header ────────────────────────── */
/* Fix: override max-width from common header.css for admin full-width */
.admin-glass-header .site-header__inner {
    max-width: 100%;
    padding: 0 20px 0 24px;
}

/* CSS var bridge for common/header.css tokens */
:root {
    --ink-900: #0f172a;
    --amber:   #D8A24A;
    --amber-dark: #B9812E;
}


.admin-glass-header {
    background: rgba(15,23,42,.92) !important;
    backdrop-filter: blur(14px) !important;
    -webkit-backdrop-filter: blur(14px) !important;
    border-bottom: 1px solid rgba(216,162,74,.22) !important;
    box-shadow: 0 1px 20px rgba(15,23,42,.3) !important;
}

.admin-glass-header .site-header__brand span:not(.site-header__mark):not(.dot) {
    color: #f8fafc !important;
    font-weight: 700;
}

.admin-glass-header .site-header__mark {
    background: linear-gradient(135deg, #D8A24A, #B9812E) !important;
}

.admin-header-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 20px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .8px;
    background: rgba(216,162,74,.18);
    color: #D8A24A;
    border: 1px solid rgba(216,162,74,.3);
    margin-left: 4px;
}

.admin-avatar-btn {
    display: inline-flex !important;
    align-items: center !important;
    gap: 8px !important;
    padding: 6px 12px 6px 6px !important;
    border-radius: 50px !important;
    background: rgba(255,255,255,.06) !important;
    border: 1px solid rgba(255,255,255,.12) !important;
    transition: background .18s ease !important;
    color: #f1f5f9 !important;
    cursor: pointer;
}

.admin-avatar-btn:hover {
    background: rgba(255,255,255,.12) !important;
}

.admin-avatar-btn img,
.admin-avatar-btn svg {
    width: 30px !important;
    height: 30px !important;
    border-radius: 50% !important;
    object-fit: cover;
}

.admin-header-username {
    font-size: 13px;
    font-weight: 600;
    max-width: 120px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.admin-header-caret {
    font-size: 10px;
    opacity: .6;
    transition: transform .2s;
}

.admin-avatar-btn[aria-expanded="true"] .admin-header-caret {
    transform: rotate(180deg);
}

/* Dropdown */
.admin-header-dropdown {
    min-width: 220px !important;
    padding: 8px !important;
    border-radius: 14px !important;
    background: rgba(15,23,42,.96) !important;
    border: 1px solid rgba(255,255,255,.1) !important;
    box-shadow: 0 20px 50px rgba(15,23,42,.4) !important;
    backdrop-filter: blur(16px) !important;
    -webkit-backdrop-filter: blur(16px) !important;
}

.admin-dropdown-info {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 10px 12px;
}

.admin-dropdown-avatar {
    width: 38px;
    height: 38px;
    border-radius: 10px;
    background: rgba(216,162,74,.15);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #D8A24A;
    font-size: 16px;
    flex-shrink: 0;
    overflow: hidden;
}

.admin-dropdown-avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.admin-dropdown-name {
    font-size: 13.5px;
    font-weight: 600;
    color: #f1f5f9;
    white-space: nowrap;
}

.admin-dropdown-role {
    font-size: 11px;
    color: rgba(148,163,184,.7);
    margin-top: 2px;
}

.admin-dropdown-divider {
    height: 1px;
    background: rgba(255,255,255,.08);
    margin: 4px 0;
}

.admin-dropdown-item {
    display: flex !important;
    align-items: center !important;
    gap: 9px !important;
    padding: 9px 12px !important;
    border-radius: 9px !important;
    font-size: 13px !important;
    font-weight: 500 !important;
    color: #94a3b8 !important;
    text-decoration: none !important;
    transition: background .15s, color .15s !important;
}

.admin-dropdown-item:hover {
    background: rgba(255,255,255,.07) !important;
    color: #f1f5f9 !important;
}

.admin-dropdown-item--danger:hover {
    background: rgba(239,68,68,.12) !important;
    color: #f87171 !important;
}
</style>

<script src="<%= adminCtx %>/assets/js/admin/admin-header.js"></script>
