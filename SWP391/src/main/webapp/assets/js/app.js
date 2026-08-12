// OCMS — shared front-end behavior

document.addEventListener('DOMContentLoaded', function () {

  // --- Login page: toggle password visibility, if the control exists ---
  var toggle = document.querySelector('[data-toggle-password]');
  var passwordField = document.getElementById('password');

  if (toggle && passwordField) {
    toggle.addEventListener('click', function () {
      var isHidden = passwordField.type === 'password';
      passwordField.type = isHidden ? 'text' : 'password';
      toggle.setAttribute('aria-pressed', String(isHidden));
      toggle.setAttribute('aria-label', isHidden ? 'Hide password' : 'Show password');
    });
  }

  // --- Login page: focus the first empty field on load ---
  var loginForm = document.getElementById('loginForm');
  if (loginForm) {
    var username = document.getElementById('username');
    if (username && !username.value) {
      username.focus();
    }
  }

  // --- Dashboard: active nav link highlighting based on data-page ---
  var activeLink = document.querySelector('.nav-link.is-active');
  if (activeLink) {
    activeLink.setAttribute('aria-current', 'page');
  }

});
