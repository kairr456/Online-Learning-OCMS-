package com.controller.home;

import com.DAO.ArchivedCourseDAO;
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

        // Kiểm tra học viên đã mua khóa học
        CourseRegistrationDAO regDAO = new CourseRegistrationDAO();
        boolean enrolled = false;
        for (Course c : regDAO.getCoursesByAccountId(account.getId())) {
            if (c.getId() == courseId) {
                enrolled = true;
                break;
            }
        }
        if (!enrolled) {
            response.sendRedirect(request.getContextPath() + "/course?id=" + courseId);
            return;
        }

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
            currentLesson = allLessons.get(0);
        }

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
            quizId = learningDAO.getQuizIdByLessonId(currentLesson.getId());
            if (quizId != null && quizId > 0) {
                quizQuestions = learningDAO.getQuestionsByQuizId(quizId);
                quizAnswers = new HashMap<>();
                int total = 0;
                for (QuizQuestion q : quizQuestions) {
                    quizAnswers.put(q.getId(), learningDAO.getAnswersByQuestionId(q.getId()));
                    total += (q.getPoints() != null ? q.getPoints() : 1);
                }
                quizTotalPoints = total;
                hasPassedQuiz = learningDAO.hasPassedQuiz(account.getId(), quizId);
                bestQuizScore = learningDAO.getBestQuizScore(account.getId(), quizId);
            }
        }

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
                int quizId = Integer.parseInt(request.getParameter("quizId"));
                List<QuizQuestion> questions = learningDAO.getQuestionsByQuizId(quizId);
                int total = 0;
                int score = 0;
                for (QuizQuestion q : questions) {
                    int points = q.getPoints() != null ? q.getPoints() : 1;
                    total += points;
                    String answerParam = request.getParameter("answer_" + q.getId());
                    if (answerParam == null || answerParam.trim().isEmpty()) {
                        continue;
                    }
                    int answerId = Integer.parseInt(answerParam);
                    for (QuizAnswer a : learningDAO.getAnswersByQuestionId(q.getId())) {
                        if (a.getId() == answerId && Boolean.TRUE.equals(a.getIsCorrect())) {
                            score += points;
                            break;
                        }
                    }
                }
                boolean passed = total > 0 && ((double) score / total) >= PASS_RATIO;
                boolean saved = learningDAO.saveQuizAttempt(account.getId(), quizId, score, passed);
                if (passed) {
                    int lessonId = learningDAO.getLessonIdByQuizId(quizId);
                    if (lessonId > 0) {
                        learningDAO.saveLessonProgress(account.getId(), lessonId, true);
                        autoArchiveIfCompleted(account.getId(), lessonId);
                    }
                }
                if (saved) {
                    out.print("{\"status\":\"success\",\"score\":" + score + ",\"total\":" + total
                            + ",\"passed\":" + passed + "}");
                } else {
                    out.print("{\"status\":\"error\", \"message\":\"Failed to save quiz attempt.\"}");
                }

            } else if ("markComplete".equals(action)) {
                int lessonId = Integer.parseInt(request.getParameter("lessonId"));
                boolean ok = learningDAO.saveLessonProgress(account.getId(), lessonId, true);
                if (ok) {
                    autoArchiveIfCompleted(account.getId(), lessonId);
                }
                out.print(ok
                        ? "{\"status\":\"success\"}"
                        : "{\"status\":\"error\", \"message\":\"Failed to update progress.\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\":\"Unknown action.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    private void autoArchiveIfCompleted(int accountId, int lessonId) {
        LearningDAO learningDAO = new LearningDAO();
        int courseId = learningDAO.getCourseIdByLessonId(lessonId);
        if (courseId <= 0) {
            return;
        }
        if (learningDAO.getCourseProgressPercent(accountId, courseId) >= 100) {
            new ArchivedCourseDAO().add(accountId, courseId);
        }
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