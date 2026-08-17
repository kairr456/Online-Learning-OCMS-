<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Account" %>
<%
    // Header admin dùng chung style site-header* của header trang public
    // (chỉ lấy màu + logo + dropdown user). Cần link assets/css/common/header.css
    // ở trang chứa (admin_layout.jsp).
    Account adminHeaderAccount = (Account) session.getAttribute("account");
    String adminCtx = request.getContextPath();
%>
<header class="site-header">
    <div class="site-header__inner">

        <a class="site-header__brand" href="<%= adminCtx %>/admin/dashboard">
            <span class="site-header__mark"><span class="dot"></span></span>
            <span>OCMS</span>
        </a>

        <div class="site-header__account">
            <div class="site-header__profile" id="adminHeaderProfile">
                <button type="button" class="site-header__avatar" id="adminHeaderProfileToggle"
                        aria-haspopup="true" aria-expanded="false" aria-label="Account menu">
                    <% if (adminHeaderAccount != null && adminHeaderAccount.getAvatar() != null && !adminHeaderAccount.getAvatar().isEmpty()) { %>
                        <img src="<%= adminHeaderAccount.getAvatar() %>" alt="">
                    <% } else { %>
                        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="12" cy="8.5" r="3.4" stroke="currentColor" stroke-width="1.6"/>
                            <path d="M4.8 19.2c1.4-3.2 4.1-4.9 7.2-4.9s5.8 1.7 7.2 4.9" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                        </svg>
                    <% } %>
                </button>

                <div class="site-header__dropdown" id="adminHeaderDropdown">
                    <a href="<%= adminCtx %>/">View Website</a>
                    <a href="<%= adminCtx %>/logout">Logout</a>
                </div>
            </div>
        </div>

    </div>
</header>

<script>
(function () {
    // Tự chứa (không phụ thuộc app.js) — copy từ header.jsp chung, đổi id tránh trùng.
    var toggle = document.getElementById('adminHeaderProfileToggle');
    var dropdown = document.getElementById('adminHeaderDropdown');
    var wrap = document.getElementById('adminHeaderProfile');
    if (!toggle || !dropdown || !wrap) return;

    function close() {
        dropdown.classList.remove('is-open');
        toggle.setAttribute('aria-expanded', 'false');
    }

    toggle.addEventListener('click', function (e) {
        e.stopPropagation();
        var willOpen = !dropdown.classList.contains('is-open');
        dropdown.classList.toggle('is-open', willOpen);
        toggle.setAttribute('aria-expanded', String(willOpen));
    });

    document.addEventListener('click', function (e) {
        if (!wrap.contains(e.target)) close();
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') close();
    });
})();
</script>
