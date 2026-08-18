package com.controller.home;

import com.DAO.CourseRegistrationDAO;
import com.entity.Account;
import com.entity.Registration;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "MyPurchasesController", urlPatterns = {"/my-purchases"})
public class MyPurchasesController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
            return;
        }

        List<Registration> purchases = new CourseRegistrationDAO().getPurchasesByAccountId(account.getId(), 0);
        Map<String, Object> summary = new CourseRegistrationDAO().getPurchaseSummary(account.getId());

        request.setAttribute("purchases", purchases);
        request.setAttribute("summary", summary);

        request.getRequestDispatcher("/view/course_learning/my-purchases.jsp").forward(request, response);
    }
}