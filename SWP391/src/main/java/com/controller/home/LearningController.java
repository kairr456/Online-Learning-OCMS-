package com.controller.home;

import com.DAO.ArchivedCourseDAO;
import com.DAO.CertificateDAO;
import com.DAO.CourseDAO;
import com.DAO.CourseRegistrationDAO;
import com.DAO.LearningDAO;
import com.DAO.LessonDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.Lesson;
import com.entity.LessonDocument;
import com.entity.LessonVideo;
import com.entity.QuizAnswer;
import com.entity.QuizQuestion;
import com.entity.Section;
import com.validator.MyLearningValidator;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LearningController", urlPatterns = {"/learning"})
public class LearningController extends HttpServlet {

    private static final String LEARNING_PAGE = "/view/course_learning/learning.jsp";
    private static final double PASS_RATIO = 0.8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String courseIdParam = request.getParameter("courseId");
        if (courseIdParam == null || courseIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/all-courses");
            return;
        }

        int courseId;
        try {
            courseId = Integer.parseInt(courseIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/all-courses");
            return;
        }

        CourseDAO courseDAO = new CourseDAO();
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            response.sendRedirect(request.getContextPath() + "/all-courses");
            return;
        }

        // Kiểm tra học viên đã mua khóa học (Admin và Tác giả khóa học mặc định được phép xem)
        CourseRegistrationDAO regDAO = new CourseRegistrationDAO();
        boolean enrolled = (account.getRoleId() == 1 || account.getId() == course.getCreatedBy());
        if (!enrolled) {
            for (Course c : regDAO.getCoursesByAccountId(account.getId())) {
                if (c.getId() == courseId) {
                    enrolled = true;
                    break;
                }
            }
        }
        request.setAttribute("isEnrolled", enrolled);

        LessonDAO lessonDAO = new LessonDAO();
        List<Section> sections = lessonDAO.getSectionsByCourseId(courseId);
        Map<Integer, List<Lesson>> lessonsMap = new HashMap<>();
        List<Lesson> allLessons = new ArrayList<>();
        for (Section s : sections) {
            List<Lesson> ls = lessonDAO.getLessonsBySectionId(s.getId());
            lessonsMap.put(s.getId(), ls);
            allLessons.addAll(ls);
        }

        request.setAttribute("course", course);
        request.setAttribute("sections", sections);
        request.setAttribute("lessonsMap", lessonsMap);

        if (allLessons.isEmpty()) {
            request.setAttribute("noContent", true);
            request.getRequestDispatcher(LEARNING_PAGE).forward(request, response);
            return;
        }

        Lesson firstLesson = allLessons.get(0);
        request.setAttribute("firstLessonId", firstLesson.getId());

        // Xác định bài học hiện tại (mặc định bài đầu tiên)
        Lesson currentLesson = null;
        String lessonIdParam = request.getParameter("lessonId");
        if (lessonIdParam != null && !lessonIdParam.trim().isEmpty()) {
            try {
                int lessonId = Integer.parseInt(lessonIdParam);
                for (Lesson l : allLessons) {
                    if (l.getId() == lessonId) {
                        currentLesson = l;
                        break;
                    }
                }
            } catch (NumberFormatException ignored) {
            }
        }
        if (currentLesson == null) {
            currentLesson = firstLesson;
        }

        // Nếu chưa mua khóa học và bài đang xem KHÔNG PHẢI bài đầu tiên -> Khóa bài học
        boolean isLockedLesson = !enrolled && (currentLesson.getId() != firstLesson.getId());
        request.setAttribute("isLockedLesson", isLockedLesson);

        int currentIndex = allLessons.indexOf(currentLesson);
        Lesson prevLesson = currentIndex > 0 ? allLessons.get(currentIndex - 1) : null;
        Lesson nextLesson = currentIndex < allLessons.size() - 1 ? allLessons.get(currentIndex + 1) : null;

        LearningDAO learningDAO = new LearningDAO();
        Set<Integer> completedLessons = learningDAO.getCompletedLessonIds(account.getId(), courseId);

