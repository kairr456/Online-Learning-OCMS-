package com.controller.auth;

import com.DAO.AccountDAO;
import com.entity.Account;
import com.utils.PasswordUtil;
import com.validator.registerValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Handles both profile-update actions. They share a controller the same way
// LoginController shares "/login" and "/logout" -- getServletPath() tells
// the two routes apart, so one class covers both forms on profile.jsp
// instead of duplicating session-lookup/redirect boilerplate twice.
//
// This is also where the Info-tab update logic that used to live directly
// inside profile.jsp (as a self-posting <% if ("POST"...) %> block) now
// lives -- profile.jsp is back to being just a view.
@WebServlet(name = "ProfileController", urlPatterns = {
    "/profile/info", "/profile/password", "/profile/email"
})
public class ProfileController extends HttpServlet {

    private static final String PROFILE_PAGE = "/view/common/profile.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // These two URLs are POST-only actions, not pages of their own --
        // send anyone who lands here via GET back to the actual profile page.
        response.sendRedirect(request.getContextPath() + PROFILE_PAGE);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // NOTE: session key here is "account" to match what header.jsp
        // currently reads. If LoginController sets "currentAccount" instead
        // on your end, this will always be null -- see the earlier note
        // about reconciling that key.
        HttpSession session = request.getSession(false);
        Account account = (session != null) ? (Account) session.getAttribute("account") : null;

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        if ("/profile/password".equals(path)) {
            handlePasswordUpdate(request, response, session, account);
        } else if ("/profile/email".equals(path)) {
            handleEmailUpdate(request, response, session, account);
        } else {
            handleInfoUpdate(request, response, session, account);
        }
    }

    // =========================================================
    // "/profile/info" -- Full Name, Phone, Gender
    // =========================================================
    private void handleInfoUpdate(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session, Account account)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String genderParam = request.getParameter("gender");

        if (fullName == null || fullName.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || genderParam == null || genderParam.trim().isEmpty()) {

            request.setAttribute("errorMessage", "Please fill in all fields.");
            request.setAttribute("activeTab", "info");
            request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
            return;
        }

        boolean genderValue = registerValidator.genderValueFor(genderParam);
        boolean updated = new AccountDAO().updateBasicInfo(
                account.getId(), fullName.trim(), phone.trim(), genderValue);

        if (updated) {
            // Keep the session copy in sync so the header/dashboard reflect
            // the change immediately, without waiting for the next login.
            account.setFullName(fullName.trim());
            account.setPhone(phone.trim());
            account.setGender(genderValue);
            session.setAttribute("account", account);

            response.sendRedirect(request.getContextPath() + PROFILE_PAGE + "?updated=info");
        } else {
            request.setAttribute("errorMessage", "Could not update your profile. Please try again.");
            request.setAttribute("activeTab", "info");
            request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
        }
    }

    // =========================================================
    // "/profile/password" -- New password + confirm
    // =========================================================
    private void handlePasswordUpdate(HttpServletRequest request, HttpServletResponse response,
                                       HttpSession session, Account account)
            throws ServletException, IOException {

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Same length rules as registration (registerValidator.PASSWORD_MIN_LENGTH/
        // MAX_LENGTH), plus a match check -- see validatePasswordChange().
        String validationError = registerValidator.validatePasswordChange(newPassword, confirmPassword);

        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            request.setAttribute("activeTab", "password");
            request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
            return;
        }

        // Hash with the same utility RegisterController/LoginController use,
        // so the stored value matches what login() will compare against.
        String hashedPassword = PasswordUtil.md5(newPassword);
        boolean updated = new AccountDAO().updatePassword(account.getId(), hashedPassword);
    }
    // =========================================================
    // "/profile/email" -- direct update, no OTP step
    // =========================================================
    private void handleEmailUpdate(HttpServletRequest request, HttpServletResponse response,
                                    HttpSession session, Account account)
            throws ServletException, IOException {

        String newEmail = request.getParameter("newEmail");

        if (newEmail == null || newEmail.trim().isEmpty()
                || !registerValidator.isValidEmail(newEmail)) {
            request.setAttribute("errorMessage", "Please enter a valid email address.");
            request.setAttribute("activeTab", "email");
            request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
            return;
        }

        newEmail = newEmail.trim().toLowerCase();

        if (newEmail.equalsIgnoreCase(account.getEmail())) {
            request.setAttribute("errorMessage", "That's already your current email.");
            request.setAttribute("activeTab", "email");
            request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
            return;
        }

        if (new AccountDAO().isEmailExists(newEmail)) {
            request.setAttribute("errorMessage", "That email is already in use by another account.");
            request.setAttribute("activeTab", "email");
            request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
            return;
        }

        boolean updated = new AccountDAO().updateEmail(account.getId(), newEmail);

        if (updated) {
            account.setEmail(newEmail);
            session.setAttribute("account", account);
            response.sendRedirect(request.getContextPath() + PROFILE_PAGE + "?updated=email");
        } else {
            request.setAttribute("errorMessage", "Could not update your email. Please try again.");
            request.setAttribute("activeTab", "email");
            request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
        }
    }
}