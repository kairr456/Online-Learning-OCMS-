<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Transaction Log | OCMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-dark: #1a1a2e;
            --accent-yellow: #ffc107;
            --bg-color: #f4f6f9;
            --white: #ffffff;
            --text-main: #333333;
            --text-muted: #6c757d;
            --border-light: #e9ecef;
        }
        body { background-color: var(--bg-color); font-family: 'Inter', 'Segoe UI', sans-serif; margin: 0; padding: 0; }
        .dashboard-container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
        .dashboard-container h1 { color: var(--primary-dark); font-size: 26px; margin-bottom: 24px; }
        .summary-grid { display: flex; gap: 20px; margin-bottom: 24px; flex-wrap: wrap; }
        .summary-card { background: var(--white); border-radius: 12px; padding: 20px 24px; flex: 1; min-width: 200px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
        .summary-value { font-size: 26px; font-weight: 700; color: var(--primary-dark); }
        .summary-label { font-size: 13px; color: var(--text-muted); margin-top: 4px; }
        .table-card { background: var(--white); border-radius: 12px; padding: 20px 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 12px 14px; border-bottom: 1px solid var(--border-light); font-size: 14px; color: var(--text-main); }
        th { background: #fafbfc; color: var(--text-muted); font-weight: 600; }
        tr:last-child td { border-bottom: none; }
        .num { text-align: right; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="dashboard-container">
        <h1>Transaction Log</h1>

        <!-- Tổng doanh thu -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="summary-value">${summary.totalSalesCount}</div>
                <div class="summary-label">Total Sales</div>
            </div>
            <div class="summary-card">
                <div class="summary-value"><fmt:formatNumber value="${summary.totalRevenue}" pattern="#,##0"/>₫</div>
                <div class="summary-label">Total Revenue</div>
            </div>
        </div>

        <!-- Số lần khóa được mua (không hiện người mua) -->
        <div class="table-card">
            <table>
                <thead>
                    <tr><th>Course</th><th class="num">Times Sold</th><th class="num">Revenue</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="sale" items="${sales}">
                        <tr>
                            <td>${sale.courseName}</td>
                            <td class="num">${sale.totalSales}</td>
                            <td class="num"><fmt:formatNumber value="${sale.totalRevenue}" pattern="#,##0"/>₫</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty sales}">
                        <tr><td colspan="3" style="text-align:center;">No courses yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>