        String type = currentLesson.getType();
        String lessonContent = null;
        List<LessonVideo> lessonVideos = null;
        String lessonFileUrl = null;
        LessonDocument lessonDocument = null;
        Integer quizId = null;
        List<QuizQuestion> quizQuestions = null;
        Map<Integer, List<QuizAnswer>> quizAnswers = null;
        Integer quizTotalPoints = null;
        Boolean hasPassedQuiz = null;
        Double bestQuizScore = null;

        if (!isLockedLesson) {

        if ("text".equals(type) || "document".equalsIgnoreCase(type)) {
            lessonContent = lessonDAO.getLessonText(currentLesson.getId());
        }
        if ("video".equals(type)) {
            lessonVideos = learningDAO.getLessonVideos(currentLesson.getId());
        }
        if ("file".equals(type)) {
            lessonFileUrl = learningDAO.getLessonFileUrl(currentLesson.getId());
        }
        if ("document".equals(type)) {
            lessonDocument = learningDAO.getLessonDocument(currentLesson.getId());
        }
                if ("quiz".equals(type)) {
            com.DAO.QuizDAO qDAO = new com.DAO.QuizDAO();
            Map<String, Object> lessonQuiz = qDAO.getLessonQuizByLessonId(currentLesson.getId());
            if (lessonQuiz == null) {
                String lText = lessonDAO.getLessonText(currentLesson.getId());
                if (lText != null && lText.startsWith("Quiz ID: ")) {
                    try {
                        int qId = Integer.parseInt(lText.substring(9).trim());
                        lessonQuiz = qDAO.getLessonQuizById(qId);
                    } catch (Exception ignored) {}
                }
            }

            if (lessonQuiz != null) {
                quizId = (Integer) lessonQuiz.get("id");
                int maxRetakes = (Integer) lessonQuiz.get("max_retakes");
                int userAttemptsCount = qDAO.countUserAttemptsForQuiz(account.getId(), quizId);
                List<Map<String, Object>> userAttemptsList = qDAO.getUserAttemptsForQuiz(account.getId(), quizId);
                boolean isExhausted = (maxRetakes != -1 && userAttemptsCount >= maxRetakes);
                boolean canViewHistory = (maxRetakes == -1 || maxRetakes >= 10 || isExhausted);

                request.setAttribute("lessonQuiz", lessonQuiz);
                request.setAttribute("quizId", quizId);
                request.setAttribute("maxRetakes", maxRetakes);
                request.setAttribute("userAttemptsCount", userAttemptsCount);
                request.setAttribute("userAttemptsList", userAttemptsList);
                request.setAttribute("isExhausted", isExhausted);
                request.setAttribute("canViewHistory", canViewHistory);

                String requestedMode = request.getParameter("quizMode");
                if (("take".equalsIgnoreCase(requestedMode) || "start".equalsIgnoreCase(requestedMode)) && !isExhausted) {
                    int timeLimit = 0;
                    if (lessonQuiz.get("time_limit_minutes") != null) {
                        timeLimit = (Integer) lessonQuiz.get("time_limit_minutes");
                    }
                    if (timeLimit <= 0 && currentLesson.getDurationMinutes() != null && currentLesson.getDurationMinutes() > 0) {
                        timeLimit = currentLesson.getDurationMinutes();
                    }
                    request.setAttribute("quizMode", "take");
                    request.setAttribute("currentAttemptNo", userAttemptsCount + 1);
                    request.setAttribute("timeLimitMinutes", timeLimit);

                    List<QuizQuestion> allQuestions = learningDAO.getQuestionsByQuizId(quizId);
                    java.util.Collections.shuffle(allQuestions);
                    
                    int numToTake = 10;
                    if (lessonQuiz.get("number_of_questions") != null) {
                        numToTake = (Integer) lessonQuiz.get("number_of_questions");
                    }
                    
                    quizQuestions = allQuestions;
                    if (numToTake > 0 && numToTake < allQuestions.size()) {
                        quizQuestions = allQuestions.subList(0, numToTake);
                    }
                    
                    StringBuilder servedIds = new StringBuilder();
                    quizAnswers = new HashMap<>();
                    Map<Integer, Boolean> quizQuestionMultipleChoiceMap = new HashMap<>();
                    int total = 0;
                    for (QuizQuestion q : quizQuestions) {
                        if (servedIds.length() > 0) servedIds.append(",");
                        servedIds.append(q.getId());
                        List<QuizAnswer> qAns = learningDAO.getAnswersByQuestionId(q.getId());
                        quizAnswers.put(q.getId(), qAns);
                        total += (q.getPoints() != null ? q.getPoints() : 1);

                        int correctCount = 0;
                        if (qAns != null) {
                            for (QuizAnswer a : qAns) {
                                if (Boolean.TRUE.equals(a.getIsCorrect())) {
                                    correctCount++;
                                }
                            }
                        }
                        quizQuestionMultipleChoiceMap.put(q.getId(), correctCount > 1);
                    }
                    request.setAttribute("quizQuestionMultipleChoiceMap", quizQuestionMultipleChoiceMap);
                    request.setAttribute("servedQuestionIds", servedIds.toString());
                    quizTotalPoints = total;
                } else {
                    request.setAttribute("quizMode", "attempt");
                }

                hasPassedQuiz = learningDAO.hasPassedQuiz(account.getId(), quizId);
                bestQuizScore = learningDAO.getBestQuizScore(account.getId(), quizId);
            }
        }
        } // End if (!isLockedLesson)

