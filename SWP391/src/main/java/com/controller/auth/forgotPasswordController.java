package com.controller.auth;

import com.DAO.AccountDAO;
import com.entity.Account;
import com.utils.OTPService;
import com.utils.PasswordUtil;
import com.validator.registerValidator;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// One controller, four routes -- same "share a class instead of duplicating
// session/redirect boilerplate" pattern as LoginController (login/logout)
// and ProfileController. The page itself has only ONE visible button
// ("Validate" / "Change"), so which of the three POST actions actually
// ran is tracked with session state (fpOtpEmail, fpOtpVerified) rather than
// separate buttons -- see forgot-password.jsp for how the same button
// re-labels itself as the user moves through the steps.
@WebServlet(name = "ForgotPasswordController", urlPatterns = {
    "/forgot-password", "/forgot-password/send-otp", "/forgot-password/verify-otp", "/forgot-password/reset"
})
public class forgotPasswordController extends HttpServlet {

    private static final String FORGOT_PAGE = "/view/authen/forgot-password.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Fixes the previously-dangling "Forgot password" link on login.jsp,
        // which already pointed at "/forgot-password" with nothing mapped there.
        request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String path = request.getServletPath();

        if ("/forgot-password/verify-otp".equals(path)) {
            handleVerifyOtp(request, response, session);
        } else if ("/forgot-password/reset".equals(path)) {
            handleReset(request, response, session);
        } else {
            handleSendOtp(request, response, session);
        }
    }

    // =========================================================
    // Step 1 (and "Resend OTP"): email -> send code
    // =========================================================
    private void handleSendOtp(HttpServletRequest request, HttpServletResponse response,
                                HttpSession session)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty() || !registerValidator.isValidEmail(email)) {
            request.setAttribute("errorMessage", "Please enter a valid email address.");
            request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
            return;
        }

        email = email.trim().toLowerCase();

        // Deliberately specific ("No account found...") rather than a vague
        // generic message -- fine for a class project; a production app
        // would usually show the same message either way to avoid leaking
        // which emails are registered.
        if (new AccountDAO().findByEmail(email) == null) {
            request.setAttribute("errorMessage", "No account found with that email.");
            request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
            return;
        }

        String otp = OTPService.generateOtp();
        String referenceCode = OTPService.generateReferenceCode();

        try {
            OTPService.sendOtpEmail(email, otp, referenceCode);
        } catch (MessagingException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Could not send the verification email. Please try again.");
            request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
            return;
        }

        session.setAttribute("fpOtp", otp);
        session.setAttribute("fpOtpEmail", email);
        session.setAttribute("fpReference", referenceCode);
        session.setAttribute("fpOtpExpiresAt", System.currentTimeMillis() + OTPService.OTP_VALID_MILLIS);
        session.removeAttribute("fpOtpVerified"); // starting a new code invalidates any prior verified state

        request.setAttribute("successMessage", "OTP sent to " + email + ".");
        request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
    }

    // =========================================================
    // Step 2: OTP -> "Validate"
    // =========================================================
    private void handleVerifyOtp(HttpServletRequest request, HttpServletResponse response,
                                  HttpSession session)
            throws ServletException, IOException {

        String submittedOtp = request.getParameter("otp");

        String pendingOtp = (String) session.getAttribute("fpOtp");
        String pendingEmail = (String) session.getAttribute("fpOtpEmail");
        Long expiresAt = (Long) session.getAttribute("fpOtpExpiresAt");

        String error = null;
        if (pendingOtp == null || pendingEmail == null || expiresAt == null) {
            error = "No pending request found. Please enter your email again.";
        } else if (System.currentTimeMillis() > expiresAt) {
            error = "This OTP has expired. Please request a new one.";
        } else if (submittedOtp == null || !submittedOtp.trim().equals(pendingOtp)) {
            error = "Incorrect OTP. Please try again.";
        }

        if (error != null) {
            request.setAttribute("errorMessage", error);
            request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
            return;
        }

        session.setAttribute("fpOtpVerified", true);
        request.setAttribute("successMessage", "Verified. Please set a new password.");
        request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
    }

    // =========================================================
    // Step 3: new password -> "Change"
    // =========================================================
    private void handleReset(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session)
            throws ServletException, IOException {

        boolean verified = Boolean.TRUE.equals(session.getAttribute("fpOtpVerified"));
        String email = (String) session.getAttribute("fpOtpEmail");

        if (!verified || email == null) {
            request.setAttribute("errorMessage", "Please verify your OTP first.");
            request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
            return;
        }

        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Same length/match rule used at registration and profile password
        // changes (registerValidator.PASSWORD_MIN_LENGTH/MAX_LENGTH).
        String validationError = registerValidator.validatePasswordChange(password, confirmPassword);
        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
            return;
        }

        Account account = new AccountDAO().findByEmail(email);
        if (account == null) {
            // Account was deleted mid-flow -- unlikely, but don't NPE on it.
            clearForgotPasswordSession(session);
            request.setAttribute("errorMessage", "Something went wrong. Please start over.");
            request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
            return;
        }

        String hashedPassword = PasswordUtil.md5(password);
        boolean updated = new AccountDAO().updatePassword(account.getId(), hashedPassword);

        clearForgotPasswordSession(session);

        if (updated) {
            response.sendRedirect(request.getContextPath() + "/login?passwordReset=true");
        } else {
            request.setAttribute("errorMessage", "Could not update your password. Please try again.");
            request.getRequestDispatcher(FORGOT_PAGE).forward(request, response);
        }
    }

    private void clearForgotPasswordSession(HttpSession session) {
        session.removeAttribute("fpOtp");
        session.removeAttribute("fpOtpEmail");
        session.removeAttribute("fpReference");
        session.removeAttribute("fpOtpExpiresAt");
        session.removeAttribute("fpOtpVerified");
    }
}