package com.controller.courseCRUD;

import com.DAO.CourseRegistrationDAO;
import com.entity.Account;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "TeacherTransactionsController", urlPatterns = {"/teacher-transactions"})
public class TeacherTransactionsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Map<String, Object>> sales = new CourseRegistrationDAO().countSalesByTeacher(account.getId());
        Map<String, Object> summary = new CourseRegistrationDAO().getSalesSummary(account.getId());

        request.setAttribute("sales", sales);
        request.setAttribute("summary", summary);

        request.getRequestDispatcher("/view/courseCRUD/teacher-transactions.jsp").forward(request, response);
    }
}