        // Chuẩn hóa URL video / tài liệu local (bỏ context path cũ)
        if (lessonVideos != null && !lessonVideos.isEmpty()) {
            for (LessonVideo v : lessonVideos) {
                if ("youtube".equalsIgnoreCase(v.getVideoProvider())) {
                    v.setVideoUrl(toYoutubeEmbed(v.getVideoUrl()));
                } else {
                    v.setVideoUrl(normalizeLocalUrl(v.getVideoUrl(), request));
                }
            }
        }
        if (lessonFileUrl != null) {
            lessonFileUrl = normalizeLocalUrl(lessonFileUrl, request);
        }
        if (lessonDocument != null && lessonDocument.getDocumentUrl() != null) {
            lessonDocument.setDocumentUrl(normalizeLocalUrl(lessonDocument.getDocumentUrl(), request));
        }

        String fromParam = request.getParameter("from");
        if (fromParam != null && !fromParam.trim().isEmpty()) {
            request.setAttribute("fromParam", fromParam.trim());
        }

        request.setAttribute("allLessons", allLessons);
        request.setAttribute("currentLesson", currentLesson);
        request.setAttribute("prevLesson", prevLesson);
        request.setAttribute("nextLesson", nextLesson);
        request.setAttribute("completedLessons", completedLessons);
        request.setAttribute("lessonContent", lessonContent);
        request.setAttribute("lessonVideos", lessonVideos);
        request.setAttribute("lessonFileUrl", lessonFileUrl);
        request.setAttribute("lessonDocument", lessonDocument);
        request.setAttribute("quizId", quizId);
        request.setAttribute("quizQuestions", quizQuestions);
        request.setAttribute("quizAnswers", quizAnswers);
        request.setAttribute("quizTotalPoints", quizTotalPoints);
        request.setAttribute("hasPassedQuiz", hasPassedQuiz);
        request.setAttribute("bestQuizScore", bestQuizScore);

