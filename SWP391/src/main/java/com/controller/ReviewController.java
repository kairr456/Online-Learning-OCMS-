package com.controller;

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
            
            com.entity.Review review = new com.entity.Review();
            review.setCourseId(courseId);
            review.setAccountId(account.getId());
            review.setRating(rating);
            review.setComment(comment);
            
            com.DAO.ReviewDAO reviewDAO = new com.DAO.ReviewDAO();
            boolean success = reviewDAO.insert(review);
            
            if (success) {
                session.setAttribute("message", "Review submitted successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Failed to submit review.");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            session.setAttribute("message", "Invalid input or error occurred.");
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
