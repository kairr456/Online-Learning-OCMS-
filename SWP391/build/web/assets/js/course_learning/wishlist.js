// Wishlist page (view/course_learning/wishlist.jsp)
const CTX = document.body.getAttribute('data-ctx') || '';

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

function filterCourses() {
    const rawSearch = document.getElementById('courseSearchInput').value || '';
    const cleanedKeyword = rawSearch.trim().replace(/\s+/g, ' ').toLowerCase();
    const categoryFilter = document.getElementById('filterCategory').value;
    const sortBy = document.getElementById('sortBy').value;

    const cards = Array.from(document.querySelectorAll('#courseGrid .course-card'));

    cards.forEach(function (card) {
        const rawTitle = card.getAttribute('data-title') || '';
        const title = rawTitle.trim().replace(/\s+/g, ' ').toLowerCase();
        const category = card.getAttribute('data-category') || '';

        const matchesKeyword = !cleanedKeyword || title.includes(cleanedKeyword);
        const matchesCategory = categoryFilter === 'all' || category === categoryFilter;

        card.style.display = (matchesKeyword && matchesCategory) ? 'block' : 'none';
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

function removeFromWishlist(btn) {
    var courseId = btn.getAttribute('data-course-id');
    fetch(CTX + '/wishlist', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: new URLSearchParams({ action: 'remove', courseId: courseId })
    })
    .then(function (res) {
        if (res.status === 401) {
            window.location.href = CTX + '/view/authen/login.jsp';
            throw new Error('Unauthorized');
        }
        return res.json();
    })
    .then(function (data) {
        if (data.status === 'success') {
            var card = document.getElementById('wishlist-card-' + courseId);
            if (card) card.remove();
            if (!document.querySelector('.course-grid .course-card')) {
                window.location.reload();
            }
        }
    })
    .catch(function (err) { console.error('Wishlist error:', err); });
}

populateCategoryFilter();
filterCourses();