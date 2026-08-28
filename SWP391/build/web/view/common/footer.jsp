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
        </div>

        <div class="site-footer__col">
            <h4>Explore</h4>
            <a href="<%= ctx %>/">Home</a>
            <a href="<%= ctx %>/courses">Browse Course</a>
            <a href="<%= ctx %>/all-courses">My Learning</a>
        </div>

        <div class="site-footer__col">
            <h4>Support</h4>
            <a href="<%= ctx %>/view/contact-help/contact.jsp">Contact Us</a>
            <a href="<%= ctx %>/view/contact-help/faq.jsp">FAQs</a>
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
