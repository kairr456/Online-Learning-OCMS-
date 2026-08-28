<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // This is now the app's entry point. Visiting the context root ("/")
    // lands here (Tomcat's default welcome-file order tries index.html,
    // then index.htm, then index.jsp) and forwards straight into homepage.jsp.
    // A server-side forward keeps the URL as "/" while rendering homepage.jsp.
    request.getRequestDispatcher("/view/common/home/homepage.jsp").forward(request, response);
%>
