package com.controller.courseCRUD;

import com.DAO.CourseDAO;
import com.entity.Account;
import com.entity.Course;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "CourseDeletePreviewController", urlPatterns = {"/course-delete-preview"})
public class CourseDeletePreviewController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/course-dashboard");
            return;
        }

        try {
            int courseId = Integer.parseInt(idStr);
            CourseDAO courseDAO = new CourseDAO();
            Course course = courseDAO.findById(courseId);

            if (course == null || course.getCreatedBy() != account.getId()) {
                response.sendRedirect(request.getContextPath() + "/course-dashboard");
                return;
            }

            request.setAttribute("course", course);
            request.getRequestDispatcher("/view/courseCRUD/course-delete-preview.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/course-dashboard");
        }
    }
}
