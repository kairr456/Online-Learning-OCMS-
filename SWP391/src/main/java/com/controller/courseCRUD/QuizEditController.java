package com.controller.courseCRUD;

import com.DAO.CourseDAO;
import com.DAO.LessonDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.Lesson;
import com.entity.Section;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "QuizEditController", urlPatterns = {"/quiz-edit"})
public class QuizEditController extends HttpServlet {

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
        LessonDAO lessonDAO = new LessonDAO();
        CourseDAO courseDAO = new CourseDAO();

        Map<String, Object> quizInfo = quizDAO.getLessonQuizById(quizId);
        if (quizInfo == null) {
            response.sendRedirect(request.getContextPath() + "/dashboard-quiz");
            return;
        }

        int lessonId = (Integer) quizInfo.get("lesson_id");
        Lesson lesson = lessonDAO.getLessonById(lessonId);
        
        List<Map<String, Object>> questions = quizDAO.getQuestionsByQuizId(quizId);
        Map<Integer, List<Map<String, Object>>> questionAnswersMap = new HashMap<>();
        for (Map<String, Object> q : questions) {
            int qId = (Integer) q.get("id");
            questionAnswersMap.put(qId, quizDAO.getAnswersByQuestionId(qId));
        }

        List<Course> courses = courseDAO.findByCreator(account.getId());
        Map<Integer, List<Section>> courseSectionsMap = new HashMap<>();
        for (Course c : courses) {
            courseSectionsMap.put(c.getId(), lessonDAO.getSectionsByCourseId(c.getId()));
        }

        request.setAttribute("courses", courses);
        request.setAttribute("courseSectionsJson", new Gson().toJson(courseSectionsMap));
        request.setAttribute("lesson", lesson);
        request.setAttribute("quizInfo", quizInfo);
        
        Gson gson = new Gson();
        request.setAttribute("questionsJson", gson.toJson(questions));
        request.setAttribute("answersJson", gson.toJson(questionAnswersMap));
        request.setAttribute("isEdit", true);

        request.getRequestDispatcher("/view/courseCRUD/quiz-builder.jsp").forward(request, response);
    }
}
