package com.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/lesson")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 50,       // 50MB
    maxRequestSize = 1024 * 1024 * 100    // 100MB
)
public class LessonController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Ensure user is a teacher
        HttpSession session = request.getSession();
        com.entity.Account account = (com.entity.Account) session.getAttribute("account");
        
        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Just forward to the view to create a new course
        request.getRequestDispatcher("/view/course_learning/lesson.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        com.entity.Account account = (com.entity.Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // 1. Course Details
            String courseName = request.getParameter("courseName");
            String courseDescription = request.getParameter("courseDescription");
            float coursePrice = Float.parseFloat(request.getParameter("coursePrice"));
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));

            // Thumbnail Upload
            jakarta.servlet.http.Part filePart = request.getPart("courseThumbnail");
            String fileName = java.nio.file.Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uploadPath = getServletContext().getRealPath("") + java.io.File.separator + "assets" + java.io.File.separator + "css" + java.io.File.separator + "img";
            java.io.File uploadDir = new java.io.File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();
            String thumbnailRelPath = "assets/css/img/" + fileName;
            filePart.write(uploadPath + java.io.File.separator + fileName);

            // Insert Course
            com.entity.Course course = new com.entity.Course();
            course.setName(courseName);
            course.setDescription(courseDescription);
            course.setPrice(coursePrice);
            course.setCategoryId(categoryId);
            course.setCreatedBy(account.getId());
            course.setThumbnail(request.getContextPath() + "/" + thumbnailRelPath);
            course.setStatus("active");
            course.setRating(0);
            
            com.DAO.CourseDAO courseDAO = new com.DAO.CourseDAO();
            int courseId = courseDAO.insert(course);

            if (courseId > 0) {
                com.DAO.LessonDAO lessonDAO = new com.DAO.LessonDAO();
                int sectionCount = Integer.parseInt(request.getParameter("sectionCount"));

                // 2. Sections
                for (int s = 0; s < sectionCount; s++) {
                    String secTitle = request.getParameter("sectionTitle_" + s);
                    if (secTitle == null) continue; // might have been removed via JS

                    com.entity.Section section = new com.entity.Section();
                    section.setCourseId(courseId);
                    section.setTitle(secTitle);
                    section.setDescription("");
                    section.setOrderNumber(s + 1);
                    section.setStatus("active");
                    int sectionId = lessonDAO.insertSection(section);

                    if (sectionId > 0) {
                        int lessonCount = Integer.parseInt(request.getParameter("lessonCount_" + s));
                        // 3. Lessons
                        for (int l = 0; l < lessonCount; l++) {
                            String lesTitle = request.getParameter("lessonTitle_" + s + "_" + l);
                            if (lesTitle == null) continue;

                            String type = request.getParameter("lessonType_" + s + "_" + l);
                            com.entity.Lesson lesson = new com.entity.Lesson();
                            lesson.setSectionId(sectionId);
                            lesson.setTitle(lesTitle);
                            lesson.setType(type);
                            lesson.setOrderNumber(l + 1);
                            lesson.setDurationMinutes(0);
                            lesson.setStatus("active");
                            int lessonId = lessonDAO.insertLesson(lesson);

                            if (lessonId > 0) {
                                if ("video".equals(type)) {
                                    String yt = request.getParameter("lessonYoutube_" + s + "_" + l);
                                    lessonDAO.insertLessonVideo(lessonId, yt);
                                } else if ("file".equals(type)) {
                                    jakarta.servlet.http.Part lPart = request.getPart("lessonFile_" + s + "_" + l);
                                    if (lPart != null && lPart.getSize() > 0) {
                                        String lName = java.nio.file.Paths.get(lPart.getSubmittedFileName()).getFileName().toString();
                                        lPart.write(uploadPath + java.io.File.separator + lName);
                                        lessonDAO.insertLessonFile(lessonId, request.getContextPath() + "/assets/css/img/" + lName);
                                    }
                                } else if ("text".equals(type)) {
                                    String text = request.getParameter("lessonText_" + s + "_" + l);
                                    lessonDAO.insertLessonText(lessonId, text);
                                }
                            }
                        }
                    }
                }
                
                session.setAttribute("message", "Course created successfully!");
                session.setAttribute("messageType", "success");
                response.sendRedirect(request.getContextPath() + "/courses");
            } else {
                throw new Exception("Failed to insert course.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error creating course: " + e.getMessage());
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/lesson");
        }
    }
}