        request.getRequestDispatcher(LEARNING_PAGE).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        PrintWriter out = response.getWriter();
        if (account == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"error\", \"message\":\"Unauthorized\"}");
            return;
        }

        String action = request.getParameter("action");
        LearningDAO learningDAO = new LearningDAO();

        try {
                        if ("submitQuiz".equals(action)) {
                String quizIdParam = request.getParameter("quizId");
                String quizIdError = MyLearningValidator.validateQuizId(quizIdParam);
                if (quizIdError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + quizIdError + "\"}");
                    return;
                }
                int quizId = Integer.parseInt(quizIdParam);
                com.DAO.QuizDAO qDAO = new com.DAO.QuizDAO();
                Map<String, Object> lessonQuizMap = qDAO.getLessonQuizById(quizId);
                
                int teacherPassingScore = 80;
                if (lessonQuizMap != null && lessonQuizMap.get("passing_score") != null) {
                    int ps = (Integer) lessonQuizMap.get("passing_score");
                    if (ps > 5) {
                        teacherPassingScore = ps;
                    }
                }

                String servedIdsParam = request.getParameter("servedQuestionIds");
                List<QuizQuestion> questions = new java.util.ArrayList<>();
                if (servedIdsParam != null && !servedIdsParam.trim().isEmpty()) {
                    String[] servedIdsArray = servedIdsParam.split(",");
                    for (String s : servedIdsArray) {
                        if (s != null && !s.trim().isEmpty()) {
                            try {
                                int qId = Integer.parseInt(s.trim());
                                QuizQuestion q = learningDAO.getQuestionById(qId);
                                if (q != null) {
                                    questions.add(q);
                                }
                            } catch (NumberFormatException ignored) {}
                        }
                    }
                }
                if (questions.isEmpty()) {
                    questions = learningDAO.getQuestionsByQuizId(quizId);
                }
                
                int total = 0;
                int score = 0;
                int totalCorrect = 0;
                for (QuizQuestion q : questions) {
                    int points = q.getPoints() != null ? q.getPoints() : 1;
                    total += points;

                    String[] selectedAnswerIds = request.getParameterValues("answer_" + q.getId());
                    java.util.Set<Integer> userAnsIds = new java.util.HashSet<>();
                    if (selectedAnswerIds != null) {
                        for (String sIdStr : selectedAnswerIds) {
                            if (sIdStr != null && !sIdStr.trim().isEmpty()) {
                                try {
                                    userAnsIds.add(Integer.parseInt(sIdStr.trim()));
                                } catch (NumberFormatException ignored) {}
                            }
                        }
                    }

                    List<QuizAnswer> answers = learningDAO.getAnswersByQuestionId(q.getId());
                    java.util.Set<Integer> correctAnsIds = new java.util.HashSet<>();
                    if (answers != null) {
                        for (QuizAnswer a : answers) {
                            if (Boolean.TRUE.equals(a.getIsCorrect())) {
                                correctAnsIds.add(a.getId());
                            }
                        }
                    }

                    if (!correctAnsIds.isEmpty() && userAnsIds.equals(correctAnsIds)) {
                        score += points;
                        totalCorrect++;
                    }
                }
                boolean previouslyPassed = learningDAO.hasPassedQuiz(account.getId(), quizId);
                double scorePercent = total > 0 ? ((double) score / total) * 100.0 : 0.0;
                boolean passed = scorePercent >= (double) teacherPassingScore;
                int attemptId = qDAO.insertQuizAttempt(account.getId(), quizId, (float) scorePercent, passed);
                if (attemptId > 0) {
                    for (QuizQuestion q : questions) {
                        String[] selectedAnswerIds = request.getParameterValues("answer_" + q.getId());
                        if (selectedAnswerIds != null) {
                            for (String sIdStr : selectedAnswerIds) {
                                if (sIdStr != null && !sIdStr.trim().isEmpty()) {
                                    try {
                                        int selectedAnsId = Integer.parseInt(sIdStr.trim());
                                        qDAO.insertQuizAttemptAnswer(attemptId, q.getId(), selectedAnsId);
                                    } catch (NumberFormatException ignored) {}
                                }
                            }
                        }
                    }
                }

                String certCode = null;
                if (passed) {
                    int lessonId = learningDAO.getLessonIdByQuizId(quizId);
                    if (lessonId > 0) {
                        learningDAO.saveLessonProgress(account.getId(), lessonId, true);
                        certCode = grantCertificateIfCompleted(account.getId(), lessonId);
                    }
                }

                int maxRetakes = -1;
                Map<String, Object> lqMap = qDAO.getLessonQuizById(quizId);
                if (lqMap != null && lqMap.get("max_retakes") != null) {
                    maxRetakes = (Integer) lqMap.get("max_retakes");
                }
                int newAttemptCount = qDAO.countUserAttemptsForQuiz(account.getId(), quizId);
                boolean isExhausted = (maxRetakes != -1 && newAttemptCount >= maxRetakes);
                double scorePercentRounded = Math.round(scorePercent * 10.0) / 10.0;
                int totalQuestions = questions.size();

                out.print("{\"status\":\"success\",\"score\":" + score + ",\"total\":" + total
                        + ",\"scorePercent\":" + scorePercentRounded
                        + ",\"totalCorrect\":" + totalCorrect
                        + ",\"totalQuestions\":" + totalQuestions
                        + ",\"passed\":" + passed
                        + ",\"previouslyPassed\":" + previouslyPassed
                        + ",\"isExhausted\":" + isExhausted
                        + ",\"certificateCode\":\"" + (certCode == null ? "" : certCode) + "\"}");

            } else if ("markComplete".equals(action)) {
                String lessonIdParam = request.getParameter("lessonId");
                String lessonIdError = MyLearningValidator.validateLessonId(lessonIdParam);
                if (lessonIdError != null) {
                    out.print("{\"status\":\"error\", \"message\":\"" + lessonIdError + "\"}");
                    return;
                }
                int lessonId = Integer.parseInt(lessonIdParam);
                boolean ok = learningDAO.saveLessonProgress(account.getId(), lessonId, true);
                // Cấp chứng chỉ ngay nếu HV vừa đạt 100% progress và khóa có template
                String certCode = ok ? grantCertificateIfCompleted(account.getId(), lessonId) : null;
                out.print(ok
                        ? "{\"status\":\"success\",\"certificateCode\":\"" + (certCode == null ? "" : certCode) + "\"}"
                        : "{\"status\":\"error\", \"message\":\"Failed to update progress.\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\":\"Unknown action.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /** Cấp chứng chỉ nếu HV đạt 100% progress của khóa (chỉ khi khóa có template). Trả về mã hoặc null. */
    private String grantCertificateIfCompleted(int accountId, int lessonId) {
        LearningDAO learningDAO = new LearningDAO();
        int courseId = learningDAO.getCourseIdByLessonId(lessonId);
        if (courseId <= 0) {
            return null;
        }
        int progress = learningDAO.getCourseProgress(accountId, courseId);
        if (progress >= 100) {
            // Tự động archive khóa học khi học viên vừa hoàn thành 100%
            new ArchivedCourseDAO().add(accountId, courseId);
            return new CertificateDAO().issueCertificate(accountId, courseId);
        }
        return null;
    }

    private String toYoutubeEmbed(String url) {
        if (url == null || url.trim().isEmpty()) {
            return "";
        }
        String id = url;
        if (url.contains("v=")) {
            id = url.substring(url.indexOf("v=") + 2);
            if (id.contains("&")) {
                id = id.substring(0, id.indexOf("&"));
            }
        } else if (url.contains("youtu.be/")) {
            id = url.substring(url.indexOf("youtu.be/") + 9);
            if (id.contains("?")) {
                id = id.substring(0, id.indexOf("?"));
            }
        }
        return "https://www.youtube.com/embed/" + id;
    }

    private String normalizeLocalUrl(String url, HttpServletRequest request) {
        if (url == null || url.trim().isEmpty()) {
            return url;
        }
        String ctx = request.getContextPath();
        if (ctx != null && !ctx.isEmpty() && url.startsWith(ctx + "/")) {
            return url;
        }
        if (url.startsWith("/")) {
            int secondSlash = url.indexOf("/", 1);
            if (secondSlash > 1) {
                return ctx + url.substring(secondSlash);
            }
        }
        return url;
    }
}

