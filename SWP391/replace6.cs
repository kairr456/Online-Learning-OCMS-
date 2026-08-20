using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        string oldQuiz = @"} else if (type === 'quiz') {
                const selectedQuizId = quizData ? quizData.group : '';
                
                let optionsHtml = '<option value="""">-- Ch?n B? D? (Question Group) --</option>';
                questionGroupList.forEach(g => {
                    const selected = (g.id == selectedQuizId) ? 'selected' : '';
                    optionsHtml += '<option value=""' + g.id + '"" ' + selected + ' data-count=""' + g.count + '"">' + escapeHtml(g.name) + ' (CA3 ' + g.count + ' cAu)</option>';
                });

                html = " + "" + @"
                    <div class=""card border-primary mb-3"">
                        <div class=""card-body bg-light"">
                            <div class=""d-flex justify-content-between align-items-center mb-3"">
                                <h5 class=""text-primary mb-0""><i class=""fas fa-tasks me-2""></i> C?u HAnh BAi Quiz</h5>
                                <button type=""submit"" name=""submitAction"" value=""goto_qbank"" class=""btn btn-outline-success btn-sm"" formnovalidate>
                                    <i class=""fas fa-plus me-1""></i> T?o b? d? m?i (Save Draft)
                                </button>
                            </div>
                            
                            <div class=""row g-3"">
                                <div class=""col-md-12"">
                                    <label class=""form-label fw-bold"">Ch?n Question Group</label>
                                    <select name=""lessonQuizGroup_\"" class=""form-select border-primary"" onchange=""updateMaxQuestions(this, '\')"">
                                        \
                                    </select>
                                </div>
                                <div class=""col-md-6"">
                                    <label class=""form-label"">S? cu h?i xu?t ra</label>
                                    <input type=""number"" name=""lessonQuizNum_\"" id=""quizNum_\"" class=""form-control"" value=""\"" min=""1"">
                                    <small class=""text-muted"" id=""quizNumHelp_\"">L?y ng?u nhin t? b? d?</small>
                                </div>
                                <div class=""col-md-6"">
                                    <label class=""form-label"">Th?i gian lm bi (Pht)</label>
                                    <input type=""number"" name=""lessonQuizTime_\"" class=""form-control"" value=""\"" min=""1"">
                                </div>
                                <div class=""col-md-6"">
                                    <label class=""form-label"">S? l?n lm l?i t?i da</label>
                                    <input type=""number"" name=""lessonQuizRetake_\"" class=""form-control"" value=""\"" min=""0"">
                                </div>
                                <div class=""col-md-6"">
                                    <label class=""form-label"">Di?m Pass (%)</label>
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
            }";
            
        // Wait, if oldQuiz doesn't match perfectly, it fails.
        // Let's just find the start and end indices to replace!
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

                html = '<div class=""card border-primary mb-3"">' +
                       ' <div class=""card-body bg-light"">' +
                       '  <div class=""d-flex justify-content-between align-items-center mb-3"">' +
                       '   <h5 class=""text-primary mb-0""><i class=""fas fa-tasks me-2""></i> Cấu Hình Bài Quiz</h5>' +
                       '   <button type=""submit"" name=""submitAction"" value=""goto_qbank"" class=""btn btn-outline-success btn-sm"" formnovalidate>' +
                       '    <i class=""fas fa-plus me-1""></i> Tạo bộ đề mới (Save Draft)' +
                       '   </button>' +
                       '  </div>' +
                       '  <div class=""row g-3"">' +
                       '   <div class=""col-md-12"">' +
                       '    <label class=""form-label fw-bold"">Chọn Question Group</label>' +
                       '    <select name=""lessonQuizGroup_' + lessonKey + '"" class=""form-select border-primary"" onchange=""updateMaxQuestions(this, \'' + lessonKey + '\')"">' +
                       optionsHtml +
                       '    </select>' +
                       '   </div>' +
                       '   <div class=""col-md-6"">' +
                       '    <label class=""form-label"">Số câu hỏi xuất ra</label>' +
                       '    <input type=""number"" name=""lessonQuizNum_' + lessonKey + '"" id=""quizNum_' + lessonKey + '"" class=""form-control"" value=""' + (quizData ? quizData.num : '10') + '"" min=""1"">' +
                       '    <small class=""text-muted"" id=""quizNumHelp_' + lessonKey + '"">Lấy ngẫu nhiên từ bộ đề</small>' +
                       '   </div>' +
                       '   <div class=""col-md-6"">' +
                       '    <label class=""form-label"">Thời gian làm bài (Phút)</label>' +
                       '    <input type=""number"" name=""lessonQuizTime_' + lessonKey + '"" class=""form-control"" value=""' + (quizData ? quizData.time : '15') + '"" min=""1"">' +
                       '   </div>' +
                       '   <div class=""col-md-6"">' +
                       '    <label class=""form-label"">Số lần làm lại tối đa</label>' +
                       '    <input type=""number"" name=""lessonQuizRetake_' + lessonKey + '"" class=""form-control"" value=""' + (quizData ? quizData.retake : '3') + '"" min=""0"">' +
                       '   </div>' +
                       '   <div class=""col-md-6"">' +
                       '    <label class=""form-label"">Điểm Pass (%)</label>' +
                       '    <input type=""number"" name=""lessonQuizPass_' + lessonKey + '"" class=""form-control"" value=""' + (quizData ? quizData.pass : '80') + '"" min=""1"" max=""100"">' +
                       '   </div>' +
                       '  </div>' +
                       ' </div>' +
                       '</div>';
                
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
                helpText.innerHTML = 'Tối đa: <strong class=""text-danger"">' + maxCount + '</strong> câu có trong bộ đề';
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
            
            File.WriteAllText(target, content, new UTF8Encoding(false));
            Console.WriteLine("Bulletproof JS block written!");
        } else {
            Console.WriteLine("Start/End not found");
        }
    }
}
