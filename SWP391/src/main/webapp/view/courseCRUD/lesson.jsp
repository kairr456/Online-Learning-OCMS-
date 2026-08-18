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
    <style>
        :root { --primary-dark: #1a1a2e; --accent-yellow: #ffc107; --bg-color: #f4f6f9; }
        body { background-color: var(--bg-color); font-family: 'Inter', 'Segoe UI', sans-serif; }
        .dashboard-container { max-width: 900px; margin: 40px auto; background: #ffffff; padding: 40px; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        h1, h2, h3, h4 { color: var(--primary-dark); font-weight: 700; }
        .section-header { border-bottom: 2px solid var(--accent-yellow); padding-bottom: 10px; margin-bottom: 30px; }
        .form-label { font-weight: 600; color: var(--primary-dark); }
        .btn-primary, .btn-warning { background-color: var(--accent-yellow); color: var(--primary-dark); font-weight: bold; border: none; }
        .btn-primary:hover, .btn-warning:hover { background-color: #e0a800; color: var(--primary-dark); }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container my-5">
        <div class="card shadow-sm">
            <div class="card-body p-5">
                <h2 class="section-header">${not empty course ? 'Edit Course' : 'Create a New Course'}</h2>
                
                <form action="${pageContext.request.contextPath}/lesson" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="courseId" value="${course != null ? course.id : ''}">
                    
                    <h4 class="mb-3">1. Course Information</h4>
                    <div class="mb-3">
                        <label class="form-label">Course Title</label>
                        <input type="text" name="courseName" class="form-control" value="${course != null ? fn:escapeXml(course.name) : ''}" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Course Category</label>
                        <select name="categoryId" class="form-select" required>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}" ${course != null && course.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Overview / Description</label>
                        <textarea name="courseDescription" rows="5" class="form-control" required>${course != null ? fn:escapeXml(course.description) : ''}</textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Price ($)</label>
                        <input type="number" name="coursePrice" step="0.01" min="0" class="form-control" value="${course != null ? course.price : '0.00'}" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Thumbnail Image (Upload)</label>
                        <c:if test="${course != null && not empty course.thumbnail}">
                            <div class="mb-2">
                                <img src="${course.thumbnail}" alt="Current Thumbnail" style="height:100px; border-radius:5px;">
                            </div>
                            <small class="text-muted">Upload a new file to change the current thumbnail.</small>
                        </c:if>
                        <input type="file" name="courseThumbnail" accept="image/*" class="form-control" ${empty course ? 'required' : ''}>
                    </div>

                    <hr class="my-5">

                    <h4 class="mb-3">2. Curriculum (Sections & Lessons)</h4>
                    <div id="sections-container">
                        <c:if test="${not empty sections}">
                            <c:forEach var="section" items="${sections}" varStatus="sStat">
                                <div class="card mb-4 bg-light shadow-sm" id="section_${sStat.index}">
                                    <div class="card-body">
                                        <input type="hidden" name="sectionId_${sStat.index}" value="${section.id}">
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Section Title</label>
                                            <input type="text" name="sectionTitle_${sStat.index}" class="form-control" value="${fn:escapeXml(section.title)}" required>
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
                                                            <input type="text" name="lessonTitle_${sStat.index}_${lStat.index}" class="form-control" value="${fn:escapeXml(lesson.title)}" required>
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
                                                        <textarea id="rawHtml_${sStat.index}_${lStat.index}" style="display:none;">${fn:escapeXml(lesson.textContent)}</textarea>
                                                        <input type="hidden" id="rawVideoUrl_${sStat.index}_${lStat.index}" value="${fn:escapeXml(lesson.videoUrl)}">
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
                    <button type="submit" class="btn btn-primary btn-lg w-100 py-3">${not empty course ? 'Save Changes' : 'Publish Course'}</button>
                    <input type="hidden" name="sectionCount" id="sectionCount" value="${not empty sections ? fn:length(sections) : 0}">
                </form>
            </div>
        </div>
    </div>

    <script>
        const quizBankList = [
            <c:forEach var="q" items="${quizBank}" varStatus="loop">
                { id: "${q.quiz_id}", title: "${fn:escapeXml(q.lesson_title)}" }${!loop.last ? ',' : ''}
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
                            <input type="text" name="sectionTitle_\${secId}" class="form-control" placeholder="e.g. Chapter 1: Introduction" required>
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
                            <input type="text" name="lessonTitle_\${lessonKey}" class="form-control" required>
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

        function changeLessonType(secId, lesId, type, rawHtml = '', rawVideo = '') {
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
                html = `
                    <div class="mb-3">
                        <label class="form-label text-danger"><i class="fab fa-youtube"></i> YouTube URL</label>
                        <input type="url" name="lessonVideo_\${lessonKey}" class="form-control" value="\${rawVideo}" placeholder="https://youtube.com/..." required>
                    </div>
                `;
                container.innerHTML = html;
            } else if (type === 'quiz') {
                let selectedQuizId = "";
                if (rawHtml && rawHtml.startsWith("Quiz ID: ")) {
                    selectedQuizId = rawHtml.substring(9).trim();
                }
                
                let optionsHtml = '<option value="">-- Select Quiz from Bank --</option>';
                quizBankList.forEach(q => {
                    const selected = (q.id == selectedQuizId) ? 'selected' : '';
                    optionsHtml += `<option value="\${q.id}" \${selected}>\${escapeHtml(q.title)}</option>`;
                });

                html = `
                    <div class="mb-3">
                        <label class="form-label text-warning"><i class="fas fa-question-circle"></i> Quiz Bank</label>
                        <select name="lessonQuiz_\${lessonKey}" class="form-select" required>
                            \${optionsHtml}
                        </select>
                    </div>
                `;
                container.innerHTML = html;
            }
        }

        function addBlock(secId, lesId, type, initialValue = '') {
            const lessonKey = secId + '_' + lesId;
            const container = document.getElementById('blocks-container_' + lessonKey);
            const blockId = blockIndexes[lessonKey]++;
            document.getElementById('blockCount_' + lessonKey).value = blockIndexes[lessonKey];

            let blockContent = '';
            let icon = '';
            let title = '';

            if (type === 'text') {
                icon = '<i class="fas fa-font text-primary"></i>';
                title = 'Text / Script Block';
                blockContent = `<textarea name="blockText_\${lessonKey}_\${blockId}" rows="4" class="form-control" placeholder="Write your lesson content here..." required>\${initialValue}</textarea>`;
            } else if (type === 'file') {
                icon = '<i class="fas fa-image text-success"></i>';
                title = 'Image Block';
                let existingInput = initialValue ? `<div class="mb-2"><img src="\${initialValue}" style="height:100px; border-radius:5px;"><input type="hidden" name="existingFile_\${lessonKey}_\${blockId}" value="\${initialValue}"></div>` : '';
                blockContent = `\${existingInput}<input type="file" name="blockFile_\${lessonKey}_\${blockId}" class="form-control" accept="image/*" \${initialValue ? '' : 'required'}>`;
            }

            const html = `
                <div class="card mb-3 border-0 shadow-sm" style="background-color: #f8f9fa;" id="block_\${lessonKey}_\${blockId}">
                    <div class="card-body p-3 position-relative">
                        <button type="button" class="btn-close position-absolute top-0 end-0 m-2" style="width:10px; height:10px;" onclick="document.getElementById('block_\${lessonKey}_\${blockId}').remove()"></button>
                        <div class="fw-bold mb-2 text-muted small">\${icon} \${title}</div>
                        <input type="hidden" name="blockType_\${lessonKey}_\${blockId}" value="\${type}">
                        \${blockContent}
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
        }

        function parseBlocks(secId, lesId, htmlString) {
            if (!htmlString || htmlString.trim() === '') return;
            // Hack to decode HTML entities in JS:
            const txt = document.createElement("textarea");
            txt.innerHTML = htmlString;
            const decodedHtml = txt.value;
            
            const parser = new DOMParser();
            const doc = parser.parseFromString(decodedHtml, 'text/html');
            const divs = doc.body.children;
            let foundAny = false;
            
            for (let i = 0; i < divs.length; i++) {
                const div = divs[i];
                if (div.classList.contains('lesson-text-block')) {
                    let textContent = div.innerHTML.replace(/<br\s*[\/]?>/gi, '\n');
                    addBlock(secId, lesId, 'text', textContent);
                    foundAny = true;
                } else if (div.classList.contains('lesson-img-block')) {
                    const img = div.querySelector('img');
                    if (img) {
                        addBlock(secId, lesId, 'file', img.getAttribute('src'));
                        foundAny = true;
                    }
                }
            }
            if (!foundAny) addBlock(secId, lesId, 'text'); // fallback
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
                        changeLessonType(${sStat.index}, ${lStat.index}, type, rawHtml, rawVideo);
                    </c:forEach>
                </c:forEach>
            }
        }
    </script>
</body>
</html>
