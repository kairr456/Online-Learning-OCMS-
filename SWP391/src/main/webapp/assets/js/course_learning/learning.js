// Learning page JS (view/course_learning/learning.jsp)
const CTX = document.body.getAttribute('data-ctx') || '';

function markComplete(lessonId) {
    const body = new URLSearchParams();
    body.append('action', 'markComplete');
    body.append('lessonId', lessonId);
    fetch(CTX + '/learning', { method: 'POST', body: body })
        .then(r => r.json())
        .then(d => {
            if (d.status === 'success') {
                location.reload();
            } else {
                alert('Error: ' + d.message);
            }
        })
        .catch(() => alert('Connection error!'));
}

let activeQuizTimerInterval = null;

function initQuizTimer() {
    const timerElem = document.getElementById('timerCountdown');
    if (!timerElem || timerElem.getAttribute('data-timer-started') === 'true') return;

    let secondsLeft = parseInt(timerElem.getAttribute('data-seconds'), 10) || 0;
    if (secondsLeft > 0) {
        timerElem.setAttribute('data-timer-started', 'true');
        
        function updateTimerDisplay() {
            if (secondsLeft < 0) return;
            const m = Math.floor(secondsLeft / 60);
            const s = secondsLeft % 60;
            timerElem.textContent = (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s);

            if (secondsLeft <= 60) {
                timerElem.classList.add('text-danger', 'fw-bold');
            }

            if (secondsLeft <= 0) {
                if (activeQuizTimerInterval) clearInterval(activeQuizTimerInterval);
                alert('⏰ Hết thời gian làm bài! Hệ thống đang tự động nộp bài.');
                const qForm = document.getElementById('quizForm');
                if (qForm) {
                    qForm.requestSubmit();
                }
            }
            secondsLeft--;
        }

        updateTimerDisplay();
        activeQuizTimerInterval = setInterval(updateTimerDisplay, 1000);
    }
}

