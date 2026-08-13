<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Learning | OCMS</title>
    
    <!-- CSS hệ thống -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">

    <!-- CSS Tùy chỉnh dành riêng cho trang My Learning (Giao diện Udemy Style) -->
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
        }

        /* Page Banner / Header Title */
        .my-learning-header {
            background-color: #2d2f31;
            color: #ffffff;
            padding: 36px 0 0 0;
            margin-bottom: 24px;
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

        .filter-select:focus {
            border-color: var(--mylearning-text-dark);
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
            margin-bottom: 48px;
        }

        .course-card {
            border: 1px solid var(--mylearning-border);
            border-radius: 4px;
            overflow: hidden;
            background: #fff;
            display: flex;
            flex-direction: column;
            transition: box-shadow 0.2s ease, transform 0.2s ease;
            position: relative;
        }

        .course-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
            transform: translateY(-2px);
        }

        .course-thumbnail {
            position: relative;
            width: 100%;
            padding-top: 56.25%; /* Aspect Ratio 16:9 */
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
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
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
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* Progress Bar */
        .progress-container {
            margin-top: auto;
            padding-top: 10px;
        }

        .progress-bar-bg {
            height: 4px;
            background-color: #d1d7dc;
            border-radius: 2px;
            overflow: hidden;
            margin-bottom: 8px;
        }

        .progress-bar-fill {
            height: 100%;
            background-color: var(--mylearning-primary);
            transition: width 0.3s ease;
        }

        .progress-info {
            display: flex;
            justify-content: space-between;
            font-size: 0.8rem;
            color: var(--mylearning-text-muted);
            font-weight: 500;
        }

        /* Action Footer */
        .course-action {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 12px;
            padding-top: 10px;
            border-top: 1px solid #f0f0f0;
        }

        .btn-continue {
            color: var(--mylearning-primary);
            font-weight: 700;
            font-size: 0.875rem;
            text-decoration: none;
        }

        .btn-continue:hover {
            color: var(--mylearning-primary-hover);
            text-decoration: underline;
        }

        .course-options-btn {
            background: none;
            border: none;
            color: var(--mylearning-text-muted);
            font-size: 1.1rem;
            padding: 4px 8px;
            cursor: pointer;
            border-radius: 50%;
        }

        .course-options-btn:hover {
            background-color: #f0f0f0;
            color: var(--mylearning-text-dark);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: var(--mylearning-bg);
            border-radius: 8px;
            margin: 40px 0;
        }

        .empty-state i {
            font-size: 3.5rem;
            color: var(--mylearning-text-muted);
            margin-bottom: 16px;
        }

        .empty-state h3 {
            font-weight: 700;
            margin-bottom: 8px;
        }

        .empty-state p {
            color: var(--mylearning-text-muted);
            margin-bottom: 20px;
        }

        .btn-browse {
            background-color: var(--mylearning-primary);
            color: #fff;
            font-weight: 700;
            padding: 12px 24px;
            border-radius: 4px;
            text-decoration: none;
            display: inline-block;
        }

        .btn-browse:hover {
            background-color: var(--mylearning-primary-hover);
            color: #fff;
        }
    </style>
</head>
<body>

    <!-- Nhúng Header dùng chung của dự án -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Section Header Trang My Learning -->
    <div class="my-learning-header">
        <div class="container">
            <h1>My Learning</h1>
            <!-- Tabs Navigation -->
            <ul class="my-learning-tabs" id="myLearningTabs">
                <li><button class="nav-link active" onclick="switchTab('all-courses', this)">All Courses</button></li>
                <li><button class="nav-link" onclick="switchTab('my-lists', this)">My Lists</button></li>
                <li><button class="nav-link" onclick="switchTab('wishlist', this)">Wishlist</button></li>
                <li><button class="nav-link" onclick="switchTab('archived', this)">Archived</button></li>
                <li><button class="nav-link" onclick="switchTab('learning-tools', this)">Learning Tools</button></li>
            </ul>
        </div>
    </div>

    <!-- Nội dung chính -->
    <main class="container my-4">
        
        <!-- Tab Content: All Courses -->
        <div id="tab-all-courses" class="tab-content-item">
            
            <!-- Controls Bar (Lọc & Tìm kiếm) -->
            <div class="learning-controls">
                <div class="learning-filters">
                    <!-- Sắp xếp -->
                    <select class="filter-select" id="sortBy" onchange="filterCourses()">
                        <option value="recent">Sort by: Recently Accessed</option>
                        <option value="title-asc">Title: A to Z</option>
                        <option value="title-desc">Title: Z to A</option>
                        <option value="progress">Completion Progress</option>
                    </select>

                    <!-- Lọc theo danh mục -->
                    <select class="filter-select" id="filterCategory" onchange="filterCourses()">
                        <option value="all">Categories: All</option>
                        <option value="1">Business</option>
                        <option value="2">Technology</option>
                    </select>

                    <!-- Lọc theo tiến độ -->
                    <select class="filter-select" id="filterProgress" onchange="filterCourses()">
                        <option value="all">Progress: All</option>
                        <option value="in-progress">In Progress</option>
                        <option value="completed">Completed</option>
                        <option value="not-started">Not Started</option>
                    </select>
                </div>

                <!-- Tìm kiếm khóa học trong danh sách cá nhân -->
                <div class="learning-search">
                    <input type="text" id="courseSearchInput" placeholder="Search my courses..." onkeyup="searchCourses()">
                    <button type="button" aria-label="Search"><i class="fas fa-search"></i></button>
                </div>
            </div>

            <!-- Danh sách các khóa học đã đăng ký -->
            <c:choose>
                <c:when test="${not empty myCourses}">
                    <div class="course-grid" id="courseGrid">
                        <c:forEach var="item" items="${myCourses}">
                            <div class="course-card" 
                                 data-title="${item.name}" 
                                 data-category="${item.categoryId}">
                                
                                <!-- Ảnh thumbnail khóa học -->
                                <div class="course-thumbnail">
                                    <img src="${not empty item.thumbnail ? item.thumbnail : pageContext.request.contextPath.concat('/assets/img/courses/default-course.jpg')}" alt="${item.name}">
                                    <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}" class="play-overlay" title="Start / Continue">
                                        <div class="play-icon"><i class="fas fa-play"></i></div>
                                    </a>
                                </div>

                                <!-- Thông tin chi tiết khóa học -->
                                <div class="course-body">
                                    <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}" class="text-decoration-none">
                                        <h2 class="course-title">${item.name}</h2>
                                    </a>
                                    <div class="course-instructor">${item.description}</div>

                                    <!-- Nút hành động -->
                                    <div class="course-action">
                                        <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}" class="btn-continue">
                                            Start Course
                                        </a>
                                        <button class="course-options-btn" title="Options" onclick="openCourseMenu('${item.id}')">
                                            <i class="fas fa-ellipsis-v"></i>
                                        </button>
                                    </div>
                                </div>

                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <!-- Màn hình rỗng hiển thị khi user chưa đăng ký khóa học nào -->
                    <div class="empty-state">
                        <i class="fas fa-book-open"></i>
                        <h3>Bạn chưa đăng ký khóa học nào</h3>
                        <p>Hãy khám phá các khóa học hấp dẫn và bắt đầu hành trình học tập của bạn ngay hôm nay!</p>
                        <a href="${pageContext.request.contextPath}/browse-course" class="btn-browse">Khám phá khóa học ngay</a>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>

        <!-- Tab Content: My Lists -->
        <div id="tab-my-lists" class="tab-content-item d-none">
            <div class="empty-state">
                <i class="fas fa-folder-plus"></i>
                <h3>Organize your learning with lists</h3>
                <p>Create custom lists of your courses to organize your learning paths.</p>
                <a href="#" class="btn-browse">+ Create New List</a>
            </div>
        </div>

        <!-- Tab Content: Wishlist -->
        <div id="tab-wishlist" class="tab-content-item d-none">
            <div class="empty-state">
                <i class="far fa-heart"></i>
                <h3>Your wishlist is empty</h3>
                <p>Explore our courses and add your favorite ones to your wishlist.</p>
                <a href="${pageContext.request.contextPath}/browse-course" class="btn-browse">Browse Courses Now</a>
            </div>
        </div>

        <!-- Tab Content: Archived -->
        <div id="tab-archived" class="tab-content-item d-none">
            <div class="empty-state">
                <i class="fas fa-archive"></i>
                <h3>No archived courses</h3>
                <p>Courses you archive will appear here.</p>
            </div>
        </div>

        <!-- Tab Content: Learning Tools -->
        <div id="tab-learning-tools" class="tab-content-item d-none">
            <div class="empty-state">
                <i class="fas fa-tools"></i>
                <h3>Learning Reminders & Schedules</h3>
                <p>Set learning reminders or sync your learning schedule with your calendar.</p>
            </div>
        </div>

    </main>

    <!-- Scripts bổ trợ -->
    <script src="${pageContext.request.contextPath}/assets/js/vendor/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    
    <script>
        function switchTab(tabName, element) {
            document.querySelectorAll('#myLearningTabs .nav-link').forEach(btn => {
                btn.classList.remove('active');
            });
            element.classList.add('active');

            document.querySelectorAll('.tab-content-item').forEach(content => {
                content.classList.add('d-none');
            });

            const targetTab = document.getElementById('tab-' + tabName);
            if (targetTab) {
                targetTab.classList.remove('d-none');
            }
        }

        function searchCourses() {
            let input = document.getElementById('courseSearchInput').value.toLowerCase();
            filterCourses(input);
        }

        function filterCourses(searchKeyword = null) {
            if (searchKeyword === null) {
                searchKeyword = document.getElementById('courseSearchInput').value.toLowerCase();
            }

            let category = document.getElementById('filterCategory').value;
            let sortBy = document.getElementById('sortBy').value;

            let grid = document.getElementById('courseGrid');
            if (!grid) return;

            let cards = Array.from(grid.querySelectorAll('.course-card'));

            cards.forEach(card => {
                let title = (card.getAttribute('data-title') || card.querySelector('.course-title').innerText).toLowerCase();
                let cardCategory = (card.getAttribute('data-category') || 'all').toLowerCase();

                let matchSearch = title.includes(searchKeyword);
                let matchCategory = (category === 'all') || (cardCategory === category.toLowerCase());

                if (matchSearch && matchCategory) {
                    card.style.display = "flex";
                } else {
                    card.style.display = "none";
                }
            });

            cards.sort((a, b) => {
                let titleA = (a.getAttribute('data-title') || a.querySelector('.course-title').innerText).toLowerCase();
                let titleB = (b.getAttribute('data-title') || b.querySelector('.course-title').innerText).toLowerCase();

                if (sortBy === 'title-asc') {
                    return titleA.localeCompare(titleB);
                } else if (sortBy === 'title-desc') {
                    return titleB.localeCompare(titleA);
                }
                return 0;
            });

            cards.forEach(card => grid.appendChild(card));
        }

        function openCourseMenu(courseId) {
            alert("Menu tùy chọn cho khóa học ID: " + courseId);
        }
    </script>

</body>
</html>