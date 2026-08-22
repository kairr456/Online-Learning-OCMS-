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
                if (name == null || name.trim().isEmpty()) {
                    session.setAttribute("errorMsg", "Tên nhóm câu hỏi không được để trống!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
                    return;
                }
                
                String trimmedName = name.trim();
                if (groupDAO.checkGroupNameExists(courseId, trimmedName)) {
                    session.setAttribute("errorMsg", "Tên nhóm câu hỏi \"" + trimmedName + "\" đã tồn tại trong khóa học này!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
                    return;
                }

                groupDAO.createGroup(courseId, trimmedName);
                session.setAttribute("successMsg", "Tạo nhóm câu hỏi thành công!");
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
            } 
            else if ("delete_group".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                groupDAO.deleteGroup(groupId);
                session.setAttribute("successMsg", "Đã xóa nhóm câu hỏi thành công!");
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
            }
            else if ("add_question".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                String text = request.getParameter("questionText");
                String pointsStr = request.getParameter("points");
                
                if (text == null || text.trim().isEmpty()) {
                    session.setAttribute("errorMsg", "Nội dung câu hỏi không được để trống!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
                    return;
                }
                
                String trimmedText = text.trim();
                // Check trùng câu hỏi trong cùng 1 group
                if (quizDAO.checkQuestionExistsInGroup(groupId, trimmedText)) {
                    session.setAttribute("errorMsg", "Câu hỏi \"" + trimmedText + "\" đã tồn tại trong nhóm này! Vui lòng không tạo trùng câu hỏi.");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
                    return;
                }

                int points = 1;
                try {
                    if (pointsStr != null && !pointsStr.trim().isEmpty()) {
                        points = Integer.parseInt(pointsStr.trim());
                        if (points < 1) points = 1;
                    }
                } catch (NumberFormatException e) {
                    points = 1;
                }

                // Check trùng câu trả lời và tính hợp lệ của answers
                String[] answers = request.getParameterValues("answers");
                String[] correctAnswers = request.getParameterValues("correctAnswers");
                
                java.util.Set<Integer> correctIndices = new java.util.HashSet<>();
                if (correctAnswers != null) {
                    for (String ca : correctAnswers) {
                        try {
                            correctIndices.add(Integer.parseInt(ca.trim()));
                        } catch (NumberFormatException ignored) {}
                    }
                }
                String singleCorrectStr = request.getParameter("correctAnswer");
                if (singleCorrectStr != null && !singleCorrectStr.trim().isEmpty()) {
                    try {
                        correctIndices.add(Integer.parseInt(singleCorrectStr.trim()));
                    } catch (NumberFormatException ignored) {}
                }

                int filledCount = 0;
                java.util.Set<String> uniqueAnswers = new java.util.HashSet<>();
                boolean hasValidCorrect = false;

                if (answers != null) {
                    for (int i = 0; i < answers.length; i++) {
                        if (answers[i] != null && !answers[i].trim().isEmpty()) {
                            String trimmedAns = answers[i].trim();
                            if (!uniqueAnswers.add(trimmedAns.toLowerCase())) {
                                session.setAttribute("errorMsg", "Các phương án trả lời không được trùng lặp nội dung: \"" + trimmedAns + "\"!");
                                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
                                return;
                            }
                            filledCount++;
                            if (correctIndices.contains(i)) {
                                hasValidCorrect = true;
                            }
                        }
                    }
                }

                if (filledCount < 2) {
                    session.setAttribute("errorMsg", "Vui lòng nhập ít nhất 2 phương án trả lời khác nhau!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
                    return;
                }

                if (!hasValidCorrect) {
                    session.setAttribute("errorMsg", "Vui lòng chọn ít nhất 1 đáp án đúng từ các phương án đã nhập!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
                    return;
                }

                int qid = quizDAO.insertQuestion(courseId, groupId, trimmedText, points);
                
                if (answers != null && qid > 0) {
                    for (int i = 0; i < answers.length; i++) {
                        if (answers[i] != null && !answers[i].trim().isEmpty()) {
                            boolean isCorrect = correctIndices.contains(i);
                            quizDAO.insertQuizAnswer(qid, answers[i].trim(), isCorrect, i + 1);
                        }
                    }
                }

                session.setAttribute("successMsg", "Thêm câu hỏi mới vào nhóm thành công!");
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
            }
            else if ("delete_question".equals(action)) {
                int questionId = Integer.parseInt(request.getParameter("questionId"));
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                quizDAO.deleteQuestion(questionId);
                session.setAttribute("successMsg", "Đã xóa câu hỏi thành công!");
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Đã xảy ra lỗi khi xử lý: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&error=1");
        }
    }
}

