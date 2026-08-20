/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.controller.home;

import com.DAO.AccountDAO;
import com.DAO.CourseDAO;
import com.DAO.ReviewDAO;
import com.entity.Course;
import com.entity.Review;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller to view course details
 */
@WebServlet(name = "BrowseCourseDetailsController", urlPatterns = {"/course"})
public class BrowseCourseDetailsController extends HttpServlet {
    private static final String COURSE_DETAILS_PAGE = "view/common/home/course-details.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                int courseId = Integer.parseInt(idParam);
                
                CourseDAO courseDAO = new CourseDAO();
                Course course = courseDAO.findById(courseId);
                
                if (course != null) {
                    AccountDAO accountDAO = new AccountDAO();
                    Map<Integer, String> authorNames = accountDAO.getAuthorNames();
                    
                    ReviewDAO reviewDAO = new ReviewDAO();
                    List<Review> reviews = reviewDAO.getReviewsByCourseId(courseId);
                    
                    com.DAO.LessonDAO lessonDAO = new com.DAO.LessonDAO();
                    java.util.List<com.entity.Section> sections = lessonDAO.getSectionsByCourseId(courseId);
                    java.util.Map<Integer, java.util.List<com.entity.Lesson>> lessonsMap = new java.util.HashMap<>();
                    java.util.Map<Integer, String> lessonVideosMap = new java.util.HashMap<>();
                    
                    for (com.entity.Section s : sections) {
                        java.util.List<com.entity.Lesson> ls = lessonDAO.getLessonsBySectionId(s.getId());
                        lessonsMap.put(s.getId(), ls);
                        for (com.entity.Lesson l : ls) {
                            if ("video".equals(l.getType())) {
                                lessonVideosMap.put(l.getId(), lessonDAO.getLessonYoutube(l.getId()));
                            }
                        }
                    }
                    
                    boolean isEnrolled = false;
                    com.entity.Account account = (com.entity.Account) request.getSession().getAttribute("account");
                    if (account != null) {
                        if (course.getCreatedBy() == account.getId()) {
                            isEnrolled = true;
                        } else {
                            com.DAO.CourseRegistrationDAO regDAO = new com.DAO.CourseRegistrationDAO();
                            java.util.List<Course> enrolledCourses = regDAO.getCoursesByAccountId(account.getId());
                            for (Course c : enrolledCourses) {
                                if (c.getId() == courseId) {
                                    isEnrolled = true;
                                    break;
                                }
                            }
                        }
                    }
                    
                    int firstLessonId = -1;
                    if (!sections.isEmpty()) {
                        java.util.List<com.entity.Lesson> firstSectionLessons = lessonsMap.get(sections.get(0).getId());
                        if (firstSectionLessons != null && !firstSectionLessons.isEmpty()) {
                            firstLessonId = firstSectionLessons.get(0).getId();
                        }
                    }
                    
                    com.DAO.CategoryDAO categoryDAO = new com.DAO.CategoryDAO();
                    String categoryName = categoryDAO.getCategoryName(course.getCategoryId());
                    if (categoryName == null || categoryName.trim().isEmpty()) {
                        categoryName = "General";
                    }

                    List<java.util.Map<String, Object>> starDistributionList = new java.util.ArrayList<>();
                    int reviewCount = (reviews != null) ? reviews.size() : 0;
                    double avgRating = 0.0;
                    if (reviewCount > 0) {
                        double sum = 0;
                        for (Review r : reviews) {
                            sum += r.getRating();
                        }
                        avgRating = Math.round((sum / reviewCount) * 10.0) / 10.0;
                    }

                    for (int star = 5; star >= 1; star--) {
                        int count = 0;
                        if (reviews != null) {
                            for (Review r : reviews) {
                                if (r.getRating() == star) {
                                    count++;
                                }
                            }
                        }
                        int percent = reviewCount > 0 ? (count * 100 / reviewCount) : 0;
                        java.util.Map<String, Object> item = new java.util.HashMap<>();
                        item.put("star", star);
                        item.put("count", count);
                        item.put("percent", percent);
                        starDistributionList.add(item);
                    }
                    course.setRating((int) Math.round(avgRating));

                    request.setAttribute("course", course);
                    request.setAttribute("authorName", authorNames.get(course.getCreatedBy()));
                    request.setAttribute("categoryName", categoryName);
                    request.setAttribute("reviews", reviews);
                    request.setAttribute("avgRating", avgRating);
                    request.setAttribute("reviewCount", reviewCount);
                    request.setAttribute("starDistributionList", starDistributionList);
                    request.setAttribute("sections", sections);
                    request.setAttribute("lessonsMap", lessonsMap);
                    request.setAttribute("lessonVideosMap", lessonVideosMap);
                    request.setAttribute("isEnrolled", isEnrolled);
                    request.setAttribute("firstLessonId", firstLessonId);
                    // Also pass authorNames so we can lookup reviewer names in the JSP
                    request.setAttribute("accountNames", authorNames);
                } else {
                    response.sendRedirect("404.jsp");
                    return;
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/courses");
                return;
            }

            // Forward to course-details.jsp
            request.getRequestDispatcher(COURSE_DETAILS_PAGE).forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("404.jsp");
        }
    }
}

