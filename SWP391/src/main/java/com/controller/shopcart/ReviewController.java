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

        int courseId = 0;
        try {
            courseId = Integer.parseInt(courseIdStr);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/all-courses");
            return;
        }

        // Validate rating & comment
        boolean hasRating = (ratingStr != null && !ratingStr.trim().isEmpty());
        boolean hasComment = (comment != null && !comment.trim().isEmpty());

        if (!hasRating && !hasComment) {
            session.setAttribute("message", "Vui lòng chọn số sao đánh giá và nhập nội dung bình luận!");
            session.setAttribute("messageType", "error");
            session.setAttribute("reviewCommentDraft", comment != null ? comment : "");
            session.setAttribute("reviewRatingDraft", ratingStr != null ? ratingStr : "");
            response.sendRedirect(request.getContextPath() + "/course?id=" + courseId + "&tab=reviews#reviews");
            return;
        }

        if (!hasRating) {
            session.setAttribute("message", "Vui lòng chọn số sao đánh giá khóa học!");
            session.setAttribute("messageType", "error");
            session.setAttribute("reviewCommentDraft", comment != null ? comment : "");
            session.setAttribute("reviewRatingDraft", "");
            response.sendRedirect(request.getContextPath() + "/course?id=" + courseId + "&tab=reviews#reviews");
            return;
        }

        if (!hasComment) {
            session.setAttribute("message", "Vui lòng nhập nội dung bình luận!");
            session.setAttribute("messageType", "error");
            session.setAttribute("reviewCommentDraft", "");
            session.setAttribute("reviewRatingDraft", ratingStr != null ? ratingStr : "");
            response.sendRedirect(request.getContextPath() + "/course?id=" + courseId + "&tab=reviews#reviews");
            return;
        }

        int rating = 0;
        try {
            rating = Integer.parseInt(ratingStr.trim());
            if (rating < 1 || rating > 5) {
                rating = 5;
            }
        } catch (NumberFormatException e) {
            session.setAttribute("message", "Đánh giá sao không hợp lệ!");
            session.setAttribute("messageType", "error");
            session.setAttribute("reviewCommentDraft", comment != null ? comment : "");
            session.setAttribute("reviewRatingDraft", ratingStr != null ? ratingStr : "");
            response.sendRedirect(request.getContextPath() + "/course?id=" + courseId + "&tab=reviews#reviews");
            return;
        }

        // 3. Save to DB
        try {
            // Check enrollment requirement
            com.entity.Course course = new com.DAO.CourseDAO().findById(courseId);
            boolean isEnrolled = (course != null && course.getCreatedBy() == account.getId())
                    || new com.DAO.CourseRegistrationDAO().isEnrolled(account.getId(), courseId);
            if (!isEnrolled) {
                session.setAttribute("message", "Bạn phải mua/đăng ký khóa học mới được gửi đánh giá!");
                session.setAttribute("messageType", "error");
                session.setAttribute("reviewCommentDraft", comment != null ? comment : "");
                session.setAttribute("reviewRatingDraft", ratingStr != null ? ratingStr : "");
                response.sendRedirect(request.getContextPath() + "/course?id=" + courseId + "&tab=reviews#reviews");
                return;
            }

            // Check single review limit
            com.DAO.ReviewDAO reviewDAO = new com.DAO.ReviewDAO();
            if (reviewDAO.hasUserReviewed(account.getId(), courseId)) {
                session.setAttribute("message", "Mỗi tài khoản chỉ được gửi đánh giá 1 lần cho mỗi khóa học!");
                session.setAttribute("messageType", "error");
                session.setAttribute("reviewCommentDraft", comment != null ? comment : "");
                session.setAttribute("reviewRatingDraft", ratingStr != null ? ratingStr : "");
                response.sendRedirect(request.getContextPath() + "/course?id=" + courseId + "&tab=reviews#reviews");
                return;
            }
            
            com.entity.Review review = new com.entity.Review();
            review.setCourseId(courseId);
            review.setAccountId(account.getId());
            review.setRating(rating);
            review.setComment(comment.trim());
            
            boolean success = reviewDAO.insert(review);
            
            if (success) {
                session.setAttribute("message", "Đã gửi đánh giá thành công! Cảm ơn ý kiến của bạn.");
                session.setAttribute("messageType", "success");
                session.removeAttribute("reviewCommentDraft");
                session.removeAttribute("reviewRatingDraft");
            } else {
                session.setAttribute("message", "Gửi đánh giá thất bại.");
                session.setAttribute("messageType", "error");
                session.setAttribute("reviewCommentDraft", comment != null ? comment : "");
                session.setAttribute("reviewRatingDraft", ratingStr != null ? ratingStr : "");
            }
        } catch (Exception e) {
            session.setAttribute("message", "Dữ liệu không hợp lệ hoặc có lỗi xảy ra.");
            session.setAttribute("messageType", "error");
            session.setAttribute("reviewCommentDraft", comment != null ? comment : "");
            session.setAttribute("reviewRatingDraft", ratingStr != null ? ratingStr : "");
        }

        // Redirect back to course details
        response.sendRedirect(request.getContextPath() + "/course?id=" + courseId + "&tab=reviews#reviews");
    }
}
