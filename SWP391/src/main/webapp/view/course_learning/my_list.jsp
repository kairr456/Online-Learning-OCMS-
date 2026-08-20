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

<body data-ctx="${pageContext.request.contextPath}">

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
            <div id="viewSelectList" class="custom-modal-body modal-body-hidden">
                <p class="text-muted small mb-3">Select a list to add this course to:</p>
                <div id="existingListsContainer" class="existing-lists-container"></div>
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
                <div id="availableCoursesContainer" class="available-courses-container">
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
    <script src="${pageContext.request.contextPath}/assets/js/course_learning/my-list.js"></script>
</body>

</html>
