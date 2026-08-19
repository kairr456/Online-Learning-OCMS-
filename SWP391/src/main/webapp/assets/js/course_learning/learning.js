// Learning page (view/course_learning/learning.jsp)
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

const quizForm = document.getElementById('quizForm');
if (quizForm) {
    quizForm.addEventListener('submit', function (e) {
        e.preventDefault();
        const body = new URLSearchParams(new FormData(quizForm));
        body.append('action', 'submitQuiz');
        fetch(CTX + '/learning', { method: 'POST', body: body })
            .then(r => r.json())
            .then(d => {
                const res = document.getElementById('quizResult');
                if (d.status === 'success') {
                    res.innerHTML = '<div class="quiz-result ' + (d.passed ? 'pass' : 'fail') + '">'
                        + 'Your score: <strong>' + d.score + ' / ' + d.total + '</strong>'
                        + (d.passed ? ' — Passed!' : ' — Not passed. Please try again.')
                        + '</div>';
                    if (d.passed) {
                        setTimeout(() => location.reload(), 1200);
                    }
                } else {
                    res.innerHTML = '<div class="quiz-result fail">Error: ' + d.message + '</div>';
                }
            })
            .catch(() => alert('Connection error!'));
    });
}