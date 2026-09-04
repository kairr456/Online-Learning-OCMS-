// Take Quiz page (view/course_learning/take-quiz.jsp)
const CTX = document.body.getAttribute('data-ctx') || '';

const durationMinutes = parseInt(document.body.getAttribute('data-duration-minutes') || '0', 10);
if (durationMinutes > 0) {
    let timeRemaining = durationMinutes * 60;
    const timerDisplay = document.getElementById('timerDisplay');

    const timerInterval = setInterval(function() {
        timeRemaining--;
        let m = Math.floor(timeRemaining / 60);
        let s = timeRemaining % 60;

        if (m < 10) m = "0" + m;
        if (s < 10) s = "0" + s;

        if (timerDisplay) timerDisplay.innerText = m + ":" + s;

        if (timeRemaining <= 0) {
            clearInterval(timerInterval);
            const btn = document.getElementById('btnSubmitQuiz');
            if (btn) btn.disabled = true;
            document.getElementById('quizForm').dispatchEvent(new Event('submit'));
        }
    }, 1000);
}

const quizFormElem = document.getElementById('quizForm');
if (quizFormElem) {
    let isQuizSubmitted = false;

    function performBeaconSubmit() {
        if (isQuizSubmitted) return;
        isQuizSubmitted = true;
        if (timerInterval) clearInterval(timerInterval);

        const formData = new FormData(quizFormElem);
        const params = new URLSearchParams(formData);

        if (navigator.sendBeacon) {
            const blob = new Blob([params.toString()], { type: 'application/x-www-form-urlencoded;charset=UTF-8' });
            navigator.sendBeacon(CTX + '/take-quiz', blob);
        } else {
            fetch(CTX + '/take-quiz', {
                method: 'POST',
                body: params,
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                keepalive: true
            });
        }
    }

    function autoSubmitAndNavigate(targetUrl) {
        if (isQuizSubmitted) return;
        isQuizSubmitted = true;
        if (timerInterval) clearInterval(timerInterval);

        const formData = new FormData(quizFormElem);
        const params = new URLSearchParams(formData);

        fetch(CTX + '/take-quiz', {
            method: 'POST',
            body: params,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            keepalive: true
        })
        .finally(() => {
            if (targetUrl) window.location.href = targetUrl;
            else window.history.back();
        });
    }

    document.addEventListener('click', function(e) {
        if (isQuizSubmitted) return;
        const link = e.target.closest('a');
        if (!link) return;
        const href = link.getAttribute('href');
        if (!href || href === '#' || href.startsWith('javascript:')) return;
        if (link.target === '_blank') return;

        e.preventDefault();
        e.stopPropagation();
        autoSubmitAndNavigate(link.href);
    }, true);

    try {
        history.pushState({ inQuiz: true }, document.title, window.location.href);
    } catch (e) {}

    window.addEventListener('popstate', function() {
        if (isQuizSubmitted) return;
        autoSubmitAndNavigate(CTX + '/courses');
    });

    // Tab switch detection (hidden tab)
    document.addEventListener('visibilitychange', function() {
        if (document.hidden && !isQuizSubmitted) {
            autoSubmitAndNavigate(null);
        }
    });

    window.addEventListener('pagehide', function() {
        performBeaconSubmit();
    });
    window.addEventListener('beforeunload', function() {
        performBeaconSubmit();
    });

    // Clear red highlight & badge dynamically when student selects an answer
    document.addEventListener('change', function(e) {
        if (e.target.matches('.question-card input[type="radio"], .question-card input[type="checkbox"]')) {
            const card = e.target.closest('.question-card');
            if (card) {
                card.style.border = '';
                const badge = card.querySelector('.unanswered-badge');
                if (badge) badge.remove();

                const remaining = document.querySelectorAll('.unanswered-badge');
                if (remaining.length === 0) {
                    const alertContainer = document.getElementById('quizAlertContainer');
                    if (alertContainer) alertContainer.innerHTML = '';
                }
            }
        }
    });

    quizFormElem.addEventListener('submit', function(e) {
        e.preventDefault();

        // 1. Clear previous inline alert & question highlights
        const alertContainer = document.getElementById('quizAlertContainer');
        if (alertContainer) alertContainer.innerHTML = '';
        document.querySelectorAll('.unanswered-badge').forEach(b => b.remove());
        document.querySelectorAll('.question-card').forEach(card => {
            card.style.border = '';
        });

        // 2. Check unanswered questions
        const questionCards = document.querySelectorAll('.question-card');
        let unansweredCards = [];

        questionCards.forEach(card => {
            const inputs = card.querySelectorAll('input[type="radio"], input[type="checkbox"]');
            let isAnswered = false;
            inputs.forEach(inp => {
                if (inp.checked) isAnswered = true;
            });

            if (!isAnswered) {
                unansweredCards.push(card);
                card.style.border = '2px solid #dc3545';
                card.style.borderRadius = '10px';
                card.style.transition = 'all 0.3s ease';

                const titleElem = card.querySelector('.question-title');
                if (titleElem && !titleElem.querySelector('.unanswered-badge')) {
                    const badge = document.createElement('span');
                    badge.className = 'badge bg-danger ms-2 unanswered-badge';
                    badge.style.fontSize = '0.75rem';
                    badge.innerHTML = '<i class="fas fa-exclamation-circle me-1"></i> Chưa làm';
                    titleElem.appendChild(badge);
                }
            }
        });

        // 3. If there are unanswered questions and time is NOT expired:
        // Show 1-line inline alert notification (NO POPUP!) & scroll to first unanswered question
        const isTimeExpired = (typeof timeRemaining !== 'undefined' && timeRemaining <= 0);
        if (unansweredCards.length > 0 && !isTimeExpired) {
            if (alertContainer) {
                alertContainer.innerHTML = `
                    <div class="alert alert-danger d-flex align-items-center shadow-sm rounded-3 mb-4" role="alert">
                        <i class="fas fa-exclamation-triangle me-2 fs-5"></i>
                        <div class="fw-bold">Bạn chưa hoàn thành tất cả các câu hỏi (${unansweredCards.length} câu chưa làm). Vui lòng hoàn thành câu hỏi được khoanh đỏ trước khi nộp bài!</div>
                    </div>
                `;
            }
            unansweredCards[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
            return; // Stop form submission, no popups, no navigation!
        }

        isQuizSubmitted = true;
        if (timerInterval) clearInterval(timerInterval);

        const btn = document.getElementById('btnSubmitQuiz');
        if (btn) {
            btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i> Submitting...';
            btn.disabled = true;
        }

        const formData = new FormData(this);
        const params = new URLSearchParams(formData);

        fetch(CTX + '/take-quiz', {
            method: 'POST',
            body: params,
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        })
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                document.getElementById('scoreDisplay').innerText = data.scorePercent + '%';
                document.getElementById('correctCountDisplay').innerText = 'You answered ' + data.totalCorrect + ' / ' + data.totalQuestions + ' questions correctly.';

                const iconDiv = document.getElementById('resultIcon');
                if(data.passed) {
                    iconDiv.innerHTML = '<i class="fas fa-check-circle text-success result-icon"></i>';
                    document.getElementById('resultTitle').innerText = "Congratulations! You Passed.";
                } else {
                    iconDiv.innerHTML = '<i class="fas fa-times-circle text-danger result-icon"></i>';
                    document.getElementById('resultTitle').innerText = "Keep Trying! You Failed.";
                }

                var resultModal = new bootstrap.Modal(document.getElementById('resultModal'));
                resultModal.show();
            } else {
                isQuizSubmitted = false;
                if (alertContainer) {
                    alertContainer.innerHTML = `<div class="alert alert-danger mb-4">Error submitting quiz: ${data.message}</div>`;
                }
                if (btn) {
                    btn.innerHTML = '<i class="fas fa-paper-plane me-2"></i> Submit Quiz';
                    btn.disabled = false;
                }
            }
        })
        .catch(err => {
            isQuizSubmitted = false;
            console.error(err);
            if (alertContainer) {
                alertContainer.innerHTML = `<div class="alert alert-danger mb-4">An error occurred. Please try again.</div>`;
            }
            if (btn) {
                btn.innerHTML = '<i class="fas fa-paper-plane me-2"></i> Submit Quiz';
                btn.disabled = false;
            }
        });
    });
}