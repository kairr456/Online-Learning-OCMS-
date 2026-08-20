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
