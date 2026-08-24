/**
 * ============================================================================
 * OCMS - Course Details Client Logic (course-details.js)
 * ============================================================================
 */

(function () {
    'use strict';

    /**
     * Handle interactive 5-star rating selection in review form
     */
    function initRatingSelection() {
        var ratingLabels = document.querySelectorAll('.rating-selection label');
        var stars = document.querySelectorAll('.rating-selection .rating-star');

        if (!ratingLabels.length || !stars.length) return;

        function updateStars(selectedIndex) {
            stars.forEach(function (star, i) {
                if (i <= selectedIndex) {
                    star.classList.remove('far');
                    star.classList.add('fas');
                } else {
                    star.classList.remove('fas');
                    star.classList.add('far');
                }
            });
        }

        ratingLabels.forEach(function (label, index) {
            label.addEventListener('click', function () {
                var radio = label.querySelector('input[type="radio"]');
                if (radio) {
                    radio.checked = true;
                }
                updateStars(index);
            });

            label.addEventListener('mouseenter', function () {
                updateStars(index);
            });
        });

        var ratingContainer = document.querySelector('.rating-selection');
        if (ratingContainer) {
            ratingContainer.addEventListener('mouseleave', function () {
                var checkedRadio = ratingContainer.querySelector('input[type="radio"]:checked');
                if (checkedRadio) {
                    var val = parseInt(checkedRadio.value, 10);
                    updateStars(val - 1);
                } else {
                    stars.forEach(function (s) {
                        s.classList.remove('fas');
                        s.classList.add('far');
                    });
                }
            });
        }
    }

    /**
     * Toggle course in user's wishlist via AJAX
     * @param {HTMLElement} btn
     */
    window.toggleWishlist = function (btn) {
        if (!btn) return;
        var courseId = btn.getAttribute('data-course-id');
        var ctx = btn.getAttribute('data-context-path') || '';

        fetch(ctx + '/wishlist', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: new URLSearchParams({
                action: 'toggle',
                courseId: courseId
            })
        })
        .then(function (res) {
            if (res.status === 401) {
                window.location.href = ctx + '/view/authen/login.jsp';
                throw new Error('Unauthorized');
            }
            return res.json();
        })
        .then(function (data) {
            if (data.status === 'success') {
                btn.classList.toggle('active');
                var icon = btn.querySelector('i');
                if (icon) {
                    if (btn.classList.contains('active')) {
                        icon.classList.remove('fa-regular');
                        icon.classList.add('fa-solid');
                    } else {
                        icon.classList.remove('fa-solid');
                        icon.classList.add('fa-regular');
                    }
                }
            }
        })
        .catch(function (err) {
            console.error('Wishlist toggle error:', err);
        });
    };

    /**
     * Alert for locked lessons
     */
    window.handleLockedLesson = function () {
        alert('Bạn chưa mua khóa học này! Vui lòng mua để xem toàn bộ bài giảng.');
    };

    /**
     * Smooth scroll back to top
     */
    window.scrollToTop = function () {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    /**
     * Initialize upon DOM load
     */
    document.addEventListener('DOMContentLoaded', function () {
        initRatingSelection();
    });
})();
