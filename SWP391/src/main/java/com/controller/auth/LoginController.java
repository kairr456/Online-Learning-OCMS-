package com.controller.auth;

import com.DAO.AccountDAO;
import com.entity.Account;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;


// This single servlet now answers two routes: "/login" (show the form / handle
// sign-in) and "/logout" (end the session). They share a controller because
// logout has no view or form of its own -- it's just one action -- so a
// separate servlet class would be more boilerplate than logic.
@WebServlet(name = "LoginController", urlPatterns = {"/login", "/logout"})
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // getServletPath() returns whichever of this servlet's own urlPatterns
        // was matched for this request -- either "/login" or "/logout" -- so
        // we can tell the two routes apart even though one class handles both.
        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            // --- Logout action: no page to show, just end the session ---
            // getSession(false) means "give me the session if one exists,
            // but don't create a new one" -- there's nothing to invalidate
            // if the user was never logged in, so we avoid creating a
            // throwaway session just to immediately kill it.
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate(); // clears currentAccount and everything else tied to this session
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return; // stop here -- don't fall through to the login-page forward below
        }

        // --- "/login" via GET: just show the login form ---
        request.getRequestDispatcher("/view/authen/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve form data
        String user = request.getParameter("username");
        String pass = request.getParameter("password"); 
        
        // Note: Hash the 'pass' here if your database stores hashed passwords
        
        AccountDAO accountDAO = new AccountDAO(new com.DAO.DBContext().getConnection());
        Account account = accountDAO.login(user, pass);
        
        if (account != null) {
            // Login successful: Create session
            HttpSession session = request.getSession();
            session.setAttribute("currentAccount", account);

            String contextPath = request.getContextPath();
            int roleId = account.getRoleId();

            if (roleId == 1) {
                // Admin -> dashboard
                response.sendRedirect(contextPath + "/view/admin/dashboard.jsp");
            } else if (roleId == 2 || roleId == 3) {
                // Teacher or Student -> homepage
                response.sendRedirect(contextPath + "/view/common/homepage.jsp");
            } else {
                // Unrecognized role: fall back to homepage rather than dead-end
                response.sendRedirect(contextPath + "/view/common/homepage.jsp");
            }
        } else {
            // Login failed: Set error message and forward back to login page
            request.setAttribute("errorMessage", "Invalid username or password!");
            request.getRequestDispatcher("/view/authen/login.jsp").forward(request, response);
        }
    }
}