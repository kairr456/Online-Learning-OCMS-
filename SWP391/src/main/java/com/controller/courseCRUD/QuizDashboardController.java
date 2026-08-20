package com.controller.courseCRUD;

import com.DAO.CourseDAO;
import com.DAO.QuestionGroupDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.QuestionGroup;
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

@WebServlet(name = "QuizDashboardController", urlPatterns = {"/dashboard-quiz"})
public class QuizDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
        com.DAO.QuizDAO quizDAO = new com.DAO.QuizDAO();

        // Get teacher's courses
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
}
