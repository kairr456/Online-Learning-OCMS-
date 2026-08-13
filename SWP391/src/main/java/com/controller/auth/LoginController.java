package com.controller.auth;

import com.DAO.AccountDAO;
import com.entity.Account;
import com.utils.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import jakarta.servlet.http.Cookie;


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
            HttpSession session = request.getSession(false);
            boolean hasRememberMeCookie = hasRememberMeCookie(request);

            // If the user checked Remember Me, keep the login cookie but clear the
            // active account from the current HTTP session instead of invalidating it.
            if (session != null) {
                session.removeAttribute("currentAccount");
                if (!hasRememberMeCookie) {
                    session.invalidate();
                }
            }

            // Preserve the Remember Me username so the login form can repopulate it.
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("rememberedUsername".equals(cookie.getName())) {
                        Cookie rememberCookie = new Cookie(
                                "rememberedUsername",
                                cookie.getValue()
                        );
                        rememberCookie.setMaxAge(30 * 24 * 60 * 60);
                        rememberCookie.setPath(
                                request.getContextPath().isEmpty()
                                        ? "/"
                                        : request.getContextPath()
                        );
                        response.addCookie(rememberCookie);
                        break;
                    }
                }
            }

            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // --- "/login" via GET: show the login form and restore remembered username ---
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("rememberedUsername".equals(cookie.getName())
                        && cookie.getValue() != null
                        && !cookie.getValue().isEmpty()) {
                    request.setAttribute("rememberedUsername", cookie.getValue());
                    request.setAttribute("rememberChecked", true);
                    break;
                }
            }
        }
        request.getRequestDispatcher("/view/authen/login.jsp").forward(request, response);
    }

    private boolean hasRememberMeCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return false;
        }

        for (Cookie cookie : cookies) {
            if ("rememberedUsername".equals(cookie.getName()) && cookie.getValue() != null && !cookie.getValue().isEmpty()) {
                return true;
            }
        }
        return false;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve form data
        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        boolean rememberMe =
        request.getParameter("remember") != null;
        // Accounts created through RegisterController store an MD5 hash
        // (see PasswordUtil.md5), so we hash what was typed and compare
        // against that first.
        String hashedPass = PasswordUtil.md5(pass);
        Account account = new AccountDAO().login(user, hashedPass);

        if (account == null) {
            // Fallback: some accounts (e.g. seeded/legacy test data) may
            // still have a plain-text password column instead of a hash.
            // Rather than break login for those, we also try the raw
            // password the user typed before giving up. This intentionally
            // keeps the old unhashed check working alongside the new
            // hashed one -- remove this fallback once all accounts in the
            // database are confirmed to be hashed.
            account = new AccountDAO().login(user, pass);
        }
        
        if (account != null) {
            // Login successful: Create session
            HttpSession session = request.getSession();
            session.setAttribute("currentAccount", account);
            // =========================================================
            // Remember Me
            // =========================================================
            Cookie rememberCookie;
            if (rememberMe) {
                rememberCookie = new Cookie(
                        "rememberedUsername",
                        user
                );
                // Remember username for 30 days
                rememberCookie.setMaxAge(30 * 24 * 60 * 60);
            } else {
                // Delete existing remembered username
                rememberCookie = new Cookie(
                        "rememberedUsername",
                        ""
                );
                rememberCookie.setMaxAge(0);
            }
            rememberCookie.setPath(
                    request.getContextPath().isEmpty()
                            ? "/"
                            : request.getContextPath()
            );
            response.addCookie(rememberCookie);

            String contextPath = request.getContextPath();
            int roleId = account.getRoleId();

            if (roleId == 1) {
                // Admin -> dashboard
                response.sendRedirect(contextPath + "/admin/dashboard");
            } else if (roleId == 2 || roleId == 3) {
                // Teacher or Student -> homepage
                response.sendRedirect(contextPath + "/view/common/home/homepage.jsp");
            } else {
                // Unrecognized role: fall back to homepage rather than dead-end
                response.sendRedirect(contextPath + "/view/common/home/homepage.jsp");
            }
        } else {
            // Login failed: Set error message and forward back to login page
            request.setAttribute("errorMessage", "Invalid username or password!");
           // --- "/login" via GET: load remembered username ---
    // --- "/login" via GET ---
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("rememberedUsername".equals(cookie.getName())) {
                        request.setAttribute(
                                "rememberedUsername",
                                cookie.getValue()
                        );
                        break;
                    }
                }
            }
request.getRequestDispatcher(
        "/view/authen/login.jsp"
).forward(request, response);
        }
    }
}