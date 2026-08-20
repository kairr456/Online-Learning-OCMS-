package com.controller.courseCRUD;

import com.DAO.CourseDAO;
import com.DAO.QuestionGroupDAO;
import com.DAO.QuizDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.QuestionGroup;
import com.entity.QuizQuestion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "QuestionBankController", urlPatterns = {"/question-bank"})
public class QuestionBankController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
                response.sendRedirect(request.getContextPath() + "/teacher-dashboard");
                return;
            }
        }
        
        try {
            int courseId = Integer.parseInt(courseIdStr);
            Course course = courseDAO.findById(courseId);

                        if (course == null || course.getCreatedBy() != account.getId()) {
                response.sendRedirect(request.getContextPath() + "/teacher-dashboard");
                return;
            }
            
            // Pass teacher's courses for dropdown
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
                
                // Fetch answers
                java.util.Map<Integer, List<java.util.Map<String, Object>>> answersMap = new java.util.HashMap<>();
                for (QuizQuestion q : questions) {
                    answersMap.put(q.getId(), quizDAO.getAnswersByQuestionId(q.getId()));
                }
                request.setAttribute("answersMap", answersMap);
            }

            request.getRequestDispatcher("/view/courseCRUD/question-bank.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/teacher-dashboard");
        }
    }
}




