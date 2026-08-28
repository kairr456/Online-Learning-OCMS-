<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán thành công · OCMS</title>
    <meta name="description" content="Đơn hàng của bạn đã được thanh toán thành công trên nền tảng OCMS">

    <!-- CSS chung & FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">

    <!-- Order Success CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkoutcart/order-success.css">
</head>
<body>

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <main class="order-success-container">

        <!-- 1. HERO BANNER: SUCCESS STATE -->
        <section class="success-hero">
            <div class="success-icon-wrap">
                <i class="fa-solid fa-check"></i>
            </div>
            <h1 class="success-hero-title">Thanh toán đơn hàng thành công!</h1>
            <p class="success-hero-subtitle">
                Cảm ơn bạn đã tin tưởng và đồng hành cùng OCMS. Khóa học đã được mở khóa và kích hoạt ngay vào tài khoản học tập của bạn.
            </p>
        </section>

        <!-- 2. MAIN LAYOUT: UNLOCKED COURSES -->
        <div class="success-layout-grid">

            <!-- UNLOCKED COURSES CARD -->
            <section class="success-card">
                <div class="success-card-header">
                    <h2 class="success-card-title">
                        <i class="fa-solid fa-graduation-cap"></i> Khóa học đã mở khóa
                    </h2>
                    <span class="badge-count">${order.itemCount} khóa học</span>
                </div>

                <div class="course-list-wrap">
                    <c:choose>
                        <c:when test="${not empty order.items}">
                            <c:forEach var="item" items="${order.items}">
                                <a href="${pageContext.request.contextPath}/my-learning" class="purchased-course-item" title="Bấm để vào Bàn học của tôi">
                                    <div class="course-thumb-box">
                                        <c:choose>
                                            <c:when test="${not empty item.thumbnail}">
                                                <img src="${item.thumbnail}" alt="${item.courseName}">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="course-thumb-fallback">
                                                    <i class="fa-solid fa-book-open"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="course-info-box">
                                        <div class="course-name-link">
                                            ${item.courseName}
                                        </div>
                                        <div class="course-meta-tags">
                                            <span><i class="fa-regular fa-user"></i> ${not empty item.teacherName ? item.teacherName : 'Giảng viên OCMS'}</span>
                                            <span class="badge-active-status">
                                                <i class="fa-solid fa-circle-check"></i> Đã kích hoạt · Bấm để học ngay
                                            </span>
                                        </div>
                                    </div>
                                    <div class="course-arrow-icon">
                                        <i class="fa-solid fa-chevron-right"></i>
                                    </div>
                                </a>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/my-learning" class="purchased-course-item" title="Bấm để vào Bàn học của tôi">
                                <div class="course-thumb-box">
                                    <div class="course-thumb-fallback"><i class="fa-solid fa-book-open"></i></div>
                                </div>
                                <div class="course-info-box">
                                    <h4 class="course-name-link">Khóa học OCMS</h4>
                                    <div class="course-meta-tags">
                                        <span class="badge-active-status"><i class="fa-solid fa-circle-check"></i> Đã kích hoạt  · Bấm để học ngay</span>
                                    </div>
                                </div>
                                <div class="course-arrow-icon">
                                    <i class="fa-solid fa-chevron-right"></i>
                                </div>
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Action buttons -->
                <div class="success-card-actions">
                    <a href="${pageContext.request.contextPath}/my-learning" class="btn-primary-mylearning">
                        <i class="fa-solid fa-book-bookmark"></i>
                        <span>Vào Bàn học của tôi (My Learning)</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/courses" class="btn-secondary-browse">
                        <i class="fa-solid fa-compass"></i>
                        <span>Khám phá thêm khóa học</span>
                    </a>
                </div>
            </section>

        </div>

        <!-- 3. TRUST & VALUE BADGES -->
        <div class="trust-benefits-wrap">
            <div class="trust-item">
                <div class="trust-icon">
                    <i class="fa-solid fa-bolt"></i>
                </div>
                <div class="trust-text">
                    <h5>Kích hoạt ngay lập tức</h5>
                    <p>Khóa học sẵn sàng .</p>
                </div>
            </div>
            <div class="trust-item">
                <div class="trust-icon">
                    <i class="fa-solid fa-shield-halved"></i>
                </div>
                <div class="trust-text">
                    <h5>Quyền học trọn đời</h5>
                    <p>Học mọi lúc, mọi nơi không giới hạn thời gian truy cập tài liệu.</p>
                </div>
            </div>
            <div class="trust-item">
                <div class="trust-icon">
                    <i class="fa-solid fa-headset"></i>
                </div>
                <div class="trust-text">
                    <h5>Hỗ trợ học viên 24/7</h5>
                    <p>Đội ngũ hỗ trợ và giảng viên luôn sẵn sàng giải đáp thắc mắc.</p>
                </div>
            </div>
        </div>

    </main>

    <!-- Footer chung -->
    <jsp:include page="/view/common/footer.jsp" />

    <!-- JS Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

    <!-- Order Success Module JS riêng biệt -->
    <script src="${pageContext.request.contextPath}/assets/js/shopcart/order-success.js"></script>
</body>
</html>
