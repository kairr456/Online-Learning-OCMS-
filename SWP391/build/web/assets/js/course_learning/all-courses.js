// All Courses page (view/course_learning/all_courses.jsp)
const CTX = document.body.getAttribute('data-ctx') || '';
const API_URL = CTX + '/user-learning-list';
let activeCourse = null;

let myListsData = [];
try {
    const rawJsonData = document.getElementById('myListsJsonData').textContent;
    myListsData = JSON.parse(rawJsonData);
} catch (e) {
    myListsData = [];
}

function sendAjaxRequest(params) {
    return fetch(API_URL, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        },
        body: new URLSearchParams(params)
    })
    .then(response => {
        if (!response.ok) throw new Error('Network error');
        return response.json();
    });
}

function reloadPreservingTab() {
    window.location.reload();
}

let pendingArchiveCourseId = null;

function archiveCourse(courseId, courseName) {
    pendingArchiveCourseId = courseId;
    document.getElementById('archiveConfirmMessage').innerText =
        'Are you sure you want to archive "' + (courseName || 'this course') + '"? You can unarchive it later from the Archived page.';
    document.getElementById('archiveConfirmModal').classList.add('show');
}

function closeArchiveConfirmModal() {
    pendingArchiveCourseId = null;
    const modal = document.getElementById('archiveConfirmModal');
    if (modal) modal.classList.remove('show');
}

function confirmArchiveAction() {
    const courseId = pendingArchiveCourseId;
    if (!courseId) return;
    closeArchiveConfirmModal();
    const body = new URLSearchParams();
    body.append('action', 'archive');
    body.append('courseId', courseId);
    fetch(CTX + '/archive-course', { method: 'POST', body: body })
        .then(r => r.json())
        .then(d => {
            if (d.status === 'success') {
                location.reload();
            } else {
                alert('Archive failed: ' + (d.message || 'Error occurred'));
            }
        })
        .catch(() => alert('Connection error occurred!'));
}

function openAddToListModal(courseId, courseTitle) {
    activeCourse = courseId ? { id: courseId, name: courseTitle } : null;
    document.getElementById('modalEditListId').value = '';
    const modal = document.getElementById('addToListModal');

    if (modal) {
        if (myListsData.length === 0) {
            document.getElementById('modalTitleHeading').innerText = "Create New List";
            document.getElementById('btnSaveListSubmit').innerText = "Create List";
            document.getElementById('createListForm').onsubmit = submitCreateList;
            showCreateListFormView();
        } else {
            showSelectListGroupView();
        }
        modal.classList.add('show');
    }
}

function showSelectListGroupView() {
    document.getElementById('modalTitleHeading').innerText = "Add to List";
    document.getElementById('viewSelectList').style.display = 'block';
    document.getElementById('createListForm').style.display = 'none';

    const container = document.getElementById('existingListsContainer');
    let html = '';

    myListsData.forEach(function (list) {
        const isAlreadyInList = activeCourse && list.courses.some(function (c) { return String(c.id) === String(activeCourse.id); });
        const actionBtn = isAlreadyInList
            ? '<span class="badge bg-success">Added</span>'
            : '<button type="button" class="btn btn-sm btn-primary" onclick="addCourseToExistingList(' + list.id + ')">Add</button>';

        html += '<div class="d-flex justify-content-between align-items-center p-2 border-bottom">' +
            '<div><strong>' + list.title + '</strong></div>' +
            actionBtn +
            '</div>';
    });

    container.innerHTML = html;
}

function showCreateListFormView() {
    document.getElementById('viewSelectList').style.display = 'none';
    document.getElementById('createListForm').style.display = 'block';
    document.getElementById('createListForm').reset();

    if (activeCourse) {
        document.getElementById('modalCourseId').value = activeCourse.id;
        document.getElementById('modalCourseTitle').value = activeCourse.name;
        document.getElementById('createListForm').onsubmit = submitCreateList;
    } else {
        document.getElementById('modalCourseId').value = '';
        document.getElementById('modalCourseTitle').value = '';
    }
}

function closeAddToListModal() {
    const modal = document.getElementById('addToListModal');
    if (modal) modal.classList.remove('show');
}

