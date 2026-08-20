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
            alert("Đã hết thời gian làm bài! Hệ thống sẽ tự động nộp bài.");
            const btn = document.getElementById('btnSubmitQuiz');
            if (btn) btn.disabled = true;
            document.getElementById('quizForm').dispatchEvent(new Event('submit'));
        }
    }, 1000);
}

document.getElementById('quizForm').addEventListener('submit', function(e) {
    e.preventDefault();

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
            alert('Error submitting quiz: ' + data.message);
            if (btn) {
                btn.innerHTML = '<i class="fas fa-paper-plane me-2"></i> Submit Quiz';
                btn.disabled = false;
            }
        }
    })
    .catch(err => {
        console.error(err);
        alert('An error occurred. Please try again.');
        if (btn) {
            btn.innerHTML = '<i class="fas fa-paper-plane me-2"></i> Submit Quiz';
            btn.disabled = false;
        }
    });
});