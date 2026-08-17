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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Learning | OCMS</title>

    <!-- System CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_learning.css">

    <style>
        body {
            background-color: #ffffff;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }

        /* Banner & Tabs Header */
        .my-learning-header {
            background-color: #2d2f31;
            color: #ffffff;
            padding-top: 32px;
            padding-bottom: 0;
        }

        .my-learning-header h1 {
            font-size: 36px;
            font-weight: 700;
            margin-bottom: 24px;
            letter-spacing: -0.5px;
        }

        .my-learning-tabs {
            display: flex;
            list-style: none;
            padding: 0;
            margin: 0;
            gap: 24px;
        }

        .my-learning-tabs .nav-link {
            background: none;
            border: none;
            color: #d1d7dc;
            font-size: 16px;
            font-weight: 700;
            padding: 12px 0;
            cursor: pointer;
            border-bottom: 4px solid transparent;
            transition: color 0.2s, border-color 0.2s;
        }

        .my-learning-tabs .nav-link:hover {
            color: #ffffff;
        }

        .my-learning-tabs .nav-link.active {
            color: #ffffff;
            border-bottom-color: #ffffff;
        }

        /* Standard Empty State Styling */
        .empty-state-box {
            background-color: #f7f9fa;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 50px 20px;
            text-align: center;
            margin-top: 20px;
            margin-bottom: 40px;
        }

        .empty-state-title {
            font-size: 20px;
            font-weight: 700;
            color: #1c1d1f;
            margin-bottom: 8px;
        }

        .empty-state-desc {
            font-size: 14px;
            color: #6a6f73;
            margin-bottom: 24px;
        }

        /* Standard Purple Buttons */
        .btn-purple {
            background-color: #a435f0;
            color: #ffffff !important;
            padding: 10px 20px;
            border-radius: 4px;
            font-weight: 700;
            font-size: 14px;
            text-decoration: none;
            border: none;
            display: inline-block;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .btn-purple:hover {
            background-color: #8710d8;
        }

        .btn-purple-sm {
            background-color: #a435f0;
            color: #ffffff !important;
            padding: 6px 14px;
            border-radius: 4px;
            font-weight: 700;
            font-size: 13px;
            border: none;
            cursor: pointer;
        }

        .btn-purple-sm:hover {
            background-color: #8710d8;
        }

        /* Filter Controls */
        .learning-controls {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            margin-top: 24px;
            margin-bottom: 24px;
        }

        .filter-select {
            padding: 10px 14px;
            border: 1px solid #1c1d1f;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 600;
            background-color: #ffffff;
            margin-right: 8px;
        }

        .learning-search input {
            padding: 10px 16px;
            border: 1px solid #1c1d1f;
            border-radius: 4px;
            font-size: 14px;
            width: 260px;
        }

        /* Tab Content Display Logic */
        .tab-content-item {
            display: none;
        }

        .tab-content-item.active {
            display: block;
        }

        /* Cards Grid */
        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .course-card {
            border: 1px solid #d1d5db;
            border-radius: 6px;
            overflow: hidden;
            background: #fff;
        }

        .course-card img {
            width: 100%;
            height: 150px;
            object-fit: cover;
        }

        .course-card-body {
            padding: 14px;
        }

        .course-card-title {
            font-size: 16px;
            font-weight: 700;
            color: #1c1d1f;
            margin-bottom: 12px;
            line-height: 1.3;
        }

        .btn-action-group {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        /* List Cards Custom UI */
        .list-card {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            background: #ffffff;
            transition: box-shadow 0.2s ease;
        }

        .list-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        .list-card-header {
            padding: 16px 20px;
            border-bottom: 1px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .list-card-body {
            padding: 20px;
        }

        .list-card-actions .btn-icon {
            background: transparent;
            border: none;
            color: #6a6f73;
            padding: 6px 10px;
            border-radius: 4px;
            transition: background 0.2s, color 0.2s;
        }

        .list-card-actions .btn-icon:hover {
            background: #f7f9fa;
            color: #1c1d1f;
        }

        .list-card-actions .btn-icon-danger:hover {
            background: #fff0f0;
            color: #d92550;
        }

        .course-item-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 14px;
            background: #f7f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            margin-bottom: 8px;
            font-size: 14px;
        }

        /* Pop-up Modal Styling */
        .custom-modal-backdrop {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background-color: rgba(0, 0, 0, 0.55);
            z-index: 99999;
            align-items: center;
            justify-content: center;
        }

        .custom-modal-backdrop.show {
            display: flex;
        }

        .custom-modal-content {
            background: #ffffff;
            width: 90%;
            max-width: 500px;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }

        .custom-modal-header {
            padding: 16px 20px;
            background: #f7f9fa;
            border-bottom: 1px solid #d1d5db;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .custom-modal-body {
            padding: 20px;
        }

        .custom-modal-footer {
            padding: 14px 20px;
            background: #f7f9fa;
            border-top: 1px solid #d1d5db;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .tool-card {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 24px;
            background: #ffffff;
            margin-bottom: 20px;
        }
    </style>
</head>

<body>

    <!-- Common Header -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Navigation Header -->
    <div class="my-learning-header">
        <div class="container">
            <h1>My Learning</h1>
            <ul class="my-learning-tabs" id="myLearningTabs">
                <li><button class="nav-link active" data-tab="all-courses" onclick="switchTab('all-courses', this)">All Courses</button></li>
                <li><button class="nav-link" data-tab="my-lists" onclick="switchTab('my-lists', this)">My Lists</button></li>
                <li><button class="nav-link" data-tab="wishlist" onclick="switchTab('wishlist', this)">Wishlist</button></li>
                <li><button class="nav-link" data-tab="archived" onclick="switchTab('archived', this)">Archived</button></li>
                <li><button class="nav-link" data-tab="learning-tools" onclick="switchTab('learning-tools', this)">Learning Tools</button></li>
            </ul>
        </div>
    </div>

    <main class="py-4">
        <!-- ==================== TAB 1: ALL COURSES ==================== -->
        <div id="tab-all-courses" class="tab-content-item active">
            <div class="container">
                <div class="learning-controls">
                    <div class="learning-filters">
                        <select class="filter-select" id="sortBy" onchange="filterCourses()">
                            <option value="recent">Sort by: Recently Accessed</option>
                            <option value="title-asc">Title: A to Z</option>
                            <option value="title-desc">Title: Z to A</option>
                        </select>

                        <select class="filter-select" id="filterProgress" onchange="filterCourses()">
                            <option value="all">Progress: All</option>
                            <option value="in-progress">In Progress</option>
                            <option value="completed">Completed</option>
                        </select>

                        <select class="filter-select" id="filterCategory" onchange="filterCourses()">
                            <option value="all">Categories: All</option>
                        </select>
                    </div>

                    <div class="learning-search">
                        <input type="text" id="courseSearchInput" placeholder="Search my courses..." onkeyup="searchCourses()">
                    </div>
                </div>

                <!-- Course List / Empty State -->
                <c:choose>
                    <c:when test="${not empty myCourses}">
                        <div class="course-grid" id="courseGrid">
                            <c:forEach var="item" items="${myCourses}">
                                <div class="course-card" data-title="${item.name}">
                                    <img src="${not empty item.thumbnail ? item.thumbnail : pageContext.request.contextPath.concat('/assets/img/courses/default-course.jpg')}" alt="${item.name}">
                                    <div class="course-card-body">
                                        <h3 class="course-card-title">${item.name}</h3>
                                        <div class="btn-action-group">
                                            <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}" class="btn-purple">Start Course</a>
                                            <button type="button" class="btn btn-outline-secondary" onclick="openAddToListModal('${item.id}', '${item.name}')">+</button>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state-box">
                            <div class="empty-state-title">You haven't enrolled in any courses yet</div>
                            <div class="empty-state-desc">Explore our extensive course library and start your learning journey today!</div>
                            <a href="${pageContext.request.contextPath}/courses" class="btn-purple">Explore Courses</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- ==================== TAB 2: MY LISTS ==================== -->
        <div id="tab-my-lists" class="tab-content-item">
            <div class="container py-2">
                <div id="listsGridContainer">
                    <!-- Dynamic rendering via Javascript -->
                </div>
            </div>
        </div>

        <!-- ==================== TAB 3: WISHLIST ==================== -->
        <div id="tab-wishlist" class="tab-content-item">
            <div class="container py-2">
                <c:choose>
                    <c:when test="${not empty wishlistCourses}">
                        <div class="course-grid">
                            <c:forEach var="item" items="${wishlistCourses}">
                                <div class="course-card">
                                    <img src="${item.thumbnail}" alt="${item.name}">
                                    <div class="course-card-body">
                                        <h3 class="course-card-title">${item.name}</h3>
                                        <a href="${pageContext.request.contextPath}/course-detail?id=${item.id}" class="btn-purple">View Course</a>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state-box">
                            <div class="empty-state-title">Your wishlist is empty</div>
                            <div class="empty-state-desc">Explore courses and add them to your wishlist to save them for later.</div>
                            <a href="${pageContext.request.contextPath}/courses" class="btn-purple">Browse Courses</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- ==================== TAB 4: ARCHIVED ==================== -->
        <div id="tab-archived" class="tab-content-item">
            <div class="container py-2">
                <c:choose>
                    <c:when test="${not empty archivedCourses}">
                        <div class="course-grid">
                            <c:forEach var="item" items="${archivedCourses}">
                                <div class="course-card">
                                    <img src="${item.thumbnail}" alt="${item.name}">
                                    <div class="course-card-body">
                                        <h3 class="course-card-title">${item.name}</h3>
                                        <button class="btn btn-outline-primary btn-sm">Unarchive</button>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state-box">
                            <div class="empty-state-title">Focus on your current goals</div>
                            <div class="empty-state-desc">Courses you archive will appear here so you can access them whenever you need.</div>
                            <a href="${pageContext.request.contextPath}/courses" class="btn-purple">Explore Courses</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- ==================== TAB 5: LEARNING TOOLS ==================== -->
        <div id="tab-learning-tools" class="tab-content-item">
            <div class="container py-2">
                <div class="row">
                    <div class="col-md-6 mb-4">
                        <div class="tool-card">
                            <div class="d-flex align-items-center mb-3">
                                <i class="fas fa-bell fa-2x text-primary me-3"></i>
                                <div>
                                    <h5 class="fw-bold mb-1">Learning Reminders</h5>
                                    <p class="text-muted small mb-0">Set regular notifications to stay on track with your courses.</p>
                                </div>
                            </div>
                            <hr>
                            <form id="reminderForm" onsubmit="saveReminderSettings(event)">
                                <div class="mb-3">
                                    <label class="form-label fw-bold small">Frequency</label>
                                    <select class="form-select" id="reminderFrequency">
                                        <option value="daily">Daily</option>
                                        <option value="weekly" selected>Weekly (Recommended)</option>
                                        <option value="weekends">Weekends Only</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold small">Reminder Time</label>
                                    <input type="time" class="form-control" id="reminderTime" value="20:00">
                                </div>
                                <button type="submit" class="btn-purple w-100">Save Reminder Settings</button>
                            </form>
                        </div>
                    </div>

                    <div class="col-md-6 mb-4">
                        <div class="tool-card">
                            <div class="d-flex align-items-center mb-3">
                                <i class="fas fa-calendar-alt fa-2x text-success me-3"></i>
                                <div>
                                    <h5 class="fw-bold mb-1">Calendar Integration</h5>
                                    <p class="text-muted small mb-0">Sync your learning schedule directly with Google or Outlook Calendar.</p>
                                </div>
                            </div>
                            <hr>
                            <p class="small text-secondary">Export your course deadlines and study events into your favorite personal calendar application.</p>
                            <div class="d-grid gap-2">
                                <button type="button" class="btn btn-outline-dark fw-bold" onclick="syncCalendar('google')">
                                    <i class="fab fa-google me-2"></i> Sync Google Calendar
                                </button>
                                <button type="button" class="btn btn-outline-primary fw-bold" onclick="syncCalendar('outlook')">
                                    <i class="fab fa-windows me-2"></i> Sync Outlook Calendar
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- ==================== MODAL 1: CREATE / EDIT LIST FORM ==================== -->
    <div class="custom-modal-backdrop" id="addToListModal">
        <div class="custom-modal-content">
            <div class="custom-modal-header">
                <h5 class="fw-bold mb-0" id="modalTitleHeading">Create New List</h5>
                <button type="button" class="btn-close" onclick="closeAddToListModal()"></button>
            </div>

            <!-- Dynamic view selector (Used by '+' button from All Courses) -->
            <div id="viewSelectList" class="custom-modal-body" style="display: none;">
                <p class="text-muted small mb-3">Select a list to add this course to:</p>
                <div id="existingListsContainer" style="max-height: 240px; overflow-y: auto; margin-bottom: 15px;"></div>
                <button type="button" class="btn btn-outline-primary w-100 fw-bold" onclick="showCreateListFormView()">
                    + Create New List
                </button>
            </div>

            <!-- Create / Edit List Form -->
            <form id="createListForm">
                <div class="custom-modal-body">
                    <input type="hidden" id="modalEditListId">
                    <input type="hidden" id="modalCourseId">
                    <input type="hidden" id="modalCourseTitle">

                    <div class="mb-3">
                        <label for="listTitleInput" class="form-label fw-bold">List Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="listTitleInput" placeholder="e.g. Java Web Development" required>
                    </div>

                    <div class="mb-3">
                        <label for="listDescInput" class="form-label fw-bold">Description</label>
                        <textarea class="form-control" id="listDescInput" rows="3" placeholder="Add a description..."></textarea>
                    </div>
                </div>
                <div class="custom-modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeAddToListModal()">Cancel</button>
                    <button type="submit" class="btn-purple" id="btnSaveListSubmit">Save List</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ==================== MODAL 2: ADD COURSE TO LIST (MY LISTS TAB) ==================== -->
    <div class="custom-modal-backdrop" id="addCourseToListModal">
        <div class="custom-modal-content">
            <div class="custom-modal-header">
                <h5 class="fw-bold mb-0">Add Courses to List</h5>
                <button type="button" class="btn-close" onclick="closeAddCourseToListModal()"></button>
            </div>
            <div class="custom-modal-body">
                <input type="hidden" id="targetListIdForCourse">
                <p class="text-muted small mb-3">Select a course from your enrolled courses:</p>
                <div id="availableCoursesContainer" style="max-height: 280px; overflow-y: auto;">
                    <!-- Dynamically rendered -->
                </div>
            </div>
            <div class="custom-modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeAddCourseToListModal()">Done</button>
            </div>
        </div>
    </div>

    <!-- Script chứa dữ liệu JSON từ JSTL -->
    <script id="myListsJsonData" type="application/json">
    [
        <c:forEach var="list" items="${myLists}" varStatus="status">
        {
            "id": ${list.id},
            "title": "${list.title}",
            "description": "${list.description}",
            "courses": [
                <c:forEach var="c" items="${list.courses}" varStatus="cStatus">
                { "id": "${c.id}", "name": "${c.name}" }<c:if test="${!cStatus.last}">,</c:if>
                </c:forEach>
            ]
        }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ]
</script>

    <script id="enrolledCoursesJsonData" type="application/json">
    [
        <c:forEach var="c" items="${myCourses}" varStatus="status">
        { "id": "${c.id}", "name": "${c.name}" }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ]
</script>

    <!-- Script xử lý logic JavaScript chính -->
    <script>
        const API_URL = '${pageContext.request.contextPath}/user-learning-list';
        // sessionStorage keeps the active tab across reloads within the same tab
        // (so refresh / list operations stay on the current tab) but clears it
        // when the browser tab/session is closed, returning to All Courses.
        const STORAGE_KEY = 'my_learning_active_tab';
        let activeCourse = null;

        let enrolledCourses = [];
        try {
            const rawEnrolledJson = document.getElementById('enrolledCoursesJsonData').textContent;
            enrolledCourses = JSON.parse(rawEnrolledJson);
        } catch (e) {
            enrolledCourses = [];
        }

        let myListsData = [];
        try {
            const rawJsonData = document.getElementById('myListsJsonData').textContent;
            myListsData = JSON.parse(rawJsonData);
        } catch (e) {
            myListsData = [];
        }

        document.addEventListener('DOMContentLoaded', function () {
            const navButtons = document.querySelectorAll('#myLearningTabs .nav-link');

            // A ?tab=... query parameter (set by the "My Learning" header/footer
            // links) forces the tab back to All Courses. It must be consumed
            // only once and stripped from the URL, otherwise it would still be
            // present on every subsequent location.reload() (after a list
            // operation) and keep resetting the tab.
            const urlParams = new URLSearchParams(window.location.search);
            const tabFromUrl = urlParams.get('tab');

            if (tabFromUrl) {
                sessionStorage.removeItem(STORAGE_KEY);
                history.replaceState({}, '', window.location.pathname);
            }

            const initialTab = tabFromUrl || sessionStorage.getItem(STORAGE_KEY) || 'all-courses';
            const initialButton = document.querySelector('#myLearningTabs .nav-link[data-tab="' + initialTab + '"]') || navButtons[0];
            switchTab(initialTab, initialButton);

            renderMyLists();
        });

        function sendAjaxRequest(params) {
            return fetch(API_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: new URLSearchParams(params)
            })
            .then(response => {
                if (!response.ok) throw new Error('Network error');
                return response.json();
            });
        }

        function reloadPreservingTab() {
            const current = sessionStorage.getItem(STORAGE_KEY);
            const url = window.location.pathname + (current && current !== 'all-courses' ? '?tab=' + current : '');
            window.location.href = url;
        }

        function switchTab(tabId, element) {
            sessionStorage.setItem(STORAGE_KEY, tabId);

            document.querySelectorAll('#myLearningTabs .nav-link').forEach(function (btn) {
                btn.classList.remove('active');
            });

            if (element) {
                element.classList.add('active');
            }

            document.querySelectorAll('.tab-content-item').forEach(function (content) {
                content.classList.remove('active');
            });

            const activeTab = document.getElementById('tab-' + tabId);
            if (activeTab) {
                activeTab.classList.add('active');
            }
        }

        function renderMyLists() {
            const container = document.getElementById('listsGridContainer');
            if (!container) return;

            if (myListsData.length === 0) {
                container.innerHTML =
                    '<div class="empty-state-box">' +
                    '<div class="empty-state-title">No lists created yet</div>' +
                    '<div class="empty-state-desc">Create a list to organize your courses and learning paths.</div>' +
                    '<button type="button" class="btn-purple" onclick="openCreateListModal()">Create List</button>' +
                    '</div>';
                return;
            }

            let html = '<div class="d-flex justify-content-start mb-4">' +
                '<button type="button" class="btn-purple" onclick="openCreateListModal()"><i class="fas fa-plus me-2"></i>Create New List</button>' +
                '</div>' +
                '<div class="row g-4">';

            myListsData.forEach(function (list) {
                let coursesHtml = '';
                const listDesc = list.description || 'No description provided.';
                const courseCount = list.courses ? list.courses.length : 0;

                if (courseCount > 0) {
                    list.courses.forEach(function (c) {
                        coursesHtml +=
                            '<div class="course-item-row">' +
                            '<span class="fw-semibold text-dark"><i class="fas fa-book-open me-2 text-muted"></i>' + c.name + '</span>' +
                            '<button class="btn btn-sm btn-outline-danger border-0" onclick="removeCourseFromList(' + list.id + ', \'' + c.id + '\')" title="Remove from list"><i class="fas fa-times"></i></button>' +
                            '</div>';
                    });
                } else {
                    coursesHtml = '<div class="text-center py-3 text-muted small bg-light rounded">No courses in this list yet. Click "+ Add Course" to add courses.</div>';
                }

                html +=
                    '<div class="col-md-6 col-lg-6">' +
                    '<div class="list-card h-100 shadow-sm">' +
                    '<div class="list-card-header">' +
                    '<h5 class="fw-bold mb-0 text-dark">' + list.title + '</h5>' +
                    '<div class="list-card-actions d-flex gap-1">' +
                    '<button type="button" class="btn-icon" onclick="openEditListModal(' + list.id + ')" title="Edit List"><i class="fas fa-edit"></i></button>' +
                    '<button type="button" class="btn-icon btn-icon-danger" onclick="deleteList(' + list.id + ')" title="Delete List"><i class="fas fa-trash-alt"></i></button>' +
                    '</div>' +
                    '</div>' +
                    '<div class="list-card-body">' +
                    '<p class="text-muted small mb-4">' + listDesc + '</p>' +
                    '<div class="d-flex justify-content-between align-items-center mb-3">' +
                    '<span class="fw-bold small text-secondary">Courses (' + courseCount + ')</span>' +
                    '<button type="button" class="btn-purple-sm" onclick="openAddCourseToListModal(' + list.id + ')"><i class="fas fa-plus me-1"></i> Add Course</button>' +
                    '</div>' +
                    '<div>' + coursesHtml + '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            });
            html += '</div>';

            container.innerHTML = html;
        }

        // Mở modal tạo mới danh sách và trỏ onsubmit về hàm submitCreateList
        function openCreateListModal() {
            activeCourse = null;
            document.getElementById('modalEditListId').value = '';
            document.getElementById('modalTitleHeading').innerText = "Create New List";
            document.getElementById('btnSaveListSubmit').innerText = "Create List";
            
            const form = document.getElementById('createListForm');
            form.onsubmit = submitCreateList;

            showCreateListFormView();

            const modal = document.getElementById('addToListModal');
            if (modal) modal.classList.add('show');
        }

        // Mở modal sửa danh sách và trỏ onsubmit về hàm submitUpdateList
        function openEditListModal(listId) {
            const list = myListsData.find(function (l) { return l.id === listId; });
            if (!list) return;

            activeCourse = null;
            document.getElementById('modalEditListId').value = list.id;
            document.getElementById('modalTitleHeading').innerText = "Edit List";
            document.getElementById('btnSaveListSubmit').innerText = "Save Changes";

            const form = document.getElementById('createListForm');
            form.onsubmit = submitUpdateList;

            showCreateListFormView();
            document.getElementById('listTitleInput').value = list.title;
            document.getElementById('listDescInput').value = list.description || '';

            const modal = document.getElementById('addToListModal');
            if (modal) modal.classList.add('show');
        }

        function openAddCourseToListModal(listId) {
            document.getElementById('targetListIdForCourse').value = listId;
            const list = myListsData.find(function (l) { return l.id === listId; });
            const container = document.getElementById('availableCoursesContainer');

            if (!container || !list) return;

            if (enrolledCourses.length === 0) {
                container.innerHTML = '<p class="text-center text-muted my-3">You have no enrolled courses available.</p>';
            } else {
                let html = '';
                enrolledCourses.forEach(function (c) {
                    const isAdded = list.courses.some(function (lc) { return String(lc.id) === String(c.id); });
                    const btnHtml = isAdded
                        ? '<span class="badge bg-success">Added</span>'
                        : '<button type="button" class="btn btn-sm btn-primary" onclick="addCourseDirectlyToList(' + listId + ', \'' + c.id + '\')">+ Add</button>';

                    html += '<div class="d-flex justify-content-between align-items-center p-2 border-bottom">' +
                        '<span class="fw-semibold text-dark fs-6">' + c.name + '</span>' +
                        btnHtml +
                        '</div>';
                });
                container.innerHTML = html;
            }

            const modal = document.getElementById('addCourseToListModal');
            if (modal) modal.classList.add('show');
        }

        function closeAddCourseToListModal() {
            const modal = document.getElementById('addCourseToListModal');
            if (modal) modal.classList.remove('show');
        }

        function addCourseDirectlyToList(listId, courseId) {
            sendAjaxRequest({ action: 'addCourse', listId: listId, courseId: courseId })
                .then(data => {
                    if (data.status === 'success') {
                        reloadPreservingTab();
                    } else {
                        alert('Error adding course: ' + (data.message || 'Operation failed'));
                    }
                })
                .catch(() => alert('Connection error occurred!'));
        }

        function openAddToListModal(courseId, courseTitle) {
            activeCourse = courseId ? { id: courseId, name: courseTitle } : null;
            document.getElementById('modalEditListId').value = '';
            const modal = document.getElementById('addToListModal');

            if (modal) {
                if (myListsData.length === 0) {
                    showCreateListFormView();
                } else {
                    showSelectListGroupView();
                }
                modal.classList.add('show');
            }
        }

        function showSelectListGroupView() {
            document.getElementById('modalTitleHeading').innerText = "Add to List";
            document.getElementById('viewSelectList').style.display = 'block';
            document.getElementById('createListForm').style.display = 'none';

            const container = document.getElementById('existingListsContainer');
            let html = '';

            myListsData.forEach(function (list) {
                const isAlreadyInList = activeCourse && list.courses.some(function (c) { return String(c.id) === String(activeCourse.id); });
                const actionBtn = isAlreadyInList
                    ? '<span class="badge bg-success">Added</span>'
                    : '<button type="button" class="btn btn-sm btn-primary" onclick="addCourseToExistingList(' + list.id + ')">Add</button>';

                html += '<div class="d-flex justify-content-between align-items-center p-2 border-bottom">' +
                    '<div><strong>' + list.title + '</strong></div>' +
                    actionBtn +
                    '</div>';
            });

            container.innerHTML = html;
        }

        function showCreateListFormView() {
            document.getElementById('viewSelectList').style.display = 'none';
            document.getElementById('createListForm').style.display = 'block';
            document.getElementById('createListForm').reset();

            // Nếu tạo list từ việc thêm nhanh course vào list mới
            if (activeCourse) {
                document.getElementById('modalCourseId').value = activeCourse.id;
                document.getElementById('modalCourseTitle').value = activeCourse.name;
                // Mặc định form tạo mới này sẽ gọi submitCreateList
                document.getElementById('createListForm').onsubmit = submitCreateList;
            } else {
                document.getElementById('modalCourseId').value = '';
                document.getElementById('modalCourseTitle').value = '';
            }
        }

        function closeAddToListModal() {
            const modal = document.getElementById('addToListModal');
            if (modal) modal.classList.remove('show');
        }

        // ==================== AJAX TẠO MỚI DANH SÁCH (Tách riêng) ====================
        function submitCreateList(event) {
            event.preventDefault();
            const title = document.getElementById('listTitleInput').value.trim();
            const description = document.getElementById('listDescInput').value.trim();
            const courseId = document.getElementById('modalCourseId').value;

            if (!title) {
                alert('Please enter a list name.');
                return;
            }

            const params = { action: 'create', title: title, description: description };
            if (courseId) {
                params.courseId = courseId;
            }

            sendAjaxRequest(params)
            .then(data => {
                if (data.status === 'success') {
                    closeAddToListModal();
                    reloadPreservingTab();
                } else {
                    alert('Create failed: ' + (data.message || 'Error occurred'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Connection error occurred!');
            });
        }

        // ==================== AJAX CẬP NHẬT DANH SÁCH (Tách riêng) ====================
        function submitUpdateList(event) {
            event.preventDefault();
            const listId = document.getElementById('modalEditListId').value;
            const title = document.getElementById('listTitleInput').value.trim();
            const description = document.getElementById('listDescInput').value.trim();

            if (!listId || !title) {
                alert('Missing list ID or title.');
                return;
            }

            sendAjaxRequest({ 
                action: 'update', 
                listId: listId, 
                title: title, 
                description: description 
            })
            .then(data => {
                if (data.status === 'success') {
                    closeAddToListModal();
                    reloadPreservingTab();
                } else {
                    alert('Update failed: ' + (data.message || 'Error occurred'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Connection error occurred!');
            });
        }

        function addCourseToExistingList(listId) {
            if (!activeCourse) return;
            sendAjaxRequest({ action: 'addCourse', listId: listId, courseId: activeCourse.id })
                .then(data => {
                    if (data.status === 'success') {
                        closeAddToListModal();
                        reloadPreservingTab();
                    } else {
                        alert('Add course failed: ' + (data.message || 'Error occurred'));
                    }
                })
                .catch(() => alert('Connection error occurred!'));
        }

        function deleteList(listId) {
            if (!confirm('Are you sure you want to delete this list?')) return;
            sendAjaxRequest({ action: 'delete', listId: listId })
                .then(data => {
                    if (data.status === 'success') {
                        reloadPreservingTab();
                    } else {
                        alert('Delete list failed: ' + (data.message || 'Error occurred'));
                    }
                })
                .catch(() => alert('Connection error occurred!'));
        }

        function removeCourseFromList(listId, courseId) {
            if (!confirm('Are you sure you want to remove this course from the list?')) return;
            sendAjaxRequest({ action: 'removeCourse', listId: listId, courseId: courseId })
                .then(data => {
                    if (data.status === 'success') {
                        reloadPreservingTab();
                    } else {
                        alert('Remove course failed: ' + (data.message || 'Error occurred'));
                    }
                })
                .catch(() => alert('Connection error occurred!'));
        }

        function searchCourses() {
            const keyword = document.getElementById('courseSearchInput').value.toLowerCase();
            document.querySelectorAll('#courseGrid .course-card').forEach(function (card) {
                const title = card.getAttribute('data-title').toLowerCase();
                card.style.display = title.includes(keyword) ? 'block' : 'none';
            });
        }

        function filterCourses() {
            searchCourses();
        }

        function saveReminderSettings(event) {
            event.preventDefault();
            alert('Learning reminder settings saved successfully!');
        }

        function syncCalendar(provider) {
            alert('Syncing with ' + provider.toUpperCase() + ' Calendar...');
        }
    </script>
</body>

</html>