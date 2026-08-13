<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Account" %>
<%
    // This fragment is meant to be pulled into other pages with:
    //   <jsp:include page="${pageContext.request.contextPath}/view/common/header.jsp" />
    // All links below are context-path-relative, so it renders correctly
    // no matter how deep the including page lives (view/admin/, view/common/, etc.)
    // Pages that include this fragment must also link assets/css/common/header.css.
    Account headerAccount = (Account) session.getAttribute("currentAccount");
    String ctx = request.getContextPath();
%>
<header class="site-header">
    <div class="site-header__inner">

        <a class="site-header__brand" href="<%= ctx %>/">
            <span class="site-header__mark"><span class="dot"></span></span>
            <span>OCMS</span>
        </a>

        <nav class="site-header__nav">
            <a href="<%= ctx %>/">Home</a>
            <a href="<%= ctx %>/courses">Browse Course</a>
            <% if (headerAccount != null) { %>
            <a href="<%= ctx %>/view/course_learning/course_learning.jsp">My Learning</a>
            <% } %>
        </nav>

        <form class="site-header__search" action="<%= ctx %>/search" method="get">
            <select name="category" class="site-header__select" aria-label="Category">
                <option value="">Category</option>
                <option value="programming">Programming</option>
                <option value="design">Design</option>
                <option value="business">Business</option>
            </select>
            <input type="search" name="q" class="site-header__input" placeholder="Search">
            <button type="submit" class="site-header__search-btn" aria-label="Search">
                <svg viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="9" cy="9" r="6" stroke="currentColor" stroke-width="1.6"/>
                    <path d="M13.5 13.5L17.5 17.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                </svg>
            </button>
        </form>

        <div class="site-header__account">
            <% if (headerAccount != null) { %>

                <a class="site-header__icon-btn" href="<%= ctx %>/view/common/wishlist.jsp" title="Wishlist" aria-label="Wishlist">
                    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 20.2s-7.6-4.6-9.8-9.1C.6 7.7 2.3 4.4 5.6 4.4c1.9 0 3.4 1 4.4 2.5.9-1.5 2.5-2.5 4.4-2.5 3.3 0 5 3.3 3.4 6.7-2.2 4.5-9.8 9.1-9.8 9.1Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>
                    </svg>
                </a>

                <a class="site-header__icon-btn" href="<%= ctx %>/view/common/cart.jsp" title="Cart" aria-label="Cart">
                    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M3.5 4.5h2l2.1 11.1a1.6 1.6 0 0 0 1.6 1.3h8.1a1.6 1.6 0 0 0 1.6-1.3l1.4-7.4H6.4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                        <circle cx="9.5" cy="20.2" r="1.3" fill="currentColor"/>
                        <circle cx="17" cy="20.2" r="1.3" fill="currentColor"/>
                    </svg>
                </a>

                <div class="site-header__profile" id="headerProfile">
                    <button type="button" class="site-header__avatar" id="headerProfileToggle" aria-haspopup="true" aria-expanded="false" aria-label="Account menu">
                        <% if (headerAccount.getAvatar() != null && !headerAccount.getAvatar().isEmpty()) { %>
                            <img src="<%= headerAccount.getAvatar() %>" alt="">
                        <% } else { %>
                            <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <circle cx="12" cy="8.5" r="3.4" stroke="currentColor" stroke-width="1.6"/>
                                <path d="M4.8 19.2c1.4-3.2 4.1-4.9 7.2-4.9s5.8 1.7 7.2 4.9" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                            </svg>
                        <% } %>
                    </button>

                    <div class="site-header__dropdown" id="headerDropdown">
                        <a href="<%= ctx %>/view/common/profile.jsp">Change profile</a>
                        <a href="<%= ctx %>/logout">Logout</a>
                    </div>
                </div>

            <% } else { %>
                <a class="btn-login" href="<%= ctx %>/login">Login</a>
            <% } %>
        </div>

    </div>
</header>

<script>
(function () {
    // Self-contained so this fragment works even on pages that don't load app.js.
    var toggle = document.getElementById('headerProfileToggle');
    var dropdown = document.getElementById('headerDropdown');
    var wrap = document.getElementById('headerProfile');
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
