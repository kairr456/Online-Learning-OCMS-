/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.controller.auth;


import com.DAO.AccountDAO;
import com.entity.Account;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;

@WebServlet("/register")
public class RegisterController extends HttpServlet {

    // =========================================================
    // DATABASE CONFIGURATION
    // Change these to your database details
    // =========================================================

    private static final String DB_URL =
            "jdbc:sqlserver://localhost:1433;databaseName=SWP391;encrypt=false";

    private static final String DB_USER =
            "sa";

    private static final String DB_PASSWORD =
            "123456";

    // =========================================================
    // GET
    // Show registration page
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.getRequestDispatcher("/register.jsp")
                .forward(request, response);
    }

    // =========================================================
    // POST
    // Process registration
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // -----------------------------------------------------
        // Get form values
        // -----------------------------------------------------

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


        // -----------------------------------------------------
        // Basic validation
        // -----------------------------------------------------

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || fullName == null || fullName.trim().isEmpty()
                || role == null || role.trim().isEmpty()
                || gender == null || gender.trim().isEmpty()) {

            request.setAttribute(
                    "errorMessage",
                    "Please fill in all required fields."
            );

            request.getRequestDispatcher("/register.jsp")
                    .forward(request, response);

            return;
        }


        // -----------------------------------------------------
        // Check password confirmation
        // -----------------------------------------------------

        if (!password.equals(confirmPassword)) {

            request.setAttribute(
                    "errorMessage",
                    "Passwords do not match."
            );

            request.getRequestDispatcher("/register.jsp")
                    .forward(request, response);

            return;
        }


        // -----------------------------------------------------
        // Convert role
        //
        // Change these IDs to match your Role table.
        // -----------------------------------------------------

        int roleId;

        try {

            if ("teacher".equalsIgnoreCase(role)) {

                roleId = 2;

            } else if ("student".equalsIgnoreCase(role)) {

                roleId = 3;

            } else {

                request.setAttribute(
                        "errorMessage",
                        "Invalid role."
                );

                request.getRequestDispatcher("/register.jsp")
                        .forward(request, response);

                return;
            }

        } catch (Exception e) {

            request.setAttribute(
                    "errorMessage",
                    "Invalid role."
            );

            request.getRequestDispatcher("/register.jsp")
                    .forward(request, response);

            return;
        }


        // -----------------------------------------------------
        // Convert gender
        //
        // true  = male
        // false = female
        //
        // Change this if your database uses another convention.
        // -----------------------------------------------------

        boolean genderValue =
                "male".equalsIgnoreCase(gender);


        // -----------------------------------------------------
        // Create Account object
        // -----------------------------------------------------

        Account account = new Account();

        account.setUsername(username.trim());
        account.setPassword(password);
        account.setEmail(email.trim());
        account.setPhone(phone.trim());
        account.setFullName(fullName.trim());
        account.setGender(genderValue);

        // No avatar during initial registration
        account.setAvatar(null);

        // New account is active
        account.setActive(true);

        account.setRoleId(roleId);


        // -----------------------------------------------------
        // Database operation
        // -----------------------------------------------------

        try {

            Class.forName(
                    "com.microsoft.sqlserver.jdbc.SQLServerDriver"
            );

            try (Connection connection =
                         DriverManager.getConnection(
                                 DB_URL,
                                 DB_USER,
                                 DB_PASSWORD
                         )) {

                AccountDAO accountDAO =
                        new AccountDAO(connection);


                // -------------------------------------------------
                // Check username
                // -------------------------------------------------

                if (accountDAO.isUsernameExists(username)) {

                    request.setAttribute(
                            "errorMessage",
                            "Username already exists."
                    );

                    request.getRequestDispatcher("/register.jsp")
                            .forward(request, response);

                    return;
                }


                // -------------------------------------------------
                // Check email
                // -------------------------------------------------

                if (accountDAO.isEmailExists(email)) {

                    request.setAttribute(
                            "errorMessage",
                            "Email already exists."
                    );

                    request.getRequestDispatcher("/register.jsp")
                            .forward(request, response);

                    return;
                }


                // -------------------------------------------------
                // Insert account
                // -------------------------------------------------

                boolean success =
                        accountDAO.register(account);


                if (success) {

                    // Registration successful
                    response.sendRedirect(
                            request.getContextPath()
                            + "/login"
                    );

                } else {

                    request.setAttribute(
                            "errorMessage",
                            "Registration failed."
                    );

                    request.getRequestDispatcher("/register.jsp")
                            .forward(request, response);
                }
            }

        } catch (ClassNotFoundException e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "Database driver not found."
            );

            request.getRequestDispatcher("/register.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "errorMessage",
                    "Database error: " + e.getMessage()
            );

            request.getRequestDispatcher("/register.jsp")
                    .forward(request, response);
        }
    }
}