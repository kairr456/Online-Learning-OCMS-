package com.controller.shopcart;

import com.entity.Account;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/submit-review")
public class ReviewController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        
        // 1. Check if logged in
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Get parameters
        String courseIdStr = request.getParameter("courseId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        // 3. Save to DB
        try {
            int courseId = Integer.parseInt(courseIdStr);
            int rating = Integer.parseInt(ratingStr);
            
            // Check enrollment requirement
            com.entity.Course course = new com.DAO.CourseDAO().findById(courseId);
            boolean isEnrolled = (course != null && course.getCreatedBy() == account.getId())
                    || new com.DAO.CourseRegistrationDAO().isEnrolled(account.getId(), courseId);
            if (!isEnrolled) {
                session.setAttribute("message", "Bạn phải mua/đăng ký khóa học mới được gửi đánh giá!");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/course?id=" + courseId);
                return;
            }

            // Check single review limit
            com.DAO.ReviewDAO reviewDAO = new com.DAO.ReviewDAO();
            if (reviewDAO.hasUserReviewed(account.getId(), courseId)) {
                session.setAttribute("message", "Mỗi tài khoản chỉ được gửi đánh giá 1 lần cho mỗi khóa học!");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/course?id=" + courseId);
                return;
            }
            
            com.entity.Review review = new com.entity.Review();
            review.setCourseId(courseId);
            review.setAccountId(account.getId());
            review.setRating(rating);
            review.setComment(comment != null ? comment.trim() : "");
            
            boolean success = reviewDAO.insert(review);
            
            if (success) {
                session.setAttribute("message", "Đã gửi đánh giá thành công! Cảm ơn ý kiến của bạn.");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Gửi đánh giá thất bại.");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            session.setAttribute("message", "Dữ liệu không hợp lệ hoặc có lỗi xảy ra.");
            session.setAttribute("messageType", "error");
        }

        // Redirect back to course details
        if (courseIdStr != null && !courseIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/course?id=" + courseIdStr);
        } else {
            response.sendRedirect(request.getContextPath() + "/courses");
        }
    }
}
