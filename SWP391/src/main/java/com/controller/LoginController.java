package com.controller;

import com.DAO.AccountDAO;
import com.entity.Account;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet(name = "LoginController", urlPatterns = {"/login"})
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to the login page when the user requests it via GET
        request.getRequestDispatcher("/view/authen/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve form data
        String user = request.getParameter("username");
        String pass = request.getParameter("password"); 
        
        // Note: Hash the 'pass' here if your database stores hashed passwords
        
        AccountDAO accountDAO = new AccountDAO();
        Account account = accountDAO.login(user, pass);
        
        if (account != null) {
            // Login successful: Create session and redirect to homepage or dashboard
            HttpSession session = request.getSession();
            session.setAttribute("currentAccount", account);
            response.sendRedirect("home.jsp"); 
        } else {
            // Login failed: Set error message and forward back to login page
            request.setAttribute("errorMessage", "Invalid username or password!");
            request.getRequestDispatcher("/view/authen/login.jsp").forward(request, response);
        }
    }
}