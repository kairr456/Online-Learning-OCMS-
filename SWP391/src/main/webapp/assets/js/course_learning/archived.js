// Archived page (view/course_learning/archived.jsp)
const ARCHIVE_API = document.body.getAttribute('data-ctx') + '/archive-course';

let pendingUnarchiveCourseId = null;

function unarchiveCourse(courseId, courseName) {
    pendingUnarchiveCourseId = courseId;
    document.getElementById('unarchiveConfirmMessage').innerText =
        'Are you sure you want to unarchive "' + (courseName || 'this course') + '"? You can archive it again from All Courses.';
    document.getElementById('unarchiveConfirmModal').classList.add('show');
}

function closeUnarchiveConfirmModal() {
    pendingUnarchiveCourseId = null;
    const modal = document.getElementById('unarchiveConfirmModal');
    if (modal) modal.classList.remove('show');
}

function confirmUnarchiveAction() {
    const courseId = pendingUnarchiveCourseId;
    if (!courseId) return;
    closeUnarchiveConfirmModal();
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