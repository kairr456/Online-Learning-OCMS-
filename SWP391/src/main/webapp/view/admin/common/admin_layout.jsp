<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — OCMS</title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">

    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Common CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/common.css?v=6">
    <!-- Header CSS (site-header*) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css?v=6">
    <!-- Layout CSS (tokens, sidebar, table, modal, etc.) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/admin_layout.css?v=6">
    <!-- Page-specific CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/dashboard.css?v=6">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/payouts.css?v=9">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/blog_categories.css?v=6">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/blog_approval.css?v=8">

    <!-- Chart.js (CDN) -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
</head>
<body>

    <!-- 1. Header — full width top bar -->
    <jsp:include page="header.jsp"/>

    <!-- 2. Body: sidebar left + content right -->
    <div class="admin-container">
        <jsp:include page="sidebar.jsp"/>

        <main class="main-content">
            <jsp:include page="/view/admin/main_content/${contentPage}"/>
        </main>
    </div>

</body>
</html>