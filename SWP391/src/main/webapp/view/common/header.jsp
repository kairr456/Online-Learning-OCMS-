<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Account" %>
<%@ page import="com.entity.Category" %>
<%@ page import="com.DAO.CategoryDAO" %>
<%@ page import="java.util.List" %>
<%
    // This fragment is meant to be pulled into other pages with:
    //   <jsp:include page="${pageContext.request.contextPath}/view/common/header.jsp" />
    // All links below are context-path-relative, so it renders correctly
    // no matter how deep the including page lives (view/admin/, view/common/, etc.)
    // Pages that include this fragment must also link assets/css/common/header.css.
    Account headerAccount = (Account) session.getAttribute("account");
    String ctx = request.getContextPath();

    // Category dropdown options come straight from the database now instead
    // of being hardcoded -- new categories show up here automatically.
    List<Category> headerCategories = new CategoryDAO().findAll();
%>
<style>
.site-header__nav-dropdown {
    position: relative;
    display: inline-flex;
    align-items: center;
    cursor: pointer;
}
.site-header__nav-dropdown .nav-dropdown-menu {
    display: none;
    position: absolute;
    top: 100%;
    left: 0;
    background-color: #fff;
    min-width: 180px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.08);
    border-radius: 8px;
    z-index: 1000;
    padding: 10px 0;
    border: 1px solid #eaeaea;
}
.site-header__nav-dropdown.show .nav-dropdown-menu {
    display: block;
}
.site-header__nav-dropdown .nav-dropdown-menu a {
    display: block;
    padding: 10px 20px;
    color: #333;
    text-decoration: none;
    white-space: nowrap;
    font-size: 14px;
    font-weight: 500;
}
.site-header__nav-dropdown .nav-dropdown-menu a:hover {
    background-color: #f8f9fa;
    color: #5d3fd3; /* primary color */
}
</style>
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
            <div class="site-header__menu" id="learningMenu">
                <a href="<%= ctx %>/all-courses" aria-haspopup="true" aria-expanded="false">My Learning</a>
                <div class="site-header__dropdown" id="learningDropdown">
                    <a href="<%= ctx %>/all-courses">All Courses</a>
                    <a href="<%= ctx %>/my-list">My List</a>
                    <a href="<%= ctx %>/wishlist">Wishlist</a>
                    <a href="<%= ctx %>/archived">Archived</a>
                    <a href="<%= ctx %>/learning-tools">Learning Tools</a>
                    <a href="<%= ctx %>/my-certificates">Certificates</a>
                </div>
            </div>
            <% } %>
        </nav>

        <form class="site-header__search" action="<%= ctx %>/courses" method="get">
            <select name="category" class="site-header__select" aria-label="Category">
                <option value="">Category</option>
                <% for (Category cat : headerCategories) { %>
                <option value="<%= cat.getId() %>"><%= cat.getName() %></option>
                <% } %>
            </select>
            <input
                type="search"
                name="courseName"
                class="site-header__input"
                placeholder="Search courses"
                value="<%= request.getParameter("courseName") != null ? request.getParameter("courseName") : "" %>"
            >
            <button type="submit" class="site-header__search-btn" aria-label="Search">
                <svg viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="9" cy="9" r="6" stroke="currentColor" stroke-width="1.6"/>
                    <path d="M13.5 13.5L17.5 17.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                </svg>
            </button>
        </form>

        <div class="site-header__account d-flex align-items-center">
            <% if (headerAccount != null) { %>

                <% if (headerAccount.getRoleId() == 2) { %>
                <div class="site-header__nav-dropdown" style="margin-right: 15px;" id="courseDashboardDropdown">
                    <a href="#" class="nav-dropdown-toggle" onclick="event.preventDefault(); document.getElementById('courseDashboardDropdown').classList.toggle('show');" style="color: #fff; text-decoration: none; font-weight: 500; display: flex; align-items: center;">
                        Course Dashboard 
                        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 4px;"><polyline points="6 9 12 15 18 9"></polyline></svg>
                    </a>
                    <div class="nav-dropdown-menu">
                        <a href="<%= ctx %>/course-dashboard">Dashboard Home</a>
                        <a href="<%= ctx %>/lesson">Course Add</a>
                        <a href="<%= ctx %>/dashboard-quiz">Dashboard Quiz</a>
                        <a href="<%= ctx %>/teacher-certificates">Course Certificate</a>
                    </div>
                </div>
                <script>
                    // Close dropdown when clicking outside
                    document.addEventListener('click', function(e) {
                        var dropdown = document.getElementById('courseDashboardDropdown');
                        if (dropdown && !dropdown.contains(e.target)) {
                            dropdown.classList.remove('show');
                        }
                    });
                </script>
                <% } %>

                <a class="site-header__icon-btn" href="<%= ctx %>/wishlist" title="Wishlist" aria-label="Wishlist">
                    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 20.2s-7.6-4.6-9.8-9.1C.6 7.7 2.3 4.4 5.6 4.4c1.9 0 3.4 1 4.4 2.5.9-1.5 2.5-2.5 4.4-2.5 3.3 0 5 3.3 3.4 6.7-2.2 4.5-9.8 9.1-9.8 9.1Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>
                    </svg>
                </a>

                <a class="site-header__icon-btn" href="<%= ctx %>/cart" title="Cart" aria-label="Cart">
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
                        <% if (headerAccount.getRoleId() == 3) { %>
                            <a href="<%= ctx %>/my-purchases">My Purchases</a>
                        <% } else if (headerAccount.getRoleId() == 2) { %>
                            <a href="<%= ctx %>/teacher-transactions">Sales Report</a>
                        <% } %>
                        <a href="<%= ctx %>/view/common/profile.jsp">Account</a>
                        <% if (headerAccount.getRoleId() == 2) { %>
                        <a href="<%= ctx %>/wallet"><i class="fa-solid fa-wallet me-1" style="color: #f59e0b;"></i> My Wallet</a>
                        <% } %>
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
