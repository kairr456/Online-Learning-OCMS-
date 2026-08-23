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

import java.io.IOException;

@WebServlet("/register")
public class RegisterController extends HttpServlet {

    // Connection details were removed from here on purpose -- AccountDAO
    // extends DBContext, which already knows how to open a MySQL connection
    // (the same one login() uses). Duplicating separate SQL Server config
    // here was the root cause of the connection error that led to the 404.


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.getRequestDispatcher("/view/authen/register.jsp")
                .forward(request, response);
    }


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");


        // =====================================================
        // Get form data
        // =====================================================

        String username =
                request.getParameter("username");

        String password =
                request.getParameter("password");

        String confirmPassword =
                request.getParameter("confirmPassword");

        String email =
                request.getParameter("email");

        String phone =
                request.getParameter("phone");

        String fullName =
                request.getParameter("fullName");

        String role =
                request.getParameter("role");

        String gender =
                request.getParameter("gender");


        // =====================================================
        // Validate form fields
        // =====================================================
        // All the field-level rules (required, length limits, email/phone
        // format, role validity, etc.) now live in RegisterValidator --
        // edit the constants/regex there rather than here.

        String validationError = registerValidator.validate(
                username, password, confirmPassword, email, phone, fullName, role, gender
        );

        if (validationError != null) {

            request.setAttribute("errorMessage", validationError);

            request.getRequestDispatcher("/view/authen/register.jsp")
                    .forward(request, response);

            return;
        }

        int roleId = registerValidator.roleIdFor(role);
        boolean genderValue = registerValidator.genderValueFor(gender);

        // Normalize inputs for consistent checks
        username = username.trim();
        email = email.trim().toLowerCase();
        phone = phone.trim();
        fullName = fullName.trim();


        // =====================================================
        // HASH PASSWORD (MD5)
        // =====================================================

        String hashedPassword = PasswordUtil.md5(password);


        // =====================================================
        // Create Account object
        // =====================================================

        Account account = new Account();

        account.setUsername(username.trim());

        // Store HASH instead of original password
        account.setPassword(hashedPassword);

        account.setEmail(email.trim());
        account.setPhone(phone.trim());
        account.setFullName(fullName.trim());

        account.setGender(genderValue);

        account.setAvatar(null);

        account.setRoleId(roleId);


        // =====================================================
        // Database
        // =====================================================
        // Each check below uses its own `new AccountDAO()`. DBContext closes
        // its connection at the end of every DAO call (see closeResources()),
        // so reusing a single AccountDAO instance across isUsernameExists,
        // isEmailExists, and register would fail on the second call -- the
        // connection would already be closed.

        try {

            // =================================================
            // Check username
            // =================================================

            if (new AccountDAO().isUsernameExists(username)) {

                request.setAttribute(
                        "errorMessage",
                        "Username already exists."
                );

                request.getRequestDispatcher(
                        "/view/authen/register.jsp"
                ).forward(request, response);

                return;
            }


            // =================================================
            // Check email
            // =================================================

            if (new AccountDAO().isEmailExists(email)) {

                request.setAttribute(
                        "errorMessage",
                        "Email already exists."
                );

                request.getRequestDispatcher(
                        "/view/authen/register.jsp"
                ).forward(request, response);

                return;
            }


            // =================================================
            // Insert account
            // =================================================

            boolean success;
            boolean isTeacher = "teacher".equalsIgnoreCase(role);

            if (isTeacher) {
                // Teacher: save with is_active = false, redirect to step 2
                account.setActive(false);
                success = new AccountDAO().registerPendingTeacher(account);
                if (success) {
                    response.sendRedirect(
                            request.getContextPath() + "/teacher-register-step2?accountId=" + account.getId()
                    );
                    return;
                }
            } else {
                // Student: normal flow, active immediately
                account.setActive(true);
                success = new AccountDAO().register(account);
            }

            if (success) {

                // Registration is complete and the account is active -- send
                // them to log in with their new credentials. Using
                // sendRedirect (not forward) so this is a fresh request/new
                // page load rather than reusing the POST's request object.
                response.sendRedirect(
                        request.getContextPath() + "/login?registered=true"
                );

            } else {
                request.setAttribute(
                        "errorMessage",
                        "Registration failed."
                );

                request.getRequestDispatcher(
                        "/view/authen/register.jsp"
                ).forward(request, response);
            }

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "Database error: " + e.getMessage()
            );

            request.getRequestDispatcher(
                    "/view/authen/register.jsp"
            ).forward(request, response);
        }
    }
}