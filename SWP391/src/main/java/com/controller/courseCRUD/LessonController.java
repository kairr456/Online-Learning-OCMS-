package com.controller.courseCRUD;

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

        // Fetch categories for dropdown
        try {
            com.DAO.CategoryDAO categoryDAO = new com.DAO.CategoryDAO();
            request.setAttribute("categories", categoryDAO.findAll());
            
            // Fetch Quiz Bank
            com.DAO.QuizDAO quizDAO = new com.DAO.QuizDAO();
            request.setAttribute("quizBank", quizDAO.getQuizBankByTeacher(account.getId()));
            
            String courseIdStr = request.getParameter("courseId");
            if (courseIdStr != null && !courseIdStr.isEmpty()) {
                int courseId = Integer.parseInt(courseIdStr);
                com.DAO.CourseDAO courseDAO = new com.DAO.CourseDAO();
                com.entity.Course course = courseDAO.findById(courseId);
                
                if (course != null && course.getCreatedBy() == account.getId()) {
                    request.setAttribute("course", course);
                    
                    com.DAO.LessonDAO lessonDAO = new com.DAO.LessonDAO();
                    java.util.List<com.entity.Section> sections = lessonDAO.getSectionsByCourseId(courseId);
                    
                    java.util.Map<Integer, java.util.List<com.entity.Lesson>> lessonsMap = new java.util.HashMap<>();
                    for (com.entity.Section sec : sections) {
                        java.util.List<com.entity.Lesson> lessons = lessonDAO.getLessonsBySectionId(sec.getId());
                        for (com.entity.Lesson les : lessons) {
                            les.setTextContent(lessonDAO.getLessonText(les.getId()));
                            les.setVideoUrl(lessonDAO.getLessonYoutube(les.getId()));
                            les.setFileUrl(lessonDAO.getLessonFileUrl(les.getId()));
                        }
                        lessonsMap.put(sec.getId(), lessons);
                    }
                    
                    request.setAttribute("sections", sections);
                    request.setAttribute("lessonsMap", lessonsMap);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Forward to the view to create/edit a course
        request.getRequestDispatcher("/view/courseCRUD/lesson.jsp").forward(request, response);
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
            String courseIdStr = request.getParameter("courseId");
            boolean isUpdate = (courseIdStr != null && !courseIdStr.trim().isEmpty());
            int courseId = isUpdate ? Integer.parseInt(courseIdStr) : 0;
            
            String courseName = request.getParameter("courseName");
            String courseDescription = request.getParameter("courseDescription");
            float coursePrice = Float.parseFloat(request.getParameter("coursePrice"));
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));

            // Thumbnail Upload
            String thumbnailRelPath = "";
            jakarta.servlet.http.Part filePart = request.getPart("courseThumbnail");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = java.nio.file.Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String uploadPath = getServletContext().getRealPath("") + java.io.File.separator + "assets" + java.io.File.separator + "css" + java.io.File.separator + "img";
                java.io.File uploadDir = new java.io.File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                thumbnailRelPath = "assets/css/img/" + fileName;
                filePart.write(uploadPath + java.io.File.separator + fileName);
            }

            com.DAO.CourseDAO courseDAO = new com.DAO.CourseDAO();
            com.entity.Course course = isUpdate ? courseDAO.findById(courseId) : new com.entity.Course();
            
            course.setName(courseName);
            course.setDescription(courseDescription);
            course.setPrice(coursePrice);
            course.setCategoryId(categoryId);
            course.setCreatedBy(account.getId());
            course.setModifiedDate(java.time.LocalDateTime.now());
            
            if (!thumbnailRelPath.isEmpty()) {
                course.setThumbnail(request.getContextPath() + "/" + thumbnailRelPath);
            } else if (!isUpdate) {
                course.setThumbnail("");
            }

            if (isUpdate) {
                courseDAO.update(course);
            } else {
                course.setStatus("pending");
                course.setRating(0);
                course.setCreatedDate(java.time.LocalDateTime.now());
                courseId = courseDAO.insert(course);
                
                if (courseId > 0) {
                    new com.DAO.CourseApprovalDAO().insertLog(courseId, "SUBMIT", "draft", "pending",
                            account.getId(), "", request.getRemoteAddr());
                }
            }

            if (courseId > 0) {
                com.DAO.LessonDAO lessonDAO = new com.DAO.LessonDAO();
                int sectionCount = 0;
                try {
                    sectionCount = Integer.parseInt(request.getParameter("sectionCount"));
                } catch (Exception e) {}

                // 2. Sections
                for (int s = 0; s < sectionCount; s++) {
                    String secTitle = request.getParameter("sectionTitle_" + s);
                    if (secTitle == null) continue; // might have been removed via JS
                    
                    String secIdStr = request.getParameter("sectionId_" + s);
                    boolean isSecUpdate = (secIdStr != null && !secIdStr.isEmpty());
                    int sectionId = isSecUpdate ? Integer.parseInt(secIdStr) : 0;

                    com.entity.Section section = new com.entity.Section();
                    section.setId(sectionId);
                    section.setCourseId(courseId);
                    section.setTitle(secTitle);
                    section.setDescription("");
                    section.setOrderNumber(s + 1);
                    section.setStatus("active");
                    
                    if (isSecUpdate) {
                        lessonDAO.updateSection(section);
                    } else {
                        sectionId = lessonDAO.insertSection(section);
                    }

                    if (sectionId > 0) {
                        int lessonCount = 0;
                        try {
                            lessonCount = Integer.parseInt(request.getParameter("lessonCount_" + s));
                        } catch (Exception e) {}
                        
                        // 3. Lessons
                        for (int l = 0; l < lessonCount; l++) {
                            String lesTitle = request.getParameter("lessonTitle_" + s + "_" + l);
                            if (lesTitle == null) continue;
                            
                            String lesIdStr = request.getParameter("lessonId_" + s + "_" + l);
                            boolean isLesUpdate = (lesIdStr != null && !lesIdStr.isEmpty());
                            int lessonId = isLesUpdate ? Integer.parseInt(lesIdStr) : 0;
                            
                            String type = request.getParameter("lessonType_" + s + "_" + l);
                            if (type == null) type = "text";

                            com.entity.Lesson lesson = new com.entity.Lesson();
                            lesson.setId(lessonId);
                            lesson.setSectionId(sectionId);
                            lesson.setTitle(lesTitle);
                            String dbType = type;
                            if ("script".equals(type) || "text_image".equals(type)) dbType = "text";
                            if ("video_image".equals(type)) dbType = "video";
                            lesson.setType(dbType);
                            lesson.setOrderNumber(l + 1);
                            lesson.setDurationMinutes(0);
                            lesson.setStatus("active");
                            
                            if (isLesUpdate) {
                                lessonDAO.updateLesson(lesson);
                            } else {
                                lessonId = lessonDAO.insertLesson(lesson);
                            }

                            if (lessonId > 0) {
                                // Handle specific lesson types
                                if ("script".equals(type) || "text".equals(type) || "text_image".equals(type)) {
                                    StringBuilder htmlContent = new StringBuilder();
                                    int blockCount = 0;
                                    try {
                                        blockCount = Integer.parseInt(request.getParameter("blockCount_" + s + "_" + l));
                                    } catch (Exception e) {}
                                    
                                    String uploadPath = getServletContext().getRealPath("") + java.io.File.separator + "assets" + java.io.File.separator + "css" + java.io.File.separator + "img";
                                    java.io.File uploadDir = new java.io.File(uploadPath);
                                    if (!uploadDir.exists()) uploadDir.mkdirs();

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
                                            String existingFile = request.getParameter("existingFile_" + s + "_" + l + "_" + b);
                                            jakarta.servlet.http.Part fPart = request.getPart("blockFile_" + s + "_" + l + "_" + b);
                                            
                                            String imgUrl = existingFile;
                                            if (fPart != null && fPart.getSize() > 0) {
                                                String fName = java.nio.file.Paths.get(fPart.getSubmittedFileName()).getFileName().toString();
                                                fPart.write(uploadPath + java.io.File.separator + fName);
                                                imgUrl = request.getContextPath() + "/assets/css/img/" + fName;
                                            }
                                            
                                            if (imgUrl != null && !imgUrl.trim().isEmpty()) {
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
                                        lessonDAO.upsertLessonText(lessonId, htmlContent.toString());
                                    }
                                } else if ("video".equals(type) || "video_image".equals(type)) {
                                    String yt = request.getParameter("lessonVideo_" + s + "_" + l);
                                    if (yt != null) {
                                        String videoId = yt;
                                        if (yt.contains("v=")) {
                                            videoId = yt.substring(yt.indexOf("v=") + 2);
                                            if (videoId.contains("&")) videoId = videoId.substring(0, videoId.indexOf("&"));
                                        } else if (yt.contains("youtu.be/")) {
                                            videoId = yt.substring(yt.indexOf("youtu.be/") + 9);
                                            if (videoId.contains("?")) videoId = videoId.substring(0, videoId.indexOf("?"));
                                        }
                                        lessonDAO.upsertLessonVideo(lessonId, videoId);
                                    }
                                } else if ("quiz".equals(type)) {
                                    String quizId = request.getParameter("lessonQuiz_" + s + "_" + l);
                                    if (quizId != null) {
                                        lessonDAO.upsertLessonText(lessonId, "Quiz ID: " + quizId); // Placeholder
                                    }
                                }
                            }
                        }
                    }
                }
                
                session.setAttribute("message", isUpdate ? "Course updated successfully!" : "Course created successfully!");
                session.setAttribute("messageType", "success");
                response.sendRedirect(request.getContextPath() + (isUpdate ? "/course-dashboard" : "/courses"));
            } else {
                throw new Exception("Failed to save course.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error saving course: " + e.getMessage());
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/lesson");
        }
    }
}

