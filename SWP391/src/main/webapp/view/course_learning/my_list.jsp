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
            <h1>My List</h1>
        </div>
    </div>

    <main class="py-4">
        <div class="container py-2">
            <div id="listsGridContainer">
                <!-- Dynamic rendering via Javascript -->
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

    <!-- ==================== MODAL 2: ADD COURSE TO LIST ==================== -->
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

    <!-- ==================== MODAL 3: CONFIRM DELETE ==================== -->
    <div class="custom-modal-backdrop" id="confirmModal">
        <div class="custom-modal-content">
            <div class="custom-modal-header">
                <h5 class="fw-bold mb-0">Confirm</h5>
                <button type="button" class="btn-close" onclick="hideConfirmDialog()"></button>
            </div>
            <div class="custom-modal-body">
                <p id="confirmModalMessage" class="mb-0"></p>
            </div>
            <div class="custom-modal-footer">
                <button type="button" class="btn btn-secondary" onclick="hideConfirmDialog()">Cancel</button>
                <button type="button" class="btn btn-danger fw-bold" onclick="confirmDeleteAction()">Delete</button>
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

    <!-- Script xử lý logic JavaScript -->
    <script>
        const API_URL = '${pageContext.request.contextPath}/user-learning-list';
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
            window.location.reload();
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

        // ==================== AJAX TẠO MỚI DANH SÁCH ====================
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

        // ==================== AJAX CẬP NHẬT DANH SÁCH ====================
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

        let confirmDeleteCallback = null;

        function showConfirmDialog(message, onConfirm) {
            confirmDeleteCallback = onConfirm;
            document.getElementById('confirmModalMessage').textContent = message;
            document.getElementById('confirmModal').classList.add('show');
        }

        function hideConfirmDialog() {
            confirmDeleteCallback = null;
            document.getElementById('confirmModal').classList.remove('show');
        }

        function confirmDeleteAction() {
            const callback = confirmDeleteCallback;
            hideConfirmDialog();
            if (typeof callback === 'function') callback();
        }

        function deleteList(listId) {
            showConfirmDialog('Are you sure you want to delete this list?', function () {
                sendAjaxRequest({ action: 'delete', listId: listId })
                    .then(data => {
                        if (data.status === 'success') {
                            reloadPreservingTab();
                        } else {
                            alert('Delete list failed: ' + (data.message || 'Error occurred'));
                        }
                    })
                    .catch(() => alert('Connection error occurred!'));
            });
        }

        function removeCourseFromList(listId, courseId) {
            showConfirmDialog('Are you sure you want to remove this course from the list?', function () {
                sendAjaxRequest({ action: 'removeCourse', listId: listId, courseId: courseId })
                    .then(data => {
                        if (data.status === 'success') {
                            reloadPreservingTab();
                        } else {
                            alert('Remove course failed: ' + (data.message || 'Error occurred'));
                        }
                    })
                    .catch(() => alert('Connection error occurred!'));
            });
        }
    </script>
</body>

</html>
