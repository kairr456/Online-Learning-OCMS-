<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create New Course - Teacher Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Include global styles if any, we'll write inline styles for dashboard simplicity -->
    <style>
        :root {
            --primary-dark: #1a1a2e; /* Dark Blue */
            --accent-yellow: #ffc107; /* Yellow */
            --bg-color: #f4f6f9;
        }

        body {
            background-color: var(--bg-color);
            font-family: 'Inter', 'Segoe UI', sans-serif; 
        }

        .dashboard-container {
            max-width: 900px;
            margin: 40px auto;
            background: #ffffff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        }

        h1, h2, h3, h4 {
            color: var(--primary-dark);
            font-weight: 700;
        }
        
        .section-header {
            border-bottom: 2px solid var(--accent-yellow);
            padding-bottom: 10px;
            margin-bottom: 30px;
            color: var(--primary-dark);
        }

        .form-label {
            font-weight: 600;
            color: var(--primary-dark);
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--accent-yellow);
            box-shadow: 0 0 0 0.25rem rgba(255, 193, 7, 0.25);
        }

        .btn-primary {
            background-color: var(--accent-yellow);
            color: var(--primary-dark);
            border: none;
            font-weight: bold;
        }
        .btn-primary:hover {
            background-color: #e0a800;
            color: var(--primary-dark);
        }
        
        .btn-warning {
            background-color: var(--accent-yellow);
            color: var(--primary-dark);
            font-weight: bold;
        }
        
        .card {
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="container my-5">
        <div class="card shadow-sm">
            <div class="card-body p-5">
                <h2 class="section-header">Create a New Course</h2>
                
                <form action="${pageContext.request.contextPath}/lesson" method="post" enctype="multipart/form-data">
                    
                    <h4 class="mb-3">1. Course Information</h4>
                    <div class="mb-3">
                        <label class="form-label">Course Title</label>
                        <input type="text" name="courseName" class="form-control" placeholder="e.g. Introduction to Java" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Course Category</label>
                        <select name="categoryId" class="form-select" required>
                            <option value="1">Development</option>
                            <option value="2">Business</option>
                            <option value="3">Design</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Overview / Description</label>
                        <textarea name="courseDescription" rows="5" class="form-control" placeholder="Describe what students will learn..." required></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Price ($)</label>
                        <input type="number" name="coursePrice" step="0.01" min="0" class="form-control" placeholder="49.99" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Thumbnail Image (Upload)</label>
                        <input type="file" name="courseThumbnail" accept="image/*" class="form-control" required>
                    </div>

                    <hr class="my-5">

                    <h4 class="mb-3">2. Curriculum (Sections & Contents)</h4>
                    <div id="sections-container">
                        <!-- Sections will be added here via JS -->
                    </div>
                    
                    <button type="button" class="btn btn-warning mb-4 px-4 py-2" onclick="addSection()">+ Add Curriculum Section</button>

                    <hr class="my-5">
                    
                    <button type="submit" class="btn btn-primary btn-lg w-100 py-3">Publish Course</button>
                    
                    <!-- Hidden inputs to track array sizes -->
                    <input type="hidden" name="sectionCount" id="sectionCount" value="0">
                </form>
            </div>
        </div>
    </div>

    <script>
        let sectionIndex = 0;
        let lessonIndexes = {}; 
        let blockIndexes = {}; // tracks blocks per lesson: blockIndexes[`${secId}_${lesId}`]

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
                        <div class="mb-4">
                            <label class="form-label fw-bold">Lesson Title</label>
                            <input type="text" name="lessonTitle_\${lessonKey}" class="form-control" required>
                        </div>
                        
                        <div class="mb-2 fw-bold text-secondary">Lesson Contents (Build your article below)</div>
                        <div id="blocks-container_\${lessonKey}" class="mb-3">
                            <!-- Content Blocks go here -->
                        </div>
                        
                        <div class="d-flex align-items-center bg-light p-2 rounded border">
                            <span class="me-3 fw-bold text-muted small">ADD BLOCK:</span>
                            <button type="button" class="btn btn-sm btn-outline-primary me-2" onclick="addBlock(\${secId}, \${lesId}, 'text')"><i class="fas fa-font"></i> Text/Script</button>
                            <button type="button" class="btn btn-sm btn-outline-success me-2" onclick="addBlock(\${secId}, \${lesId}, 'file')"><i class="fas fa-image"></i> Image/File</button>
                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="addBlock(\${secId}, \${lesId}, 'video')"><i class="fab fa-youtube"></i> YouTube Video</button>
                        </div>
                        <input type="hidden" name="blockCount_\${lessonKey}" id="blockCount_\${lessonKey}" value="0">
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
            
            // Auto-add first text block
            addBlock(secId, lesId, 'text');
        }

        function addBlock(secId, lesId, type) {
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
                blockContent = `<textarea name="blockText_\${lessonKey}_\${blockId}" rows="4" class="form-control" placeholder="Write your lesson content here..." required></textarea>`;
            } else if (type === 'file') {
                icon = '<i class="fas fa-image text-success"></i>';
                title = 'Image / File Block';
                blockContent = `<input type="file" name="blockFile_\${lessonKey}_\${blockId}" class="form-control" accept="image/*" required>`;
            } else if (type === 'video') {
                icon = '<i class="fab fa-youtube text-danger"></i>';
                title = 'YouTube Video Block';
                blockContent = `<input type="url" name="blockVideo_\${lessonKey}_\${blockId}" class="form-control" placeholder="https://www.youtube.com/watch?v=..." required>`;
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
        
        window.onload = function() {
            addSection();
        }
    </script>
</body>
</html>
