<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Certificate | OCMS</title>
    <style>
        body { background: #f4f6f9; font-family: 'Georgia','Times New Roman',serif; margin: 0; padding: 0; }
        .toolbar { position: fixed; top: 14px; right: 20px; display: flex; gap: 10px; z-index: 100; }
        .toolbar button { padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-family: 'Inter',sans-serif; font-weight: 600; }
        .btn-print { background: #5d3fd3; color: #fff; }
        .btn-back { background: #fff; color: #333; border: 1px solid #ccc; }
        .wrap { display: flex; justify-content: center; padding: 30px 20px; }
        .cert-page { width: 1000px; height: 707px; position: relative; background-size: 100% 100%; background-position: center; background-repeat: no-repeat; border: 1px solid #ddd; box-shadow: 0 6px 24px rgba(0,0,0,.12); box-sizing: border-box; }
        .cert-default { background: linear-gradient(135deg, #fff8e1, #ffecb3); }
        .cert-content {
            position: absolute;
            inset: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 40px 60px;
            box-sizing: border-box;
        }
        .cert-title { font-size: 34px; font-weight: 700; color: #1a1a2e; letter-spacing: 1px; margin-bottom: 6px; }
        .cert-sub { font-size: 15px; color: #6c757d; margin: 6px 0; }
        .cert-name { font-size: 40px; font-weight: 700; color: #5d3fd3; margin: 8px 0; }
        .cert-course { font-size: 24px; color: #333; font-weight: 600; margin: 6px 0 16px; }
        .cert-meta { font-size: 14px; color: #6c757d; margin-top: 8px; }
        .cert-code { font-size: 12px; letter-spacing: 1.5px; color: #888; margin-top: 4px; }
        @media print {
            @page {
                size: landscape;
                margin: 0;
            }
            * {
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
                color-adjust: exact !important;
            }
            html, body {
                width: 297mm !important;
                height: 210mm !important;
                margin: 0 !important;
                padding: 0 !important;
                background: #ffffff !important;
                overflow: hidden !important;
            }
            .toolbar {
                display: none !important;
            }
            .wrap {
                padding: 0 !important;
                margin: 0 !important;
                width: 297mm !important;
                height: 210mm !important;
            }
            .cert-page {
                width: 297mm !important;
                height: 210mm !important;
                max-width: none !important;
                max-height: none !important;
                border: none !important;
                box-shadow: none !important;
                margin: 0 !important;
                padding: 0 !important;
                page-break-before: avoid !important;
                page-break-after: avoid !important;
                page-break-inside: avoid !important;
                background-size: 100% 100% !important;
            }
        }
    </style>
</head>
<body>
    <div class="toolbar">
        <button class="btn-back" onclick="location.href='${pageContext.request.contextPath}/my-certificates'">Back</button>
        <button class="btn-print" onclick="window.print()">Print</button>
    </div>

    <div class="wrap">
        <c:choose>
            <c:when test="${not empty cert.backgroundUrl}">
                <div class="cert-page" style="background-image:url('${cert.backgroundUrl}');">
            </c:when>
            <c:otherwise>
                <div class="cert-page cert-default">
            </c:otherwise>
        </c:choose>
            <div class="cert-content">
                <div class="cert-title">${not empty cert.title ? cert.title : 'Certificate of Completion'}</div>
                <div class="cert-sub">This is to certify that</div>
                <div class="cert-name">${cert.studentName}</div>
                <div class="cert-sub">has successfully completed the course</div>
                <div class="cert-course">${cert.courseName}</div>
                <div class="cert-meta">Issued on <fmt:formatDate value="${cert.issuedDateAsDate}" pattern="dd MMMM yyyy" /></div>
                <div class="cert-code">Certificate ID: ${cert.certificateCode}</div>
            </div>
        </div>
    </div>
</body>
</html>