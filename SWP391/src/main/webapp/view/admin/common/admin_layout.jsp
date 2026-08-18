<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Common CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/common.css?v=2">
    <!-- Common Header CSS (site-header*, dùng cho header admin) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css?v=2">
    <!-- Layout CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/admin_layout.css?v=2">
    <!-- Page CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/dashboard.css?v=2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin_css/payouts.css?v=2">
</head>
<body>

    <!-- 1. Header nằm trên cùng kéo dài hết chiều ngang -->
    <jsp:include page="header.jsp"/>

    <!-- 2. Phần thân chia làm 2 cột: Sidebar bên trái & Content bên phải -->
    <div class="admin-container">
        <jsp:include page="sidebar.jsp"/>

        <main class="main-content">
            <jsp:include page="/view/admin/main_content/${contentPage}"/>
        </main>
    </div>

</body>
</html>