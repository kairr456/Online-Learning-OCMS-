$path = "C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp"
$content = Get-Content $path -Raw

$oldBlockPattern = '(?s)\} else if \(type === ''quiz''\) \{.*?setTimeout\(\(\) => \{.*?100\);\s*\}'

$newBlock = '} else if (type === ''quiz'') {
                const selectedQuizId = quizData ? quizData.group : '''';
                
                let optionsHtml = ''<option value="">-- Chọn Bộ Đề (Question Group) --</option>'';
                questionGroupList.forEach(g => {
                    const selected = (g.id == selectedQuizId) ? ''selected'' : '''';
                    optionsHtml += ''<option value="'' + g.id + ''" '' + selected + '' data-count="'' + g.count + ''">'' + escapeHtml(g.name) + '' (Có '' + g.count + '' câu)</option>'';
                });

                html = `
                    <div class="card border-primary mb-3">
                        <div class="card-body bg-light">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="text-primary mb-0"><i class="fas fa-tasks me-2"></i> Cấu Hình Bài Quiz</h5>
                                <button type="submit" name="submitAction" value="goto_qbank" class="btn btn-outline-success btn-sm">
                                    <i class="fas fa-plus me-1"></i> Tạo bộ đề mới (Save Draft)
                                </button>
                            </div>
                            
                            <div class="row g-3">
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Chọn Question Group</label>
                                    <select name="lessonQuizGroup_\${lessonKey}" class="form-select border-primary" onchange="updateMaxQuestions(this, ''\${lessonKey}'')" required>
                                        \${optionsHtml}
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Số câu hỏi xuất ra</label>
                                    <input type="number" name="lessonQuizNum_\${lessonKey}" id="quizNum_\${lessonKey}" class="form-control" value="\${quizData ? quizData.num : ''10''}" min="1" required>
                                    <small class="text-muted" id="quizNumHelp_\${lessonKey}">Lấy ngẫu nhiên từ bộ đề</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Thời gian làm bài (Phút)</label>
                                    <input type="number" name="lessonQuizTime_\${lessonKey}" class="form-control" value="\${quizData ? quizData.time : ''15''}" min="1" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Số lần làm lại tối đa</label>
                                    <input type="number" name="lessonQuizRetake_\${lessonKey}" class="form-control" value="\${quizData ? quizData.retake : ''3''}" min="0" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Điểm Pass (%)</label>
                                    <input type="number" name="lessonQuizPass_\${lessonKey}" class="form-control" value="\${quizData ? quizData.pass : ''80''}" min="1" max="100" required>
                                </div>
                            </div>
                        </div>
                    </div>
`;
                container.innerHTML = html;
                
                setTimeout(() => {
                    const selectEl = document.querySelector(''select[name="lessonQuizGroup_'' + lessonKey + ''"]'');
                    if (selectEl && selectEl.value) {
                        updateMaxQuestions(selectEl, lessonKey);
                    }
                }, 100);
            }'

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldBlockPattern, $newBlock)

Set-Content -Path $path -Value $content -Encoding UTF8
