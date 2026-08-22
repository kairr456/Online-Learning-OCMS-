<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty teacher.fullName ? teacher.fullName : teacher.username} - Instructor Profile | OCMS</title>
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        /* Protect header SVGs from Bootstrap sizing resets */
        .site-header svg {
            width: 20px !important;
            height: 20px !important;
            max-width: 20px !important;
            max-height: 20px !important;
            display: inline-block !important;
        }
        .site-header__search-btn svg {
            width: 17px !important;
            height: 17px !important;
            max-width: 17px !important;
            max-height: 17px !important;
        }
        .site-header__icon-btn svg {
            width: 18px !important;
            height: 18px !important;
            max-width: 18px !important;
            max-height: 18px !important;
        }

        /* Footer styling matching homepage exactly */
        .site-footer {
            background: #0f172a !important;
            color: rgba(255, 255, 255, 0.72) !important;
            border-top: 1px solid rgba(255, 255, 255, 0.06) !important;
            margin-top: 60px !important;
        }
        .site-footer a {
            text-decoration: none !important;
            color: rgba(255, 255, 255, 0.7) !important;
            transition: color 0.15s ease !important;
        }
        .site-footer a:hover {
            color: #f59e0b !important;
        }
        .site-footer__brand a {
            color: #fff !important;
        }
        .site-footer__col h4 {
            color: #fff !important;
            font-size: 13px !important;
            font-weight: 700 !important;
            margin-bottom: 16px !important;
            text-transform: uppercase !important;
            letter-spacing: 0.8px !important;
        }
        .site-footer__col a {
            display: block !important;
            font-size: 13.5px !important;
            margin-bottom: 10px !important;
        }
        .site-footer__bottom {
            border-top: 1px solid rgba(255, 255, 255, 0.06) !important;
            padding: 20px 24px !important;
            text-align: center !important;
            font-size: 12.5px !important;
            color: rgba(255, 255, 255, 0.45) !important;
        }

        body {
            background-color: #f8fafc;
            color: #334155;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .teacher-header-banner {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            color: #fff;
            padding: 50px 0 60px 0;
            border-bottom: 1px solid #334155;
            position: relative;
        }

        .teacher-avatar-wrapper {
            position: relative;
            width: 140px;
            height: 140px;
            border-radius: 50%;
            padding: 4px;
            background: #fff;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            margin: 0 auto;
        }

        .teacher-avatar-img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
        }

        .teacher-avatar-placeholder {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            background: #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 4rem;
            color: #64748b;
        }

        .teacher-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
            color: #f8fafc;
        }

        .teacher-email {
            font-size: 1.05rem;
            color: #94a3b8;
            margin-bottom: 1rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .teacher-badges {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .teacher-badge {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: #e2e8f0;
            padding: 6px 16px;
            border-radius: 30px;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .teacher-badge.highlight {
            background: rgba(59, 130, 246, 0.2);
            border-color: #3b82f6;
            color: #60a5fa;
            font-weight: 600;
        }

        .readonly-notice {
            background: #e0f2fe;
            border-left: 4px solid #0284c7;
            color: #0369a1;
            padding: 12px 20px;
            border-radius: 6px;
            font-size: 0.95rem;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-heading {
            font-size: 1.5rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .course-card-readonly {
            background: #fff;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        .course-card-readonly:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 20px -3px rgba(0, 0, 0, 0.1);
        }

        .course-thumbnail-box {
            position: relative;
            width: 100%;
            height: 180px;
            overflow: hidden;
            background-color: #f1f5f9;
        }

        .course-thumbnail-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .course-category-tag {
            position: absolute;
            top: 12px;
            left: 12px;
            background: rgba(15, 23, 42, 0.85);
            color: #fff;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 20px;
            backdrop-filter: blur(4px);
        }

        .course-card-body {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .course-card-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 10px;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            height: 2.8rem;
        }

        .course-card-desc {
            font-size: 0.875rem;
            color: #64748b;
            margin-bottom: 16px;
            line-height: 1.5;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .course-card-meta {
            margin-top: auto;
            padding-top: 14px;
            border-top: 1px solid #f1f5f9;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .course-price {
            font-size: 1.15rem;
            font-weight: 700;
            color: #2563eb;
        }

        .course-rating {
            font-size: 0.9rem;
            color: #f59e0b;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .view-detail-btn {
            display: block;
            width: 100%;
            text-align: center;
            padding: 10px 16px;
            margin-top: 14px;
            background: #f8fafc;
            color: #3b82f6;
            border: 1px solid #bfdbfe;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.9rem;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .view-detail-btn:hover {
            background: #3b82f6;
            color: #fff;
            border-color: #3b82f6;
        }

        .empty-courses-card {
            background: #fff;
            border: 2px dashed #cbd5e1;
            border-radius: 16px;
            padding: 60px 20px;
            text-align: center;
            color: #64748b;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Teacher Profile Banner (Read-only) -->
    <header class="teacher-header-banner">
        <div class="container text-center">
            <div class="teacher-avatar-wrapper mb-3">
                <c:choose>
                    <c:when test="${not empty teacher.avatar}">
                        <img src="${teacher.avatar}" alt="${fn:escapeXml(teacher.fullName)}" class="teacher-avatar-img" onerror="this.onerror=null; this.src='https://via.placeholder.com/150x150.png?text=Avatar';">
                    </c:when>
                    <c:otherwise>
                        <div class="teacher-avatar-placeholder">
                            <i class="fas fa-user-tie"></i>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <h1 class="teacher-title">
                <c:out value="${not empty teacher.fullName ? teacher.fullName : teacher.username}" />
            </h1>
            
            <div class="teacher-email">
                <i class="fas fa-envelope text-primary"></i>
                <span><c:out value="${not empty teacher.email ? teacher.email : 'Chưa cập nhật email'}" /></span>
            </div>

            <div class="teacher-badges">
                <div class="teacher-badge highlight">
                    <i class="fas fa-chalkboard-teacher"></i>
                    <span>Instructor / Giảng viên</span>
                </div>
                <div class="teacher-badge">
                    <i class="fas fa-book-open text-warning"></i>
                    <span><strong>${totalCourses}</strong> Khóa học</span>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content Area -->
    <main class="py-5">
        <div class="container">
            
            <!-- Read-Only Notice -->
            <div class="readonly-notice shadow-sm">
                <i class="fas fa-info-circle fs-5"></i>
                <div>
                    <strong>Chế độ xem hồ sơ (Read-Only):</strong> Đây là trang thông tin công khai của giảng viên. Bạn có thể xem thông tin cá nhân và danh sách các khóa học được giảng dạy bởi giảng viên này.
                </div>
            </div>

            <!-- Course List Section -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="section-heading mb-0">
                    <i class="fas fa-layer-group text-primary"></i>
                    Danh sách khóa học của giảng viên (${totalCourses})
                </h2>
                <a href="${pageContext.request.contextPath}/courses" class="btn btn-outline-secondary btn-sm">
                    <i class="fas fa-arrow-left me-1"></i> Khám phá tất cả khóa học
                </a>
            </div>

            <c:choose>
                <c:when test="${not empty courses}">
                    <div class="row g-4">
                        <c:forEach var="course" items="${courses}">
                            <div class="col-xl-4 col-lg-4 col-md-6">
                                <div class="course-card-readonly">
                                    <div class="course-thumbnail-box">
                                        <c:choose>
                                            <c:when test="${not empty course.thumbnail}">
                                                <img src="${course.thumbnail}" alt="${fn:escapeXml(course.name)}" class="course-thumbnail-img" onerror="this.onerror=null; this.src='https://via.placeholder.com/350x200.png?text=Course+Thumbnail';">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://via.placeholder.com/350x200.png?text=Course+Thumbnail" alt="No Thumbnail" class="course-thumbnail-img">
                                            </c:otherwise>
                                        </c:choose>
                                        
                                        <span class="course-category-tag">
                                            <c:out value="${not empty categoryMap[course.categoryId] ? categoryMap[course.categoryId] : 'General'}" />
                                        </span>
                                    </div>

                                    <div class="course-card-body">
                                        <h3 class="course-card-title" title="${fn:escapeXml(course.name)}">
                                            <c:out value="${course.name}" />
                                        </h3>
                                        
                                        <p class="course-card-desc">
                                            <c:out value="${not empty course.description ? course.description : 'Không có mô tả chi tiết cho khóa học này.'}" />
                                        </p>

                                        <div class="course-card-meta">
                                            <div class="course-rating">
                                                <i class="fas fa-star"></i>
                                                <span><fmt:formatNumber value="${course.rating > 0 ? course.rating : 5.0}" pattern="0.0"/></span>
                                            </div>

                                            <div class="course-price">
                                                <c:choose>
                                                    <c:when test="${course.price > 0}">
                                                        <fmt:formatNumber value="${course.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-success fw-bold">Miễn phí</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <a href="${pageContext.request.contextPath}/course?id=${course.id}" class="view-detail-btn">
                                            <i class="fas fa-eye me-1"></i> Xem Chi Tiết Khóa Học
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-courses-card">
                        <i class="fas fa-folder-open mb-3 text-muted" style="font-size: 3.5rem;"></i>
                        <h4>Giảng viên chưa xuất bản khóa học nào</h4>
                        <p class="text-muted">Các khóa học mới sẽ được cập nhật tại đây khi giảng viên xuất bản.</p>
                        <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary mt-3">
                            <i class="fas fa-compass me-1"></i> Xem các khóa học khác
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="/view/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
