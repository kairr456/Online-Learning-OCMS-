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
            <h1>All Courses</h1>
        </div>
    </div>

    <main class="py-4">
        <div class="container">
            <div class="learning-controls">
                <div class="learning-filters">
                    <select class="filter-select" id="sortBy" onchange="filterCourses()">
                        <option value="title-asc" selected>Sort by: Title A to Z</option>
                        <option value="title-desc">Sort by: Title Z to A</option>
                    </select>

                    <select class="filter-select" id="filterProgress" onchange="filterCourses()">
                        <option value="all">Progress: All</option>
                        <option value="not-started">Not Started</option>
                        <option value="in-progress">In Progress</option>
                        <option value="completed">Completed</option>
                    </select>

                    <select class="filter-select" id="filterCategory" onchange="filterCourses()">
                        <option value="all">Categories: All</option>
                    </select>
                </div>

                <div class="learning-search">
<<<<<<< Updated upstream
                    <input type="text" id="courseSearchInput" placeholder="Search my courses..." 
                           oninput="filterCourses()" 
                           onblur="this.value=this.value.trim(); filterCourses();" 
                           onkeydown="if(event.key==='Enter'){ this.value=this.value.trim(); filterCourses(); }">
                    <button type="button" onclick="const i=document.getElementById('courseSearchInput'); if(i){i.value=i.value.trim();} filterCourses();"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
=======
                    <input type="text" id="courseSearchInput" placeholder="Search my courses..." onkeydown="if(event.key==='Enter'){ const i=document.getElementById('courseSearchInput'); if(i){ i.value=i.value.trim().replace(/\s+/g, ' '); } filterCourses(); }">
                    <button type="button" onclick="const i=document.getElementById('courseSearchInput'); if(i){ i.value=i.value.trim().replace(/\s+/g, ' '); } filterCourses();"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
>>>>>>> Stashed changes
                </div>
            </div>

            <!-- Course List / Empty State -->
            <c:choose>
                <c:when test="${not empty myCourses}">
                    <div class="course-grid" id="courseGrid">
                        <c:forEach var="item" items="${myCourses}">
                            <div class="course-card" data-title="${item.name}" data-progress="${item.progress}" data-category="${item.categoryName}">
                                <img src="${not empty item.thumbnail ? item.thumbnail : pageContext.request.contextPath.concat('/assets/img/courses/default-course.jpg')}" alt="${item.name}">
                                <div class="course-card-body">
                                    <h3 class="course-card-title">${item.name}</h3>
                                    <div class="course-progress">
                                        <div class="course-progress-bar"><span style="--progress-width:${item.progress}%"></span></div>
                                        <span class="course-progress-text">${item.progress}%</span>
                                    </div>
                                    <div class="btn-action-group">
                                        <a href="${pageContext.request.contextPath}/learning?courseId=${item.id}&from=all-courses" class="btn-purple">Start Course</a>
                                        <c:if test="${item.progress >= 100}">
                                            <c:set var="certCode" value="${certCodeMap[item.id]}" />
                                            <c:choose>
                                                <c:when test="${not empty certCode}">
                                                    <a href="${pageContext.request.contextPath}/certificate?code=${certCode}" class="btn btn-outline-secondary" title="View Certificate"><i class="fa-solid fa-award text-warning"></i></a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/my-certificates" class="btn btn-outline-secondary" title="View Certificate"><i class="fa-solid fa-award text-warning"></i></a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                        <button type="button" class="btn btn-outline-secondary" title="Archive" onclick="archiveCourse(${item.id}, '${item.name}')"><i class="fa-solid fa-box-archive"></i></button>
                                        <button type="button" class="btn btn-outline-secondary" onclick="openAddToListModal('${item.id}', '${item.name}')">+</button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="empty-state-box" id="noResults" style="display:none;">
                        <div class="empty-state-title">No courses found</div>
                        <div class="empty-state-desc">No courses match your search or filter. Try adjusting your criteria.</div>
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
            <div id="viewSelectList" class="custom-modal-body modal-body-hidden">
                <p class="text-muted small mb-3">Select a list to add this course to:</p>
                <div id="existingListsContainer" class="existing-lists-container"></div>
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

    <!-- ==================== MODAL: CONFIRM ARCHIVE ==================== -->
    <div class="custom-modal-backdrop" id="archiveConfirmModal">
        <div class="custom-modal-content">
            <div class="custom-modal-header">
                <h5 class="fw-bold mb-0">Archive Course</h5>
                <button type="button" class="btn-close" onclick="closeArchiveConfirmModal()"></button>
            </div>
            <div class="custom-modal-body">
                <p id="archiveConfirmMessage" class="mb-0"></p>
            </div>
            <div class="custom-modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeArchiveConfirmModal()">Cancel</button>
                <button type="button" class="btn btn-danger fw-bold" onclick="confirmArchiveAction()">Archive</button>
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

    <!-- Script xử lý logic JavaScript -->
<<<<<<< Updated upstream
    <script src="${pageContext.request.contextPath}/assets/js/course_learning/all-courses.js?v=1.2"></script>
=======
    <script src="${pageContext.request.contextPath}/assets/js/course_learning/all-courses.js?v=<%=System.currentTimeMillis()%>"></script>
>>>>>>> Stashed changes
</body>

</html>
