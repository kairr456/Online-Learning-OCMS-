using System;
using System.IO;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        string path = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(path);

        string oldPattern = @"(?s)function addSection\(\).*?(?=function addBlock\()";
        
        string newCode = @"function addSection() {
            const container = document.getElementById('sections-container');
            const secId = sectionIndex++;
            lessonIndexes[secId] = 0;
            document.getElementById('sectionCount').value = sectionIndex;

            const html = `
                <div class=\""card mb-4 bg-light shadow-sm\"" id=\""section_\${secId}\"">
                    <div class=\""card-body\"">
                        <div class=\""mb-3\"">
                            <label class=\""form-label fw-bold\"">Section Title</label>
                            <input type=\""text\"" name=\""sectionTitle_\${secId}\"" class=\""form-control\"" placeholder=\""e.g. Chapter 1: Introduction\"">
                        </div>
                        <div id=\""lessons-container_\${secId}\"" class=\""ps-4 border-start border-3 border-warning mt-4\""></div>
                        <div class=\""mt-4\"">
                            <button type=\""button\"" class=\""btn btn-success btn-sm me-2 fw-bold px-3 py-2\"" onclick=\""addLesson(\${secId})\""><i class=\""fas fa-plus\""></i> Add Lesson</button>
                            <button type=\""button\"" class=\""btn btn-outline-danger btn-sm fw-bold px-3 py-2\"" onclick=\""document.getElementById('section_\${secId}').remove()\""><i class=\""fas fa-trash\""></i> Remove Section</button>
                        </div>
                        <input type=\""hidden\"" name=\""lessonCount_\${secId}\"" id=\""lessonCount_\${secId}\"" value=\""0\"">
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
                <div class=\""card mb-4 border-secondary\"" id=\""lesson_\${lessonKey}\"">
                    <div class=\""card-header bg-white d-flex justify-content-between align-items-center\"">
                        <h5 class=\""mb-0 text-primary\""><i class=\""fas fa-book-open me-2\""></i>Lesson</h5>
                        <button type=\""button\"" class=\""btn btn-sm btn-outline-danger\"" onclick=\""document.getElementById('lesson_\${lessonKey}').remove()\""><i class=\""fas fa-times\""></i></button>
                    </div>
                    <div class=\""card-body\"">
                        <div class=\""mb-3\"">
                            <label class=\""form-label fw-bold\"">Lesson Title</label>
                            <input type=\""text\"" name=\""lessonTitle_\${lessonKey}\"" class=\""form-control\"">
                        </div>
                        <div class=\""mb-3\"">
                            <label class=\""form-label fw-bold\"">Lesson Type</label>
                            <select name=\""lessonType_\${lessonKey}\"" class=\""form-select\"" onchange=\""changeLessonType(\${secId}, \${lesId}, this.value)\"">
                                <option value=\""script\"" selected>Script + Image (Blocks)</option>
                                <option value=\""video\"">Video Only</option>
                                <option value=\""quiz\"">Quiz</option>
                            </select>
                        </div>
                        <div id=\""lesson_fields_\${lessonKey}\"">
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
                    <div class=\""mb-2 fw-bold text-secondary\"">Lesson Contents (Build your article below)</div>
                    <div id=\""blocks-container_\${lessonKey}\"" class=\""mb-3\""></div>
                    <div class=\""d-flex align-items-center bg-light p-2 rounded border\"">
                        <span class=\""me-3 fw-bold text-muted small\"">ADD BLOCK:</span>
                        <button type=\""button\"" class=\""btn btn-sm btn-outline-primary me-2\"" onclick=\""addBlock(\${secId}, \${lesId}, 'text')\""><i class=\""fas fa-font\""></i> Text/Script</button>
                        <button type=\""button\"" class=\""btn btn-sm btn-outline-success\"" onclick=\""addBlock(\${secId}, \${lesId}, 'file')\""><i class=\""fas fa-image\""></i> Image</button>
                    </div>
                    <input type=\""hidden\"" name=\""blockCount_\${lessonKey}\"" id=\""blockCount_\${lessonKey}\"" value=\""0\"">
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
                if (fullUrl && !fullUrl.StartsWith('http')) {
                    fullUrl = 'https://www.youtube.com/watch?v=' + fullUrl;
                }
                html = `
                    <div class=\""mb-3\"">
                        <label class=\""form-label text-danger\""><i class=\""fab fa-youtube\""></i> YouTube URL</label>
                        <input type=\""url\"" name=\""lessonVideo_\${lessonKey}\"" class=\""form-control\"" value=\"\${fullUrl}\"" placeholder=\""https://youtube.com/...\"">
                    </div>
                `;
                container.innerHTML = html;
            } else if (type === 'quiz') {
                const selectedQuizId = quizData ? quizData.group : '';
                
                let optionsHtml = '<option value=\""\"">-- Chọn Bộ Đề (Question Group) --</option>';
                questionGroupList.forEach(g => {
                    const selected = (g.id == selectedQuizId) ? 'selected' : '';
                    optionsHtml += '<option value=\"\"' + g.id + '\"\" ' + selected + ' data-count=\"\"' + g.count + '\"\">' + escapeHtml(g.name) + ' (Có ' + g.count + ' câu)</option>';
                });

                html = `
                    <div class=\""card border-primary mb-3\"">
                        <div class=\""card-body bg-light\"">
                            <div class=\""d-flex justify-content-between align-items-center mb-3\"">
                                <h5 class=\""text-primary mb-0\""><i class=\""fas fa-tasks me-2\""></i> Cấu Hình Bài Quiz</h5>
                                <button type=\""submit\"" name=\""submitAction\"" value=\""goto_qbank\"" class=\""btn btn-outline-success btn-sm\"" formnovalidate>
                                    <i class=\""fas fa-plus me-1\""></i> Tạo bộ đề mới (Save Draft)
                                </button>
                            </div>
                            
                            <div class=\""row g-3\"">
                                <div class=\""col-md-12\"">
                                    <label class=\""form-label fw-bold\"">Chọn Question Group</label>
                                    <select name=\""lessonQuizGroup_\${lessonKey}\"" class=\""form-select border-primary\"" onchange=\""updateMaxQuestions(this, '\${lessonKey}')\"">
                                        \${optionsHtml}
                                    </select>
                                </div>
                                <div class=\""col-md-6\"">
                                    <label class=\""form-label\"">Số câu hỏi xuất ra</label>
                                    <input type=\""number\"" name=\""lessonQuizNum_\${lessonKey}\"" id=\""quizNum_\${lessonKey}\"" class=\""form-control\"" value=\"\${quizData ? quizData.num : '10'}\"" min=\""1\"">
                                    <small class=\""text-muted\"" id=\""quizNumHelp_\${lessonKey}\"">Lấy ngẫu nhiên từ bộ đề</small>
                                </div>
                                <div class=\""col-md-6\"">
                                    <label class=\""form-label\"">Thời gian làm bài (Phút)</label>
                                    <input type=\""number\"" name=\""lessonQuizTime_\${lessonKey}\"" class=\""form-control\"" value=\"\${quizData ? quizData.time : '15'}\"" min=\""1\"">
                                </div>
                                <div class=\""col-md-6\"">
                                    <label class=\""form-label\"">Số lần làm lại tối đa</label>
                                    <input type=\""number\"" name=\""lessonQuizRetake_\${lessonKey}\"" class=\""form-control\"" value=\"\${quizData ? quizData.retake : '3'}\"" min=\""0\"">
                                </div>
                                <div class=\""col-md-6\"">
                                    <label class=\""form-label\"">Điểm Pass (%)</label>
                                    <input type=\""number\"" name=\""lessonQuizPass_\${lessonKey}\"" class=\""form-control\"" value=\"\${quizData ? quizData.pass : '80'}\"" min=\""1\"" max=\""100\"">
                                </div>
                            </div>
                        </div>
                    </div>
                `;
                container.innerHTML = html;
                
                setTimeout(() => {
                    const selectEl = document.querySelector('select[name=\""lessonQuizGroup_' + lessonKey + '\""]');
                    if (selectEl && selectEl.value) {
                        updateMaxQuestions(selectEl, lessonKey);
                    }
                }, 100);
            }
        }
        
        ";

        content = Regex.Replace(content, oldPattern, newCode);
        File.WriteAllText(path, content, System.Text.Encoding.UTF8);
    }
}
