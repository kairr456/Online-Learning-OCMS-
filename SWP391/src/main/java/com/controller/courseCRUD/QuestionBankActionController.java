package com.controller.courseCRUD;

import com.DAO.QuestionGroupDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "QuestionBankActionController", urlPatterns = {"/question-bank-action"})
public class QuestionBankActionController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.getWriter().write("error:unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String courseIdStr = request.getParameter("courseId");
        if (courseIdStr == null) {
            response.getWriter().write("error:missing_course");
            return;
        }
        int courseId = Integer.parseInt(courseIdStr);

        QuestionGroupDAO groupDAO = new QuestionGroupDAO();
        QuizDAO quizDAO = new QuizDAO();

        try {
            if ("add_group".equals(action)) {
                String name = request.getParameter("name");
                groupDAO.createGroup(courseId, name);
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
            } 
            else if ("delete_group".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                groupDAO.deleteGroup(groupId);
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
            }
            else if ("add_question".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                String text = request.getParameter("questionText");
                int points = Integer.parseInt(request.getParameter("points"));
                
                int qid = quizDAO.insertQuestion(courseId, groupId, text, points);
                
                // insert answers
                String[] answers = request.getParameterValues("answers");
                String correctIndexStr = request.getParameter("correctAnswer");
                int correctIndex = (correctIndexStr != null) ? Integer.parseInt(correctIndexStr) : 0;
                
                if (answers != null) {
                    for (int i = 0; i < answers.length; i++) {
                        if (answers[i] != null && !answers[i].trim().isEmpty()) {
                            quizDAO.insertQuizAnswer(qid, answers[i], (i == correctIndex), i+1);
                        }
                    }
                }
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
            }
            else if ("delete_question".equals(action)) {
                int questionId = Integer.parseInt(request.getParameter("questionId"));
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                quizDAO.deleteQuestion(questionId);
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&error=1");
        }
    }
}