// Option selection styling & timer start
document.addEventListener('DOMContentLoaded', function () {
    initQuizTimer();

    const quizAnswers = document.querySelectorAll('.quiz-answer input');
    quizAnswers.forEach(input => {
        input.addEventListener('change', function () {
            if (this.type === 'radio') {
                const name = this.name;
                document.querySelectorAll(`input[name="${name}"]`).forEach(r => {
                    const label = r.closest('.quiz-answer');
                    if (label) {
                        label.style.borderColor = '#dee2e6';
                        label.style.backgroundColor = '#ffffff';
                    }
                });
            }
            const currentLabel = this.closest('.quiz-answer');
            if (currentLabel) {
                if (this.checked) {
                    currentLabel.style.borderColor = '#7b2cbf';
                    currentLabel.style.backgroundColor = '#f3e8ff';
                } else {
                    currentLabel.style.borderColor = '#dee2e6';
                    currentLabel.style.backgroundColor = '#ffffff';
                }
            }
        });
    });

    // Quiz form submission
    const quizForm = document.getElementById('quizForm');
    if (quizForm) {
        quizForm.addEventListener('submit', function (e) {
            e.preventDefault();
            if (activeQuizTimerInterval) {
                clearInterval(activeQuizTimerInterval);
            }

            const nextUrl = quizForm.getAttribute('data-next-url') || '';
            const historyUrl = quizForm.getAttribute('data-history-url') || '';
            const attemptUrl = quizForm.getAttribute('data-attempt-url') || '';

            const body = new URLSearchParams(new FormData(quizForm));
            body.append('action', 'submitQuiz');

            const submitBtn = quizForm.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i> Đang nộp bài...';
            }

            fetch(CTX + '/learning', { method: 'POST', body: body })
                .then(r => r.json())
                .then(d => {
                    const res = document.getElementById('quizResult');
                    if (d.status === 'success') {
                        const passed = d.passed;
                        const previouslyPassed = d.previouslyPassed;
                        const isExhausted = d.isExhausted;
                        const scorePercent = d.scorePercent || (d.total > 0 ? Math.round((d.score / d.total) * 1000) / 10 : 0);

                        let html = '<div class="card p-4 text-center my-4 border-0 shadow" style="border-radius: 16px; background: #ffffff;">';
                        
                        if (passed) {
                            html += '<div class="text-success mb-2"><i class="fa-solid fa-circle-check" style="font-size: 56px;"></i></div>';
                            html += '<h2 class="fw-bold text-success mb-2">🎉 Chúc mừng! Bạn đã ĐẠT bài Quiz</h2>';
                        } else {
                            html += '<div class="text-danger mb-2"><i class="fa-solid fa-circle-xmark" style="font-size: 56px;"></i></div>';
                            html += '<h2 class="fw-bold text-danger mb-2">❌ Bài làm CHƯA ĐẠT</h2>';
                        }

                        html += '<div class="text-secondary small fw-bold text-uppercase mb-1">% Điểm Làm Bài</div>';
                        html += '<h1 class="display-3 fw-bold ' + (passed ? 'text-success' : 'text-danger') + ' mb-2">' + scorePercent + '%</h1>';
                        html += '<p class="fs-5 text-muted mb-4">% Điểm làm bài: <strong class="' + (passed ? 'text-success' : 'text-danger') + '">' + scorePercent + '%</strong> (Đúng ' + d.score + '/' + d.total + ' câu)</p>';

                        html += '<div class="d-flex flex-wrap justify-content-center align-items-center gap-3 mt-3">';

                        // Rule 1: Pass OR previously passed -> Show Next Lesson Button if available
                        if ((passed || previouslyPassed) && nextUrl !== '') {
                            html += '<a href="' + nextUrl + '" class="btn btn-success btn-lg px-4 py-2 rounded-pill fw-bold text-decoration-none shadow-sm"><i class="fa-solid fa-circle-arrow-right me-2"></i> Tiếp tục bài học tiếp theo</a>';
                        }

                        // Rule 2: Failed & retakes remaining -> Show Retake Button
                        if (!passed && !isExhausted) {
                            html += '<button onclick="location.reload()" class="btn btn-warning btn-lg px-4 py-2 rounded-pill fw-bold shadow-sm me-2"><i class="fa-solid fa-rotate-right me-2"></i> Làm lại bài</button>';
                        }

                        // Rule 3: Retakes exhausted -> Show History & Detailed Answers Button
                        if (isExhausted) {
                            html += '<a href="' + historyUrl + '" class="btn btn-info text-white btn-lg px-4 py-2 rounded-pill fw-bold text-decoration-none shadow-sm"><i class="fa-solid fa-clock-rotate-left me-2"></i> Xem lịch sử & đáp án chi tiết</a>';
                        }

                        // Rule 4: Always offer return to Quiz Overview
                        html += '<a href="' + attemptUrl + '" class="btn btn-outline-secondary btn-lg px-4 py-2 rounded-pill fw-bold text-decoration-none"><i class="fa-solid fa-list me-2"></i> Danh mục Quiz</a>';

                        html += '</div></div>';
                        res.innerHTML = html;
                        res.scrollIntoView({ behavior: 'smooth' });

                        if (submitBtn) {
                            submitBtn.style.display = 'none';
                        }
                    } else {
                        res.innerHTML = '<div class="alert alert-danger shadow-sm mt-3"><i class="fa-solid fa-triangle-exclamation me-2"></i> Lỗi: ' + d.message + '</div>';
                        if (submitBtn) {
                            submitBtn.disabled = false;
                            submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane me-2"></i> Thử Nộp Lại';
                        }
                    }
                })
                .catch(() => {
                    alert('Lỗi kết nối máy chủ!');
                    if (submitBtn) {
                        submitBtn.disabled = false;
                        submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane me-2"></i> Nộp Bài Quiz';
                    }
                });
        });
    }
});

// Run timer immediately in case DOM is already loaded
initQuizTimer();