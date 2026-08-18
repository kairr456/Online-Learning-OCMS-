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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "QuizResultsController", urlPatterns = {"/quiz-results"})
public class QuizResultsController extends HttpServlet {

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
        if (quizIdStr == null || quizIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/dashboard-quiz");
            return;
        }

        int quizId = Integer.parseInt(quizIdStr);
        QuizDAO quizDAO = new QuizDAO();
        
        Map<String, Object> quizInfo = quizDAO.getLessonQuizById(quizId);
        
        if (quizInfo == null) {
            response.sendRedirect(request.getContextPath() + "/dashboard-quiz");
            return;
        }

        List<Map<String, Object>> attempts = quizDAO.getAttemptsByQuizId(quizId);
        List<Map<String, Object>> questions = quizDAO.getQuestionsByQuizId(quizId);
        
        request.setAttribute("quizInfo", quizInfo);
        request.setAttribute("attempts", attempts);
        request.setAttribute("questions", questions);

        String attemptIdStr = request.getParameter("attemptId");
        if (attemptIdStr != null && !attemptIdStr.isEmpty()) {
            int attemptId = Integer.parseInt(attemptIdStr);
            List<Map<String, Object>> attemptAnswers = quizDAO.getAttemptAnswers(attemptId);
            
            // map questionId -> user's answer mapping
            Map<Integer, Map<String, Object>> userAnswersMap = new HashMap<>();
            for (Map<String, Object> ans : attemptAnswers) {
                userAnswersMap.put((Integer) ans.get("question_id"), ans);
            }
            request.setAttribute("userAnswersMap", userAnswersMap);
            request.setAttribute("selectedAttemptId", attemptId);
        }
        
        request.getRequestDispatcher("/view/courseCRUD/quiz-results.jsp").forward(request, response);
    }
}
