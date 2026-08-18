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

                                <li class="avg-rating"><i class="fas fa-star"></i> (${course.rating} Reviews)</li>
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
                                                <div class="accordion-item" style="margin-bottom: 15px; border: 1px solid #eee; border-radius: 8px; overflow: hidden;">
                                                    <h2 class="accordion-header" id="heading${status.index}">
                                                        <button class="accordion-button ${status.index != 0 ? 'collapsed' : ''}" type="button" data-bs-toggle="collapse" data-bs-target="#collapse${status.index}" aria-expanded="${status.index == 0 ? 'true' : 'false'}" aria-controls="collapse${status.index}" style="background-color: #f8f9fa; font-weight: 600; padding: 15px 20px;">
                                                            ${section.title}
                                                        </button>
                                                    </h2>
                                                    <div id="collapse${status.index}" class="accordion-collapse collapse ${status.index == 0 ? 'show' : ''}" aria-labelledby="heading${status.index}" data-bs-parent="#accordionExample">
                                                        <div class="accordion-body" style="padding: 0;">
                                                            <ul class="list-group list-group-flush">
                                                                <c:forEach var="lesson" items="${lessonsMap[section.id]}">
                                                                    <li class="list-group-item" style="padding: 15px 20px; display: flex; justify-content: space-between; align-items: center;">
                                                                        <span>
                                                                            <c:if test="${lesson.type == 'video'}">
                                                                                <i class="fas fa-play-circle" style="color: var(--primary); margin-right: 10px;"></i>
                                                                            </c:if>
                                                                            <c:if test="${lesson.type == 'file'}">
                                                                                <i class="fas fa-file-alt" style="color: #28a745; margin-right: 10px;"></i>
                                                                            </c:if>
                                                                            <c:if test="${lesson.type == 'text'}">
                                                                                <i class="fas fa-book" style="color: #ffc107; margin-right: 10px;"></i>
                                                                            </c:if>
                                                                            
                                                                            <!-- Link to the unified lesson details page -->
                                                                            <!-- Conditional Link based on Enrollment / Free first lesson -->
                                                                            <c:choose>
                                                                                <c:when test="${isEnrolled or lesson.id == firstLessonId}">
                                                                                    <a href="${pageContext.request.contextPath}/lesson-details?id=${lesson.id}" style="color: #333; text-decoration: none; cursor: pointer; font-weight: 500;">
                                                                                        ${lesson.title}
                                                                                    </a>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <a href="javascript:void(0);" onclick="alert('Bạn chưa mua khóa học này! Vui lòng mua để xem toàn bộ bài giảng.');" style="color: #888; text-decoration: none; cursor: pointer; font-weight: 500;">
                                                                                        <i class="fas fa-lock" style="font-size: 12px; margin-right: 5px;"></i> ${lesson.title}
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
                                        
                                        <!-- Reviews List -->
                                        <div class="course-reviews-list" style="margin-bottom: 30px;">
                                            <c:if test="${empty reviews}">
                                                <p style="color: #666; font-style: italic;">No reviews yet. Be the first to review this course!</p>
                                            </c:if>
                                            <c:forEach var="review" items="${reviews}">
                                                <div class="review-item" style="border-bottom: 1px solid #eee; padding: 15px 0;">
                                                    <div class="review-header" style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                                        <strong style="font-size: 16px;">${accountNames[review.accountId]}</strong>
                                                        <span style="color: #888; font-size: 14px;">${review.createdDate}</span>
                                                    </div>
                                                    <div class="review-rating" style="color: #ffc107; margin-bottom: 10px; font-size: 14px;">
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
                                                    <p class="review-comment" style="color: #444; line-height: 1.5; margin: 0;">${review.comment}</p>
                                                </div>
                                            </c:forEach>
                                        </div>
                                        
                                        <!-- Review Form -->
                                        <div class="course-review-form" style="margin-top: 40px; border-top: 1px solid #eee; padding-top: 30px;">
                                            <h3 class="title" style="font-size: 22px; font-weight: 700; color: #1a1a2e; margin-bottom: 20px;">Write a Review</h3>
                                            <form action="${pageContext.request.contextPath}/submit-review" method="post">
                                                <input type="hidden" name="courseId" value="${course.id}">
                                                <div style="margin-bottom: 15px;">
                                                    <label style="display: block; font-weight: 600; margin-bottom: 8px;">Your Rating:</label>
                                                    <div class="rating-selection" style="color: #ffc107; font-size: 20px; cursor: pointer;">
                                                        <label><input type="radio" name="rating" value="1" style="display:none;" required> <i class="far fa-star rating-star"></i></label>
                                                        <label><input type="radio" name="rating" value="2" style="display:none;"> <i class="far fa-star rating-star"></i></label>
                                                        <label><input type="radio" name="rating" value="3" style="display:none;"> <i class="far fa-star rating-star"></i></label>
                                                        <label><input type="radio" name="rating" value="4" style="display:none;"> <i class="far fa-star rating-star"></i></label>
                                                        <label><input type="radio" name="rating" value="5" style="display:none;"> <i class="far fa-star rating-star"></i></label>
                                                    </div>
                                                </div>
                                                <div style="margin-bottom: 20px;">
                                                    <label for="reviewComment" style="display: block; font-weight: 600; margin-bottom: 8px;">Your Comment:</label>
                                                    <textarea name="comment" id="reviewComment" rows="4" style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; outline: none;" placeholder="What do you think about this course?" required></textarea>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${not empty sessionScope.account}">
                                                        <button type="submit" class="btn" style="background-color: #ffc107; color: #1a1a2e; padding: 10px 25px; border: none; border-radius: 20px; font-weight: bold; cursor: pointer;">Submit Review</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/login" class="btn" style="display: inline-block; background-color: #ffc107; color: #1a1a2e; padding: 10px 25px; border: none; border-radius: 20px; font-weight: bold; cursor: pointer; text-decoration: none;">Login to Submit Review</a>
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
                                    <div class="courses__cost-wrap" style="background-color: #28a745;">
                                        <span>Status:</span>
                                        <h2 class="title" style="font-size: 24px;">
                                            <i class="fas fa-check-circle"></i> Purchased
                                        </h2>
                                        <p style="margin-top: 10px; margin-bottom: 0; font-size: 14px;">You can now access all lessons in the curriculum.</p>
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
        
        <div class="container text-center" style="padding-bottom: 40px;">
            <button onclick="window.scrollTo({top: 0, behavior: 'smooth'})" class="btn btn-primary" style="background-color: var(--primary-color); border: none; padding: 10px 25px; border-radius: 25px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
                <i class="fas fa-arrow-up me-2"></i> Back to Top
            </button>
        </div>

    </main>
    <!-- main-area-end -->

    <!-- Bootstrap JS for tabs/accordion -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>
