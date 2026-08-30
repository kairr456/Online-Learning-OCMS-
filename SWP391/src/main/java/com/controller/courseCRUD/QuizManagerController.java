package com.controller.courseCRUD;

import com.DAO.CourseDAO;
import com.DAO.LessonDAO;
import com.DAO.QuestionGroupDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.Lesson;
import com.entity.QuestionGroup;
import com.entity.QuizQuestion;
import com.entity.Section;
import com.google.gson.Gson;

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
import java.util.Set;
import java.util.HashSet;

@WebServlet(name = "QuizManagerController", urlPatterns = {
    "/quiz-manager",
    "/dashboard-quiz",
    "/quiz-builder",
    "/quiz-edit",
    "/quiz-delete",
    "/quiz-results",
    "/question-bank",
    "/question-bank-action"
})
public class QuizManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        if (action == null) action = "";

        if ("/dashboard-quiz".equals(path) || "dashboard".equals(action)) {
            handleDashboard(request, response);
        } else if ("/quiz-builder".equals(path) || "builder".equals(action)) {
            handleBuilderGet(request, response);
        } else if ("/quiz-edit".equals(path) || "edit".equals(action)) {
            handleEditGet(request, response);
        } else if ("/quiz-delete".equals(path) || "delete".equals(action)) {
            handleDeleteGet(request, response);
        } else if ("/quiz-results".equals(path) || "results".equals(action)) {
            handleResultsGet(request, response);
        } else if ("/question-bank".equals(path) || "questionBank".equals(action)) {
            handleQuestionBankGet(request, response);
        } else {
            handleDashboard(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        if (action == null) action = "";

        if ("/quiz-builder".equals(path) || "builderSave".equals(action)) {
            handleBuilderPost(request, response);
        } else if ("/question-bank-action".equals(path) || "bankAction".equals(action)) {
            handleQuestionBankActionPost(request, response);
        } else {
            doGet(request, response);
        }
    }

    // --- 1. DASHBOARD QUIZ ---
    private void handleDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int teacherId = account.getId();
        CourseDAO courseDAO = new CourseDAO();
        QuestionGroupDAO groupDAO = new QuestionGroupDAO();
        QuizDAO quizDAO = new QuizDAO();

        List<Course> courses = courseDAO.findByCreator(teacherId);
        List<Map<String, Object>> courseBankStats = new ArrayList<>();
        int totalQuestions = 0;
        int totalGroups = 0;

        for (Course c : courses) {
            Map<String, Object> stat = new HashMap<>();
            stat.put("courseId", c.getId());
            stat.put("courseName", c.getName());
            stat.put("thumbnail", c.getThumbnail());

            List<QuestionGroup> groups = groupDAO.getGroupsByCourseId(c.getId());
            int courseQCount = 0;
            for (QuestionGroup g : groups) {
                courseQCount += quizDAO.getQuestionsByGroupId(g.getId()).size();
            }
            stat.put("groupCount", groups.size());
            stat.put("questionCount", courseQCount);

            totalGroups += groups.size();
            totalQuestions += courseQCount;

            courseBankStats.add(stat);
        }

        request.setAttribute("courseBankStats", courseBankStats);
        request.setAttribute("totalCourses", courses.size());
        request.setAttribute("totalGroups", totalGroups);
        request.setAttribute("totalQuestions", totalQuestions);

        request.getRequestDispatcher("/view/courseCRUD/dashboard-quiz.jsp").forward(request, response);
    }

    // --- 2. QUIZ BUILDER (GET) ---
    private void handleBuilderGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        CourseDAO courseDAO = new CourseDAO();
        LessonDAO lessonDAO = new LessonDAO();

        List<Course> courses = courseDAO.findByCreator(account.getId());
        Map<Integer, List<Section>> courseSectionsMap = new HashMap<>();

        for (Course c : courses) {
            courseSectionsMap.put(c.getId(), lessonDAO.getSectionsByCourseId(c.getId()));
        }

        request.setAttribute("courses", courses);
        request.setAttribute("courseSectionsJson", new Gson().toJson(courseSectionsMap));

        request.getRequestDispatcher("/view/courseCRUD/quiz-builder.jsp").forward(request, response);
    }

    // --- 3. QUIZ BUILDER (POST) ---
    private void handleBuilderPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String quizIdStr = request.getParameter("quizId");
            boolean isEdit = (quizIdStr != null && !quizIdStr.trim().isEmpty());
            int editQuizId = isEdit ? Integer.parseInt(quizIdStr) : 0;

            String sectionIdStr = request.getParameter("sectionId");
            int sectionId = (sectionIdStr != null && !sectionIdStr.trim().isEmpty()) ? Integer.parseInt(sectionIdStr) : 0;

            String title = request.getParameter("title");
            String description = request.getParameter("description");
            int duration = Integer.parseInt(request.getParameter("durationMinutes"));
            int maxRetakes = Integer.parseInt(request.getParameter("maxRetakes"));
            int passingScore = Integer.parseInt(request.getParameter("passingScore"));
            String action = request.getParameter("action");

            Lesson lesson = new Lesson();
            lesson.setSectionId(sectionId);
            lesson.setTitle(title);
            lesson.setDescription(description);
            lesson.setType("quiz");
            lesson.setOrderNumber(1);
            lesson.setDurationMinutes(duration);
            lesson.setStatus("publish".equals(action) ? "active" : "inactive");

            QuizDAO quizDAO = new QuizDAO();

            if (isEdit) {
                Map<String, Object> existingQuiz = quizDAO.getLessonQuizById(editQuizId);
                if (existingQuiz != null) {
                    int existingLessonId = (Integer) existingQuiz.get("lesson_id");
                    lesson.setId(existingLessonId);

                    quizDAO.updateQuizLesson(lesson);
                    quizDAO.updateLessonQuiz(editQuizId, passingScore, maxRetakes);
                    quizDAO.clearQuizQuestions(editQuizId);

                    int quizId = editQuizId;
                    String[] qIds = request.getParameterValues("qIds");
                    if (qIds != null) {
                        for (int i = 0; i < qIds.length; i++) {
                            String qId = qIds[i];
                            String qText = request.getParameter("q_text_" + qId);
                            int points = Integer.parseInt(request.getParameter("q_points_" + qId));

                            int dbQuestionId = quizDAO.insertQuizQuestion(quizId, qText, points, i + 1);

                            if (dbQuestionId > 0) {
                                String[] aIds = request.getParameterValues("aIds_" + qId);
                                String correctAnswerId = request.getParameter("a_correct_" + qId);

                                if (aIds != null) {
                                    for (int j = 0; j < aIds.length; j++) {
                                        String aId = aIds[j];
                                        String aText = request.getParameter("a_text_" + qId + "_" + aId);
                                        boolean isCorrect = aId.equals(correctAnswerId);

                                        quizDAO.insertQuizAnswer(dbQuestionId, aText, isCorrect, j + 1);
                                    }
                                }
                            }
                        }
                    }
                    session.setAttribute("message", "Quiz Updated Successfully!");
                    session.setAttribute("messageType", "success");
                }
            } else {
                int lessonId = quizDAO.insertQuizLesson(lesson, account.getId());
                if (lessonId > 0) {
                    int quizId = quizDAO.insertLessonQuiz(lessonId, passingScore, maxRetakes);

                    if (quizId > 0) {
                        String[] qIds = request.getParameterValues("qIds");
                        if (qIds != null) {
                            for (int i = 0; i < qIds.length; i++) {
                                String qId = qIds[i];
                                String qText = request.getParameter("q_text_" + qId);
                                int points = Integer.parseInt(request.getParameter("q_points_" + qId));

                                int dbQuestionId = quizDAO.insertQuizQuestion(quizId, qText, points, i + 1);

                                if (dbQuestionId > 0) {
                                    String[] aIds = request.getParameterValues("aIds_" + qId);
                                    String correctAnswerId = request.getParameter("a_correct_" + qId);

                                    if (aIds != null) {
                                        for (int j = 0; j < aIds.length; j++) {
                                            String aId = aIds[j];
                                            String aText = request.getParameter("a_text_" + qId + "_" + aId);
                                            boolean isCorrect = aId.equals(correctAnswerId);

                                            quizDAO.insertQuizAnswer(dbQuestionId, aText, isCorrect, j + 1);
                                        }
                                    }
                                }
                            }
                        }
                        session.setAttribute("message", "publish".equals(action) ? "Quiz Published Successfully!" : "Quiz Saved as Draft.");
                        session.setAttribute("messageType", "success");
                    }
                } else {
                    throw new Exception("Failed to save lesson.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error saving quiz: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }

        response.sendRedirect(request.getContextPath() + "/dashboard-quiz");
    }

    // --- 4. QUIZ EDIT (GET) ---
    private void handleEditGet(HttpServletRequest request, HttpServletResponse response)
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

    // --- 5. QUIZ DELETE (GET) ---
    private void handleDeleteGet(HttpServletRequest request, HttpServletResponse response)
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

    // --- 6. QUIZ RESULTS (GET) ---
    private void handleResultsGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        QuizDAO quizDAO = new QuizDAO();
        CourseDAO courseDAO = new CourseDAO();

        // 1. Get teacher's active courses for the filter dropdown
        List<Course> allCourses = courseDAO.findByCreator(account.getId());
        List<Course> courses = new ArrayList<>();
        if (allCourses != null) {
            for (Course c : allCourses) {
                if ("active".equalsIgnoreCase(c.getStatus())) {
                    courses.add(c);
                }
            }
        }
        request.setAttribute("courses", courses);

        String courseIdStr = request.getParameter("courseId");
        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim().replaceAll("\\s+", " ");
        }
        List<Map<String, Object>> teacherQuizzes = quizDAO.getQuizzesByTeacher(account.getId(), search, courseIdStr, null);
//        if (teacherQuizzes != null && teacherQuizzes.size() > 3) {
//        teacherQuizzes = teacherQuizzes.subList(0, 3);
//        }

        request.setAttribute("teacherQuizzes", teacherQuizzes);
        request.setAttribute("selectedCourseId", courseIdStr);
        request.setAttribute("searchKeyword", search);

        String quizIdStr = request.getParameter("quizId");
        String lessonIdStr = request.getParameter("lessonId");
        int quizId = 0;
        if (quizIdStr != null && !quizIdStr.trim().isEmpty()) {
            try {
                quizId = Integer.parseInt(quizIdStr.trim());
            } catch (Exception ignored) {}
        } else if (lessonIdStr != null && !lessonIdStr.trim().isEmpty()) {
            try {
                int lessonId = Integer.parseInt(lessonIdStr.trim());
                Map<String, Object> lq = quizDAO.getLessonQuizByLessonId(lessonId);
                if (lq != null) {
                    quizId = (Integer) lq.get("id");
                }
            } catch (Exception ignored) {}
        }

        if (quizId <= 0) {
            // Overview mode: Teacher chooses which course/quiz to view scores
            request.setAttribute("isOverview", true);
            request.getRequestDispatcher("/view/courseCRUD/quiz-results.jsp").forward(request, response);
            return;
        }

        Map<String, Object> quizInfo = quizDAO.getLessonQuizById(quizId);

        if (quizInfo == null) {
            response.sendRedirect(request.getContextPath() + "/quiz-results");
            return;
        }

        List<Map<String, Object>> attempts = quizDAO.getAttemptsByQuizId(quizId);
        List<Map<String, Object>> questions = quizDAO.getQuestionsByQuizId(quizId);

        // Calculate summary metrics
        int totalAttempts = (attempts != null) ? attempts.size() : 0;
        int passedCount = 0;
        double totalScore = 0;
        if (totalAttempts > 0) {
            for (Map<String, Object> a : attempts) {
                Boolean passed = (Boolean) a.get("passed");
                if (passed != null && passed) passedCount++;
                Number sc = (Number) a.get("score");
                if (sc != null) totalScore += sc.doubleValue();
            }
        }
        double avgScore = (totalAttempts > 0) ? Math.round((totalScore / totalAttempts) * 10.0) / 10.0 : 0.0;
        double passRate = (totalAttempts > 0) ? Math.round(((double) passedCount / totalAttempts) * 100.0) : 0.0;

        request.setAttribute("quizInfo", quizInfo);
        request.setAttribute("attempts", attempts);
        request.setAttribute("questions", questions);
        request.setAttribute("totalAttempts", totalAttempts);
        request.setAttribute("passedCount", passedCount);
        request.setAttribute("avgScore", avgScore);
        request.setAttribute("passRate", passRate);

        String attemptIdStr = request.getParameter("attemptId");
        if (attemptIdStr != null && !attemptIdStr.trim().isEmpty()) {
            try {
                int attemptId = Integer.parseInt(attemptIdStr.trim());
                List<Map<String, Object>> attemptAnswers = quizDAO.getAttemptAnswers(attemptId);

                Map<Integer, List<Map<String, Object>>> userAnswersMap = new HashMap<>();
                if (attemptAnswers != null) {
                    for (Map<String, Object> ans : attemptAnswers) {
                        int qKey = (Integer) ans.get("question_id");
                        userAnswersMap.computeIfAbsent(qKey, k -> new ArrayList<>()).add(ans);
                    }
                }

                if (questions != null) {
                    for (Map<String, Object> q : questions) {
                        int qId = (Integer) q.get("id");
                        List<Map<String, Object>> uAnsList = userAnswersMap.get(qId);
                        
                        Map<String, Object> combinedAns = new HashMap<>();
                        if (uAnsList != null && !uAnsList.isEmpty()) {
                            StringBuilder sb = new StringBuilder();
                            boolean allCorrect = true;
                            for (Map<String, Object> ans : uAnsList) {
                                if (sb.length() > 0) sb.append(", ");
                                sb.append(ans.get("selected_answer_text"));
                                
                                Boolean isCorr = (Boolean) ans.get("is_correct");
                                if (isCorr == null || !isCorr) {
                                    allCorrect = false;
                                }
                            }
                            
                            // Check if student selected ALL correct answers and NO incorrect answers!
                            List<Map<String, Object>> qAnswers = quizDAO.getAnswersByQuestionId(qId);
                            int totalCorrectAnswers = 0;
                            if (qAnswers != null) {
                                for (Map<String, Object> qa : qAnswers) {
                                    Boolean isCorr = (Boolean) qa.get("is_correct");
                                    if (isCorr != null && isCorr) {
                                        totalCorrectAnswers++;
                                    }
                                }
                            }
                            if (uAnsList.size() != totalCorrectAnswers) {
                                allCorrect = false;
                            }
                            
                            combinedAns.put("selected_answer_text", sb.toString());
                            combinedAns.put("is_correct", allCorrect);
                        } else {
                            combinedAns.put("selected_answer_text", "");
                            combinedAns.put("is_correct", false);
                        }
                        q.put("userAns", combinedAns);
                    }
                }
                request.setAttribute("selectedAttemptId", attemptId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.getRequestDispatcher("/view/courseCRUD/quiz-results.jsp").forward(request, response);
    }

    // --- 7. QUESTION BANK (GET) ---
    private void handleQuestionBankGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        CourseDAO courseDAO = new CourseDAO();
        String courseIdStr = request.getParameter("courseId");
        if (courseIdStr == null || courseIdStr.isEmpty()) {
            List<Course> teacherCourses = courseDAO.findByCreator(account.getId());
            if (teacherCourses != null && !teacherCourses.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + teacherCourses.get(0).getId());
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
                return;
            }
        }

        try {
            int courseId = Integer.parseInt(courseIdStr);
            Course course = courseDAO.findById(courseId);

            if (course == null || course.getCreatedBy() != account.getId()) {
                response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
                return;
            }

            List<Course> teacherCourses = courseDAO.findByCreator(account.getId());
            request.setAttribute("teacherCourses", teacherCourses);

            QuestionGroupDAO groupDAO = new QuestionGroupDAO();
            List<QuestionGroup> groups = groupDAO.getGroupsByCourseId(courseId);

            request.setAttribute("course", course);
            request.setAttribute("groups", groups);

            String groupIdStr = request.getParameter("groupId");
            if (groupIdStr != null && !groupIdStr.isEmpty()) {
                int groupId = Integer.parseInt(groupIdStr);
                request.setAttribute("activeGroupId", groupId);

                QuizDAO quizDAO = new QuizDAO();
                List<QuizQuestion> questions = quizDAO.getQuestionsByGroupId(groupId);
                request.setAttribute("questions", questions);

                Map<Integer, List<Map<String, Object>>> answersMap = new HashMap<>();
                for (QuizQuestion q : questions) {
                    answersMap.put(q.getId(), quizDAO.getAnswersByQuestionId(q.getId()));
                }
                request.setAttribute("answersMap", answersMap);
            }

            request.getRequestDispatcher("/view/courseCRUD/question-bank.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
        }
    }

    // --- 8. QUESTION BANK ACTION (POST) ---
    private void handleQuestionBankActionPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
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
                if (trimmedName.length() > 255) {
                    session.setAttribute("errorMsg", "Tên nhóm câu hỏi không được vượt quá 255 ký tự!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
                    return;
                }
                if (groupDAO.checkGroupNameExists(courseId, trimmedName)) {
                    session.setAttribute("errorMsg", "Tên nhóm câu hỏi \"" + trimmedName + "\" đã tồn tại trong khóa học này!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
                    return;
                }

                groupDAO.createGroup(courseId, trimmedName);
                session.setAttribute("successMsg", "Tạo nhóm câu hỏi thành công!");
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
            } else if ("delete_group".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                groupDAO.deleteGroup(groupId);
                session.setAttribute("successMsg", "Đã xóa nhóm câu hỏi thành công!");
                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
            } else if ("add_question".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                String text = request.getParameter("questionText");
                String pointsStr = request.getParameter("points");

                if (text == null || text.trim().isEmpty()) {
                    session.setAttribute("errorMsg", "Nội dung câu hỏi không được để trống!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
                    return;
                }

                String trimmedText = text.trim();
                if (trimmedText.length() > 1000) {
                    session.setAttribute("errorMsg", "Nội dung câu hỏi (Question Text) không được vượt quá 1000 ký tự (độ dài hiện tại: " + trimmedText.length() + ")!");
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
                    return;
                }

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

                String[] answers = request.getParameterValues("answers");
                String[] correctAnswers = request.getParameterValues("correctAnswers");

                Set<Integer> correctIndices = new HashSet<>();
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
                Set<String> uniqueAnswers = new HashSet<>();
                boolean hasValidCorrect = false;

                if (answers != null) {
                    for (int i = 0; i < answers.length; i++) {
                        if (answers[i] != null && !answers[i].trim().isEmpty()) {
                            String trimmedAns = answers[i].trim();
                            if (trimmedAns.length() > 500) {
                                session.setAttribute("errorMsg", "Nội dung câu trả lời không được vượt quá 500 ký tự (độ dài hiện tại: " + trimmedAns.length() + ")!");
                                response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId + "&groupId=" + groupId);
                                return;
                            }
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
            } else if ("delete_question".equals(action)) {
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
