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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course/course-details.css">
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
                                        <a href="${pageContext.request.contextPath}/teacher-detail?id=${course.createdBy}">${authorName}</a>
                                    </li>
                                    <li class="date"><i class="fas fa-calendar"></i> ${course.createdDate}</li>
                                </ul>
                            </div>
                            <c:set var="isReviewsActive" value="${param.tab == 'reviews' or not empty sessionScope.message or not empty sessionScope.reviewCommentDraft or not empty sessionScope.reviewRatingDraft}" />
                            <ul class="nav nav-tabs" id="myTab" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link ${isReviewsActive ? '' : 'active'}" id="overview-tab" data-bs-toggle="tab" data-bs-target="#overview-tab-pane" type="button" role="tab" aria-controls="overview-tab-pane" aria-selected="${isReviewsActive ? 'false' : 'true'}">Overview</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                     <button class="nav-link" id="curriculum-tab" data-bs-toggle="tab" data-bs-target="#curriculum-tab-pane" type="button" role="tab" aria-controls="curriculum-tab-pane" aria-selected="false">Curriculum</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="instructors-tab" data-bs-toggle="tab" data-bs-target="#instructors-tab-pane" type="button" role="tab" aria-controls="instructors-tab-pane" aria-selected="false">Instructors</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link ${isReviewsActive ? 'active' : ''}" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews-tab-pane" type="button" role="tab" aria-controls="reviews-tab-pane" aria-selected="${isReviewsActive ? 'true' : 'false'}">Reviews</button>
                                </li>
                            </ul>
                            <div class="tab-content" id="myTabContent">
                                <div class="tab-pane fade ${isReviewsActive ? '' : 'show active'}" id="overview-tab-pane" role="tabpanel" aria-labelledby="overview-tab" tabindex="0">
                                    <div class="courses__overview-wrap">
                                        <h3 class="title">Course Description</h3>
                                        ${course.description}                                        
                                    </div>
                                </div>
                                <div class="tab-pane fade" id="curriculum-tab-pane" role="tabpanel" aria-labelledby="curriculum-tab" tabindex="0">
                                    <c:set var="isTeacherSelfCourse" value="${sessionScope.account != null && sessionScope.account.roleId == 2 && course.createdBy == sessionScope.account.id}" />
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
                                                                    <li class="list-group-item course-curriculum-lesson" ${isTeacherSelfCourse ? 'style="opacity: 0.5; cursor: not-allowed;"' : ''}>
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
                                                                            <!-- Conditional Link based on Enrollment / Free first lesson / Teacher self course -->
                                                                            <c:choose>
                                                                                <c:when test="${isTeacherSelfCourse}">
                                                                                    <span style="cursor: not-allowed; color: #6c757d; font-weight: 500;">
                                                                                        ${lesson.title}
                                                                                    </span>
                                                                                </c:when>
                                                                                <c:when test="${isEnrolled}">
                                                                                    <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${lesson.id}" class="lesson-link">
                                                                                        ${lesson.title}
                                                                                    </a>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <a href="${pageContext.request.contextPath}/learning?courseId=${course.id}&lessonId=${lesson.id}" class="lesson-link-locked">
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
                                        <h3 class="title">Instructor</h3>
                                        <div class="instructor-card">
                                            <div class="instructor-avatar">
                                                <i class="fas fa-user-tie"></i>
                                            </div>
                                            <div class="instructor-info">
                                                <h4><a href="${pageContext.request.contextPath}/teacher-detail?id=${course.createdBy}" class="text-decoration-none text-dark">${not empty authorName ? authorName : (instructor != null ? instructor.fullName : 'Giảng viên')}</a></h4>
                                                <p><c:out value="${instructor != null && not empty instructor.email ? instructor.email : 'Instructor at OCMS'}" /></p>
                                                <div class="instructor-meta">
                                                    <span><i class="fas fa-book-open"></i> ${instructorCourseCount > 0 ? instructorCourseCount : 1} Courses</span>
                                                    <span><i class="fas fa-star text-warning"></i> ${avgRating > 0 ? avgRating : '5.0'} Rating</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="tab-pane fade ${isReviewsActive ? 'show active' : ''}" id="reviews-tab-pane" role="tabpanel" aria-labelledby="reviews-tab" tabindex="0">
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

                                             <c:if test="${not empty sessionScope.message}">
                                                 <div class="alert alert-${sessionScope.messageType == 'error' ? 'danger' : 'success'} alert-dismissible fade show mb-4" role="alert">
                                                     <i class="fas ${sessionScope.messageType == 'error' ? 'fa-exclamation-circle' : 'fa-check-circle'} me-2"></i>
                                                     <c:out value="${sessionScope.message}" />
                                                     <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                                 </div>
                                                 <c:remove var="message" scope="session" />
                                                 <c:remove var="messageType" scope="session" />
                                             </c:if>

                                             <c:choose>
                                                 <c:when test="${empty sessionScope.account}">
                                                     <div class="alert alert-info py-2" style="font-size:14px;">
                                                         Vui lòng <a href="${pageContext.request.contextPath}/login" class="fw-bold">Đăng nhập</a> để viết đánh giá.
                                                     </div>
                                                 </c:when>
                                                 <c:when test="${!isEnrolled}">
                                                     <div class="alert alert-warning py-2" style="font-size:14px;">
                                                         <i class="fas fa-lock me-1"></i> Bạn cần mua/đăng ký khóa học này mới có thể bình luận và đánh giá.
                                                     </div>
                                                 </c:when>
                                                 <c:when test="${hasReviewed}">
                                                     <div class="alert alert-success py-2" style="font-size:14px;">
                                                         <i class="fas fa-check-circle me-1"></i> Bạn đã gửi đánh giá cho khóa học này rồi. Cảm ơn phản hồi của bạn!
                                                     </div>
                                                 </c:when>
                                                 <c:otherwise>
                                                     <form action="${pageContext.request.contextPath}/submit-review" method="post" id="reviewForm" novalidate>
                                                         <input type="hidden" name="courseId" value="${course.id}">
                                                         
                                                         <!-- Client validation alert box -->
                                                         <div id="reviewFormAlert" class="alert alert-warning py-2 mb-3" style="display: none; font-size: 14px; border-radius: 8px;">
                                                             <i class="fas fa-exclamation-triangle me-2 text-warning"></i>
                                                             <span id="reviewFormAlertText" class="fw-medium"></span>
                                                         </div>
                                                         <c:set var="draftRating" value="${sessionScope.reviewRatingDraft}" />
                                                         <c:set var="draftComment" value="${sessionScope.reviewCommentDraft}" />

                                                         <div class="review-form-group">
                                                             <label class="review-form-label">Your Rating: <span class="text-danger">*</span></label>
                                                             <div class="rating-selection">
                                                                 <label><input type="radio" name="rating" value="1" class="rating-input" ${draftRating == '1' ? 'checked' : ''}> <i class="${draftRating >= '1' ? 'fas' : 'far'} fa-star rating-star"></i></label>
                                                                 <label><input type="radio" name="rating" value="2" class="rating-input" ${draftRating == '2' ? 'checked' : ''}> <i class="${draftRating >= '2' ? 'fas' : 'far'} fa-star rating-star"></i></label>
                                                                 <label><input type="radio" name="rating" value="3" class="rating-input" ${draftRating == '3' ? 'checked' : ''}> <i class="${draftRating >= '3' ? 'fas' : 'far'} fa-star rating-star"></i></label>
                                                                 <label><input type="radio" name="rating" value="4" class="rating-input" ${draftRating == '4' ? 'checked' : ''}> <i class="${draftRating >= '4' ? 'fas' : 'far'} fa-star rating-star"></i></label>
                                                                 <label><input type="radio" name="rating" value="5" class="rating-input" ${draftRating == '5' ? 'checked' : ''}> <i class="${draftRating >= '5' ? 'fas' : 'far'} fa-star rating-star"></i></label>
                                                             </div>
                                                         </div>
                                                         <div class="review-form-group-spaced">
                                                             <label for="reviewComment" class="review-form-label">Your Comment: <span class="text-danger">*</span></label>
                                                             <textarea name="comment" id="reviewComment" rows="4" class="review-textarea" placeholder="What do you think about this course?"><c:out value="${draftComment}" /></textarea>
                                                         </div>
                                                         <c:remove var="reviewRatingDraft" scope="session" />
                                                         <c:remove var="reviewCommentDraft" scope="session" />
                                                         <button type="submit" class="btn review-submit-btn">Submit Review</button>
                                                     </form>
                                                 </c:otherwise>
                                             </c:choose>
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
                                <c:when test="${sessionScope.account != null && sessionScope.account.roleId == 2 && course.createdBy == sessionScope.account.id}">
                                    <div class="courses__cost-wrap" style="background-color: #0d6efd !important;">
                                        <span style="color: white !important;">Status:</span>
                                        <h2 class="title" style="color: white !important;">
                                            <i class="fas fa-chalkboard-teacher"></i> My Course
                                        </h2>
                                        <p class="purchase-note" style="color: white !important; opacity: 0.9;">You are the creator of this course.</p>
                                    </div>
                                </c:when>
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

                            <c:set var="quizCount" value="0" />
                            <c:forEach var="sect" items="${sections}">
                                <c:forEach var="les" items="${lessonsMap[sect.id]}">
                                    <c:if test="${les.type == 'quiz'}">
                                        <c:set var="quizCount" value="${quizCount + 1}" />
                                    </c:if>
                                </c:forEach>
                            </c:forEach>

                            <div class="courses__information-wrap">
                                <h5 class="title">Course includes:</h5>
                                <ul class="list-wrap">
                                    <li>
                                        Quizzes
                                        <span>${quizCount}</span>
                                    </li>
                                    <li>
                                        Certifications
                                        <span>${hasCertificate ? 'Yes' : 'No'}</span>
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
                                            data-course-id="${course.id}" data-context-path="${pageContext.request.contextPath}" onclick="toggleWishlist(this)" title="Add to wishlist">
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
            <button onclick="scrollToTop()" class="btn btn-primary back-to-top-btn">
                <i class="fas fa-arrow-up me-2"></i> Back to Top
            </button>
        </div>

    </main>
    <!-- main-area-end -->

    <!-- Bootstrap JS for tabs/accordion -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/course/course-details.js?v=<%= System.currentTimeMillis() %>"></script>
</body>

</html>
