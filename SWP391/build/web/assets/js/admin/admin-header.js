// OCMS — admin: common header (view/admin/common/header.jsp)
// Toggle dropdown tài khoản. Tự chứa (không phụ thuộc app.js).
(function () {
    var toggle = document.getElementById('adminHeaderProfileToggle');
    var dropdown = document.getElementById('adminHeaderDropdown');
    var wrap = document.getElementById('adminHeaderProfile');
    if (!toggle || !dropdown || !wrap) return;

    function close() {
        dropdown.classList.remove('is-open');
        toggle.setAttribute('aria-expanded', 'false');
    }

    toggle.addEventListener('click', function (e) {
        e.stopPropagation();
        var willOpen = !dropdown.classList.contains('is-open');
        dropdown.classList.toggle('is-open', willOpen);
        toggle.setAttribute('aria-expanded', String(willOpen));
    });

    document.addEventListener('click', function (e) {
        if (!wrap.contains(e.target)) close();
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') close();
    });
})();