function submitCreateList(event) {
    event.preventDefault();
    const title = document.getElementById('listTitleInput').value.trim();
    const description = document.getElementById('listDescInput').value.trim();
    const courseId = document.getElementById('modalCourseId').value;

    if (!title) {
        alert('Please enter a list name.');
        return;
    }

    const params = { action: 'create', title: title, description: description };
    if (courseId) {
        params.courseId = courseId;
    }

    sendAjaxRequest(params)
    .then(data => {
        if (data.status === 'success') {
            closeAddToListModal();
            reloadPreservingTab();
        } else {
            alert('Create failed: ' + (data.message || 'Error occurred'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Connection error occurred!');
    });
}

function addCourseToExistingList(listId) {
    if (!activeCourse) return;
    sendAjaxRequest({ action: 'addCourse', listId: listId, courseId: activeCourse.id })
        .then(data => {
            if (data.status === 'success') {
                closeAddToListModal();
                reloadPreservingTab();
            } else {
                alert('Add course failed: ' + (data.message || 'Error occurred'));
            }
        })
        .catch(() => alert('Connection error occurred!'));
}

function populateCategoryFilter() {
    const categories = new Set();
    document.querySelectorAll('#courseGrid .course-card').forEach(function (card) {
        const category = card.getAttribute('data-category');
        if (category) categories.add(category);
    });

    const select = document.getElementById('filterCategory');
    categories.forEach(function (category) {
        const option = document.createElement('option');
        option.value = category;
        option.textContent = category;
        select.appendChild(option);
    });
}

<<<<<<< HEAD
function filterCourses() {
    const keyword = document.getElementById('courseSearchInput').value.toLowerCase();
=======
function executeSearch() {
    const inputElem = document.getElementById('courseSearchInput');
    if (inputElem) {
        inputElem.value = inputElem.value.trim().replace(/\s+/g, ' ');
    }
    filterCourses();
}

function filterCourses() {
    const rawSearch = document.getElementById('courseSearchInput').value || '';
    // Trim leading/trailing whitespace and collapse consecutive middle spaces
    const cleanedKeyword = rawSearch.trim().replace(/\s+/g, ' ').toLowerCase();
>>>>>>> main
    const progressFilter = document.getElementById('filterProgress').value;
    const categoryFilter = document.getElementById('filterCategory').value;
    const sortBy = document.getElementById('sortBy').value;

    const cards = Array.from(document.querySelectorAll('#courseGrid .course-card'));

    cards.forEach(function (card) {
<<<<<<< HEAD
        const title = card.getAttribute('data-title').toLowerCase();
        const progress = parseInt(card.getAttribute('data-progress'), 10) || 0;
        const category = card.getAttribute('data-category') || '';

        const matchesKeyword = title.includes(keyword);
=======
        const rawTitle = card.getAttribute('data-title') || '';
        const title = rawTitle.trim().replace(/\s+/g, ' ').toLowerCase();
        const progress = parseInt(card.getAttribute('data-progress'), 10) || 0;
        const category = card.getAttribute('data-category') || '';

        const matchesKeyword = !cleanedKeyword || title.includes(cleanedKeyword);
>>>>>>> main
        const matchesProgress = progressFilter === 'all'
            || (progressFilter === 'not-started' && progress === 0)
            || (progressFilter === 'in-progress' && progress > 0 && progress < 100)
            || (progressFilter === 'completed' && progress >= 100);
        const matchesCategory = categoryFilter === 'all' || category === categoryFilter;

        card.style.display = (matchesKeyword && matchesProgress && matchesCategory) ? 'block' : 'none';
    });

    const visibleCards = cards.filter(function (card) {
        return card.style.display !== 'none';
    });

    if (sortBy === 'title-asc') {
        visibleCards.sort(function (a, b) {
            return a.getAttribute('data-title').localeCompare(b.getAttribute('data-title'), undefined, { numeric: true, sensitivity: 'base' });
        });
    } else if (sortBy === 'title-desc') {
        visibleCards.sort(function (a, b) {
            return b.getAttribute('data-title').localeCompare(a.getAttribute('data-title'), undefined, { numeric: true, sensitivity: 'base' });
        });
    }

    const grid = document.getElementById('courseGrid');
    visibleCards.forEach(function (card) {
        grid.appendChild(card);
    });

    document.getElementById('noResults').style.display = visibleCards.length === 0 ? 'block' : 'none';
}

populateCategoryFilter();
filterCourses();