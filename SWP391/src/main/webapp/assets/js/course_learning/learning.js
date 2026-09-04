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
                if (window.quizTimerInterval) clearInterval(window.quizTimerInterval);
                alert('⏰ Hết thời gian làm bài! Hệ thống đang tự động nộp bài.');
                const qForm = document.getElementById('quizForm');
                if (qForm) {
                    qForm.setAttribute('data-is-auto-submit', 'true');
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
            const questionCard = this.closest('.quiz-question');
            if (questionCard) {
                // Clear unanswered red error styling when user selects an option
                questionCard.style.border = '1px solid #dee2e6';
                questionCard.style.backgroundColor = '#fafafa';
                const unBadge = questionCard.querySelector('.unanswered-badge');
                if (unBadge) unBadge.remove();
            }

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

    // Quiz form submission & auto-submit on exit/back
    // Quiz form submission & auto-submit on exit/back/tab-switch
    const quizForm = document.getElementById('quizForm');
    if (quizForm) {
        let isQuizSubmitted = false;
        const nextUrl = quizForm.getAttribute('data-next-url') || '';
        const historyUrl = quizForm.getAttribute('data-history-url') || '';
        const attemptUrl = quizForm.getAttribute('data-attempt-url') || '';

        function renderQuizResult(d, isTabSwitch) {
            const res = document.getElementById('quizResult');
            if (!res) return;

            const passed = d.passed;
            const previouslyPassed = d.previouslyPassed;
            const isExhausted = d.isExhausted;
            const scorePercent = d.scorePercent || (d.total > 0 ? Math.round((d.score / d.total) * 1000) / 10 : 0);

            let html = '<div class="card p-4 text-center my-4 border-0 shadow" style="border-radius: 16px; background: #ffffff;">';

            if (isTabSwitch) {
                html += '<div class="alert alert-warning border border-warning fw-bold text-dark py-3 px-4 rounded-3 mb-4 shadow-sm text-start">';
                html += '<i class="fa-solid fa-triangle-exclamation text-warning fs-4 me-2 align-middle"></i> ';
                html += '<span><strong>Phát hiện chuyển tab!</strong> Hệ thống đã tự động thu bài và nộp bài làm của bạn do bạn rời khỏi màn hình làm bài.</span>';
                html += '</div>';
            }

            if (passed) {
                html += '<div class="text-success mb-2"><i class="fa-solid fa-circle-check" style="font-size: 56px;"></i></div>';
                html += '<h2 class="fw-bold text-success mb-2">🎉 Chúc mừng! Bạn đã ĐẠT bài Quiz</h2>';
            } else {
                html += '<div class="text-danger mb-2"><i class="fa-solid fa-circle-xmark" style="font-size: 56px;"></i></div>';
                html += '<h2 class="fw-bold text-danger mb-2">❌ Bài làm CHƯA ĐẠT</h2>';
            }

            html += '<div class="text-secondary small fw-bold text-uppercase mb-1">% Điểm Làm Bài</div>';
            html += '<h1 class="display-3 fw-bold ' + (passed ? 'text-success' : 'text-danger') + ' mb-2">' + scorePercent + '%</h1>';

            var correctDisplay = '';
            if (typeof d.totalCorrect !== 'undefined' && typeof d.totalQuestions !== 'undefined') {
                correctDisplay = 'Đúng ' + d.totalCorrect + '/' + d.totalQuestions + ' câu <span class="text-muted">- ' + d.score + '/' + d.total + ' điểm</span>';
            } else {
                correctDisplay = 'Đúng ' + d.score + '/' + d.total + ' điểm';
            }
            html += '<p class="fs-5 text-muted mb-4">% Điểm làm bài: <strong class="' + (passed ? 'text-success' : 'text-danger') + '">' + scorePercent + '%</strong> (' + correctDisplay + ')</p>';

            html += '<div class="d-flex flex-wrap justify-content-center align-items-center gap-3 mt-3">';

            if ((passed || previouslyPassed) && nextUrl !== '') {
                html += '<a href="' + nextUrl + '" class="btn btn-success btn-lg px-4 py-2 rounded-pill fw-bold text-decoration-none shadow-sm"><i class="fa-solid fa-circle-arrow-right me-2"></i> Tiếp tục bài học tiếp theo</a>';
            }

            if (!passed && !isExhausted) {
                html += '<button onclick="location.reload()" class="btn btn-warning btn-lg px-4 py-2 rounded-pill fw-bold shadow-sm me-2"><i class="fa-solid fa-rotate-right me-2"></i> Làm lại bài</button>';
            }

            if (isExhausted) {
                html += '<a href="' + historyUrl + '" class="btn btn-info text-white btn-lg px-4 py-2 rounded-pill fw-bold text-decoration-none shadow-sm"><i class="fa-solid fa-clock-rotate-left me-2"></i> Xem lịch sử & đáp án chi tiết</a>';
            }

            html += '<a href="' + attemptUrl + '" class="btn btn-outline-secondary btn-lg px-4 py-2 rounded-pill fw-bold text-decoration-none"><i class="fa-solid fa-list me-2"></i> Danh mục Quiz</a>';

            html += '</div></div>';
            res.innerHTML = html;
            res.scrollIntoView({ behavior: 'smooth' });

            // Hide the question form so user cannot interact further
            quizForm.style.display = 'none';
        }

        function showAutoSubmitOverlay(msg) {
            let overlay = document.getElementById('autoSubmitOverlay');
            if (!overlay) {
                overlay = document.createElement('div');
                overlay.id = 'autoSubmitOverlay';
                overlay.style.cssText = 'position:fixed;top:0;left:0;width:100vw;height:100vh;background:rgba(0,0,0,0.65);z-index:99999;display:flex;flex-direction:column;justify-content:center;align-items:center;color:#fff;backdrop-filter:blur(3px);';
                overlay.innerHTML = `
                    <div class="spinner-border text-light mb-3" style="width: 3.5rem; height: 3.5rem;" role="status"></div>
                    <h4 class="fw-bold mb-2">Đang tự động nộp bài...</h4>
                    <p class="text-light opacity-75 fs-6" id="autoSubmitMsg">` + (msg || 'Bạn đang rời khỏi bài làm. Hệ thống đang tự động nộp bài...') + `</p>
                `;
                document.body.appendChild(overlay);
            } else {
                const msgEl = document.getElementById('autoSubmitMsg');
                if (msgEl && msg) msgEl.innerText = msg;
                overlay.style.display = 'flex';
            }
        }

        function autoSubmitAndNavigate(targetUrl, msg) {
            if (isQuizSubmitted) return;
            isQuizSubmitted = true;

            if (activeQuizTimerInterval) {
                clearInterval(activeQuizTimerInterval);
                activeQuizTimerInterval = null;
            }
            if (window.quizTimerInterval) {
                clearInterval(window.quizTimerInterval);
                window.quizTimerInterval = null;
            }

            showAutoSubmitOverlay(msg);

            const body = new URLSearchParams(new FormData(quizForm));
            body.append('action', 'submitQuiz');

            fetch(CTX + '/learning', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body,
                keepalive: true
            })
            .then(r => r.json())
            .catch(() => null)
            .finally(() => {
                if (targetUrl) {
                    window.location.href = targetUrl;
                } else {
                    const fallbackUrl = attemptUrl || (window.location.href.replace('quizMode=take', 'quizMode=attempt'));
                    window.location.href = fallbackUrl;
                }
            });
        }

        function handleTabSwitch() {
            if (isQuizSubmitted) return;
            isQuizSubmitted = true;

            if (activeQuizTimerInterval) {
                clearInterval(activeQuizTimerInterval);
                activeQuizTimerInterval = null;
            }
            if (window.quizTimerInterval) {
                clearInterval(window.quizTimerInterval);
                window.quizTimerInterval = null;
            }

            const body = new URLSearchParams(new FormData(quizForm));
            body.append('action', 'submitQuiz');

            fetch(CTX + '/learning', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body,
                keepalive: true
            })
            .then(r => r.json())
            .then(d => {
                const overlay = document.getElementById('autoSubmitOverlay');
                if (overlay) overlay.remove();
                if (d && d.status === 'success') {
                    renderQuizResult(d, true);
                }
            })
            .catch(() => {
                if (navigator.sendBeacon) {
                    const blob = new Blob([body.toString()], { type: 'application/x-www-form-urlencoded;charset=UTF-8' });
                    navigator.sendBeacon(CTX + '/learning', blob);
                }
            });
        }

        function performBeaconSubmit() {
            if (isQuizSubmitted) return;
            isQuizSubmitted = true;

            if (activeQuizTimerInterval) {
                clearInterval(activeQuizTimerInterval);
                activeQuizTimerInterval = null;
            }
            if (window.quizTimerInterval) {
                clearInterval(window.quizTimerInterval);
                window.quizTimerInterval = null;
            }

            const body = new URLSearchParams(new FormData(quizForm));
            body.append('action', 'submitQuiz');

            if (navigator.sendBeacon) {
                const blob = new Blob([body.toString()], { type: 'application/x-www-form-urlencoded;charset=UTF-8' });
                navigator.sendBeacon(CTX + '/learning', blob);
            } else {
                fetch(CTX + '/learning', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: body,
                    keepalive: true
                });
            }
        }

        // Tab switch detection (hidden tab)
        document.addEventListener('visibilitychange', function () {
            if (document.hidden && !isQuizSubmitted) {
                handleTabSwitch();
            }
        });

        // 2. Intercept clicking on ANY link or button navigating away while in quiz
        document.addEventListener('click', function (e) {
            if (isQuizSubmitted) return;

            const link = e.target.closest('a');
            if (!link) return;

            const href = link.getAttribute('href');
            if (!href || href === '#' || href.startsWith('javascript:')) return;
            if (link.target === '_blank') return;

            e.preventDefault();
            e.stopPropagation();

            const isBackBtn = link.innerText.includes('Quay lại') || href.includes('quizMode=attempt') || link.classList.contains('back-link');
            const msg = isBackBtn
                ? 'Bạn đã nhấn nút quay lại. Hệ thống đang tự động nộp bài làm của bạn...'
                : 'Bạn đang rời khỏi trang làm bài. Hệ thống đang tự động nộp bài làm của bạn...';

            autoSubmitAndNavigate(link.href, msg);
        }, true);

        // 3. Intercept browser Back button
        try {
            history.pushState({ inQuiz: true }, document.title, window.location.href);
        } catch (err) {}

        window.addEventListener('popstate', function () {
            if (isQuizSubmitted) return;
            const fallbackUrl = attemptUrl || (window.location.href.replace('quizMode=take', 'quizMode=attempt'));
            autoSubmitAndNavigate(fallbackUrl, 'Bạn đã ấn nút quay lại trình duyệt. Hệ thống đang tự động nộp bài...');
        });

        // 4. Tab close, browser close, or page reload
        window.addEventListener('pagehide', function () {
            performBeaconSubmit();
        });
        window.addEventListener('beforeunload', function () {
            performBeaconSubmit();
        });

        // 5. Form submission handler (manual or timer-triggered)
        quizForm.addEventListener('submit', function (e) {
            const isAutoSubmit = quizForm.getAttribute('data-is-auto-submit') === 'true';

            // Manual Submit Validation
            if (!isAutoSubmit) {
                const questionCards = quizForm.querySelectorAll('.quiz-question');
                const unansweredCards = [];

                questionCards.forEach((card) => {
                    const checkedInput = card.querySelector('input[type="radio"]:checked, input[type="checkbox"]:checked');
                    const titleElem = card.querySelector('.quiz-question-title');
                    
                    if (!checkedInput) {
                        card.style.border = '2px solid #dc3545';
                        card.style.backgroundColor = '#fff5f5';

                        if (titleElem && !titleElem.querySelector('.unanswered-badge')) {
                            const badge = document.createElement('span');
                            badge.className = 'badge bg-danger ms-2 unanswered-badge';
                            badge.innerHTML = '<i class="fa-solid fa-circle-exclamation me-1"></i> Chưa chọn đáp án';
                            titleElem.appendChild(badge);
                        }
                        unansweredCards.push(card);
                    } else {
                        card.style.border = '1px solid #dee2e6';
                        card.style.backgroundColor = '#fafafa';
                        const unBadge = card.querySelector('.unanswered-badge');
                        if (unBadge) unBadge.remove();
                    }
                });

                if (unansweredCards.length > 0) {
                    e.preventDefault();
                    e.stopPropagation();
                    unansweredCards[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
                    return false;
                }
            }

            isQuizSubmitted = true;

            // Stop timer completely on submit
            if (activeQuizTimerInterval) {
                clearInterval(activeQuizTimerInterval);
                activeQuizTimerInterval = null;
            }
            if (window.quizTimerInterval) {
                clearInterval(window.quizTimerInterval);
                window.quizTimerInterval = null;
            }

            const timerBox = document.getElementById('quizTimerBox');
            if (timerBox) {
                timerBox.classList.remove('border-warning');
                timerBox.classList.add('border-secondary', 'bg-light', 'opacity-75');
                const tElem = document.getElementById('timerCountdown');
                if (tElem) {
                    tElem.classList.remove('text-danger');
                    tElem.classList.add('text-secondary');
                }
            }

            e.preventDefault();

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
                    if (d.status === 'success') {
                        isQuizSubmitted = true;
                        renderQuizResult(d, false);
                    } else {
                        isQuizSubmitted = false;
                        const res = document.getElementById('quizResult');
                        if (res) {
                            res.innerHTML = '<div class="alert alert-danger shadow-sm mt-3"><i class="fa-solid fa-triangle-exclamation me-2"></i> Lỗi: ' + d.message + '</div>';
                        }
                        if (submitBtn) {
                            submitBtn.disabled = false;
                            submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane me-2"></i> Thử Nộp Lại';
                        }
                    }
                })
                .catch(() => {
                    isQuizSubmitted = false;
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