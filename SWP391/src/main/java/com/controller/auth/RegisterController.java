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

    private static final java.util.logging.Logger LOGGER =
            java.util.logging.Logger.getLogger(RegisterController.class.getName());

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("pendingTeacherAccount") != null) {
            Account pending = (Account) session.getAttribute("pendingTeacherAccount");
            if (request.getAttribute("username") == null && pending.getUsername() != null) {
                request.setAttribute("username", pending.getUsername());
            }
            if (request.getAttribute("fullName") == null && pending.getFullName() != null) {
                request.setAttribute("fullName", pending.getFullName());
            }
            if (request.getAttribute("email") == null && pending.getEmail() != null) {
                request.setAttribute("email", pending.getEmail());
            }
            if (request.getAttribute("phone") == null && pending.getPhone() != null) {
                request.setAttribute("phone", pending.getPhone());
            }
            if (request.getAttribute("gender") == null) {
                request.setAttribute("gender", pending.isGender() ? "male" : "female");
            }
            if (request.getAttribute("role") == null) {
                request.setAttribute("role", "teacher");
            }
        }

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

        String validationError = registerValidator.validate(
                username, password, confirmPassword, email, phone, fullName, role, gender
        );

        if (validationError != null) {
            LOGGER.warning("Registration validation failed: " + validationError
                    + " [username=" + username + ", email=" + email + "]");

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
        fullName = fullName.replaceAll("\\s+", " ").trim();


        // =====================================================
        // HASH PASSWORD (MD5)
        // =====================================================

        String hashedPassword = PasswordUtil.md5(password);


        // =====================================================
        // Create Account object
        // =====================================================

        Account account = new Account();

        account.setUsername(username);

        // Store HASH instead of original password
        account.setPassword(hashedPassword);

        account.setEmail(email);
        account.setPhone(phone);
        account.setFullName(fullName);

        account.setGender(genderValue);

        account.setAvatar(null);

        account.setRoleId(roleId);

        boolean isTeacher = "teacher".equalsIgnoreCase(role);

        // =====================================================
        // Database checks & logic
        // =====================================================
        try {

            // Check if this username/email corresponds to an old-flow pending teacher without profile
            if (isTeacher) {
                Account oldPendingTeacher = new AccountDAO().getPendingTeacherWithoutProfile(username, email);
                if (oldPendingTeacher != null) {
                    LOGGER.info("Forwarding existing pending teacher (old flow) to step 2 [id=" + oldPendingTeacher.getId() + "]");
                    response.sendRedirect(
                            request.getContextPath() + "/teacher-register-step2?accountId=" + oldPendingTeacher.getId()
                    );
                    return;
                }
            }

            // =================================================
            // Check username
            // =================================================

            if (new AccountDAO().isUsernameExists(username)) {
                LOGGER.warning("Registration failed: Username already exists [" + username + "]");

                request.setAttribute(
                        "errorMessage",
                        "Tên đăng nhập đã tồn tại trên hệ thống."
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
                LOGGER.warning("Registration failed: Email already exists [" + email + "]");

                request.setAttribute(
                        "errorMessage",
                        "Địa chỉ Email đã tồn tại trên hệ thống."
                );

                request.getRequestDispatcher(
                        "/view/authen/register.jsp"
                ).forward(request, response);

                return;
            }


            // =================================================
            // Save logic
            // =================================================

            if (isTeacher) {
                // Teacher flow: DO NOT save to DB yet; store temporarily in Session
                account.setActive(false);
                request.getSession().setAttribute("pendingTeacherAccount", account);
                response.sendRedirect(
                        request.getContextPath() + "/teacher-register-step2"
                );
                return;
            }

            // Student: normal flow, active immediately
            account.setActive(true);
            boolean success = new AccountDAO().register(account);

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