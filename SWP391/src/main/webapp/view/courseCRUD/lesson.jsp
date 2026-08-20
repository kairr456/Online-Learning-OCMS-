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
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container my-5">
        <div class="card shadow-sm">
            <div class="card-body p-5">
                <h2 class="section-header">${not empty course ? 'Edit Course' : 'Create a New Course'}</h2>
                
                <form action="${pageContext.request.contextPath}/lesson" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="courseId" value="${course != null ? course.id : ''}">
                    
                    <ul class="nav nav-tabs mb-4" id="courseTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active fw-bold" id="info-tab" onclick="switchTab('info-content', this)" type="button"><i class="fas fa-info-circle me-1"></i> 1. Course Information</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-bold" id="curriculum-tab" onclick="switchTab('curriculum-content', this)" type="button" ${empty course ? 'style="opacity:0.5;cursor:not-allowed;" title="Save course info first"' : ''}><i class="fas fa-list me-1"></i> 2. Curriculum</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fw-bold text-primary" id="qbank-tab" onclick="switchTab('qbank-content', this)" type="button" ${empty course ? 'style="opacity:0.5;cursor:not-allowed;" title="Save course info first"' : ''}><i class="fas fa-database me-1"></i> 3. Question Bank</button>
                        </li>
                    </ul>
                    <style>
                        .tab-pane { display: none; }
                        .tab-pane.show { display: block; }
                        #info-content { display: block; }
                    </style>
                    <div class="tab-content" id="courseTabsContent">
                    <div class="tab-pane fade show active" id="info-content" role="tabpanel">
                    <div class="mb-3">
                        <label class="form-label">Course Title</label>
                        <input type="text" name="courseName" class="form-control" value="${course != null ? fn:escapeXml(course.name) : ''}" >
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Course Category</label>
                        <select name="categoryId" class="form-select" >
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}" ${course != null && course.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Overview / Description</label>
                        <textarea name="courseDescription" rows="5" class="form-control" >${course != null ? fn:escapeXml(course.description) : ''}</textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Price (VND)</label>
                        <input type="number" name="coursePrice" step="0.01" min="0" class="form-control" value="${course != null ? course.price : '0.00'}" >
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Thumbnail Image (Upload)</label>
                        <c:if test="${course != null && not empty course.thumbnail}">
                            <div class="mb-2">
                                <img src="${course.thumbnail}" alt="Current Thumbnail" class="thumbnail-preview">
                            </div>
                            <small class="text-muted">Upload a new file to change the current thumbnail.</small>
                        </c:if>
                        <input type="file" name="courseThumbnail" accept="image/*" class="form-control" ${empty course ? 'required' : ''}>
                    </div>

                    </div> <!-- End info-content -->
                    <div class="tab-pane fade" id="curriculum-content" role="tabpanel">
                    <div id="sections-container">
                        <c:if test="${not empty sections}">
                            <c:forEach var="section" items="${sections}" varStatus="sStat">
                                <div class="card mb-4 bg-light shadow-sm" id="section_${sStat.index}">
                                    <div class="card-body">
                                        <input type="hidden" name="sectionId_${sStat.index}" value="${section.id}">
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Section Title</label>
                                            <input type="text" name="sectionTitle_${sStat.index}" class="form-control" value="${fn:escapeXml(section.title)}">
                                        </div>
                                        <div id="lessons-container_${sStat.index}" class="ps-4 border-start border-3 border-warning mt-4">
                                            <c:forEach var="lesson" items="${lessonsMap[section.id]}" varStatus="lStat">
                                                <div class="card mb-4 border-secondary" id="lesson_${sStat.index}_${lStat.index}">
                                                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                                        <h5 class="mb-0 text-primary"><i class="fas fa-book-open me-2"></i>Lesson</h5>
                                                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="document.getElementById('lesson_${sStat.index}_${lStat.index}').remove()"><i class="fas fa-times"></i></button>
                                                    </div>
                                                    <div class="card-body">
                                                        <input type="hidden" name="lessonId_${sStat.index}_${lStat.index}" value="${lesson.id}">
                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold">Lesson Title</label>
                                                            <input type="text" name="lessonTitle_${sStat.index}_${lStat.index}" class="form-control" value="${fn:escapeXml(lesson.title)}" >
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold">Lesson Type</label>
                                                            <select name="lessonType_${sStat.index}_${lStat.index}" class="form-select" onchange="changeLessonType(${sStat.index}, ${lStat.index}, this.value)">
                                                                <option value="script" ${lesson.type == 'script' || lesson.type == 'text' || lesson.type == 'text_image' ? 'selected' : ''}>Script + Image (Blocks)</option>
                                                                <option value="video" ${lesson.type == 'video' || lesson.type == 'video_image' ? 'selected' : ''}>Video Only</option>
                                                                <option value="quiz" ${lesson.type == 'quiz' ? 'selected' : ''}>Quiz</option>
                                                            </select>
                                                        </div>
                                                        <div id="lesson_fields_${sStat.index}_${lStat.index}">
                                                            <!-- Managed by JS based on selection -->
                                                        </div>
                                                        <textarea id="rawHtml_${sStat.index}_${lStat.index}" class="raw-html-field">${fn:escapeXml(lesson.textContent)}</textarea>
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
                    <div class="tab-pane fade" id="qbank-content" role="tabpanel">
                        <c:if test="${not empty course}">
                            <div class="card bg-light border-0 mt-4">
                                <div class="card-body text-center p-5">
                                    <h4><i class="fas fa-database text-primary mb-3" style="font-size: 3rem;"></i></h4>
                                    <h3>Course Question Bank</h3>
                                    <p class="text-muted">Manage all questions and groups for this course.</p>
                                    <a href="${pageContext.request.contextPath}/question-bank?courseId=${course.id}" class="btn btn-primary btn-lg mt-3">
                                        <i class="fas fa-external-link-alt me-2"></i> Open Question Bank Manager
                                    </a>
                                </div>
                            </div>
                        </c:if>
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
                <div class="card mb-4 bg-light shadow-sm" id="section_\${secId}">
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Section Title</label>
                            <input type="text" name="sectionTitle_\${secId}" class="form-control" placeholder="e.g. Chapter 1: Introduction">
                        </div>
                        <div id="lessons-container_\${secId}" class="ps-4 border-start border-3 border-warning mt-4"></div>
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
                <div class="card mb-4 border-secondary" id="lesson_\${lessonKey}">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0 text-primary"><i class="fas fa-book-open me-2"></i>Lesson</h5>
                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="document.getElementById('lesson_\${lessonKey}').remove()"><i class="fas fa-times"></i></button>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Lesson Title</label>
                            <input type="text" name="lessonTitle_\${lessonKey}" class="form-control">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Lesson Type</label>
                            <select name="lessonType_\${lessonKey}" class="form-select" onchange="changeLessonType(\${secId}, \${lesId}, this.value)">
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
                    <div class="mb-2 fw-bold text-secondary">Lesson Contents (Build your article below)</div>
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
                        <label class="form-label text-danger"><i class="fab fa-youtube"></i> YouTube URL</label>
                        <input type="url" name="lessonVideo_\${lessonKey}" class="form-control" value="\${fullUrl}" placeholder="https://youtube.com/...">
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
                       '    <label class="form-label fw-bold">Chọn Question Group</label>' +
                       '    <select name="lessonQuizGroup_' + lessonKey + '" class="form-select border-primary" onchange="updateMaxQuestions(this, \'' + lessonKey + '\')">' +
                       optionsHtml +
                       '    </select>' +
                       '   </div>' +
                       '   <div class="col-md-6">' +
                       '    <label class="form-label">Số câu hỏi xuất ra</label>' +
                       '    <input type="number" name="lessonQuizNum_' + lessonKey + '" id="quizNum_' + lessonKey + '" class="form-control" value="' + (quizData ? quizData.num : '10') + '" min="1">' +
                       '    <small class="text-muted" id="quizNumHelp_' + lessonKey + '">Lấy ngẫu nhiên từ bộ đề</small>' +
                       '   </div>' +
                       '   <div class="col-md-6">' +
                       '    <label class="form-label">Thời gian làm bài (Phút)</label>' +
                       '    <input type="number" name="lessonQuizTime_' + lessonKey + '" class="form-control" value="' + (quizData ? quizData.time : '15') + '" min="1">' +
                       '   </div>' +
                       '   <div class="col-md-6">' +
                       '    <label class="form-label">Số lần làm lại tối đa</label>' +
                       '    <input type="number" name="lessonQuizRetake_' + lessonKey + '" class="form-control" value="' + (quizData ? quizData.retake : '3') + '" min="0">' +
                       '   </div>' +
                       '   <div class="col-md-6">' +
                       '    <label class="form-label">Điểm Pass (%)</label>' +
                       '    <input type="number" name="lessonQuizPass_' + lessonKey + '" class="form-control" value="' + (quizData ? quizData.pass : '80') + '" min="1" max="100">' +
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
                blockContent = `<textarea name="blockText_\${lessonKey}_\${blockId}" rows="4" class="form-control" placeholder="Write your lesson content here...">\${initialValue}</textarea>`;
            } else if (type === 'file') {
                let existingInput = initialValue ? `<div class="mb-2"><img src="\${initialValue}" class="thumbnail-preview"><input type="hidden" name="existingFile_\${lessonKey}_\${blockId}" value="\${initialValue}"></div>` : '';
                blockContent = `\${existingInput}<input type="file" name="blockFile_\${lessonKey}_\${blockId}" class="form-control" accept="image/*">`;
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
                } else if (el.innerHTML.trim() !== '') {
                    addBlock(secId, lesId, 'text', el.innerHTML.trim());
                }
            }
        }

        window.onload = function() {
            if (sectionIndex === 0) {
                addSection();
            } else {
                <c:forEach var="section" items="${sections}" varStatus="sStat">
                    <c:forEach var="lesson" items="${lessonsMap[section.id]}" varStatus="lStat">
                        var sel = document.querySelector('select[name="lessonType_${sStat.index}_${lStat.index}"]');
                        var type = sel ? sel.value : 'script';
                        var rawHtml = document.getElementById('rawHtml_${sStat.index}_${lStat.index}').value;
                        var rawVideo = document.getElementById('rawVideoUrl_${sStat.index}_${lStat.index}').value;
                        var rawQuizNum = document.getElementById('rawQuizNum_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizNum_${sStat.index}_${lStat.index}').value : '10';
                        var rawQuizTime = document.getElementById('rawQuizTime_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizTime_${sStat.index}_${lStat.index}').value : '15';
                        var rawQuizRetake = document.getElementById('rawQuizRetake_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizRetake_${sStat.index}_${lStat.index}').value : '3';
                        var rawQuizPass = document.getElementById('rawQuizPass_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizPass_${sStat.index}_${lStat.index}').value : '5';
                        var rawQuizGroup = document.getElementById('rawQuizGroup_${sStat.index}_${lStat.index}') ? document.getElementById('rawQuizGroup_${sStat.index}_${lStat.index}').value : '';
                        changeLessonType(${sStat.index}, ${lStat.index}, type, rawHtml, rawVideo, {num: rawQuizNum, time: rawQuizTime, retake: rawQuizRetake, pass: rawQuizPass, group: rawQuizGroup});
                    </c:forEach>
                </c:forEach>
            }
        }
    </script>
</body>
</html>


















