<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
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
</head>

<body>

    <!-- Common Header -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Navigation Header -->
    <div class="my-learning-header">
        <div class="container">
            <h1>All Courses</h1>
        </div>
    </div>

    <main class="py-4">
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
                                    <div class="course-progress">
                                        <div class="course-progress-bar"><span style="width:${item.progress}%"></span></div>
                                        <span class="course-progress-text">${item.progress}%</span>
                                    </div>
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
    </main>

    <!-- ==================== MODAL: ADD TO LIST / CREATE NEW LIST ==================== -->
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

            <!-- Create List Form -->
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
                    <button type="submit" class="btn-purple" id="btnSaveListSubmit">Create List</button>
                </div>
            </form>
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

    <!-- Script xử lý logic JavaScript -->
    <script>
        const API_URL = '${pageContext.request.contextPath}/user-learning-list';
        let activeCourse = null;

        let myListsData = [];
        try {
            const rawJsonData = document.getElementById('myListsJsonData').textContent;
            myListsData = JSON.parse(rawJsonData);
        } catch (e) {
            myListsData = [];
        }

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
            window.location.reload();
        }

        function openAddToListModal(courseId, courseTitle) {
            activeCourse = courseId ? { id: courseId, name: courseTitle } : null;
            document.getElementById('modalEditListId').value = '';
            const modal = document.getElementById('addToListModal');

            if (modal) {
                if (myListsData.length === 0) {
                    document.getElementById('modalTitleHeading').innerText = "Create New List";
                    document.getElementById('btnSaveListSubmit').innerText = "Create List";
                    document.getElementById('createListForm').onsubmit = submitCreateList;
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

            if (activeCourse) {
                document.getElementById('modalCourseId').value = activeCourse.id;
                document.getElementById('modalCourseTitle').value = activeCourse.name;
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
    </script>
</body>

</html>
