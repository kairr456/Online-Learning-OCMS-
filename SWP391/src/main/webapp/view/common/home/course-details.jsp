<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>OCMS - Course Details</title>
    <meta name="description" content="OCMS - Online Courses & Education">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Bootstrap CSS for tabs/accordion -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --primary-color: #5d3fd3;
            --primary-dark: #1a1a2e;
            --accent-yellow: #ffc107;
            --bg-light: #f8f9fa;
            --text-main: #333;
            --text-muted: #6c757d;
            --border-color: #eaeaea;
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: #fff;
            color: var(--text-main);
        }
        .courses__details-area {
            padding: 60px 0;
        }
        /* Left Column Content */
        .courses__details-thumb img {
            width: 100%;
            border-radius: 20px;
            margin-bottom: 25px;
            box-shadow: 0 10px 30px rgba(93, 63, 211, 0.15);
        }
        .courses__item-meta {
            list-style: none;
            padding: 0;
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }
        .courses__item-tag a {
            background-color: var(--bg-light);
            color: var(--text-main);
            padding: 6px 15px;
            border-radius: 20px;
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            border: 1px solid var(--border-color);
        }
        .avg-rating {
            font-size: 14px;
            color: var(--text-muted);
            font-weight: 500;
        }
        .avg-rating i {
            color: var(--accent-yellow);
        }
        .courses__details-content .title {
            font-size: 32px;
            font-weight: 800;
            color: var(--primary-dark);
            margin-bottom: 20px;
        }
        .courses__details-meta ul {
            list-style: none;
            padding: 0;
            display: flex;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
            margin-bottom: 30px;
            font-size: 14px;
            color: var(--text-muted);
        }
        .courses__details-meta img {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            margin-right: 8px;
        }
        
        /* Tabs */
        .nav-tabs {
            border-bottom: none;
            gap: 10px;
            margin-bottom: 30px;
        }
        .nav-tabs .nav-link {
            border: none;
            background-color: var(--bg-light);
            color: var(--text-muted);
            border-radius: 30px;
            padding: 10px 25px;
            font-weight: 600;
            font-size: 15px;
            transition: all 0.3s;
        }
        .nav-tabs .nav-link.active {
            background-color: var(--primary-color);
            color: #fff;
            box-shadow: 0 4px 15px rgba(93, 63, 211, 0.3);
        }
        
        /* Tab Content */
        .tab-pane {
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.02);
        }
        .courses__overview-wrap .title,
        .courses__curriculum-wrap .title,
        .courses__instructors-wrap .title,
        .courses__rating-wrap .title {
            font-size: 22px;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 20px;
        }
        
        /* Accordion */
        .accordion-item {
            border: 1px solid var(--border-color);
            border-radius: 10px !important;
            margin-bottom: 15px;
            overflow: hidden;
        }
        .accordion-button {
            background-color: var(--bg-light);
            font-weight: 600;
            color: var(--primary-dark);
            box-shadow: none !important;
        }
        .accordion-button:not(.collapsed) {
            background-color: #f0edff;
            color: var(--primary-color);
        }
        .course-item-link {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px dashed var(--border-color);
            text-decoration: none;
            color: var(--text-main);
        }
        .course-item-link:hover {
            color: var(--primary-color);
        }
        
        /* Right Sidebar */
        .courses__details-sidebar {
            background: #fff;
            border-radius: 16px;
            padding: 25px;
            border: 1px solid var(--border-color);
            box-shadow: 0 10px 40px rgba(0,0,0,0.06);
            position: sticky;
            top: 20px;
        }
        .courses__details-video img {
            width: 100%;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        .courses__cost-wrap {
            background-color: var(--primary-color);
            color: #fff;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            text-align: left;
        }
        .courses__cost-wrap span {
            font-size: 14px;
            opacity: 0.9;
        }
        .courses__cost-wrap .title {
            font-size: 28px;
            font-weight: 800;
            margin: 5px 0 0 0;
            color: #fff;
        }
        .courses__information-wrap ul {
            list-style: none;
            padding: 0;
        }
        .courses__information-wrap li {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px dashed var(--border-color);
            font-size: 14px;
            color: var(--text-muted);
        }
        .courses__information-wrap li span {
            font-weight: 600;
            color: var(--primary-dark);
        }
        
        /* Payment & Social */
        .courses__payment, .courses__details-social {
            margin-top: 20px;
        }
        .courses__payment .title, .courses__details-social .title {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 10px;
            color: var(--primary-dark);
        }
        .courses__details-social ul {
            display: flex;
            gap: 10px;
            list-style: none;
            padding: 0;
        }
        .courses__details-social a {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 35px;
            height: 35px;
            background-color: var(--bg-light);
            border-radius: 50%;
            color: var(--text-muted);
            transition: all 0.2s;
        }
        .courses__details-social a:hover {
            background-color: var(--primary-color);
            color: #fff;
        }
        
        /* Add to cart btn */
        .btn-two {
            width: 100%;
            background-color: var(--accent-yellow);
            color: var(--primary-dark);
            border: none;
            padding: 15px;
            border-radius: 30px;
            font-weight: 700;
            font-size: 16px;
            margin-top: 25px;
            transition: all 0.3s;
            cursor: pointer;
        }
        .btn-two:hover {
            background-color: #e0a800;
            transform: translateY(-2px);
        }

        /* Review styles */
        .course-rate {
            display: flex;
            gap: 40px;
            margin-bottom: 30px;
        }
        .course-rate__summary {
            text-align: center;
        }
        .course-rate__summary-value {
            font-size: 48px;
            font-weight: 800;
            color: var(--primary-dark);
        }
        .course-rate__summary-stars {
            color: var(--accent-yellow);
        }
        .course-rate__summary-text {
            color: var(--text-muted);
            font-size: 14px;
        }
        .course-rate__details {
            flex: 1;
        }
        .course-rate__details-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 5px;
        }
        .course-rate__details-row-star {
            font-size: 14px;
            color: var(--text-muted);
            min-width: 30px;
        }
        .course-rate__details-row-star i {
            color: var(--accent-yellow);
        }
        .course-rate__details-row-value {
            flex: 1;
            display: flex;
            align-items: center;
            gap: 8px;
            position: relative;
        }
        .rating-gray {
            width: 100%;
            height: 6px;
            background: #e9ecef;
            border-radius: 3px;
        }
        .rating {
            position: absolute;
            height: 6px;
            background: var(--accent-yellow);
            border-radius: 3px;
        }
        .rating-count {
            font-size: 13px;
            color: var(--text-muted);
            min-width: 20px;
        }

        .course-review-head {
            display: flex;
            gap: 15px;
            padding: 20px 0;
            border-bottom: 1px solid var(--border-color);
        }
        .review-author-thumb img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
        }
        .author-name {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .author-name .name {
            font-size: 16px;
            font-weight: 600;
            margin: 0;
        }
        .author-name span {
            font-size: 12px;
            color: var(--text-muted);
        }
        .author-rating i {
            color: var(--accent-yellow);
            font-size: 12px;
        }
        .list-wrap {
            list-style: none;
            padding: 0;
        }
        .rating-selection {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-top: 5px;
        }
        .rating-selection label {
            cursor: pointer;
            margin: 0;
            display: inline-flex;
            align-items: center;
        }
        .rating-selection input[type="radio"],
        .rating-input {
            display: none !important;
        }
        .rating-star {
            font-size: 24px;
            color: var(--accent-yellow);
            transition: transform 0.2s, color 0.2s;
        }
        .rating-star:hover {
            transform: scale(1.2);
        }
        .review-item {
            padding: 20px 0;
            border-bottom: 1px solid var(--border-color);
        }
        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 6px;
        }
        .review-author-name {
            font-size: 16px;
            font-weight: 600;
            color: var(--primary-dark);
        }
        .review-date {
            font-size: 13px;
            color: var(--text-muted);
        }
        .review-rating {
            color: var(--accent-yellow);
            font-size: 14px;
            margin-bottom: 8px;
        }
        .review-comment {
            color: #555;
            font-size: 14px;
            line-height: 1.6;
            margin: 0;
        }
        .review-form-title {
            font-size: 18px;
            font-weight: 700;
            margin-top: 30px;
            margin-bottom: 15px;
            color: var(--primary-dark);
        }
        .review-form-label {
            font-weight: 600;
            font-size: 14px;
            color: var(--text-main);
            margin-bottom: 6px;
            display: block;
        }
        .review-textarea {
            width: 100%;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 12px 15px;
            font-size: 14px;
            resize: vertical;
            outline: none;
        }
        .review-textarea:focus {
            border-color: var(--primary-color);
        }
        .review-submit-btn {
            background-color: var(--primary-color);
            color: #fff;
            padding: 10px 24px;
            border-radius: 8px;
            font-weight: 600;
            border: none;
            cursor: pointer;
            margin-top: 15px;
            transition: all 0.2s;
        }
        .review-submit-btn:hover {
            background-color: #4a2ec2;
            color: #fff;
        }
    </style>
