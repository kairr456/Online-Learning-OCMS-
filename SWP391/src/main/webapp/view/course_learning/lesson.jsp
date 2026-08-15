<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create New Course - Teacher Dashboard</title>
    <!-- Include global styles if any, we'll write inline styles for dashboard simplicity -->
    <style>
        :root {
            --primary: #525fe1;
            --white: #ffffff;
            --bg-color: #f5f5f5;
            --text-color: #333;
            --border-color: #ddd;
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            margin: 0;
            padding: 0;
            color: var(--text-color);
        }
        .dashboard-container {
            max-width: 1000px;
            margin: 40px auto;
            background: var(--white);
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }
        h1, h2, h3 {
            color: #1a1a2e;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            box-sizing: border-box;
        }
        .btn {
            background-color: var(--primary);
            color: var(--white);
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
        }
        .btn-secondary {
            background-color: #ffc107;
            color: #1a1a2e;
        }
        .btn-danger {
            background-color: #dc3545;
        }
        .section-box {
            border: 1px solid var(--border-color);
            padding: 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            background: #fafafa;
        }
        .lesson-box {
            border: 1px dashed #ccc;
            padding: 15px;
            margin-top: 10px;
            background: #fff;
            position: relative;
        }
        .lesson-box .remove-btn {
            position: absolute;
            top: 10px;
            right: 10px;
        }
    </style>
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />

    <div class="dashboard-container">
        <h1>Create a New Course</h1>
        
        <form action="${pageContext.request.contextPath}/lesson" method="post" enctype="multipart/form-data">
            
            <h2>1. Course Information</h2>
            <div class="form-group">
                <label>Course Title</label>
                <input type="text" name="courseName" class="form-control" required>
            </div>
            
            <div class="form-group">
                <label>Course Category</label>
                <select name="categoryId" class="form-control" required>
                    <!-- Will fetch from DB in a real scenario, but let's hardcode a few for now or pass from controller -->
                    <option value="1">Development</option>
                    <option value="2">Business</option>
                    <option value="3">Design</option>
                </select>
            </div>

            <div class="form-group">
                <label>Overview / Description</label>
                <textarea name="courseDescription" rows="5" class="form-control" required></textarea>
            </div>

            <div class="form-group">
                <label>Price ($)</label>
                <input type="number" name="coursePrice" step="0.01" min="0" class="form-control" required>
            </div>

            <div class="form-group">
                <label>Thumbnail Image (Upload)</label>
                <input type="file" name="courseThumbnail" accept="image/*" class="form-control" required>
            </div>

            <hr style="margin: 40px 0;">

            <h2>2. Curriculum (Sections & Lessons)</h2>
            <div id="sections-container">
                <!-- Sections will be added here via JS -->
            </div>
            
            <button type="button" class="btn btn-secondary" onclick="addSection()">+ Add Curriculum Section</button>

            <hr style="margin: 40px 0;">
            
            <button type="submit" class="btn" style="width: 100%; font-size: 18px; padding: 15px;">Publish Course</button>
            
            <!-- Hidden inputs to track array sizes -->
            <input type="hidden" name="sectionCount" id="sectionCount" value="0">
        </form>
    </div>

    <script>
        let sectionIndex = 0;
        let lessonIndexes = {}; // tracks lesson count per section

        function addSection() {
            const container = document.getElementById('sections-container');
            const secId = sectionIndex++;
            lessonIndexes[secId] = 0;
            
            document.getElementById('sectionCount').value = sectionIndex;

            const html = `
                <div class="section-box" id="section_${secId}">
                    <div class="form-group">
                        <label>Section Title</label>
                        <input type="text" name="sectionTitle_${secId}" class="form-control" placeholder="e.g. Introduction" required>
                    </div>
                    
                    <div id="lessons-container_${secId}"></div>
                    
                    <button type="button" class="btn" style="background: #28a745;" onclick="addLesson(${secId})">+ Add Lesson</button>
                    <button type="button" class="btn btn-danger" onclick="document.getElementById('section_${secId}').remove()">Remove Section</button>
                    <input type="hidden" name="lessonCount_${secId}" id="lessonCount_${secId}" value="0">
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
        }

        function addLesson(secId) {
            const container = document.getElementById('lessons-container_' + secId);
            const lesId = lessonIndexes[secId]++;
            
            document.getElementById('lessonCount_' + secId).value = lessonIndexes[secId];

            const html = `
                <div class="lesson-box" id="lesson_${secId}_${lesId}">
                    <button type="button" class="btn btn-danger remove-btn" onclick="document.getElementById('lesson_${secId}_${lesId}').remove()">X</button>
                    
                    <div class="form-group" style="width: 80%;">
                        <label>Lesson Title</label>
                        <input type="text" name="lessonTitle_${secId}_${lesId}" class="form-control" required>
                    </div>
                    
                    <div class="form-group" style="width: 80%;">
                        <label>Lesson Content Type</label>
                        <select name="lessonType_${secId}_${lesId}" class="form-control" onchange="toggleLessonInput(${secId}, ${lesId}, this.value)">
                            <option value="video">YouTube Video Link</option>
                            <option value="file">Image / File Upload</option>
                            <option value="text">Text / Script</option>
                        </select>
                    </div>

                    <div id="input_video_${secId}_${lesId}" class="form-group" style="width: 80%;">
                        <label>YouTube Link</label>
                        <input type="url" name="lessonYoutube_${secId}_${lesId}" class="form-control" placeholder="https://www.youtube.com/watch?v=...">
                    </div>

                    <div id="input_file_${secId}_${lesId}" class="form-group" style="width: 80%; display: none;">
                        <label>Upload File (Image/PDF/etc)</label>
                        <input type="file" name="lessonFile_${secId}_${lesId}" class="form-control">
                    </div>

                    <div id="input_text_${secId}_${lesId}" class="form-group" style="width: 80%; display: none;">
                        <label>Lesson Script / Content</label>
                        <textarea name="lessonText_${secId}_${lesId}" rows="4" class="form-control"></textarea>
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
        }

        function toggleLessonInput(secId, lesId, type) {
            document.getElementById(`input_video_${secId}_${lesId}`).style.display = 'none';
            document.getElementById(`input_file_${secId}_${lesId}`).style.display = 'none';
            document.getElementById(`input_text_${secId}_${lesId}`).style.display = 'none';

            if (type === 'video') {
                document.getElementById(`input_video_${secId}_${lesId}`).style.display = 'block';
            } else if (type === 'file') {
                document.getElementById(`input_file_${secId}_${lesId}`).style.display = 'block';
            } else if (type === 'text') {
                document.getElementById(`input_text_${secId}_${lesId}`).style.display = 'block';
            }
        }
        
        // Add one empty section by default
        window.onload = function() {
            addSection();
        }
    </script>
</body>
</html>
