<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Blog" %>
<%@ page import="com.DAO.BlogDAO" %>
<%@ page import="java.util.List" %>
<%
    List<Blog> allBlogs = new BlogDAO().getAllBlogs();
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blogs · OCMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
</head>
<body>

    <jsp:include page="/view/common/header.jsp" />

   <h1>Blogs here</h1>
    <jsp:include page="/view/common/footer.jsp" />

</body>
</html>