</head>

<body>

    <!-- header-area -->
    <jsp:include page="/view/common/header.jsp" />
    <!-- header-area-end -->

    <!-- main-area -->
    <main class="main-area">

        <!-- courses-details-area -->
        <section class="courses__details-area">
            <div class="container">
                <div class="row">
                    <div class="col-xl-9 col-lg-8">
                        <div class="courses__details-thumb">
                            <img src="${course.thumbnail}" alt="${course.name}">
                        </div>
                        <div class="courses__details-content">
                            <ul class="courses__item-meta list-wrap">
                                <li class="courses__item-tag">
                                    <a href="${pageContext.request.contextPath}/courses?category=${course.categoryId}">${not empty categoryName ? categoryName : 'General'}</a>
                                </li>
                                <li class="avg-rating"><i class="fas fa-star"></i> ${avgRating > 0 ? avgRating : '0.0'} (${reviewCount} ${reviewCount == 1 ? 'Review' : 'Reviews'})</li>
                            </ul>
                            <h2 class="title">${course.name}</h2>
                            <div class="courses__details-meta">
                                <ul class="list-wrap">
                                    <li class="author-two">
                                        By
                                        <a href="teacher-detail.jsp?id=${course.createdBy}">${authorName}</a>
                                    </li>
                                    <li class="date"><i class="fas fa-calendar"></i> ${course.createdDate}</li>
                                </ul>
                            </div>
                            <ul class="nav nav-tabs" id="myTab" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link active" id="overview-tab" data-bs-toggle="tab" data-bs-target="#overview-tab-pane" type="button" role="tab" aria-controls="overview-tab-pane" aria-selected="true">Overview</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="curriculum-tab" data-bs-toggle="tab" data-bs-target="#curriculum-tab-pane" type="button" role="tab" aria-controls="curriculum-tab-pane" aria-selected="false">Curriculum</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="instructors-tab" data-bs-toggle="tab" data-bs-target="#instructors-tab-pane" type="button" role="tab" aria-controls="instructors-tab-pane" aria-selected="false">Instructors</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews-tab-pane" type="button" role="tab" aria-controls="reviews-tab-pane" aria-selected="false">Reviews</button>
                                </li>
                            </ul>
                            <div class="tab-content" id="myTabContent">
                                <div class="tab-pane fade show active" id="overview-tab-pane" role="tabpanel" aria-labelledby="overview-tab" tabindex="0">
                                    <div class="courses__overview-wrap">
                                        <h3 class="title">Course Description</h3>
                                        ${course.description}                                        
                                    </div>
                                </div>
                                <div class="tab-pane fade" id="curriculum-tab-pane" role="tabpanel" aria-labelledby="curriculum-tab" tabindex="0">
                                    <div class="courses__curriculum-wrap">
                                        <h3 class="title">Course Curriculum</h3>
                                        <div class="accordion" id="accordionExample">
                                            <c:forEach var="section" items="${sections}" varStatus="status">
                                                <div class="accordion-item course-curriculum-item">
                                                    <h2 class="accordion-header" id="heading${status.index}">
                                                        <button class="accordion-button ${status.index != 0 ? 'collapsed' : ''} course-curriculum-btn" type="button" data-bs-toggle="collapse" data-bs-target="#collapse${status.index}" aria-expanded="${status.index == 0 ? 'true' : 'false'}" aria-controls="collapse${status.index}">
                                                            ${section.title}
                                                        </button>
                                                    </h2>
                                                    <div id="collapse${status.index}" class="accordion-collapse collapse ${status.index == 0 ? 'show' : ''}" aria-labelledby="heading${status.index}" data-bs-parent="#accordionExample">
                                                        <div class="accordion-body course-curriculum-body">
                                                            <ul class="list-group list-group-flush">
                                                                <c:forEach var="lesson" items="${lessonsMap[section.id]}">
