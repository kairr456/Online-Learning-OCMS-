package com.controller.home;

import com.DAO.CourseDAO;
import com.DAO.CourseRegistrationDAO;
import com.DAO.LearningDAO;
import com.DAO.LessonDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.Lesson;
import com.entity.Section;
import com.validator.MyLearningValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet(name = "StudentLearningController", urlPatterns = {
    "/student-learning",
    "/lesson-details",
    "/take-quiz",
    "/quiz-result"
})
public class StudentLearningController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/quiz-result".equals(path)) {
            handleQuizResultGet(request, response);
            return;
        }

        String lessonIdParam = request.getParameter("id");
        if (lessonIdParam == null || lessonIdParam.isEmpty()) {
            lessonIdParam = request.getParameter("lessonId");
        }

        if (lessonIdParam != null && !lessonIdParam.trim().isEmpty()) {
            try {
                int lId = Integer.parseInt(lessonIdParam.trim());
                Lesson lesson = new LessonDAO().getLessonById(lId);
                if (lesson != null) {
                    int cId = new LessonDAO().getCourseIdBySectionId(lesson.getSectionId());
                    String quizMode = "/take-quiz".equals(path) ? "&quizMode=take" : "";
                    response.sendRedirect(request.getContextPath() + "/learning?courseId=" + cId + "&lessonId=" + lId + quizMode);
                    return;
                }
            } catch (Exception ignored) {}
        }
        response.sendRedirect(request.getContextPath() + "/all-courses");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        if (action == null) action = "";

        if ("/take-quiz".equals(path) || "submitQuiz".equals(action)) {
            handleTakeQuizPost(request, response);
        } else {
            doGet(request, response);
        }
    }

    // --- 1. LESSON DETAILS (GET) ---
    private void handleLessonDetailsGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String lessonIdParam = request.getParameter("id");
        if (lessonIdParam == null || lessonIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        try {
            int lessonId = Integer.parseInt(lessonIdParam);
            LessonDAO lessonDAO = new LessonDAO();
            Lesson lesson = lessonDAO.getLessonById(lessonId);

            if (lesson == null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            int courseId = lessonDAO.getCourseIdBySectionId(lesson.getSectionId());

            boolean isEnrolled = false;
            Account account = (Account) request.getSession().getAttribute("account");
            if (account != null) {
                CourseDAO courseDAO = new CourseDAO();
                Course course = courseDAO.findById(courseId);
                if (course != null && course.getCreatedBy() == account.getId()) {
                    isEnrolled = true;
                } else {
                    CourseRegistrationDAO regDAO = new CourseRegistrationDAO();
                    List<Course> enrolledCourses = regDAO.getCoursesByAccountId(account.getId());
                    for (Course c : enrolledCourses) {
                        if (c.getId() == courseId) {
                            isEnrolled = true;
                            break;
                        }
                    }
                }
            }

            int firstLessonId = -1;
            List<Section> sections = lessonDAO.getSectionsByCourseId(courseId);
            if (sections != null && !sections.isEmpty()) {
                List<Lesson> firstSectionLessons = lessonDAO.getLessonsBySectionId(sections.get(0).getId());
                if (firstSectionLessons != null && !firstSectionLessons.isEmpty()) {
                    firstLessonId = firstSectionLessons.get(0).getId();
                }
            }

            if (!isEnrolled) {
                response.sendRedirect(request.getContextPath() + "/course?id=" + courseId);
                return;
            }

            String lessonContent = lessonDAO.getLessonText(lessonId);

            if ("video".equals(lesson.getType())) {
                String videoUrl = lessonDAO.getLessonYoutube(lessonId);
                request.setAttribute("videoUrl", videoUrl);
            } else if ("quiz".equals(lesson.getType()) && account != null) {
                QuizDAO quizDAO = new QuizDAO();
                Map<String, Object> lessonQuiz = quizDAO.getLessonQuizByLessonId(lessonId);
                if (lessonQuiz == null) {
                    if (lessonContent != null && lessonContent.startsWith("Quiz ID: ")) {
                        try {
                            int qId = Integer.parseInt(lessonContent.substring(9).trim());
                            lessonQuiz = quizDAO.getLessonQuizById(qId);
                        } catch (Exception ex) {}
                    }
                }

                if (lessonQuiz != null) {
                    int quizId = (Integer) lessonQuiz.get("id");
                    int maxRetakes = (Integer) lessonQuiz.get("max_retakes");
                    int userAttempts = quizDAO.countUserAttemptsForQuiz(account.getId(), quizId);

                    request.setAttribute("maxRetakes", maxRetakes);
                    request.setAttribute("userAttempts", userAttempts);
                }
            }

            request.setAttribute("lesson", lesson);
            request.setAttribute("lessonContent", lessonContent);
            request.setAttribute("courseId", courseId);

            request.getRequestDispatcher("/view/courseCRUD/lesson-details.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/courses");
        }
    }

    // --- 2. TAKE QUIZ (GET) ---
    private void handleTakeQuizGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String lessonIdStr = request.getParameter("lessonId");
        if (lessonIdStr == null || lessonIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int lessonId = Integer.parseInt(lessonIdStr);
            LessonDAO lessonDAO = new LessonDAO();
            Lesson lesson = lessonDAO.getLessonById(lessonId);

            if (lesson == null || !"quiz".equals(lesson.getType())) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            QuizDAO quizDAO = new QuizDAO();
            Map<String, Object> lessonQuiz = quizDAO.getLessonQuizByLessonId(lessonId);
            if (lessonQuiz == null) {
                String textContent = lessonDAO.getLessonText(lessonId);
                if (textContent != null && textContent.startsWith("Quiz ID: ")) {
                    try {
                        int qId = Integer.parseInt(textContent.substring(9).trim());
                        lessonQuiz = quizDAO.getLessonQuizById(qId);

                        if (lessonQuiz != null) {
                            int originalLessonId = (Integer) lessonQuiz.get("lesson_id");
                            Lesson originalLesson = lessonDAO.getLessonById(originalLessonId);
                            if (originalLesson != null) {
                                lesson.setDurationMinutes(originalLesson.getDurationMinutes());
                                lesson.setDescription(originalLesson.getDescription());
                            }
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }

            if (lessonQuiz == null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            int quizId = (Integer) lessonQuiz.get("id");
            int maxRetakes = (Integer) lessonQuiz.get("max_retakes");

            int userAttempts = quizDAO.countUserAttemptsForQuiz(account.getId(), quizId);
            if (userAttempts >= maxRetakes) {
                response.sendRedirect(request.getContextPath() + "/lesson-details?id=" + lessonId + "&error=max_retakes");
                return;
            }

            request.setAttribute("userAttempts", userAttempts);
            request.setAttribute("maxRetakes", maxRetakes);
            List<Map<String, Object>> allQuestions = quizDAO.getQuestionsByQuizId(quizId);
            Collections.shuffle(allQuestions);

            int numToTake = (Integer) lessonQuiz.get("number_of_questions");
            List<Map<String, Object>> questions = allQuestions;
            if (numToTake > 0 && numToTake < allQuestions.size()) {
                questions = allQuestions.subList(0, numToTake);
            }

            StringBuilder servedIds = new StringBuilder();
            for (Map<String, Object> q : questions) {
                if (servedIds.length() > 0) servedIds.append(",");
                servedIds.append(q.get("id"));
            }
            request.setAttribute("servedQuestionIds", servedIds.toString());

            Map<Integer, List<Map<String, Object>>> questionAnswersMap = new HashMap<>();
            Map<Integer, Boolean> questionMultipleChoiceMap = new HashMap<>();
            for (Map<String, Object> q : questions) {
                int qId = (Integer) q.get("id");
                List<Map<String, Object>> answers = quizDAO.getAnswersByQuestionId(qId);
                questionAnswersMap.put(qId, answers);

                int correctCount = 0;
                if (answers != null) {
                    for (Map<String, Object> ans : answers) {
                        Boolean isCorrect = (Boolean) ans.get("is_correct");
                        if (isCorrect != null && isCorrect) {
                            correctCount++;
                        }
                    }
                }
                questionMultipleChoiceMap.put(qId, correctCount > 1);
            }

            request.setAttribute("lesson", lesson);
            request.setAttribute("lessonQuiz", lessonQuiz);
            request.setAttribute("questions", questions);
            request.setAttribute("questionAnswersMap", questionAnswersMap);
            request.setAttribute("questionMultipleChoiceMap", questionMultipleChoiceMap);
            request.setAttribute("courseId", lessonDAO.getCourseIdBySectionId(lesson.getSectionId()));

            request.getRequestDispatcher("/view/course_learning/take-quiz.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/courses");
        }
    }

    // --- 3. TAKE QUIZ (POST) ---
    private void handleTakeQuizPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        try {
            String quizIdParam = request.getParameter("quizId");
            String lessonIdParam = request.getParameter("lessonId");
            String idError = MyLearningValidator.validateQuizId(quizIdParam);
            if (idError == null) {
                idError = MyLearningValidator.validateLessonId(lessonIdParam);
            }
            if (idError != null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"" + idError + "\"}");
                return;
            }
            int quizId = Integer.parseInt(quizIdParam);
            int lessonId = Integer.parseInt(lessonIdParam);

            QuizDAO quizDAO = new QuizDAO();
            LessonDAO lessonDAO = new LessonDAO();
            List<Map<String, Object>> allQuestions = quizDAO.getQuestionsByQuizId(quizId);
            String servedIdsParam = request.getParameter("servedQuestionIds");
            List<Map<String, Object>> questions = new ArrayList<>();
            if (servedIdsParam != null && !servedIdsParam.isEmpty()) {
                String[] servedIdsArray = servedIdsParam.split(",");
                Set<Integer> servedIdsSet = new HashSet<>();
                for (String s : servedIdsArray) {
                    servedIdsSet.add(Integer.parseInt(s.trim()));
                }
                for (Map<String, Object> q : allQuestions) {
                    if (servedIdsSet.contains(q.get("id"))) {
                        questions.add(q);
                    }
                }
            } else {
                questions = allQuestions;
            }

            int totalPoints = 0;
            int earnedPoints = 0;
            int totalCorrectQuestions = 0;

            for (Map<String, Object> q : questions) {
                int qId = (Integer) q.get("id");
                int points = (Integer) q.get("points");
                totalPoints += points;

                // Support multiple choice answers using getParameterValues
                String[] selectedAnswerIds = request.getParameterValues("q_" + qId);
                Set<Integer> userAnsIds = new HashSet<>();
                if (selectedAnswerIds != null) {
                    for (String sIdStr : selectedAnswerIds) {
                        if (sIdStr != null && !sIdStr.trim().isEmpty()) {
                            try {
                                userAnsIds.add(Integer.parseInt(sIdStr.trim()));
                            } catch (NumberFormatException ignored) {}
                        }
                    }
                }

                List<Map<String, Object>> answers = quizDAO.getAnswersByQuestionId(qId);
                Set<Integer> correctAnsIds = new HashSet<>();
                if (answers != null) {
                    for (Map<String, Object> a : answers) {
                        Boolean isCorrect = (Boolean) a.get("is_correct");
                        if (isCorrect != null && isCorrect) {
                            correctAnsIds.add((Integer) a.get("id"));
                        }
                    }
                }

                // If correctAnsIds matches userAnsIds exactly, user gets points for this question
                if (!correctAnsIds.isEmpty() && userAnsIds.equals(correctAnsIds)) {
                    earnedPoints += points;
                    totalCorrectQuestions++;
                }
            }

            float scorePercent = 0;
            if (totalPoints > 0) {
                scorePercent = ((float) earnedPoints / totalPoints) * 100;
            } else if (questions.size() > 0) {
                scorePercent = ((float) totalCorrectQuestions / questions.size()) * 100;
            }

            Map<String, Object> lessonQuiz = quizDAO.getLessonQuizByLessonId(lessonId);
            if (lessonQuiz == null) {
                String textContent = lessonDAO.getLessonText(lessonId);
                if (textContent != null && textContent.startsWith("Quiz ID: ")) {
                    try {
                        int qId = Integer.parseInt(textContent.substring(9).trim());
                        lessonQuiz = quizDAO.getLessonQuizById(qId);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }
            int passingScore = 0;
            if (lessonQuiz != null) {
                passingScore = (Integer) lessonQuiz.get("passing_score");
            }
            boolean passed = scorePercent >= passingScore;

            int attemptId = quizDAO.insertQuizAttempt(account.getId(), quizId, scorePercent, passed);
            if (passed) {
                new LearningDAO().saveLessonProgress(account.getId(), lessonId, true);
            }

            if (attemptId > 0) {
                for (Map<String, Object> q : questions) {
                    int qId = (Integer) q.get("id");
                    String[] selectedAnswerIds = request.getParameterValues("q_" + qId);
                    if (selectedAnswerIds != null) {
                        for (String sIdStr : selectedAnswerIds) {
                            if (sIdStr != null && !sIdStr.trim().isEmpty()) {
                                try {
                                    int selectedAnswerId = Integer.parseInt(sIdStr.trim());
                                    quizDAO.insertQuizAttemptAnswer(attemptId, qId, selectedAnswerId);
                                } catch (NumberFormatException ignored) {}
                            }
                        }
                    }
                }
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            String jsonResponse = String.format(
                "{\"success\": true, \"scorePercent\": %.2f, \"totalCorrect\": %d, \"totalQuestions\": %d, \"passed\": %b, \"passingScore\": %d}",
                scorePercent, totalCorrectQuestions, questions.size(), passed, passingScore
            );
            response.getWriter().write(jsonResponse);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }

    // --- 4. QUIZ RESULT (GET) ---
    private void handleQuizResultGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
            return;
        }

        String lessonIdParam = request.getParameter("lessonId");
        if (lessonIdParam == null || lessonIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        try {
            String lessonIdError = MyLearningValidator.validateLessonId(lessonIdParam);
            if (lessonIdError != null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }
            int lessonId = Integer.parseInt(lessonIdParam);
            LessonDAO lessonDAO = new LessonDAO();
            Lesson lesson = lessonDAO.getLessonById(lessonId);

            if (lesson == null || !"quiz".equals(lesson.getType())) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            QuizDAO quizDAO = new QuizDAO();
            Map<String, Object> lessonQuiz = quizDAO.getLessonQuizByLessonId(lessonId);

            if (lessonQuiz == null) {
                String textContent = lessonDAO.getLessonText(lessonId);
                if (textContent != null && textContent.startsWith("Quiz ID: ")) {
                    try {
                        int qId = Integer.parseInt(textContent.substring(9).trim());
                        lessonQuiz = quizDAO.getLessonQuizById(qId);
                    } catch (Exception ex) {}
                }
            }

            if (lessonQuiz == null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            int passingScore = 80;
            if (lessonQuiz.get("passing_score") != null) {
                int ps = (Integer) lessonQuiz.get("passing_score");
                if (ps > 5) passingScore = ps;
            }
            lessonQuiz.put("passing_score", passingScore);

            int quizId = (Integer) lessonQuiz.get("id");

            List<Map<String, Object>> userAttempts = quizDAO.getUserAttemptsForQuiz(account.getId(), quizId);
            if (userAttempts.isEmpty()) {
                int courseId = lessonDAO.getCourseIdBySectionId(lesson.getSectionId());
                response.sendRedirect(request.getContextPath() + "/learning?courseId=" + courseId + "&lessonId=" + lessonId);
                return;
            }

            int maxRetakes = -1;
            if (lessonQuiz.get("max_retakes") != null) {
                maxRetakes = (Integer) lessonQuiz.get("max_retakes");
            }
            int revealScoreAttempt = 1;
            if (lessonQuiz.get("reveal_score_attempt") != null) {
                revealScoreAttempt = (Integer) lessonQuiz.get("reveal_score_attempt");
            }
            boolean isExhausted = (maxRetakes != -1 && userAttempts.size() >= maxRetakes);
            boolean canViewHistory = (maxRetakes == -1 || userAttempts.size() >= revealScoreAttempt || isExhausted);
            if (!canViewHistory) {
                int courseId = lessonDAO.getCourseIdBySectionId(lesson.getSectionId());
                response.sendRedirect(request.getContextPath() + "/learning?courseId=" + courseId + "&lessonId=" + lessonId + "&error=history_locked");
                return;
            }

            String attemptIdParam = request.getParameter("attemptId");
            String attemptIdError = MyLearningValidator.validateOptionalId("attemptId", attemptIdParam);
            if (attemptIdError != null) {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }
            int selectedAttemptId = -1;
            if (attemptIdParam != null && !attemptIdParam.isEmpty()) {
                selectedAttemptId = Integer.parseInt(attemptIdParam);
            } else {
                selectedAttemptId = (Integer) userAttempts.get(userAttempts.size() - 1).get("id");
            }

            Map<String, Object> selectedAttempt = null;
            for (Map<String, Object> att : userAttempts) {
                if ((Integer) att.get("id") == selectedAttemptId) {
                    selectedAttempt = att;
                    break;
                }
            }

            if (selectedAttempt == null) {
                selectedAttempt = userAttempts.get(userAttempts.size() - 1);
                selectedAttemptId = (Integer) selectedAttempt.get("id");
            }

            List<Map<String, Object>> questions = quizDAO.getQuestionsByQuizId(quizId);

            for (Map<String, Object> q : questions) {
                int qId = (Integer) q.get("id");
                List<Map<String, Object>> answers = quizDAO.getAnswersByQuestionId(qId);
                q.put("answers", answers);
            }

            List<Map<String, Object>> attemptAnswers = quizDAO.getAttemptAnswers(selectedAttemptId);

            for (Map<String, Object> q : questions) {
                int qId = (Integer) q.get("id");
                List<Integer> selectedAnswerIds = new ArrayList<>();
                for (Map<String, Object> ans : attemptAnswers) {
                    Integer ansQId = (Integer) ans.get("question_id");
                    if (ansQId != null && ansQId.equals(qId)) {
                        selectedAnswerIds.add((Integer) ans.get("selected_answer_id"));
                    }
                }
                q.put("selectedAnswerIds", selectedAnswerIds);
            }

            if (attemptAnswers != null && !attemptAnswers.isEmpty() && !questions.isEmpty()) {
                int totalAttemptPoints = 0;
                int earnedAttemptPoints = 0;
                int totalCorrectCount = 0;
                for (Map<String, Object> q : questions) {
                    int points = q.get("points") != null ? (Integer) q.get("points") : 1;
                    if (points <= 0) points = 1;
                    totalAttemptPoints += points;

                    @SuppressWarnings("unchecked")
                    List<Integer> userAnsIds = (List<Integer>) q.get("selectedAnswerIds");
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> answers = (List<Map<String, Object>>) q.get("answers");
                    
                    Set<Integer> userAnsSet = new HashSet<>(userAnsIds != null ? userAnsIds : Collections.emptyList());
                    Set<Integer> correctAnsSet = new HashSet<>();
                    if (answers != null) {
                        for (Map<String, Object> a : answers) {
                            if (Boolean.TRUE.equals(a.get("is_correct"))) {
                                correctAnsSet.add((Integer) a.get("id"));
                            }
                        }
                    }
                    if (!correctAnsSet.isEmpty() && userAnsSet.equals(correctAnsSet)) {
                        earnedAttemptPoints += points;
                        totalCorrectCount++;
                    }
                }
                if (totalAttemptPoints > 0) {
                    double calcScore = ((double) earnedAttemptPoints / totalAttemptPoints) * 100.0;
                    double calcScoreRounded = Math.round(calcScore * 10.0) / 10.0;
                    boolean isPassed = calcScoreRounded >= (double) passingScore;
                    selectedAttempt.put("score", calcScoreRounded);
                    selectedAttempt.put("passed", isPassed);
                    selectedAttempt.put("earned_points", earnedAttemptPoints);
                    selectedAttempt.put("total_points", totalAttemptPoints);
                    selectedAttempt.put("earned_count", totalCorrectCount);
                    selectedAttempt.put("total_questions", questions.size());

                    if (isPassed) {
                        new LearningDAO().saveLessonProgress(account.getId(), lessonId, true);
                    }
                } else {
                    // Fallback when total points is 0 (should not happen)
                    selectedAttempt.put("earned_count", totalCorrectCount);
                    selectedAttempt.put("total_questions", questions.size());
                }
            } else if (!questions.isEmpty()) {
                // No answers yet: initialize counts for display
                selectedAttempt.put("earned_count", 0);
                selectedAttempt.put("total_questions", questions.size());
            }

            int courseId = lessonDAO.getCourseIdBySectionId(lesson.getSectionId());
            request.setAttribute("courseId", courseId);
            request.setAttribute("lesson", lesson);
            request.setAttribute("lessonQuiz", lessonQuiz);
            request.setAttribute("userAttempts", userAttempts);
            request.setAttribute("selectedAttempt", selectedAttempt);
            request.setAttribute("questions", questions);

            request.getRequestDispatcher("/view/course_learning/quiz-result.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/plain");
            response.getWriter().write("Error occurred in QuizResultController: " + e.getMessage() + "\n");
            for (StackTraceElement ste : e.getStackTrace()) {
                response.getWriter().write(ste.toString() + "\n");
            }
        }
    }
}
