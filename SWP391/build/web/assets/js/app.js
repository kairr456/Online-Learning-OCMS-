// OCMS — shared front-end behavior

document.addEventListener('DOMContentLoaded', function () {

  // --- Login page: toggle password visibility, if the control exists ---
  document.querySelectorAll('.login-eye').forEach(function (button) {
    button.addEventListener('click', function () {
      var targetId = button.getAttribute('data-password-target');
      var input = targetId ? document.getElementById(targetId) : null;

      if (!input) return;

      var isHidden = input.type === 'password';
      input.type = isHidden ? 'text' : 'password';
      button.innerHTML = isHidden ? '&#128064;' : '&#128065;';
      button.setAttribute('aria-label', isHidden ? 'Hide password' : 'Show password');
    });
  });

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
