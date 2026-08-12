<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Account" %>
<%
    // This fragment is meant to be pulled into other pages with:
    //   <jsp:include page="${pageContext.request.contextPath}/view/common/header.jsp" />
    // All links below are context-path-relative, so it renders correctly
    // no matter how deep the including page lives (view/admin/, view/common/, etc.)
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
            <a href="<%= ctx %>/view/common/browse-course.jsp">Browse Course</a>
            <% if (headerAccount != null) { %>
            <a href="<%= ctx %>/view/common/my-learning.jsp">My Learning</a>
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
                <a class="site-header__avatar" href="<%= ctx %>/view/common/profile.jsp" title="Change profile" aria-label="Change profile">
                    <% if (headerAccount.getAvatar() != null && !headerAccount.getAvatar().isEmpty()) { %>
                        <img src="<%= headerAccount.getAvatar() %>" alt="">
                    <% } else { %>
                        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="12" cy="8.5" r="3.4" stroke="currentColor" stroke-width="1.6"/>
                            <path d="M4.8 19.2c1.4-3.2 4.1-4.9 7.2-4.9s5.8 1.7 7.2 4.9" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                        </svg>
                    <% } %>
                </a>
            <% } else { %>
                <a class="btn-login" href="<%= ctx %>/login">Login</a>
            <% } %>
        </div>

    </div>
</header>
