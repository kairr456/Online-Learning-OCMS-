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

@WebServlet(name = "CourseDeleteController", urlPatterns = {"/course-delete"})
public class CourseDeleteController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

            if (course != null && course.getCreatedBy() == account.getId()) {
                boolean isDeleted = courseDAO.delete(course);
                if (isDeleted) {
                    session.setAttribute("msg", "Xóa khóa học thành công!");
                } else {
                    session.setAttribute("msg", "Xóa khóa học thất bại. Vui lòng thử lại.");
                }
            }
        } catch (NumberFormatException e) {
            session.setAttribute("msg", "ID không hợp lệ.");
        }
        
        response.sendRedirect(request.getContextPath() + "/course-dashboard");
    }
}
