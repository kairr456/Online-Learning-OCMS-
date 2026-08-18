<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // This fragment is meant to be pulled into other pages with:
    //   <jsp:include page="${pageContext.request.contextPath}/view/common/footer.jsp" />
    // Same context-path pattern as header.jsp so links resolve correctly
    // regardless of how deep the including page lives. Unlike the header,
    // this has no session-dependent state -- it's the same for every visitor.
    String ctx = request.getContextPath();
%>
<footer class="site-footer">
    <div class="site-footer__inner">

        <div class="site-footer__brand">
            <a class="site-footer__mark" href="<%= ctx %>/">
                <span class="site-footer__dot-wrap"><span class="dot"></span></span>
                <span>OCMS</span>
            </a>
            <p class="site-footer__tagline">Learn smarter with courses built for busy schedules.</p>

            <div class="site-footer__social">
                <a href="#" aria-label="Twitter">
                    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M22 5.9c-.7.3-1.5.6-2.3.7.8-.5 1.5-1.3 1.8-2.3-.8.5-1.7.8-2.6 1a4.1 4.1 0 0 0-7 3.7A11.6 11.6 0 0 1 3.4 4.6a4.1 4.1 0 0 0 1.3 5.5c-.7 0-1.3-.2-1.9-.5v.1a4.1 4.1 0 0 0 3.3 4 4.2 4.2 0 0 1-1.9.1 4.1 4.1 0 0 0 3.8 2.9A8.3 8.3 0 0 1 2 18.4a11.6 11.6 0 0 0 6.3 1.9c7.5 0 11.7-6.3 11.7-11.7v-.5c.8-.6 1.5-1.3 2-2.2Z" stroke="currentColor" stroke-width="1.3" stroke-linejoin="round"/>
                    </svg>
                </a>
                <a href="#" aria-label="GitHub">
                    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 2a10 10 0 0 0-3.2 19.5c.5.1.7-.2.7-.5v-1.7c-2.8.6-3.4-1.3-3.4-1.3-.4-1.2-1.1-1.5-1.1-1.5-.9-.6.1-.6.1-.6 1 .1 1.5 1 1.5 1 .9 1.6 2.4 1.1 3 .8.1-.7.3-1.1.6-1.4-2.2-.3-4.6-1.1-4.6-5 0-1.1.4-2 1-2.7-.1-.3-.5-1.3.1-2.7 0 0 .8-.3 2.7 1a9.1 9.1 0 0 1 4.9 0c1.9-1.3 2.7-1 2.7-1 .6 1.4.2 2.4.1 2.7.6.7 1 1.6 1 2.7 0 3.9-2.4 4.7-4.6 5 .3.3.6.9.6 1.8v2.6c0 .3.2.6.7.5A10 10 0 0 0 12 2Z" stroke="currentColor" stroke-width="1.3" stroke-linejoin="round"/>
                    </svg>
                </a>
                <a href="#" aria-label="LinkedIn">
                    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.3"/>
                        <path d="M7.5 10.2v6.3M7.5 7.6v.03M11.5 16.5v-3.7c0-1.3.9-2.3 2.2-2.3 1.2 0 1.8.8 1.8 2.3v3.7" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </a>
            </div>
        </div>

        <div class="site-footer__col">
            <h4>Explore</h4>
            <a href="<%= ctx %>/">Home</a>
            <a href="<%= ctx %>/courses">Browse Course</a>
            <a href="<%= ctx %>/all-courses">My Learning</a>
        </div>

        <div class="site-footer__col">
            <h4>Support</h4>
            <a href="<%= ctx %>/view/common/help.jsp">Help Center</a>
            <a href="<%= ctx %>/view/common/contact.jsp">Contact Us</a>
            <a href="<%= ctx %>/view/common/faq.jsp">FAQs</a>
        </div>

        <div class="site-footer__col">
            <h4>Legal</h4>
            <a href="<%= ctx %>/view/common/terms.jsp">Terms of Service</a>
            <a href="<%= ctx %>/view/common/privacy.jsp">Privacy Policy</a>
        </div>

    </div>

    <div class="site-footer__bottom">
        <span>&copy; <%= java.time.Year.now() %> OCMS. All rights reserved.</span>
    </div>
</footer>
