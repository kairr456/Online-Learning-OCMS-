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
            course.setStatus("pending");
            course.setRating(0);
            course.setCreatedDate(java.time.LocalDateTime.now());
            course.setModifiedDate(java.time.LocalDateTime.now());
            
            com.DAO.CourseDAO courseDAO = new com.DAO.CourseDAO();
            int courseId = courseDAO.insert(course);

            if (courseId > 0) {
                new com.DAO.CourseApprovalDAO().insertLog(courseId, "SUBMIT", "draft", "pending",
                        account.getId(), "", request.getRemoteAddr());
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

                            com.entity.Lesson lesson = new com.entity.Lesson();
                            lesson.setSectionId(sectionId);
                            lesson.setTitle(lesTitle);
                            lesson.setType("text"); // Treat as a rich text document natively
                            lesson.setOrderNumber(l + 1);
                            lesson.setDurationMinutes(0);
                            lesson.setStatus("active");
                            int lessonId = lessonDAO.insertLesson(lesson);

                            if (lessonId > 0) {
                                StringBuilder htmlContent = new StringBuilder();
                                
                                int blockCount = 0;
                                try {
                                    blockCount = Integer.parseInt(request.getParameter("blockCount_" + s + "_" + l));
                                } catch (Exception e) {}
                                
                                for (int b = 0; b < blockCount; b++) {
                                    String bType = request.getParameter("blockType_" + s + "_" + l + "_" + b);
                                    if (bType == null) continue;
                                    
                                    if ("text".equals(bType)) {
                                        String text = request.getParameter("blockText_" + s + "_" + l + "_" + b);
                                        if (text != null && !text.trim().isEmpty()) {
                                            htmlContent.append("<div class='lesson-text-block' style='margin-bottom: 20px; font-size: 16px; line-height: 1.6;'>")
                                                       .append(text.replace("\n", "<br>"))
                                                       .append("</div>");
                                        }
                                    } else if ("file".equals(bType)) {
                                        jakarta.servlet.http.Part fPart = request.getPart("blockFile_" + s + "_" + l + "_" + b);
                                        if (fPart != null && fPart.getSize() > 0) {
                                            String fName = java.nio.file.Paths.get(fPart.getSubmittedFileName()).getFileName().toString();
                                            fPart.write(uploadPath + java.io.File.separator + fName);
                                            String imgUrl = request.getContextPath() + "/assets/css/img/" + fName;
                                            htmlContent.append("<div class='lesson-img-block' style='text-align: center; margin-bottom: 20px;'>")
                                                       .append("<img src='").append(imgUrl).append("' style='max-width: 100%; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);'>")
                                                       .append("</div>");
                                        }
                                    } else if ("video".equals(bType)) {
                                        String yt = request.getParameter("blockVideo_" + s + "_" + l + "_" + b);
                                        if (yt != null && !yt.trim().isEmpty()) {
                                            String videoId = yt;
                                            if (yt.contains("v=")) {
                                                videoId = yt.substring(yt.indexOf("v=") + 2);
                                                if (videoId.contains("&")) {
                                                    videoId = videoId.substring(0, videoId.indexOf("&"));
                                                }
                                            } else if (yt.contains("youtu.be/")) {
                                                videoId = yt.substring(yt.indexOf("youtu.be/") + 9);
                                                if (videoId.contains("?")) {
                                                    videoId = videoId.substring(0, videoId.indexOf("?"));
                                                }
                                            }
                                            htmlContent.append("<div class='lesson-video-block' style='margin-bottom: 20px; text-align: center;'>")
                                                       .append("<iframe width='100%' height='500' style='max-width: 800px; border-radius: 8px;' src='https://www.youtube.com/embed/")
                                                       .append(videoId)
                                                       .append("' frameborder='0' allowfullscreen></iframe>")
                                                       .append("</div>");
                                        }
                                    }
                                }
                                
                                if (htmlContent.length() > 0) {
                                    lessonDAO.insertLessonText(lessonId, htmlContent.toString());
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
