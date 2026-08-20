using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string path = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(path);
        
        int start = content.IndexOf("} else if (type === 'quiz') {");
        int end = content.IndexOf("function updateMaxQuestions");
        
        if (start > 0 && end > start) {
            string replacement = @"} else if (type === 'quiz') {
                const selectedQuizId = quizData ? quizData.group : '';
                
                let optionsHtml = '<option value="""">-- Chọn Bộ Đề (Question Group) --</option>';
                questionGroupList.forEach(g => {
                    const selected = (g.id == selectedQuizId) ? 'selected' : '';
                    optionsHtml += '<option value=""' + g.id + '"" ' + selected + ' data-count=""' + g.count + '"">' + escapeHtml(g.name) + ' (Có ' + g.count + ' câu)</option>';
                });

                html = " + "" + @"
                    <div class=""card border-primary mb-3"">
                        <div class=""card-body bg-light"">
                            <div class=""d-flex justify-content-between align-items-center mb-3"">
                                <h5 class=""text-primary mb-0""><i class=""fas fa-tasks me-2""></i> Cấu Hình Bài Quiz</h5>
                                <button type=""submit"" name=""submitAction"" value=""goto_qbank"" class=""btn btn-outline-success btn-sm"" formnovalidate>
                                    <i class=""fas fa-plus me-1""></i> Tạo bộ đề mới (Save Draft)
                                </button>
                            </div>
                            
                            <div class=""row g-3"">
                                <div class=""col-md-12"">
                                    <label class=""form-label fw-bold"">Chọn Question Group</label>
                                    <select name=""lessonQuizGroup_\"" class=""form-select border-primary"" onchange=""updateMaxQuestions(this, '\')"">
                                        \
                                    </select>
                                </div>
                                <div class=""col-md-6"">
                                    <label class=""form-label"">Số câu hỏi xuất ra</label>
                                    <input type=""number"" name=""lessonQuizNum_\"" id=""quizNum_\"" class=""form-control"" value=""\"" min=""1"">
                                    <small class=""text-muted"" id=""quizNumHelp_\"">Lấy ngẫu nhiên từ bộ đề</small>
                                </div>
                                <div class=""col-md-6"">
                                    <label class=""form-label"">Thời gian làm bài (Phút)</label>
                                    <input type=""number"" name=""lessonQuizTime_\"" class=""form-control"" value=""\"" min=""1"">
                                </div>
                                <div class=""col-md-6"">
                                    <label class=""form-label"">Số lần làm lại tối đa</label>
                                    <input type=""number"" name=""lessonQuizRetake_\"" class=""form-control"" value=""\"" min=""0"">
                                </div>
                                <div class=""col-md-6"">
                                    <label class=""form-label"">Điểm Pass (%)</label>
                                    <input type=""number"" name=""lessonQuizPass_\"" class=""form-control"" value=""\"" min=""1"" max=""100"">
                                </div>
                            </div>
                        </div>
                    </div>
                " + "" + @";
                container.innerHTML = html;
                
                setTimeout(() => {
                    const selectEl = document.querySelector('select[name=""lessonQuizGroup_' + lessonKey + '""]');
                    if (selectEl && selectEl.value) {
                        updateMaxQuestions(selectEl, lessonKey);
                    }
                }, 100);
            }
        }

        ";
            
            content = content.Substring(0, start) + replacement + content.Substring(end);
            
            // Also fix updateMaxQuestions
            int updateStart = content.IndexOf("function updateMaxQuestions");
            int updateEnd = content.IndexOf("function addBlock");
            if (updateStart > 0 && updateEnd > updateStart) {
                string updateRep = @"function updateMaxQuestions(selectEl, lessonKey) {
            const selectedOption = selectEl.options[selectEl.selectedIndex];
            const maxCount = selectedOption.getAttribute('data-count');
            const numInput = document.getElementById('quizNum_' + lessonKey);
            const helpText = document.getElementById('quizNumHelp_' + lessonKey);
            if (maxCount) {
                numInput.max = maxCount;
                helpText.innerHTML = " + "" + @"Tối đa: <strong class=""text-danger"">\</strong> câu có trong bộ đề" + "" + @";
                if (parseInt(numInput.value) > parseInt(maxCount)) {
                    numInput.value = maxCount;
                }
            } else {
                numInput.removeAttribute('max');
                helpText.innerHTML = 'Lấy ngẫu nhiên từ bộ đề';
            }
        }

        ";
                content = content.Substring(0, updateStart) + updateRep + content.Substring(updateEnd);
            }

            System.IO.File.WriteAllText(path, content, new System.Text.UTF8Encoding(false));
            Console.WriteLine("Fixed!");
        }
    }
}
