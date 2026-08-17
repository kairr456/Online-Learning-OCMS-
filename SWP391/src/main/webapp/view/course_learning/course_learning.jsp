<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>My Learning | OCMS</title>

                        <!-- CSS hệ thống -->
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
                        <link rel="stylesheet"
                            href="${pageContext.request.contextPath}/assets/css/fontawesome-all.min.css">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">

                        <!-- CSS Tùy chỉnh dành riêng cho trang My Learning -->
                        <style>
                            :root {
                                --mylearning-primary: #5624d0;
                                --mylearning-primary-hover: #401b9c;
                                --mylearning-bg: #f7f9fa;
                                --mylearning-text-dark: #2d2f31;
                                --mylearning-text-muted: #6a6f73;
                                --mylearning-border: #d1d7dc;
                            }

                            body {
                                background-color: #ffffff;
                                color: var(--mylearning-text-dark);
                                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
                                margin: 0;
                                padding: 0;
                            }

                            /* Page Banner / Header Title */
                            .my-learning-header {
                                background-color: #2d2f31;
                                color: #ffffff;
                                padding: 36px 0 0 0;
                                margin-bottom: 0;
                            }

                            .my-learning-header h1 {
                                font-size: 2.2rem;
                                font-weight: 700;
                                margin-bottom: 20px;
                                color: #ffffff;
                            }

                            /* Navigation Tabs */
                            .my-learning-tabs {
                                display: flex;
                                gap: 24px;
                                border-bottom: 1px solid #6a6f73;
                                list-style: none;
                                padding: 0;
                                margin: 0;
                                overflow-x: auto;
                            }

                            .my-learning-tabs .nav-link {
                                color: #d1d7dc;
                                font-weight: 600;
                                padding: 12px 4px;
                                text-decoration: none;
                                border: none;
                                border-bottom: 3px solid transparent;
                                background: transparent;
                                font-size: 1rem;
                                cursor: pointer;
                                white-space: nowrap;
                            }

                            .my-learning-tabs .nav-link:hover {
                                color: #ffffff;
                            }

                            .my-learning-tabs .nav-link.active {
                                color: #ffffff;
                                border-bottom-color: #ffffff;
                            }

                            /* Content Layout Container */
                            .content-container {
                                padding-top: 32px;
                                padding-bottom: 60px;
                            }

                            /* Controls / Filter Bar */
                            .learning-controls {
                                display: flex;
                                flex-wrap: wrap;
                                justify-content: space-between;
                                align-items: center;
                                gap: 16px;
                                margin-bottom: 28px;
                            }

                            .learning-filters {
                                display: flex;
                                gap: 12px;
                                flex-wrap: wrap;
                            }

                            .filter-select {
                                padding: 10px 14px;
                                border: 1px solid var(--mylearning-border);
                                border-radius: 4px;
                                background-color: #fff;
                                font-weight: 600;
                                font-size: 0.9rem;
                                color: var(--mylearning-text-dark);
                                cursor: pointer;
                                outline: none;
                            }

                            .learning-search {
                                position: relative;
                                min-width: 260px;
                                flex-grow: 1;
                                max-width: 360px;
                            }

                            .learning-search input {
                                width: 100%;
                                padding: 10px 40px 10px 14px;
                                border: 1px solid var(--mylearning-border);
                                border-radius: 4px;
                                font-size: 0.9rem;
                            }

                            /* Đổi màu chữ gợi ý (placeholder) "Search my courses..." */
                            .learning-search input::placeholder {
                                color: #ffffff;
                                /* Thay mã màu bạn muốn tại đây */
                                opacity: 1;
                                /* Đảm bảo màu hiển thị rõ ràng trên mọi trình duyệt */
                            }

                            .learning-search button {
                                position: absolute;
                                right: 10px;
                                top: 50%;
                                transform: translateY(-50%);
                                background: none;
                                border: none;
                                color: var(--mylearning-text-muted);
                                cursor: pointer;
                            }

                            /* Course Grid & Cards */
                            .course-grid {
                                display: grid;
                                grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
                                gap: 24px;
                            }

                            .course-card {
                                border: 1px solid var(--mylearning-border);
                                border-radius: 4px;
                                overflow: hidden;
                                background: #fff;
                                display: flex;
                                flex-direction: column;
                                transition: box-shadow 0.2s ease, transform 0.2s ease;
                            }

                            .course-card:hover {
                                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
                                transform: translateY(-2px);
                            }

                            .course-thumbnail {
                                position: relative;
                                width: 100%;
                                padding-top: 56.25%;
                                background-color: #e8e9eb;
                                overflow: hidden;
                            }

                            .course-thumbnail img {
                                position: absolute;
                                top: 0;
                                left: 0;
                                width: 100%;
                                height: 100%;
                                object-fit: cover;
                            }

                            .play-overlay {
                                position: absolute;
                                top: 0;
                                left: 0;
                                width: 100%;
                                height: 100%;
                                background: rgba(0, 0, 0, 0.35);
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                opacity: 0;
                                transition: opacity 0.2s ease;
                            }

                            .course-card:hover .play-overlay {
                                opacity: 1;
                            }

                            .play-icon {
                                width: 48px;
                                height: 48px;
                                background: #fff;
                                border-radius: 50%;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                color: var(--mylearning-text-dark);
                                font-size: 1.2rem;
                            }

                            .course-body {
                                padding: 16px;
                                display: flex;
                                flex-direction: column;
                                flex-grow: 1;
                            }

                            .course-title {
                                font-size: 1rem;
                                font-weight: 700;
                                line-height: 1.3;
                                margin-bottom: 6px;
                                color: var(--mylearning-text-dark);
                                display: -webkit-box;
                                -webkit-line-clamp: 2;
                                line-clamp: 2;
                                -webkit-box-orient: vertical;
                                overflow: hidden;
                                height: 2.6em;
                            }

                            .course-instructor {
                                font-size: 0.825rem;
                                color: var(--mylearning-text-muted);
                                margin-bottom: 12px;
                            }

                            .course-action {
                                display: flex;
                                align-items: center;
                                justify-content: space-between;
                                margin-top: auto;
                                padding-top: 10px;
                                border-top: 1px solid #f0f0f0;
                            }

                            .btn-purple {
                                background-color: var(--mylearning-primary);
                                color: #fff !important;
                                font-weight: 700;
                                padding: 10px 20px;
                                border-radius: 4px;
                                text-decoration: none;
                                border: none;
                                display: inline-block;
                                cursor: pointer;
                                transition: background-color 0.2s ease;
                            }

                            .btn-purple:hover {
                                background-color: var(--mylearning-primary-hover);
                            }

                            .btn-outline-custom {
                                border: 1px solid var(--mylearning-text-dark);
                                color: var(--mylearning-text-dark);
                                font-weight: 700;
                                padding: 8px 16px;
                                border-radius: 4px;
                                background: transparent;
                                text-decoration: none;
                            }

                            .btn-outline-custom:hover {
                                background-color: #f7f9fa;
                            }

                            /* Empty State dùng chung đồng bộ toàn bộ các Tab */
                            .empty-state {
                                text-align: center;
                                padding: 50px 20px;
                                background: var(--mylearning-bg);
                                border: 1px dashed var(--mylearning-border);
                                border-radius: 8px;
                                margin: 10px 0;
                            }

                            .empty-state i {
                                font-size: 3rem;
                                color: var(--mylearning-text-muted);
                                margin-bottom: 16px;
                            }

                            .empty-state h3 {
                                font-weight: 700;
                                margin-bottom: 8px;
                                font-size: 1.25rem;
                                color: var(--mylearning-text-dark);
                            }

                            .empty-state p {
                                color: var(--mylearning-text-muted);
                                margin-bottom: 24px;
                                font-size: 0.95rem;
                            }

                            /* Tab Content Panel Display State */
                            .tab-content-item {
                                display: none;
                            }

                            .tab-content-item.active {
                                display: block;
                            }

                            /* My Lists Cards */
                            .list-card {
                                border: 1px solid var(--mylearning-border);
                                border-radius: 6px;
                                padding: 20px;
                                background: #fff;
                                transition: all 0.2s ease;
                                display: flex;
                                flex-direction: column;
                                justify-content: space-between;
                                height: 100%;
                            }

                            .list-card:hover {
                                border-color: var(--mylearning-text-dark);
                                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                            }

                            .list-card-title {
                                font-size: 1.1rem;
                                font-weight: 700;
                                color: var(--mylearning-text-dark);
                                margin-bottom: 6px;
                            }

                            .list-card-count {
                                font-size: 0.85rem;
                                color: var(--mylearning-text-muted);
                                margin-bottom: 16px;
                            }

                            .list-thumbnails-preview {
                                display: flex;
                                gap: 6px;
                                margin-bottom: 16px;
                            }

                            .list-thumbnails-preview img {
                                width: 48px;
                                height: 48px;
                                object-fit: cover;
                                border-radius: 4px;
                                background-color: #eee;
                            }

                            /* Learning Tools Section */
                            .tool-box {
                                border: 1px solid var(--mylearning-border);
                                border-radius: 8px;
                                padding: 24px;
                                margin-bottom: 24px;
                                background: #fff;
                            }

                            .tool-box-header {
                                display: flex;
                                align-items: center;
                                gap: 16px;
                                margin-bottom: 16px;
                            }

                            .tool-icon {
                                width: 48px;
                                height: 48px;
                                border-radius: 8px;
                                background: #f0ebff;
                                color: var(--mylearning-primary);
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                font-size: 1.4rem;
                                flex-shrink: 0;
                            }

                            .tool-title-text h4 {
                                font-size: 1.15rem;
                                font-weight: 700;
                                margin: 0 0 4px 0;
                            }

                            .tool-title-text p {
                                margin: 0;
                                color: var(--mylearning-text-muted);
                                font-size: 0.9rem;
                            }

                            .day-selector button {
                                width: 38px;
                                height: 38px;
                                border-radius: 50%;
                                border: 1px solid var(--mylearning-border);
                                background: #fff;
                                font-weight: 600;
                                font-size: 0.85rem;
                                color: var(--mylearning-text-dark);
                                cursor: pointer;
                                transition: all 0.2s;
                            }

                            .day-selector button.active {
                                background: var(--mylearning-primary);
                                color: #fff;
                                border-color: var(--mylearning-primary);
                            }

                            .goal-bar-bg {
                                height: 10px;
                                background-color: #e8e9eb;
                                border-radius: 5px;
                                overflow: hidden;
                                margin: 12px 0 8px 0;
                            }

                            .goal-bar-fill {
                                height: 100%;
                                background-color: #2e7d32;
                                width: 40%;
                            }
                        </style>
                    </head>

                    <body>

                        <!-- Nhúng Header dùng chung -->
                        <jsp:include page="/view/common/header.jsp" />

                        <!-- Header Trang My Learning -->
                        <div class="my-learning-header">
                            <div class="container">
                                <h1>My Learning</h1>
                                <!-- Tabs Navigation -->
                                <ul class="my-learning-tabs" id="myLearningTabs">
                                    <li><button class="nav-link active" data-tab="all-courses"
                                            onclick="switchTab('all-courses', this)">All Courses</button></li>
                                    <li><button class="nav-link" data-tab="my-lists"
                                            onclick="switchTab('my-lists', this)">My Lists</button></li>
                                    <li><button class="nav-link" data-tab="wishlist"
                                            onclick="switchTab('wishlist', this)">Wishlist</button></li>
                                    <li><button class="nav-link" data-tab="archived"
                                            onclick="switchTab('archived', this)">Archived</button></li>
                                    <li><button class="nav-link" data-tab="learning-tools"
                                            onclick="switchTab('learning-tools', this)">Learning Tools</button></li>
                                </ul>
                            </div>
                        </div>

                        <!-- Nội dung chính -->
                        <main>

                            <!-- ==================== TAB 1: ALL COURSES ==================== -->
                            <div id="tab-all-courses" class="tab-content-item active">
                                <div class="container content-container">
                                    <div class="learning-controls">
                                        <div class="learning-filters">
                                            <select class="filter-select" id="sortBy" onchange="filterCourses()">
                                                <option value="recent">Sort by: Recently Accessed</option>
                                                <option value="title-asc">Title: A to Z</option>
                                                <option value="title-desc">Title: Z to A</option>
                                            </select>

                                            <select class="filter-select" id="filterProgress"
                                                onchange="filterCourses()">
                                                <option value="all">Progress: All</option>
                                                <option value="in-progress">In Progress</option>
                                                <option value="completed">Completed</option>
                                                <option value="not-started">Not Started</option>
                                            </select>

                                            <select class="filter-select" id="filterCategory"
                                                onchange="filterCourses()">
                                                <option value="all">Categories: All</option>
                                                <option value="1">Software Engineering</option>
                                                <option value="2">Business & Management</option>
                                            </select>
                                        </div>

                                        <div class="learning-search">
                                            <input type="text" id="courseSearchInput" placeholder="Search my courses..."
                                                onkeyup="searchCourses()">
                                            <button type="button" aria-label="Search"><i
                                                    class="fas fa-search"></i></button>
                                        </div>
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty myCourses}">
                                            <div class="course-grid" id="courseGrid">
                                                <c:forEach var="item" items="${myCourses}">
                                                    <div class="course-card" data-title="${item.name}"
                                                        data-progress="in-progress"
                                                        data-category="${not empty item.categoryId ? item.categoryId : 'all'}">
                                                        <div class="course-thumbnail">
                                                            <img src="${not empty item.thumbnail ? item.thumbnail : pageContext.request.contextPath.concat('/assets/img/courses/default-course.jpg')}"
                                                                alt="${item.name}">
                                                            <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}"
                                                                class="play-overlay" title="Start / Continue">
                                                                <div class="play-icon"><i class="fas fa-play"></i></div>
                                                            </a>
                                                        </div>
                                                        <div class="course-body">
                                                            <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}"
                                                                class="text-decoration-none">
                                                                <h2 class="course-title">${item.name}</h2>
                                                            </a>
                                                            <div class="course-instructor">${item.description}</div>
                                                            <div class="course-action">
                                                                <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}"
                                                                    class="btn-purple btn-sm w-100 text-center">
                                                                    Start Course
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="empty-state">
                                                <i class="fas fa-book-open"></i>
                                                <h3>You haven't enrolled in any courses yet</h3>
                                                <p>Explore our extensive course library and start your learning journey
                                                    today!</p>
                                                <a href="${pageContext.request.contextPath}/courses"
                                                    class="btn-purple">Explore Courses</a>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- ==================== TAB 2: MY LISTS ==================== -->
                            <div id="tab-my-lists" class="tab-content-item">
                                <div class="container content-container">
                                    <div class="mb-4">
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty userLists}">
                                            <div class="row g-4">
                                                <c:forEach var="list" items="${userLists}">
                                                    <div class="col-md-4 col-sm-6">
                                                        <div class="list-card">
                                                            <div>
                                                                <div class="list-card-title">${list.title}</div>
                                                                <div class="list-card-count">${list.courseCount} Course
                                                                    List</div>
                                                                <div class="list-thumbnails-preview">
                                                                    <c:forEach var="thumb" items="${list.thumbnails}">
                                                                        <img src="${thumb}"
                                                                            alt="Course thumbnail preview">
                                                                    </c:forEach>
                                                                </div>
                                                            </div>
                                                            <a href="${pageContext.request.contextPath}/my-lists/detail?id=${list.id}"
                                                                class="btn-outline-custom text-center w-100">View
                                                                List</a>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="empty-state">
                                                <i class="fas fa-list-ul"></i>
                                                <h3>Your list is empty</h3>
                                                <p>Create a list to organize your learning path more effectively.</p>
                                                <button type="button" onclick="switchTab('all-courses')"
                                                    class="btn-purple">Go to All Course tab</button>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- ==================== TAB 3: WISHLIST ==================== -->
                            <div id="tab-wishlist" class="tab-content-item">
                                <div class="container content-container">
                                    <div class="mb-4">
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty wishlistCourses}">
                                            <div class="course-grid">
                                                <c:forEach var="item" items="${wishlistCourses}">
                                                    <div class="course-card">
                                                        <div class="course-thumbnail">
                                                            <img src="${not empty item.thumbnail ? item.thumbnail : pageContext.request.contextPath.concat('/assets/img/courses/default-course.jpg')}"
                                                                alt="${item.name}">
                                                        </div>
                                                        <div class="course-body">
                                                            <h2 class="course-title">${item.name}</h2>
                                                            <div class="course-instructor">${item.description}</div>
                                                            <div class="course-action gap-2">
                                                                <a href="${pageContext.request.contextPath}/course-detail?id=${item.id}"
                                                                    class="btn-purple btn-sm flex-grow-1 text-center">View
                                                                    Course</a>
                                                                <button class="btn btn-outline-danger btn-sm"
                                                                    title="Remove from Wishlist"
                                                                    onclick="removeFromWishlist('${item.id}')">
                                                                    <i class="fas fa-trash-alt"></i>
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="empty-state">
                                                <i class="far fa-heart"></i>
                                                <h3>Your wishlist is empty</h3>
                                                <p>Explore the course catalog and click the heart icon to save the
                                                    courses that interest you.</p>
                                                <button type="button" onclick="switchTab('all-courses')"
                                                    class="btn-purple">Go to All Course tab</button>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- ==================== TAB 4: ARCHIVED ==================== -->
                            <div id="tab-archived" class="tab-content-item">
                                <div class="container content-container">
                                    <div class="mb-4">
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty archivedCourses}">
                                            <div class="course-grid">
                                                <c:forEach var="item" items="${archivedCourses}">
                                                    <div class="course-card">
                                                        <div class="course-thumbnail">
                                                            <img src="${not empty item.thumbnail ? item.thumbnail : pageContext.request.contextPath.concat('/assets/img/courses/default-course.jpg')}"
                                                                alt="${item.name}">
                                                        </div>
                                                        <div class="course-body">
                                                            <h2 class="course-title">${item.name}</h2>
                                                            <div class="course-instructor">${item.description}</div>
                                                            <div class="course-action gap-2">
                                                                <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}"
                                                                    class="btn-purple btn-sm flex-grow-1 text-center">Retake
                                                                    course</a>
                                                                <button class="btn-outline-custom btn-sm"
                                                                    onclick="unarchiveCourse('${item.id}')">Unarchive</button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="empty-state">
                                                <i class="fas fa-archive"></i>
                                                <h3>No archived courses yet</h3>
                                                <p>You can move completed or on-hold courses to the Archived section.
                                                </p>
                                                <button type="button" onclick="switchTab('all-courses')"
                                                    class="btn-purple">Go to All Course tab</button>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- ==================== TAB 5: LEARNING TOOLS ==================== -->
                            <div id="tab-learning-tools" class="tab-content-item">
                                <div class="container content-container">
                                    <div class="row">
                                        <div class="col-lg-8 mx-auto">
                                            <!-- Goal Setting -->
                                            <div class="tool-box">
                                                <div class="tool-box-header">
                                                    <div class="tool-icon"><i class="fas fa-bullseye"></i></div>
                                                    <div class="tool-title-text">
                                                        <h4>Mục tiêu học tập hàng tuần</h4>
                                                        <p>Thiết lập thói quen học tập đều đặn để đạt tiến độ mong muốn.
                                                        </p>
                                                    </div>
                                                </div>
                                                <div class="p-3 bg-light rounded">
                                                    <div class="d-flex justify-content-between align-items-center">
                                                        <div>
                                                            <span class="fw-bold text-dark">Mục tiêu hiện tại: </span>
                                                            <span class="text-success fw-bold">3 ngày / tuần (30
                                                                phút/ngày)</span>
                                                        </div>
                                                        <button class="btn-outline-custom btn-sm"
                                                            onclick="editGoal()">Thay đổi</button>
                                                    </div>
                                                    <div class="goal-bar-bg">
                                                        <div class="goal-bar-fill"></div>
                                                    </div>
                                                    <small class="text-muted">Đã hoàn thành 1/3 ngày trong tuần
                                                        này.</small>
                                                </div>
                                            </div>

                                            <!-- Reminders -->
                                            <div class="tool-box">
                                                <div class="tool-box-header">
                                                    <div class="tool-icon"><i class="far fa-bell"></i></div>
                                                    <div class="tool-title-text">
                                                        <h4>Nhắc nhở học tập (Learning Reminders)</h4>
                                                        <p>Cài đặt thông báo tự động gửi về Email hoặc hệ thống để không
                                                            bỏ lỡ buổi học nào.</p>
                                                    </div>
                                                </div>
                                                <form id="reminderForm" onsubmit="saveReminder(event)">
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold">Chọn ngày nhắc nhở trong
                                                            tuần:</label>
                                                        <div class="day-selector d-flex gap-2">
                                                            <button type="button" onclick="toggleDay(this)">T2</button>
                                                            <button type="button" class="active"
                                                                onclick="toggleDay(this)">T3</button>
                                                            <button type="button" onclick="toggleDay(this)">T4</button>
                                                            <button type="button" class="active"
                                                                onclick="toggleDay(this)">T5</button>
                                                            <button type="button" onclick="toggleDay(this)">T6</button>
                                                            <button type="button" class="active"
                                                                onclick="toggleDay(this)">T7</button>
                                                            <button type="button" onclick="toggleDay(this)">CN</button>
                                                        </div>
                                                    </div>
                                                    <div class="row g-3 align-items-center mb-3">
                                                        <div class="col-auto">
                                                            <label for="reminderTime"
                                                                class="form-label fw-bold mb-0">Khung giờ nhắc:</label>
                                                        </div>
                                                        <div class="col-auto">
                                                            <input type="time" id="reminderTime" class="form-control"
                                                                value="20:00">
                                                        </div>
                                                    </div>
                                                    <button type="submit" class="btn-purple btn-sm">Lưu cài đặt nhắc
                                                        nhở</button>
                                                </form>
                                            </div>

                                            <!-- Calendar Sync -->
                                            <div class="tool-box">
                                                <div class="tool-box-header">
                                                    <div class="tool-icon"><i class="far fa-calendar-alt"></i></div>
                                                    <div class="tool-title-text">
                                                        <h4>Đồng bộ Lịch học</h4>
                                                        <p>Thêm thời gian biểu học tập trực tiếp vào ứng dụng lịch cá
                                                            nhân của bạn.</p>
                                                    </div>
                                                </div>
                                                <div class="d-flex flex-wrap gap-3">
                                                    <button class="btn-outline-custom" onclick="syncCalendar('google')">
                                                        <i class="fab fa-google me-2"></i> Đồng bộ Google Calendar
                                                    </button>
                                                    <button class="btn-outline-custom"
                                                        onclick="syncCalendar('outlook')">
                                                        <i class="fab fa-windows me-2"></i> Đồng bộ Outlook Calendar
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </main>

                        <!-- Scripts -->
                        <script src="${pageContext.request.contextPath}/assets/js/vendor/jquery-3.6.0.min.js"></script>
                        <script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

                        <script>
                            // Điều hướng Tab SPA
                            function switchTab(tabId, element) {
                                document.querySelectorAll('#myLearningTabs .nav-link').forEach(btn => btn.classList.remove('active'));

                                if (element) {
                                    element.classList.add('active');
                                } else {
                                    const targetBtn = document.querySelector(`#myLearningTabs .nav-link[data-tab="${tabId}"]`);
                                    if (targetBtn) targetBtn.classList.add('active');
                                }

                                document.querySelectorAll('.tab-content-item').forEach(content => {
                                    content.classList.remove('active');
                                });

                                const targetTab = document.getElementById('tab-' + tabId);
                                if (targetTab) {
                                    targetTab.classList.add('active');
                                }

                                if (history.pushState) {
                                    history.pushState(null, null, '#' + tabId);
                                } else {
                                    location.hash = '#' + tabId;
                                }
                            }

                            document.addEventListener("DOMContentLoaded", function () {
                                const currentHash = window.location.hash.replace('#', '');
                                if (currentHash) {
                                    const targetBtn = document.querySelector(`#myLearningTabs .nav-link[data-tab="${currentHash}"]`);
                                    if (targetBtn) {
                                        switchTab(currentHash, targetBtn);
                                    }
                                }
                            });

                            // Lọc và Tìm kiếm
                            function searchCourses() {
                                filterCourses();
                            }

                            function filterCourses() {
                                let searchKeyword = document.getElementById('courseSearchInput').value.toLowerCase();
                                let selectedProgress = document.getElementById('filterProgress').value;
                                let selectedCategory = document.getElementById('filterCategory').value;
                                let grid = document.getElementById('courseGrid');

                                if (!grid) return;

                                let cards = Array.from(grid.querySelectorAll('.course-card'));
                                cards.forEach(card => {
                                    let title = (card.getAttribute('data-title') || '').toLowerCase();
                                    let progress = card.getAttribute('data-progress') || 'all';
                                    let category = card.getAttribute('data-category') || 'all';

                                    let matchSearch = title.includes(searchKeyword);
                                    let matchProgress = (selectedProgress === 'all') || (progress === selectedProgress);
                                    let matchCategory = (selectedCategory === 'all') || (category === selectedCategory);

                                    if (matchSearch && matchProgress && matchCategory) {
                                        card.style.display = "flex";
                                    } else {
                                        card.style.display = "none";
                                    }
                                });
                            }

                            // JS Bổ trợ
                            function toggleDay(btn) {
                                btn.classList.toggle('active');
                            }

                            function saveReminder(e) {
                                e.preventDefault();
                                alert('Đã lưu lịch nhắc nhở học tập thành công!');
                            }

                            function syncCalendar(provider) {
                                alert('Đang kết nối và đồng bộ lịch học với ' + (provider === 'google' ? 'Google Calendar' : 'Outlook Calendar') + '...');
                            }

                            function removeFromWishlist(courseId) {
                                if (confirm('Bạn có chắc chắn muốn xóa khóa học này khỏi danh sách yêu thích?')) {
                                    window.location.href = '${pageContext.request.contextPath}/wishlist/remove?id=' + courseId;
                                }
                            }

                            function unarchiveCourse(courseId) {
                                window.location.href = '${pageContext.request.contextPath}/archived/unarchive?id=' + courseId;
                            }

                            function editGoal() {
                                alert('Chức năng điều chỉnh mục tiêu tuần sẽ sớm cập nhật!');
                            }
                        </script>

                    </body>

                    </html>