<li class="list-group-item course-curriculum-lesson">
                                        <span>
                                            <c:if test="${lesson.type == 'video'}">
                                                <i class="fas fa-play-circle lesson-icon-play"></i>
                                            </c:if>
                                            <c:if test="${lesson.type == 'file'}">
                                                <i class="fas fa-file-alt lesson-icon-file"></i>
                                            </c:if>
                                            <c:if test="${lesson.type == 'text'}">
                                                <i class="fas fa-book lesson-icon-text"></i>
                                            </c:if>
                                            
                                            <!-- Link to the unified lesson details page -->
                                            <!-- Conditional Link based on Enrollment / Free first lesson -->
                                            <c:choose>
                                                <c:when test="${isEnrolled or lesson.id == firstLessonId}">
                                                    <a href="${pageContext.request.contextPath}/lesson-details?id=${lesson.id}" class="lesson-link">
                                                        ${lesson.title}
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="javascript:void(0);" onclick="alert('Bạn chưa mua khóa học này! Vui lòng mua để xem toàn bộ bài giảng.');" class="lesson-link-locked">
                                                        <i class="fas fa-lock lesson-lock-icon"></i> ${lesson.title}
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </li>
                                                                </c:forEach>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>
                                <div class="tab-pane fade" id="instructors-tab-pane" role="tabpanel" aria-labelledby="instructors-tab" tabindex="0">
                                    <div class="courses__instructors-wrap">
                                        <h3 class="title">Instructors</h3>
                                        <!-- Instructor content will be loaded dynamically -->
                                    </div>
                                </div>
                                <div class="tab-pane fade" id="reviews-tab-pane" role="tabpanel" aria-labelledby="reviews-tab" tabindex="0">
                                    <div class="courses__rating-wrap">
                                        <h2 class="title">Reviews</h2>
                                        
                                        <!-- Overall Rating Summary -->
                                        <div class="course-rate">
                                            <div class="course-rate__summary">
                                                <div class="course-rate__summary-value">${avgRating > 0 ? avgRating : '0.0'}</div>
                                                <div class="course-rate__summary-stars">
                                                    <c:forEach begin="1" end="5" var="s">
                                                        <c:choose>
                                                            <c:when test="${s <= avgRating}">
                                                                <i class="fas fa-star"></i>
                                                            </c:when>
                                                            <c:when test="${s - 0.5 <= avgRating}">
                                                                <i class="fas fa-star-half-alt"></i>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="far fa-star"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:forEach>
                                                </div>
                                                <div class="course-rate__summary-text">(${reviewCount} ${reviewCount == 1 ? 'Review' : 'Reviews'})</div>
                                            </div>
                                            <div class="course-rate__details">
                                                <c:forEach var="item" items="${starDistributionList}">
                                                    <div class="course-rate__details-row">
                                                        <div class="course-rate__details-row-star">${item.star} <i class="fas fa-star"></i></div>
                                                        <div class="course-rate__details-row-value">
                                                            <div class="rating-gray">
                                                                <div class="rating" style="width: ${item.percent}%;"></div>
                                                            </div>
                                                        </div>
                                                        <div class="rating-count">${item.count}</div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>

                                        <!-- Reviews List -->
                                        <div class="course-reviews-list">
                                            <c:if test="${empty reviews}">
                                                <p class="no-reviews-text">No reviews yet. Be the first to review this course!</p>
                                            </c:if>
                                            <c:forEach var="review" items="${reviews}">
                                                <div class="review-item">
                                                    <div class="review-header">
                                                        <strong class="review-author-name">${not empty accountNames[review.accountId] ? accountNames[review.accountId] : 'Học viên'}</strong>
                                                        <span class="review-date">${review.createdDate}</span>
                                                    </div>
                                                    <div class="review-rating">
                                                        <c:forEach begin="1" end="5" var="i">
                                                            <c:choose>
                                                                <c:when test="${i <= review.rating}">
                                                                    <i class="fas fa-star"></i>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="far fa-star"></i>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>
                                                    </div>
                                                    <p class="review-comment">${review.comment}</p>
                                                </div>
                                            </c:forEach>
                                        </div>
                                        
                                        <!-- Review Form -->
                                        <div class="course-review-form">
                                            <h3 class="title review-form-title">Write a Review</h3>
                                            <form action="${pageContext.request.contextPath}/submit-review" method="post">
                                                <input type="hidden" name="courseId" value="${course.id}">
                                                <div class="review-form-group">
                                                    <label class="review-form-label">Your Rating:</label>
                                                    <div class="rating-selection">
                                                        <label><input type="radio" name="rating" value="1" class="rating-input" required> <i class="far fa-star rating-star"></i></label>
                                                        <label><input type="radio" name="rating" value="2" class="rating-input"> <i class="far fa-star rating-star"></i></label>
                                                        <label><input type="radio" name="rating" value="3" class="rating-input"> <i class="far fa-star rating-star"></i></label>
                                                        <label><input type="radio" name="rating" value="4" class="rating-input"> <i class="far fa-star rating-star"></i></label>
                                                        <label><input type="radio" name="rating" value="5" class="rating-input"> <i class="far fa-star rating-star"></i></label>
                                                    </div>
                                                </div>
                                                <div class="review-form-group-spaced">
                                                    <label for="reviewComment" class="review-form-label">Your Comment:</label>
                                                    <textarea name="comment" id="reviewComment" rows="4" class="review-textarea" placeholder="What do you think about this course?" required></textarea>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${not empty sessionScope.account}">
                                                        <button type="submit" class="btn review-submit-btn">Submit Review</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/login" class="btn review-submit-btn">Login to Submit Review</a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                            <script>
                                                document.addEventListener("DOMContentLoaded", function() {
                                                    const stars = document.querySelectorAll('.rating-star');
                                                    const labels = document.querySelectorAll('.rating-selection label');
                                                    
                                                    labels.forEach((label, index) => {
                                                        label.addEventListener('click', () => {
                                                            stars.forEach(s => {
                                                                s.classList.remove('fas');
                                                                s.classList.add('far');
                                                            });
                                                            for (let i = 0; i <= index; i++) {
                                                                stars[i].classList.remove('far');
                                                                stars[i].classList.add('fas');
                                                            }
                                                        });
                                                    });
                                                });
                                            </script>
                                        </div>
                                        <!-- End Review Form -->
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-4">
                        <div class="courses__details-sidebar">
                            <c:choose>
                                <c:when test="${isEnrolled}">
                                    <div class="courses__cost-wrap courses__cost-wrap--purchased">
                                        <span>Status:</span>
                                        <h2 class="title">
                                            <i class="fas fa-check-circle"></i> Purchased
                                        </h2>
                                        <p class="purchase-note">You can now access all lessons in the curriculum.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="courses__cost-wrap">
                                        <span>This Course Fee:</span>
                                        <h2 class="title">
                                            ${course.price}₫
                                        </h2>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <div class="courses__information-wrap">
                                <h5 class="title">Course includes:</h5>
                                <ul class="list-wrap">
                                    <li>
                                        Level
                                        <span>Expert</span>
                                    </li>
                                    <li>
                                        Quizzes
                                        <span>145</span>
                                    </li>
                                    <li>
                                        Certifications
                                        <span>Yes</span>
                                    </li>
                                </ul>
                            </div>
                            <div class="courses__details-social">
                                <h5 class="title">Share this course:</h5>
                                <ul class="list-wrap">
                                    <li><a href="#"><i class="fab fa-facebook-f"></i></a></li>
                                    <li><a href="#"><i class="fab fa-twitter"></i></a></li>
                                    <li><a href="#"><i class="fab fa-whatsapp"></i></a></li>
                                    <li><a href="#"><i class="fab fa-instagram"></i></a></li>
                                    <li><a href="#"><i class="fab fa-youtube"></i></a></li>
                                </ul>
                            </div>
                            
                            <c:if test="${not isEnrolled}">
                                <div class="courses__details-enroll">
                                    <button type="button" class="wishlist-heart wishlist-heart--lg ${isWishlisted ? 'active' : ''}"
                                            data-course-id="${course.id}" onclick="toggleWishlist(this)" title="Add to wishlist">
                                        <i class="${isWishlisted ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
                                    </button>
                                    <form action="${pageContext.request.contextPath}/cart" method="post">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="courseId" value="${course.id}">
                                        <input type="hidden" name="price" value="${course.price}">
                                        <button type="submit" class="btn-two">
                                            Add To Cart
                                        </button>
                                    </form>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        <!-- courses-details-area-end -->

        <div class="container text-center back-to-top-wrap">
            <button onclick="window.scrollTo({top: 0, behavior: 'smooth'})" class="btn btn-primary back-to-top-btn">
                <i class="fas fa-arrow-up me-2"></i> Back to Top
            </button>
        </div>

    </main>
    <!-- main-area-end -->

    <!-- Bootstrap JS for tabs/accordion -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleWishlist(btn) {
            var courseId = btn.getAttribute('data-course-id');
            var ctx = '${pageContext.request.contextPath}';
            fetch(ctx + '/wishlist', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: new URLSearchParams({ action: 'toggle', courseId: courseId })
            })
            .then(function (res) {
                if (res.status === 401) {
                    window.location.href = ctx + '/view/authen/login.jsp';
                    throw new Error('Unauthorized');
                }
                if (!res.ok) {
                    throw new Error('Server responded with status ' + res.status);
                }
                return res.json();
            })
            .then(function (data) {
                if (data.status === 'success') {
                    btn.classList.toggle('active');
                    var icon = btn.querySelector('i');
                    if (icon) {
                        if (btn.classList.contains('active')) {
                            icon.classList.remove('fa-regular');
                            icon.classList.add('fa-solid');
                        } else {
                            icon.classList.remove('fa-solid');
                            icon.classList.add('fa-regular');
                        }
                    }
                } else {
                    alert(data.message || 'Operation failed.');
                }
            })
            .catch(function (err) {
                console.error('Wishlist error:', err);
                if (!err || err.message !== 'Unauthorized') {
                    alert('Wishlist request failed: ' + (err && err.message ? err.message : 'Unknown error'));
                }
            });
        }
    </script>
</body>

</html>
