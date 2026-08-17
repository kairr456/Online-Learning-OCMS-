package com.controller.courseCRUD;

import com.DAO.QuizDAO;
import com.entity.Account;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "QuizDeleteController", urlPatterns = {"/quiz-delete"})
public class QuizDeleteController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String quizIdStr = request.getParameter("quizId");
        if (quizIdStr != null && !quizIdStr.isEmpty()) {
            int quizId = Integer.parseInt(quizIdStr);
            QuizDAO quizDAO = new QuizDAO();
            
            boolean success = quizDAO.deleteQuiz(quizId);
            
            if (success) {
                session.setAttribute("message", "Quiz deleted successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Failed to delete quiz.");
                session.setAttribute("messageType", "error");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/dashboard-quiz");
    }
}
