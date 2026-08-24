<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${not empty course ? 'Edit Course' : 'Create New Course'} - Teacher Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_crud/lesson.css">
    <style>
        .tab-pane { display: none; }
        .tab-pane.show { display: block; }
        #info-content { display: block; }
        .is-invalid { border-color: #dc3545 !important; }
        .invalid-feedback { color: #dc3545; font-size: 0.85rem; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container my-5">
        <div class="card shadow-sm">
            <div class="card-body p-5">
                <h2 class="section-header">${not empty course ? 'Edit Course' : 'Create a New Course'}</h2>
                
                <!-- Server-side alert messages -->
                <c:if test="${not empty sessionScope.message}">
                    <div class="alert alert-${sessionScope.messageType == 'error' ? 'danger' : 'success'} alert-dismissible fade show mb-4 shadow-sm" role="alert">
                        <i class="fas fa-${sessionScope.messageType == 'error' ? 'exclamation-circle' : 'check-circle'} me-2"></i>
                        <c:out value="${sessionScope.message}" />
                        <button type="button" class="btn-close" onclick="this.closest('.alert').remove();" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="message" scope="session" />
                    <c:remove var="messageType" scope="session" />
                </c:if>

                <!-- Client-side validation summary banner -->
                <div id="validationSummary" class="alert alert-danger shadow-sm mb-4" style="display:none;">
                    <div class="d-flex align-items-center mb-2">
                        <i class="fas fa-exclamation-triangle fs-5 me-2"></i>
                        <strong class="fs-6">Vui lòng kiểm tra và sửa các thông tin sau:</strong>
                    </div>
                    <ul id="validationErrorsList" class="mb-0 ps-3"></ul>
                </div>

                <form id="courseForm" action="${pageContext.request.contextPath}/lesson" method="post" enctype="multipart/form-data" onsubmit="return validateCourseForm(event)">
                    <input type="hidden" name="courseId" id="courseIdInput" value="${course != null ? course.id : ''}">
                    
                    <ul class="nav nav-tabs mb-4" id="courseTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active fw-bold" id="info-tab" onclick="switchTab('info-content', this)" type="button"><i class="fas fa-info-circle me-1"></i> 1. Course Information</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-bold" id="curriculum-tab" onclick="switchTab('curriculum-content', this)" type="button"><i class="fas fa-list me-1"></i> 2. Curriculum</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-bold text-primary" id="qbank-tab" onclick="switchTab('qbank-content', this)" type="button"><i class="fas fa-database me-1"></i> 3. Question Bank</button>
                        </li>
                    </ul>

                    <div class="tab-content" id="courseTabsContent">
                        <!-- Tab 1: Course Information -->
                        <div class="tab-pane fade show active" id="info-content" role="tabpanel">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Course Title <span class="text-danger">*</span></label>
                                <input type="text" name="courseName" id="courseName" class="form-control" value="${course != null ? fn:escapeXml(course.name) : ''}" placeholder="Nhập tên khóa học">
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label fw-bold">Course Category <span class="text-danger">*</span></label>
                                <select name="categoryId" id="categoryId" class="form-select">
                                    <option value="">-- Chọn danh mục khóa học --</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.id}" ${course != null && course.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Overview / Description <span class="text-danger">*</span></label>
                                <textarea name="courseDescription" id="courseDescription" rows="5" class="form-control" placeholder="Nhập mô tả tổng quan về khóa học">${course != null ? fn:escapeXml(course.description) : ''}</textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Price (VND) <span class="text-danger">*</span></label>
                                <input type="number" name="coursePrice" id="coursePrice" step="0.01" min="0" class="form-control" value="${course != null ? course.price : '0.00'}">
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Thumbnail Image (Upload JPG, PNG) <c:if test="${empty course}"><span class="text-danger">*</span></c:if></label>
                                <c:if test="${course != null && not empty course.thumbnail}">
                                    <div class="mb-2">
                                        <img src="${course.thumbnail}" alt="Current Thumbnail" class="thumbnail-preview" id="currentThumbImg">
                                    </div>
                                    <small class="text-muted d-block mb-1">Tải lên tệp mới nếu muốn thay đổi ảnh đại diện hiện tại.</small>
                                </c:if>
                                <input type="file" name="courseThumbnail" id="courseThumbnail" accept=".jpg,.jpeg,.png,image/jpeg,image/png" class="form-control">
                            </div>
                        </div> <!-- End info-content -->

                        <!-- Tab 2: Curriculum -->
                        <div class="tab-pane fade" id="curriculum-content" role="tabpanel">
                            <div id="sections-container">
                                <c:if test="${not empty sections}">
                                    <c:forEach var="section" items="${sections}" varStatus="sStat">
                                        <div class="card mb-4 bg-light shadow-sm section-card" id="section_${sStat.index}">
                                            <div class="card-body">
                                                <input type="hidden" name="sectionId_${sStat.index}" value="${section.id}">
                                                <div class="mb-3">
                                                    <label class="form-label fw-bold">Section Title <span class="text-danger">*</span></label>
                                                    <input type="text" name="sectionTitle_${sStat.index}" class="form-control section-title-input" value="${fn:escapeXml(section.title)}" placeholder="e.g. Chapter 1: Introduction">
                                                </div>
                                                <div id="lessons-container_${sStat.index}" class="ps-4 border-start border-3 border-warning mt-4 lessons-container">
                                                    <c:forEach var="lesson" items="${lessonsMap[section.id]}" varStatus="lStat">
                                                        <div class="card mb-4 border-secondary lesson-card" id="lesson_${sStat.index}_${lStat.index}">
                                                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                                                <h5 class="mb-0 text-primary"><i class="fas fa-book-open me-2"></i>Lesson</h5>
                                                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="document.getElementById('lesson_${sStat.index}_${lStat.index}').remove()"><i class="fas fa-times"></i></button>
                                                            </div>
                                                            <div class="card-body">
                                                                <input type="hidden" name="lessonId_${sStat.index}_${lStat.index}" value="${lesson.id}">
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-bold">Lesson Title <span class="text-danger">*</span></label>
                                                                    <input type="text" name="lessonTitle_${sStat.index}_${lStat.index}" class="form-control lesson-title-input" value="${fn:escapeXml(lesson.title)}" placeholder="Nhập tên bài học">
                                                                </div>
                                                                <div class="mb-3">
                                                                    <label class="form-label fw-bold">Lesson Type</label>
                                                                    <select name="lessonType_${sStat.index}_${lStat.index}" class="form-select lesson-type-select" onchange="changeLessonType(${sStat.index}, ${lStat.index}, this.value)">
                                                                        <option value="script" ${lesson.type == 'script' || lesson.type == 'text' || lesson.type == 'text_image' ? 'selected' : ''}>Script + Image (Blocks)</option>
                                                                        <option value="video" ${lesson.type == 'video' || lesson.type == 'video_image' ? 'selected' : ''}>Video Only</option>
                                                                        <option value="quiz" ${lesson.type == 'quiz' ? 'selected' : ''}>Quiz</option>
                                                                    </select>
                                                                </div>
                                                                <div id="lesson_fields_${sStat.index}_${lStat.index}">
                                                                    <!-- Managed by JS based on selection -->
                                                                </div>
                                                                <textarea id="rawHtml_${sStat.index}_${lStat.index}" class="raw-html-field" style="display:none;">${fn:escapeXml(lesson.textContent)}</textarea>
                                                                <input type="hidden" id="rawVideoUrl_${sStat.index}_${lStat.index}" value="${fn:escapeXml(lesson.videoUrl)}">
                                                                <c:if test="${lesson.quizConfig != null}">
                                                                    <input type="hidden" id="rawQuizNum_${sStat.index}_${lStat.index}" value="${lesson.quizConfig.numberOfQuestions}">
                                                                    <input type="hidden" id="rawQuizTime_${sStat.index}_${lStat.index}" value="${lesson.quizConfig.timeLimitMinutes}">
                                                                    <input type="hidden" id="rawQuizRetake_${sStat.index}_${lStat.index}" value="${lesson.quizConfig.maxRetakes}">
                                                                    <input type="hidden" id="rawQuizPass_${sStat.index}_${lStat.index}" value="${lesson.quizConfig.passingScore}">
                                                                    <input type="hidden" id="rawQuizGroup_${sStat.index}_${lStat.index}" value="${lesson.quizConfig.questionGroupId}">
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                                <div class="mt-4">
                                                    <button type="button" class="btn btn-success btn-sm me-2 fw-bold px-3 py-2" onclick="addLesson(${sStat.index})"><i class="fas fa-plus"></i> Add Lesson</button>
                                                    <button type="button" class="btn btn-outline-danger btn-sm fw-bold px-3 py-2" onclick="document.getElementById('section_${sStat.index}').remove()"><i class="fas fa-trash"></i> Remove Section</button>
                                                </div>
                                                <input type="hidden" name="lessonCount_${sStat.index}" id="lessonCount_${sStat.index}" value="${fn:length(lessonsMap[section.id])}">
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:if>
                            </div>
                            
                            <button type="button" class="btn btn-warning mb-4 px-4 py-2" onclick="addSection()">+ Add Curriculum Section</button>

                            <hr class="my-5">
                            <input type="hidden" name="sectionCount" id="sectionCount" value="${not empty sections ? fn:length(sections) : 0}">
                        </div> <!-- End curriculum-content -->

                        <!-- Tab 3: Question Bank -->
                        <div class="tab-pane fade" id="qbank-content" role="tabpanel">
                            <c:choose>
                                <c:when test="${not empty course}">
                                    <div class="card bg-light border-0 mt-4">
                                        <div class="card-body text-center p-5">
                                            <h4><i class="fas fa-database text-primary mb-3" style="font-size: 3rem;"></i></h4>
                                            <h3>Course Question Bank</h3>
                                            <p class="text-muted">Quản lý toàn bộ câu hỏi và bộ đề (Question Groups) dành riêng cho khóa học <strong>"${fn:escapeXml(course.name)}"</strong>.</p>
                                            <div class="d-flex justify-content-center gap-3 mt-4">
                                                <a href="${pageContext.request.contextPath}/question-bank?courseId=${course.id}" class="btn btn-primary btn-lg">
                                                    <i class="fas fa-external-link-alt me-2"></i> Mở Question Bank Của Khóa Học Này
                                                </a>
                                                <a href="${pageContext.request.contextPath}/dashboard-quiz" class="btn btn-outline-secondary btn-lg">
                                                    <i class="fas fa-layer-group me-2"></i> Quản Lý Tất Cả Question Bank
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="card bg-light border-0 mt-4">
                                        <div class="card-body text-center p-5">
                                            <h4><i class="fas fa-database text-warning mb-3" style="font-size: 3rem;"></i></h4>
                                            <h3>Ngân Hàng Câu Hỏi (Question Bank)</h3>
                                            <p class="text-muted">Bạn đang tạo một khóa học mới. Hãy lưu nháp khóa học để hệ thống cấp mã định danh và bắt đầu tạo câu hỏi.</p>
                                            <div class="d-flex justify-content-center gap-3 mt-4">
                                                <button type="submit" name="submitAction" value="goto_qbank" class="btn btn-primary btn-lg" formnovalidate>
                                                    <i class="fas fa-save me-2"></i> Lưu Nháp & Mở Question Bank
                                                </button>
                                                <a href="${pageContext.request.contextPath}/dashboard-quiz" class="btn btn-outline-secondary btn-lg">
                                                    <i class="fas fa-layer-group me-2"></i> Xem Tất Cả Question Bank
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div> <!-- End courseTabsContent -->
                    
                    <hr class="my-5">
                    <div class="d-flex gap-3 mb-4">
                        <button type="submit" name="submitAction" value="continue" class="btn btn-outline-primary btn-lg w-50 py-3 fw-bold">
                            <i class="fas fa-save me-2"></i> Save Draft & Continue
                        </button>
                        <button type="submit" name="submitAction" value="exit" class="btn btn-primary btn-lg w-50 py-3 fw-bold">
                            <i class="fas fa-check me-2"></i> ${not empty course ? 'Save Changes & Exit' : 'Publish Course & Exit'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function switchTab(tabId, clickedBtn) {
            document.querySelectorAll('.tab-pane').forEach(pane => {
                pane.style.display = 'none';
                pane.classList.remove('show', 'active');
            });
            document.querySelectorAll('.nav-link').forEach(btn => btn.classList.remove('active'));

            const target = document.getElementById(tabId);
            if (target) {
                target.style.display = 'block';
                target.classList.add('show', 'active');
            }
            if (clickedBtn) clickedBtn.classList.add('active');
        }

        // Danh sách tên khóa học của giáo viên (ngoại trừ khóa học hiện tại)
        const existingCourseNames = [
            <c:forEach var="tc" items="${teacherCourses}" varStatus="loop">
                <c:if test="${empty course || tc.id != course.id}">
                    "${fn:escapeXml(tc.name)}"<c:if test="${!loop.last}">,</c:if>
                </c:if>
            </c:forEach>
        ];

        const questionGroupList = [
            <c:forEach var="g" items="${questionGroups}" varStatus="loop">
                { id: "${g.id}", name: "${fn:escapeXml(g.name)}", count: ${g.questionCount} }${!loop.last ? ',' : ''}
            </c:forEach>
        ];

        let sectionIndex = ${not empty sections ? fn:length(sections) : 0};
        let lessonIndexes = {};
        let blockIndexes = {};

        function escapeHtml(unsafe) {
            return (unsafe||'').replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }

        <c:if test="${not empty sections}">
            <c:forEach var="section" items="${sections}" varStatus="sStat">
                lessonIndexes[${sStat.index}] = ${fn:length(lessonsMap[section.id])};
                <c:forEach var="lesson" items="${lessonsMap[section.id]}" varStatus="lStat">
                    blockIndexes['${sStat.index}_${lStat.index}'] = 0;
                </c:forEach>
            </c:forEach>
        </c:if>

        function addSection() {
            const container = document.getElementById('sections-container');
            const secId = sectionIndex++;
            lessonIndexes[secId] = 0;
            document.getElementById('sectionCount').value = sectionIndex;

            const html = `
                <div class="card mb-4 bg-light shadow-sm section-card" id="section_\${secId}">
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Section Title <span class="text-danger">*</span></label>
                            <input type="text" name="sectionTitle_\${secId}" class="form-control section-title-input" placeholder="e.g. Chapter 1: Introduction">
                        </div>
                        <div id="lessons-container_\${secId}" class="ps-4 border-start border-3 border-warning mt-4 lessons-container"></div>
                        <div class="mt-4">
                            <button type="button" class="btn btn-success btn-sm me-2 fw-bold px-3 py-2" onclick="addLesson(\${secId})"><i class="fas fa-plus"></i> Add Lesson</button>
                            <button type="button" class="btn btn-outline-danger btn-sm fw-bold px-3 py-2" onclick="document.getElementById('section_\${secId}').remove()"><i class="fas fa-trash"></i> Remove Section</button>
                        </div>
                        <input type="hidden" name="lessonCount_\${secId}" id="lessonCount_\${secId}" value="0">
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
        }

        function addLesson(secId) {
            const container = document.getElementById('lessons-container_' + secId);
            const lesId = lessonIndexes[secId]++;
            document.getElementById('lessonCount_' + secId).value = lessonIndexes[secId];
            
            const lessonKey = secId + '_' + lesId;
            blockIndexes[lessonKey] = 0;

            const html = `
                <div class="card mb-4 border-secondary lesson-card" id="lesson_\${lessonKey}">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0 text-primary"><i class="fas fa-book-open me-2"></i>Lesson</h5>
                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="document.getElementById('lesson_\${lessonKey}').remove()"><i class="fas fa-times"></i></button>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Lesson Title <span class="text-danger">*</span></label>
                            <input type="text" name="lessonTitle_\${lessonKey}" class="form-control lesson-title-input" placeholder="Nhập tên bài học">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Lesson Type</label>
                            <select name="lessonType_\${lessonKey}" class="form-select lesson-type-select" onchange="changeLessonType(\${secId}, \${lesId}, this.value)">
                                <option value="script" selected>Script + Image (Blocks)</option>
                                <option value="video">Video Only</option>
                                <option value="quiz">Quiz</option>
                            </select>
                        </div>
                        <div id="lesson_fields_\${lessonKey}">
                        </div>
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
            changeLessonType(secId, lesId, 'script');
        }

        function changeLessonType(secId, lesId, type, rawHtml = '', rawVideo = '', quizData = null) {
            const lessonKey = secId + '_' + lesId;
            const container = document.getElementById('lesson_fields_' + lessonKey);
            let html = '';
            
            if (type === 'script' || type === 'text' || type === 'text_image') {
                html = `
                    <div class="mb-2 fw-bold text-secondary">Lesson Contents (Build your article below) <span class="text-danger">*</span></div>
                    <div id="blocks-container_\${lessonKey}" class="mb-3"></div>
                    <div class="d-flex align-items-center bg-light p-2 rounded border">
                        <span class="me-3 fw-bold text-muted small">ADD BLOCK:</span>
                        <button type="button" class="btn btn-sm btn-outline-primary me-2" onclick="addBlock(\${secId}, \${lesId}, 'text')"><i class="fas fa-font"></i> Text/Script</button>
                        <button type="button" class="btn btn-sm btn-outline-success" onclick="addBlock(\${secId}, \${lesId}, 'file')"><i class="fas fa-image"></i> Image</button>
                    </div>
                    <input type="hidden" name="blockCount_\${lessonKey}" id="blockCount_\${lessonKey}" value="0">
                `;
                container.innerHTML = html;
                
                blockIndexes[lessonKey] = 0;
                if (rawHtml) {
                    parseBlocks(secId, lesId, rawHtml);
                } else if (blockIndexes[lessonKey] === 0) {
                    addBlock(secId, lesId, 'text');
                }
            } else if (type === 'video' || type === 'video_image') {
                let fullUrl = rawVideo || '';
                if (fullUrl && !fullUrl.startsWith('http')) {
                    fullUrl = 'https://www.youtube.com/watch?v=' + fullUrl;
                }
                html = `
                    <div class="mb-3">
                        <label class="form-label text-danger fw-bold"><i class="fab fa-youtube"></i> YouTube URL <span class="text-danger">*</span></label>
                        <input type="url" name="lessonVideo_\${lessonKey}" class="form-control lesson-video-input" value="\${fullUrl}" placeholder="https://youtube.com/...">
                    </div>
                `;
                container.innerHTML = html;
            } else if (type === 'quiz') {
                const selectedQuizId = quizData ? quizData.group : '';
                
                let optionsHtml = '<option value="">-- Chọn Bộ Đề (Question Group) --</option>';
                questionGroupList.forEach(g => {
                    const selected = (g.id == selectedQuizId) ? 'selected' : '';
                    optionsHtml += '<option value="' + g.id + '" ' + selected + ' data-count="' + g.count + '">' + escapeHtml(g.name) + ' (Có ' + g.count + ' câu)</option>';
                });

                html = '<div class="card border-primary mb-3">' +
                       ' <div class="card-body bg-light">' +
                       '  <div class="d-flex justify-content-between align-items-center mb-3">' +
                       '   <h5 class="text-primary mb-0"><i class="fas fa-tasks me-2"></i> Cấu Hình Bài Quiz</h5>' +
                       '   <button type="submit" name="submitAction" value="goto_qbank" class="btn btn-outline-success btn-sm" formnovalidate>' +
                       '    <i class="fas fa-plus me-1"></i> Tạo bộ đề mới (Save Draft)' +
                       '   </button>' +
                       '  </div>' +
                       '  <div class="row g-3">' +
                       '   <div class="col-md-12">' +
                       '    <label class="form-label fw-bold">Chọn Question Group <span class="text-danger">*</span></label>' +
                       '    <select name="lessonQuizGroup_' + lessonKey + '" class="form-select border-primary quiz-group-select" onchange="updateMaxQuestions(this, \'' + lessonKey + '\')">' +
                       optionsHtml +
                       '    </select>' +
                       '   </div>' +
                       '   <div class="col-md-6">' +
                       '    <label class="form-label fw-bold">Số câu hỏi xuất ra <span class="text-danger">*</span></label>' +
                       '    <input type="number" name="lessonQuizNum_' + lessonKey + '" id="quizNum_' + lessonKey + '" class="form-control quiz-num-input" value="' + (quizData ? quizData.num : '10') + '" min="1">' +
                       '    <small class="text-muted" id="quizNumHelp_' + lessonKey + '">Lấy ngẫu nhiên từ bộ đề</small>' +
                       '   </div>' +
                       '   <div class="col-md-6">' +
                       '    <label class="form-label fw-bold">Thời gian làm bài (Phút) <span class="text-danger">*</span></label>' +
                       '    <input type="number" name="lessonQuizTime_' + lessonKey + '" class="form-control quiz-time-input" value="' + (quizData ? quizData.time : '15') + '" min="1">' +
                       '   </div>' +
                       '   <div class="col-md-6">' +
                       '    <label class="form-label fw-bold">Số lần làm lại tối đa <span class="text-danger">*</span></label>' +
                       '    <input type="number" name="lessonQuizRetake_' + lessonKey + '" class="form-control quiz-retake-input" value="' + (quizData ? quizData.retake : '3') + '" min="0">' +
                       '   </div>' +
                       '   <div class="col-md-6">' +
                       '    <label class="form-label fw-bold">Điểm Pass (%) <span class="text-danger">*</span></label>' +
                       '    <input type="number" name="lessonQuizPass_' + lessonKey + '" class="form-control quiz-pass-input" value="' + (quizData ? quizData.pass : '80') + '" min="1" max="100">' +
                       '   </div>' +
                       '  </div>' +
                       ' </div>' +
                       '</div>';
                
                container.innerHTML = html;
                
                setTimeout(() => {
                    const selectEl = document.querySelector('select[name="lessonQuizGroup_' + lessonKey + '"]');
                    if (selectEl && selectEl.value) {
                        updateMaxQuestions(selectEl, lessonKey);
                    }
                }, 100);
            }
        }

        function updateMaxQuestions(selectEl, lessonKey) {
            const selectedOption = selectEl.options[selectEl.selectedIndex];
            const maxCount = selectedOption.getAttribute('data-count');
            const numInput = document.getElementById('quizNum_' + lessonKey);
            const helpText = document.getElementById('quizNumHelp_' + lessonKey);
            if (maxCount) {
                numInput.max = maxCount;
                helpText.innerHTML = 'Tối đa: <strong class="text-danger">' + maxCount + '</strong> câu có trong bộ đề';
                if (parseInt(numInput.value) > parseInt(maxCount)) {
                    numInput.value = maxCount;
                }
            } else {
                numInput.removeAttribute('max');
                helpText.innerHTML = 'Lấy ngẫu nhiên từ bộ đề';
            }
        }

        function addBlock(secId, lesId, type, initialValue = '') {
            const lessonKey = secId + '_' + lesId;
            const container = document.getElementById('blocks-container_' + lessonKey);
            const blockId = blockIndexes[lessonKey]++;
            document.getElementById('blockCount_' + lessonKey).value = blockIndexes[lessonKey];

            let blockContent = '';
            if (type === 'text') {
                blockContent = `<textarea name="blockText_\${lessonKey}_\${blockId}" rows="4" class="form-control block-text-input" placeholder="Write your lesson content here...">\${initialValue}</textarea>`;
            } else if (type === 'file') {
                let existingInput = initialValue ? `<div class="mb-2"><img src="\${initialValue}" class="thumbnail-preview"><input type="hidden" name="existingFile_\${lessonKey}_\${blockId}" value="\${initialValue}" class="existing-file-input"></div>` : '';
                blockContent = `\${existingInput}<input type="file" name="blockFile_\${lessonKey}_\${blockId}" class="form-control block-file-input" accept=".jpg,.jpeg,.png,image/jpeg,image/png">`;
            }

            const html = `
                <div class="card mb-3 border-0 shadow-sm block-card" id="block_\${lessonKey}_\${blockId}">
                    <div class="card-body p-3 position-relative bg-white">
                        <button type="button" class="btn-close position-absolute top-0 end-0 m-2 block-close" onclick="document.getElementById('block_\${lessonKey}_\${blockId}').remove()"></button>
                        <input type="hidden" name="blockType_\${lessonKey}_\${blockId}" value="\${type}">
                        \${blockContent}
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
        }

        function parseBlocks(secId, lesId, rawHtml) {
            const parser = new DOMParser();
            const doc = parser.parseFromString(rawHtml, 'text/html');
            const elements = doc.body.children;
            
            for (let i = 0; i < elements.length; i++) {
                const el = elements[i];
                if (el.tagName.toLowerCase() === 'img') {
                    addBlock(secId, lesId, 'file', el.src);
                } else if (el.classList.contains('lesson-img-block')) {
                    const img = el.querySelector('img');
                    if (img) addBlock(secId, lesId, 'file', img.src);
                } else if (el.innerHTML.trim() !== '') {
                    addBlock(secId, lesId, 'text', el.innerHTML.trim());
                }
            }
        }

        // ====================== FORM VALIDATION ENGINE ======================
        function isImageFile(fileName) {
            if (!fileName) return false;
            const ext = fileName.toLowerCase().split('.').pop();
            return ['jpg', 'jpeg', 'png'].includes(ext);
        }

        function markInvalid(element, message) {
            if (!element) return;
            element.classList.add('is-invalid');
            
            let parent = element.parentElement;
            let feedback = parent.querySelector('.invalid-feedback');
            if (!feedback) {
                feedback = document.createElement('div');
                feedback.className = 'invalid-feedback d-block fw-semibold mt-1';
                parent.appendChild(feedback);
            }
            feedback.innerHTML = '<i class="fas fa-exclamation-circle me-1"></i>' + message;

            const clearHandler = function() {
                element.classList.remove('is-invalid');
                if (feedback) feedback.remove();
                element.removeEventListener('input', clearHandler);
                element.removeEventListener('change', clearHandler);
            };
            element.addEventListener('input', clearHandler);
            element.addEventListener('change', clearHandler);
        }

        function clearAllValidationErrors() {
            document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
            document.querySelectorAll('.invalid-feedback').forEach(el => el.remove());
            const summary = document.getElementById('validationSummary');
            if (summary) summary.style.display = 'none';
            const list = document.getElementById('validationErrorsList');
            if (list) list.innerHTML = '';
        }

        function validateCourseForm(event) {
            const submitter = event.submitter;
            const isDraft = (submitter && (submitter.value === 'continue' || submitter.value === 'goto_qbank' || submitter.getAttribute('formnovalidate') !== null));

            if (isDraft) {
                // For draft save, only require basic Course Title if empty, or allow saving
                clearAllValidationErrors();
                const nameInput = document.getElementById('courseName');
                const nameVal = nameInput ? nameInput.value.trim() : '';
                if (nameInput) nameInput.value = nameVal;

                if (!nameVal) {
                    markInvalid(nameInput, 'Vui lòng nhập Tên khóa học để lưu bản nháp (Draft)!');
                    const summary = document.getElementById('validationSummary');
                    if (summary) summary.style.display = 'block';
                    const list = document.getElementById('validationErrorsList');
                    if (list) list.innerHTML = '<li>Vui lòng nhập tên khóa học để lưu bản nháp.</li>';
                    if (event) event.preventDefault();
                    return false;
                }
                return true; // Bypass all other checks for draft
            }

            clearAllValidationErrors();
            const errors = [];

            // 1. Validate Course Title
            const nameInput = document.getElementById('courseName');
            const nameVal = nameInput ? nameInput.value.trim() : '';
            if (nameInput) nameInput.value = nameVal;

            if (!nameVal) {
                markInvalid(nameInput, 'Vui lòng nhập tên khóa học!');
                errors.push('Tên khóa học không được để trống.');
            } else {
                const isDuplicateCourse = existingCourseNames.some(n => n.trim().toLowerCase() === nameVal.toLowerCase());
                if (isDuplicateCourse) {
                    markInvalid(nameInput, 'Tên khóa học "' + nameVal + '" đã tồn tại trong danh sách của bạn! Vui lòng đặt tên khác.');
                    errors.push('Tên khóa học "' + nameVal + '" bị trùng lặp.');
                }
            }

            // 2. Validate Category
            const catSelect = document.getElementById('categoryId');
            if (!catSelect || !catSelect.value) {
                markInvalid(catSelect, 'Vui lòng chọn danh mục khóa học!');
                errors.push('Danh mục khóa học chưa được chọn.');
            }

            // 3. Validate Overview / Description
            const descInput = document.getElementById('courseDescription');
            const descVal = descInput ? descInput.value.trim() : '';
            if (descInput) descInput.value = descVal;
            if (!descVal) {
                markInvalid(descInput, 'Vui lòng nhập mô tả khóa học!');
                errors.push('Mô tả khóa học không được để trống.');
            }

            // 4. Validate Price
            const priceInput = document.getElementById('coursePrice');
            const priceVal = priceInput ? priceInput.value.trim() : '';
            if (priceVal === '' || isNaN(priceVal) || parseFloat(priceVal) < 0) {
                markInvalid(priceInput, 'Vui lòng nhập giá khóa học hợp lệ (>= 0)!');
                errors.push('Giá khóa học không hợp lệ (phải >= 0).');
            }

            // 5. Validate Thumbnail
            const thumbInput = document.getElementById('courseThumbnail');
            const currentThumb = document.getElementById('currentThumbImg');
            if (!currentThumb && (!thumbInput || !thumbInput.files || thumbInput.files.length === 0)) {
                markInvalid(thumbInput, 'Vui lòng tải lên ảnh Thumbnail cho khóa học!');
                errors.push('Ảnh Thumbnail của khóa học không được để trống.');
            } else if (thumbInput && thumbInput.files && thumbInput.files.length > 0) {
                const fileName = thumbInput.files[0].name;
                if (!isImageFile(fileName)) {
                    markInvalid(thumbInput, 'Ảnh Thumbnail chỉ chấp nhận định dạng JPG, JPEG hoặc PNG!');
                    errors.push('Ảnh Thumbnail có định dạng không hợp lệ (chỉ nhận JPG, PNG).');
                }
            }

            // 6. Validate Sections and Lessons
            const sectionCards = document.querySelectorAll('#sections-container .section-card');
            if (sectionCards.length === 0) {
                errors.push('Khóa học phải có ít nhất 1 Section (Chương học).');
            }

            const seenSectionTitles = {};
            sectionCards.forEach((secCard, sIdx) => {
                const secTitleInput = secCard.querySelector('.section-title-input');
                const secVal = secTitleInput ? secTitleInput.value.trim() : '';
                if (secTitleInput) secTitleInput.value = secVal;

                if (!secVal) {
                    markInvalid(secTitleInput, 'Vui lòng nhập tiêu đề cho Section!');
                    errors.push('Section #' + (sIdx + 1) + ': Tiêu đề không được để trống.');
                } else {
                    const secLower = secVal.toLowerCase();
                    if (seenSectionTitles[secLower]) {
                        markInvalid(secTitleInput, 'Tên Section "' + secVal + '" bị trùng lặp trong khóa học!');
                        errors.push('Tên Section "' + secVal + '" bị trùng lặp trong khóa học.');
                    }
                    seenSectionTitles[secLower] = true;
                }

                // Lessons in this section
                const lessonCards = secCard.querySelectorAll('.lesson-card');
                if (lessonCards.length === 0) {
                    errors.push('Section "' + (secVal || '#' + (sIdx + 1)) + '" phải có ít nhất 1 bài học.');
                }

                const seenLessonTitles = {};
                lessonCards.forEach((lesCard, lIdx) => {
                    const lesTitleInput = lesCard.querySelector('.lesson-title-input');
                    const lesVal = lesTitleInput ? lesTitleInput.value.trim() : '';
                    if (lesTitleInput) lesTitleInput.value = lesVal;

                    if (!lesVal) {
                        markInvalid(lesTitleInput, 'Vui lòng nhập tiêu đề bài học!');
                        errors.push('Bài học #' + (lIdx + 1) + ' trong Section "' + (secVal || '#' + (sIdx + 1)) + '": Tiêu đề không được để trống.');
                    } else {
                        const lesLower = lesVal.toLowerCase();
                        if (seenLessonTitles[lesLower]) {
                            markInvalid(lesTitleInput, 'Tên bài học "' + lesVal + '" bị trùng lặp trong Section này!');
                            errors.push('Tên bài học "' + lesVal + '" bị trùng lặp trong Section "' + (secVal || '#' + (sIdx + 1)) + '".');
                        }
                        seenLessonTitles[lesLower] = true;
                    }

                    // Validate Lesson Type & Contents
                    const typeSelect = lesCard.querySelector('.lesson-type-select');
                    const type = typeSelect ? typeSelect.value : 'script';

                    if (type === 'script' || type === 'text' || type === 'text_image') {
                        const blockCards = lesCard.querySelectorAll('.block-card');
                        if (blockCards.length === 0) {
                            markInvalid(typeSelect, 'Bài học cần ít nhất 1 khối nội dung (Văn bản hoặc Hình ảnh)!');
                            errors.push('Bài học "' + (lesVal || '#' + (lIdx + 1)) + '" phải có ít nhất 1 khối nội dung.');
                        } else {
                            blockCards.forEach((bCard, bIdx) => {
                                const bTextInput = bCard.querySelector('.block-text-input');
                                const bFileInput = bCard.querySelector('.block-file-input');
                                const existingFileInput = bCard.querySelector('.existing-file-input');

                                if (bTextInput) {
                                    const bTextVal = bTextInput.value.trim();
                                    bTextInput.value = bTextVal;
                                    if (!bTextVal) {
                                        markInvalid(bTextInput, 'Nội dung khối văn bản không được để trống!');
                                        errors.push('Khối văn bản #' + (bIdx + 1) + ' trong bài học "' + (lesVal || '#' + (lIdx + 1)) + '" không được để trống.');
                                    }
                                } else if (bFileInput) {
                                    const hasExisting = existingFileInput && existingFileInput.value.trim() !== '';
                                    const hasNewFile = bFileInput.files && bFileInput.files.length > 0;
                                    if (!hasExisting && !hasNewFile) {
                                        markInvalid(bFileInput, 'Vui lòng tải lên hình ảnh cho khối này!');
                                        errors.push('Khối hình ảnh #' + (bIdx + 1) + ' trong bài học "' + (lesVal || '#' + (lIdx + 1)) + '" chưa có ảnh.');
                                    } else if (hasNewFile) {
                                        const fName = bFileInput.files[0].name;
                                        if (!isImageFile(fName)) {
                                            markInvalid(bFileInput, 'Ảnh bài học chỉ chấp nhận định dạng JPG, JPEG hoặc PNG!');
                                            errors.push('Ảnh trong bài học "' + (lesVal || '#' + (lIdx + 1)) + '" phải có định dạng JPG hoặc PNG.');
                                        }
                                    }
                                }
                            });
                        }
                    } else if (type === 'video' || type === 'video_image') {
                        const videoInput = lesCard.querySelector('.lesson-video-input');
                        const videoVal = videoInput ? videoInput.value.trim() : '';
                        if (videoInput) videoInput.value = videoVal;
                        if (!videoVal) {
                            markInvalid(videoInput, 'Vui lòng nhập đường dẫn YouTube cho bài học!');
                            errors.push('Bài học "' + (lesVal || '#' + (lIdx + 1)) + '": Đường dẫn YouTube không được để trống.');
                        }
                    } else if (type === 'quiz') {
                        const qGroupSelect = lesCard.querySelector('.quiz-group-select');
                        const qNumInput = lesCard.querySelector('.quiz-num-input');
                        const qTimeInput = lesCard.querySelector('.quiz-time-input');
                        const qRetakeInput = lesCard.querySelector('.quiz-retake-input');
                        const qPassInput = lesCard.querySelector('.quiz-pass-input');

                        if (!qGroupSelect || !qGroupSelect.value) {
                            markInvalid(qGroupSelect, 'Vui lòng chọn Bộ Đề (Question Group) cho bài Quiz!');
                            errors.push('Bài Quiz "' + (lesVal || '#' + (lIdx + 1)) + '": Chưa chọn Bộ Đề.');
                        }

                        const qNumVal = qNumInput ? qNumInput.value.trim() : '';
                        if (qNumInput) qNumInput.value = qNumVal;
                        if (!qNumVal || isNaN(qNumVal) || parseInt(qNumVal) <= 0) {
                            markInvalid(qNumInput, 'Số câu hỏi xuất ra phải là số nguyên > 0!');
                            errors.push('Bài Quiz "' + (lesVal || '#' + (lIdx + 1)) + '": Số câu hỏi xuất ra không hợp lệ.');
                        }

                        const qTimeVal = qTimeInput ? qTimeInput.value.trim() : '';
                        if (qTimeInput) qTimeInput.value = qTimeVal;
                        if (!qTimeVal || isNaN(qTimeVal) || parseInt(qTimeVal) <= 0) {
                            markInvalid(qTimeInput, 'Thời gian làm bài phải là số phút > 0!');
                            errors.push('Bài Quiz "' + (lesVal || '#' + (lIdx + 1)) + '": Thời gian làm bài không hợp lệ.');
                        }

                        const qRetakeVal = qRetakeInput ? qRetakeInput.value.trim() : '';
                        if (qRetakeInput) qRetakeInput.value = qRetakeVal;
                        if (qRetakeVal === '' || isNaN(qRetakeVal) || parseInt(qRetakeVal) < 0) {
                            markInvalid(qRetakeInput, 'Số lần làm lại tối đa phải >= 0!');
                            errors.push('Bài Quiz "' + (lesVal || '#' + (lIdx + 1)) + '": Số lần làm lại không hợp lệ.');
                        }

                        const qPassVal = qPassInput ? qPassInput.value.trim() : '';
                        if (qPassInput) qPassInput.value = qPassVal;
                        if (qPassVal === '' || isNaN(qPassVal) || parseInt(qPassVal) < 1 || parseInt(qPassVal) > 100) {
                            markInvalid(qPassInput, 'Điểm Pass (%) phải từ 1 đến 100!');
                            errors.push('Bài Quiz "' + (lesVal || '#' + (lIdx + 1)) + '": Điểm Pass (%) phải từ 1 đến 100.');
                        }
                    }
                });
            });

            if (errors.length > 0) {
                // Hiển thị summary lỗi
                const summary = document.getElementById('validationSummary');
                const list = document.getElementById('validationErrorsList');
                if (summary && list) {
                    list.innerHTML = errors.map(err => '<li>' + escapeHtml(err) + '</li>').join('');
                    summary.style.display = 'block';
                }

                // Chuyển tab và focus vào ô lỗi đầu tiên
                const firstInvalid = document.querySelector('.is-invalid');
                if (firstInvalid) {
                    if (document.getElementById('info-content').contains(firstInvalid)) {
                        switchTab('info-content', document.getElementById('info-tab'));
                    } else if (document.getElementById('curriculum-content').contains(firstInvalid)) {
                        switchTab('curriculum-content', document.getElementById('curriculum-tab'));
                    }
                    firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    firstInvalid.focus();
                } else if (summary) {
                    summary.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }

                event.preventDefault();
                return false;
            }

            return true;
        }

        window.onload = function() {
            if (sectionIndex === 0) {
                addSection();
            } else {
                <c:forEach var="section" items="${sections}" varStatus="sStat">
                    <c:forEach var="lesson" items="${lessonsMap[section.id]}" varStatus="lStat">
                        var sel = document.querySelector('select[name="lessonType_${sStat.index}_${lStat.index}"]');
                        var type = sel ? sel.value : 'script';
                        var rawHtml = document.getElementById('rawHtml_${sStat.index}_${lStat.index}') ? document.getElementById('rawHtml_${sStat.index}_${lStat.index}').value : '';
                        var rawVideo = document.getElementById('rawVideoUrl_${sStat.index}_${lStat.index}') ? document.getElementById('rawVideoUrl_${sStat.index}_${lStat.index}').value : '';
                        var rawQuizNum = document.getElementById('rawQuizNum_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizNum_${sStat.index}_${lStat.index}').value : '10';
                        var rawQuizTime = document.getElementById('rawQuizTime_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizTime_${sStat.index}_${lStat.index}').value : '15';
                        var rawQuizRetake = document.getElementById('rawQuizRetake_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizRetake_${sStat.index}_${lStat.index}').value : '3';
                        var rawQuizPass = document.getElementById('rawQuizPass_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizPass_${sStat.index}_${lStat.index}').value : '80';
                        var rawQuizGroup = document.getElementById('rawQuizGroup_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizGroup_${sStat.index}_${lStat.index}').value : '';
                        changeLessonType(${sStat.index}, ${lStat.index}, type, rawHtml, rawVideo, {num: rawQuizNum, time: rawQuizTime, retake: rawQuizRetake, pass: rawQuizPass, group: rawQuizGroup});
                    </c:forEach>
                </c:forEach>
            }
        }
    </script>
</body>
</html>
