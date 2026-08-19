// Archived page (view/course_learning/archived.jsp)
const ARCHIVE_API = document.body.getAttribute('data-ctx') + '/archive-course';

function unarchiveCourse(courseId) {
    const body = new URLSearchParams();
    body.append('action', 'unarchive');
    body.append('courseId', courseId);
    fetch(ARCHIVE_API, { method: 'POST', body: body })
        .then(r => r.json())
        .then(d => {
            if (d.status === 'success') {
                location.reload();
            } else {
                alert('Unarchive failed: ' + (d.message || 'Error occurred'));
            }
        })
        .catch(() => alert('Connection error occurred!'));
}