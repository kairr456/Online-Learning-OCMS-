<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Reusable JS include fragment for the home/public-facing layout --%>

<%-- jQuery --%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<%-- Bootstrap 5 Bundle (includes Popper) --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<%-- Swiper --%>
<script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>

<%-- WOW.js for scroll animations --%>
<script src="https://cdnjs.cloudflare.com/ajax/libs/wow/1.1.2/wow.min.js"></script>

<%-- Initialize WOW --%>
<script>
    if (typeof WOW !== 'undefined') {
        new WOW().init();
    }

    // Sticky header behaviour
    window.addEventListener('scroll', function () {
        var sticky = document.getElementById('sticky-header');
        if (sticky) {
            if (window.scrollY > 80) {
                sticky.classList.add('sticky-menu');
            } else {
                sticky.classList.remove('sticky-menu');
            }
        }
    });

    // Scroll-to-top button
    var scrollTop = document.querySelector('.scroll__top');
    if (scrollTop) {
        window.addEventListener('scroll', function () {
            if (window.scrollY > 300) {
                scrollTop.style.display = 'block';
            } else {
                scrollTop.style.display = 'none';
            }
        });
        scrollTop.addEventListener('click', function () {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }
</script>
