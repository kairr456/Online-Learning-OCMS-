package com.controller.home;

import com.DAO.RegistrationDAO;
import com.entity.Account;
import com.entity.Course;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MyLearningController", urlPatterns = {"/my-learning"})
public class MyLearningController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account"); // Tên attribute lưu thông tin đăng nhập trong Session

        // Kiểm tra đăng nhập
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
            return;
        }

        // Lấy danh sách khóa học của người dùng
        RegistrationDAO registrationDAO = new RegistrationDAO();
        List<Course> myCourses = registrationDAO.getCoursesByAccountId(account.getId());

        // Đẩy danh sách sang JSP
        request.setAttribute("myCourses", myCourses);

        // Chuyển hướng đúng đường dẫn view/course_learning/course_learning.jsp
        request.getRequestDispatcher("/view/course_learning/course_learning.jsp").forward(request, response);
    }
}