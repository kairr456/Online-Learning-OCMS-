/**
 * ============================================================================
 * OCMS - Browse Courses Client Logic (browse-course.js)
 * ============================================================================
 */

(function () {
    'use strict';

    /**
     * Submit filter form with updated page number
     * @param {number|string} page
     */
    window.goToPage = function (page) {
        var pageInput = document.getElementById('pageInput');
        var filterForm = document.getElementById('filterForm');
        if (pageInput && filterForm) {
            pageInput.value = page;
            filterForm.submit();
        }
    };

    /**
     * Submit form to add course to shopping cart
     * @param {HTMLElement} btn
     */
    window.submitAddToCart = function (btn) {
        if (!btn) return;
        var courseId = btn.getAttribute('data-course-id');
        var price = btn.getAttribute('data-price');
        var cartCourseId = document.getElementById('cartCourseId');
        var cartPrice = document.getElementById('cartPrice');
        var addToCartForm = document.getElementById('addToCartForm');

        if (cartCourseId && cartPrice && addToCartForm) {
            cartCourseId.value = courseId;
            cartPrice.value = price;
            addToCartForm.submit();
        }
    };

    /**
     * Trigger filter form submission after resetting page to 1
     */
    window.submitFilterResetPage = function () {
        var pageInput = document.getElementById('pageInput');
        var filterForm = document.getElementById('filterForm');
        if (pageInput) {
            pageInput.value = 1;
        }
        if (filterForm) {
            filterForm.submit();
        }
    };

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
            if (!res.ok) {
                throw new Error('Server responded with status ' + res.status);
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
            } else {
                alert(data.message || 'Operation failed.');
            }
        })
        .catch(function (err) {
            console.error('Wishlist error:', err);
            if (!err || err.message !== 'Unauthorized') {
                alert('Wishlist request failed: ' + (err && err.message ? err.message : 'Unknown error'));
            }
        });
    };

    /**
     * Initialize event listeners when DOM is loaded
     */
    document.addEventListener('DOMContentLoaded', function () {
        // Teacher search input enter key handler
        var teacherSearchInput = document.querySelector('input[name="teacherName"]');
        if (teacherSearchInput) {
            teacherSearchInput.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    window.submitFilterResetPage();
                }
            });
        }
    });
})();
