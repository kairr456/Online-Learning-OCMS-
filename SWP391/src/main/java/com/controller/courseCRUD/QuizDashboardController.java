package com.controller.courseCRUD;

import com.DAO.CourseDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import com.entity.Course;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "QuizDashboardController", urlPatterns = {"/dashboard-quiz"})
public class QuizDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || account.getRoleId() != 2) { // Assuming Role 2 is Teacher/Instructor
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int teacherId = account.getId();
        QuizDAO quizDAO = new QuizDAO();
        CourseDAO courseDAO = new CourseDAO();

        // 1. Get Summary KPIs
        Map<String, Object> summary = quizDAO.getQuizSummary(teacherId);
        request.setAttribute("summary", summary);

        // 2. Handle Filters
        String search = request.getParameter("search");
        String courseId = request.getParameter("courseId");
        String status = request.getParameter("status");

        // Set attributes back to form so they don't reset
        request.setAttribute("search", search);
        request.setAttribute("selectedCourseId", courseId);
        request.setAttribute("selectedStatus", status);

        // 3. Get Course List for Dropdown
        List<Course> courses = courseDAO.findByCreator(teacherId);
        request.setAttribute("courses", courses);

        // 4. Get Quiz Data Table List
        List<Map<String, Object>> quizzes = quizDAO.getQuizzesByTeacher(teacherId, search, courseId, status);
        request.setAttribute("quizzes", quizzes);

        // 5. Get Recent Attempts
        List<Map<String, Object>> recentAttempts = quizDAO.getRecentAttempts(teacherId, 5); // Limit 5
        request.setAttribute("recentAttempts", recentAttempts);

        // Forward to JSP
        request.getRequestDispatcher("/view/courseCRUD/dashboard-quiz.jsp").forward(request, response);
    }
}
