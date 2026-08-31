package com.controller.courseCRUD;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LessonController", urlPatterns = {"/lesson"})
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
            
            com.DAO.CourseDAO courseDAO = new com.DAO.CourseDAO();
            request.setAttribute("teacherCourses", courseDAO.findByCreator(account.getId()));
            
            // Fetch Quiz Bank
            com.DAO.QuizDAO quizDAO = new com.DAO.QuizDAO();
            request.setAttribute("quizBank", quizDAO.getQuizBankByTeacher(account.getId()));
            
            String courseIdStr = request.getParameter("courseId");
            if (courseIdStr != null && !courseIdStr.isEmpty()) {
                int courseId = Integer.parseInt(courseIdStr);
                com.entity.Course course = courseDAO.findById(courseId);
                
                if (course != null && course.getCreatedBy() == account.getId()) {
                    String status = course.getStatus();
                    if ("active".equalsIgnoreCase(status) || "pending".equalsIgnoreCase(status)) {
                        response.sendRedirect(request.getContextPath() + "/course-dashboard");
                        return;
                    }
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
                            if ("quiz".equals(les.getType())) {
                                les.setQuizConfig(lessonDAO.getLessonQuizConfig(les.getId()));
                            }
                        }
                        lessonsMap.put(sec.getId(), lessons);
                    }
                    
                    request.setAttribute("sections", sections);
                    request.setAttribute("lessonsMap", lessonsMap);
                    
                    java.util.List<com.entity.QuestionGroup> questionGroups = new com.DAO.QuestionGroupDAO().getGroupsByCourseId(courseId);
                    request.setAttribute("questionGroups", questionGroups);
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
             String courseIdStr = request.getParameter("courseId");
             boolean isUpdate = (courseIdStr != null && !courseIdStr.trim().isEmpty());
             int courseId = isUpdate ? Integer.parseInt(courseIdStr) : 0;
             if (isUpdate) {
                 com.entity.Course existingCourse = new com.DAO.CourseDAO().findById(courseId);
                 if (existingCourse != null) {
                     String status = existingCourse.getStatus();
                     if ("active".equalsIgnoreCase(status) || "pending".equalsIgnoreCase(status)) {
                         response.sendRedirect(request.getContextPath() + "/course-dashboard");
                         return;
                     }
                 }
             }
            
            String submitAction = request.getParameter("submitAction");
            boolean isDraft = "continue".equals(submitAction) || "goto_qbank".equals(submitAction);

            String courseName = request.getParameter("courseName");
            if (courseName != null) {
                courseName = courseName.replaceAll("[\\r\\n]+", " ").trim();
            }
            if (courseName == null || courseName.isEmpty()) {
                if (!isDraft) {
                    throw new IllegalArgumentException("Vui lòng nhập tên khóa học!");
                } else {
                    courseName = "Khóa học nháp (" + java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").format(java.time.LocalDateTime.now()) + ")";
                }
            }
            if (courseName.length() > 150) {
                throw new IllegalArgumentException("Tiêu đề khóa học (Course Title) không được vượt quá 150 ký tự (độ dài hiện tại: " + courseName.length() + ")!");
            }

            com.DAO.CourseDAO courseDAO = new com.DAO.CourseDAO();
            if (courseDAO.checkCourseNameExists(account.getId(), courseName, courseId)) {
                throw new IllegalArgumentException("Tên khóa học '" + courseName + "' đã tồn tại trong danh sách của bạn! Vui lòng chọn tên khác.");
            }

            String catIdStr = request.getParameter("categoryId");
            int categoryId = 0;
            try {
                categoryId = Integer.parseInt(catIdStr);
            } catch (Exception e) {}
            if (categoryId <= 0) {
                if (!isDraft) {
                    throw new IllegalArgumentException("Vui lòng chọn danh mục khóa học!");
                } else {
                    try {
                        java.util.List<com.entity.Category> catList = new com.DAO.CategoryDAO().findAll();
                        if (catList != null && !catList.isEmpty()) {
                            categoryId = catList.get(0).getId();
                        }
                    } catch (Exception ignored) {}
                }
            }

            String courseDescription = request.getParameter("courseDescription");
            if (courseDescription == null || courseDescription.trim().isEmpty()) {
                if (!isDraft) {
                    throw new IllegalArgumentException("Vui lòng nhập mô tả khóa học!");
                } else {
                    courseDescription = "";
                }
            }
            courseDescription = courseDescription.trim();
            if (courseDescription.length() > 5000) {
                throw new IllegalArgumentException("Mô tả tổng quan (Overview / Description) không được vượt quá 5000 ký tự (độ dài hiện tại: " + courseDescription.length() + ")!");
            }

            float coursePrice = 0f;
            try {
                String priceStr = request.getParameter("coursePrice");
                if (priceStr != null && !priceStr.trim().isEmpty()) {
                    coursePrice = Float.parseFloat(priceStr);
                    if (coursePrice < 0) coursePrice = 0f;
                }
            } catch (Exception e) {
                if (!isDraft) {
                    throw new IllegalArgumentException("Vui lòng nhập giá khóa học hợp lệ (>= 0)!");
                }
            }

            // Thumbnail Upload
            String thumbnailRelPath = "";
            jakarta.servlet.http.Part filePart = request.getPart("courseThumbnail");
            if (filePart != null && filePart.getSize() > 0) {
                if (filePart.getSize() > 1024 * 1024) {
                    throw new IllegalArgumentException("Dung lượng ảnh Thumbnail không được vượt quá 1MB!");
                }
                String fileName = java.nio.file.Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String fNameLower = fileName.toLowerCase();
                if (!fNameLower.endsWith(".jpg") && !fNameLower.endsWith(".jpeg") && !fNameLower.endsWith(".png")) {
                    throw new IllegalArgumentException("Ảnh Thumbnail chỉ chấp nhận định dạng JPG, JPEG hoặc PNG!");
                }
                 String buildPath = getServletContext().getRealPath("");
                 String uploadPath = buildPath + java.io.File.separator + "assets" + java.io.File.separator + "img";
                 java.io.File uploadDir = new java.io.File(uploadPath);
                 if (!uploadDir.exists()) uploadDir.mkdirs();
                 thumbnailRelPath = "assets/img/" + fileName;
                 filePart.write(uploadPath + java.io.File.separator + fileName);

                 // Also save to source directory so it is not lost on server restart/rebuild
                 try {
                     String srcPath = buildPath;
                     if (buildPath.contains("target" + java.io.File.separator + "Test")) {
                         srcPath = buildPath.replace("target" + java.io.File.separator + "Test", "src" + java.io.File.separator + "main" + java.io.File.separator + "webapp");
                     } else if (buildPath.contains("build" + java.io.File.separator + "web")) {
                         srcPath = buildPath.replace("build" + java.io.File.separator + "web", "src" + java.io.File.separator + "main" + java.io.File.separator + "webapp");
                     }
                     if (!srcPath.equals(buildPath)) {
                         String srcUploadPath = srcPath + java.io.File.separator + "assets" + java.io.File.separator + "img";
                         java.io.File srcUploadDir = new java.io.File(srcUploadPath);
                         if (!srcUploadDir.exists()) srcUploadDir.mkdirs();
                         java.nio.file.Files.copy(
                             filePart.getInputStream(), 
                             java.nio.file.Paths.get(srcUploadPath, fileName), 
                             java.nio.file.StandardCopyOption.REPLACE_EXISTING
                         );
                     }
                 } catch (Exception ex) {
                     System.out.println("[LessonController] Warning: Could not copy upload to source directory: " + ex.getMessage());
                 }
            } else if (!isUpdate && !isDraft) {
                throw new IllegalArgumentException("Vui lòng tải lên ảnh Thumbnail cho khóa học!");
            }

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

            // Pre-validate all Sections and Lessons
            int sectionCount = 0;
            try {
                sectionCount = Integer.parseInt(request.getParameter("sectionCount"));
            } catch (Exception e) {}

            java.util.Set<String> sectionTitles = new java.util.HashSet<>();
            int validSectionCount = 0;

            for (int s = 0; s < sectionCount; s++) {
                String secTitle = request.getParameter("sectionTitle_" + s);
                if (secTitle == null || secTitle.trim().isEmpty()) continue;
                secTitle = secTitle.trim();
                if (secTitle.length() > 255) {
                    throw new IllegalArgumentException("Tiêu đề chương học (Section Title) không được vượt quá 255 ký tự (độ dài hiện tại: " + secTitle.length() + ")!");
                }
                validSectionCount++;
                
                if (sectionTitles.contains(secTitle.toLowerCase())) {
                    throw new IllegalArgumentException("Tên Section '" + secTitle + "' bị trùng lặp trong khóa học! Các Section phải có tên khác nhau.");
                }
                sectionTitles.add(secTitle.toLowerCase());
                
                int lessonCount = 0;
                try {
                    lessonCount = Integer.parseInt(request.getParameter("lessonCount_" + s));
                } catch (Exception e) {}
                
                java.util.Set<String> lessonTitles = new java.util.HashSet<>();
                int validLessonCount = 0;
                
                for (int l = 0; l < lessonCount; l++) {
                    String lesTitle = request.getParameter("lessonTitle_" + s + "_" + l);
                    if (lesTitle == null || lesTitle.trim().isEmpty()) continue;
                    lesTitle = lesTitle.trim();
                    if (lesTitle.length() > 255) {
                        throw new IllegalArgumentException("Tiêu đề bài học (Lesson Title) không được vượt quá 255 ký tự (độ dài hiện tại: " + lesTitle.length() + ")!");
                    }
                    validLessonCount++;
                    
                    if (lessonTitles.contains(lesTitle.toLowerCase())) {
                        throw new IllegalArgumentException("Tên bài học '" + lesTitle + "' bị trùng lặp trong Section '" + secTitle + "'! Các bài học trong cùng một Section phải có tên khác nhau.");
                    }
                    lessonTitles.add(lesTitle.toLowerCase());
                    
                    String type = request.getParameter("lessonType_" + s + "_" + l);
                    if (type == null) type = "script";
                    
                    if ("script".equals(type) || "text".equals(type) || "text_image".equals(type)) {
                        int blockCount = 0;
                        try {
                            blockCount = Integer.parseInt(request.getParameter("blockCount_" + s + "_" + l));
                        } catch (Exception e) {}
                        
                        int validBlocks = 0;
                        for (int b = 0; b < blockCount; b++) {
                            String bType = request.getParameter("blockType_" + s + "_" + l + "_" + b);
                            if (bType == null) continue;
                            if ("text".equals(bType)) {
                                String text = request.getParameter("blockText_" + s + "_" + l + "_" + b);
                                if (text != null && !text.trim().isEmpty()) {
                                    if (text.trim().length() > 5000) {
                                        throw new IllegalArgumentException("Nội dung khối văn bản trong bài học '" + lesTitle + "' không được vượt quá 5000 ký tự (độ dài hiện tại: " + text.trim().length() + ")!");
                                    }
                                    validBlocks++;
                                }
                            } else if ("file".equals(bType)) {
                                String existingFile = request.getParameter("existingFile_" + s + "_" + l + "_" + b);
                                jakarta.servlet.http.Part fPart = request.getPart("blockFile_" + s + "_" + l + "_" + b);
                                if ((existingFile != null && !existingFile.trim().isEmpty()) || (fPart != null && fPart.getSize() > 0)) {
                                    if (fPart != null && fPart.getSize() > 0) {
                                        String fName = java.nio.file.Paths.get(fPart.getSubmittedFileName()).getFileName().toString().toLowerCase();
                                        if (!fName.endsWith(".jpg") && !fName.endsWith(".jpeg") && !fName.endsWith(".png")) {
                                            throw new IllegalArgumentException("Ảnh bài học chỉ chấp nhận định dạng JPG, JPEG hoặc PNG!");
                                        }
                                    }
                                    validBlocks++;
                                }
                            }
                        }
                        if (!isDraft && validBlocks == 0) {
                            throw new IllegalArgumentException("Nội dung bài học '" + lesTitle + "' không được để trống (cần ít nhất 1 khối nội dung văn bản hoặc hình ảnh)!");
                        }
                    } else if ("video".equals(type) || "video_image".equals(type)) {
                        String yt = request.getParameter("lessonVideo_" + s + "_" + l);
                        if (yt != null && yt.trim().length() > 500) {
                            throw new IllegalArgumentException("Đường dẫn video YouTube bài học '" + lesTitle + "' không được vượt quá 500 ký tự!");
                        }
                        if (!isDraft && (yt == null || yt.trim().isEmpty())) {
                            throw new IllegalArgumentException("Vui lòng nhập đường dẫn video YouTube cho bài học '" + lesTitle + "'!");
                        }
                    } else if ("quiz".equals(type)) {
                        String qGroupStr = request.getParameter("lessonQuizGroup_" + s + "_" + l);
                        String qNumStr = request.getParameter("lessonQuizNum_" + s + "_" + l);
                        String qTimeStr = request.getParameter("lessonQuizTime_" + s + "_" + l);
                        String qRetakeStr = request.getParameter("lessonQuizRetake_" + s + "_" + l);
                        String qPassStr = request.getParameter("lessonQuizPass_" + s + "_" + l);
                        
                        if (!isDraft) {
                            if (qGroupStr == null || qGroupStr.trim().isEmpty()) {
                                throw new IllegalArgumentException("Vui lòng chọn Bộ Đề (Question Group) cho bài Quiz '" + lesTitle + "'!");
                            }
                            try {
                                int qNum = Integer.parseInt(qNumStr.trim());
                                int qTime = Integer.parseInt(qTimeStr.trim());
                                int qRetake = Integer.parseInt(qRetakeStr.trim());
                                int qPass = Integer.parseInt(qPassStr.trim());
                                if (qNum <= 0) throw new IllegalArgumentException("Số câu hỏi xuất ra phải lớn hơn 0 trong bài Quiz '" + lesTitle + "'!");
                                if (qTime <= 0) throw new IllegalArgumentException("Thời gian làm bài phải lớn hơn 0 phút trong bài Quiz '" + lesTitle + "'!");
                                if (qRetake < 1) throw new IllegalArgumentException("Số lần làm lại tối đa phải từ 1 trở lên trong bài Quiz '" + lesTitle + "'!");
                                if (qPass < 1 || qPass > 100) throw new IllegalArgumentException("Điểm Pass phải từ 1 đến 100% trong bài Quiz '" + lesTitle + "'!");
                            } catch (Exception e) {
                                if (e instanceof IllegalArgumentException) throw e;
                                throw new IllegalArgumentException("Các thông số cấu hình bài Quiz '" + lesTitle + "' không được để trống và phải là số hợp lệ!");
                            }
                        }
                    }
                }
                
                if (!isDraft && validLessonCount == 0) {
                    throw new IllegalArgumentException("Section '" + secTitle + "' phải có ít nhất 1 bài học!");
                }
            }

            if (!isDraft && validSectionCount == 0) {
                throw new IllegalArgumentException("Khóa học phải có ít nhất 1 Section (Chương học)!");
            }

            if (isUpdate) {
                // If teacher clicks "Publish" (exit) on a draft course → upgrade to pending for admin review
                String currentStatus = course.getStatus();
                if (!isDraft && ("draft".equalsIgnoreCase(currentStatus) || "cancelled".equalsIgnoreCase(currentStatus) || "rejected".equalsIgnoreCase(currentStatus))) {
                    course.setStatus("pending");
                    courseDAO.update(course);
                    new com.DAO.CourseApprovalDAO().insertLog(courseId, "SUBMIT", currentStatus, "pending",
                            account.getId(), "", request.getRemoteAddr());
                } else if (isDraft && "active".equals(currentStatus)) {
                    // Teacher is editing an active course → keep active, just save changes
                    courseDAO.update(course);
                } else {
                    // Keep existing status (draft stays draft on Save Draft, pending/active stays unchanged)
                    courseDAO.update(course);
                }
            } else {
                course.setStatus(isDraft ? "draft" : "pending");
                course.setRating(0);
                course.setCreatedDate(java.time.LocalDateTime.now());
                courseId = courseDAO.insert(course);
                
                if (courseId > 0) {
                    new com.DAO.CourseApprovalDAO().insertLog(courseId, "SUBMIT", "draft", "pending",
                            account.getId(), "", request.getRemoteAddr());
                            
                    // Automatically enroll the teacher in their own course
                    try {
                        String enrollSql = "INSERT INTO registration (account_id, course_id, status) VALUES (?, ?, 'Active')";
                        try (java.sql.PreparedStatement ps = new com.DAO.DBContext().getConnection().prepareStatement(enrollSql)) {
                            ps.setInt(1, account.getId());
                            ps.setInt(2, courseId);
                            ps.executeUpdate();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            if (courseId > 0) {
                com.DAO.LessonDAO lessonDAO = new com.DAO.LessonDAO();
                try {
                    sectionCount = Integer.parseInt(request.getParameter("sectionCount"));
                } catch (Exception e) {}

                java.util.List<Integer> keptSectionIds = new java.util.ArrayList<>();
                java.util.List<Integer> keptLessonIds = new java.util.ArrayList<>();

                // 2. Sections
                for (int s = 0; s < sectionCount; s++) {
                    String secTitle = request.getParameter("sectionTitle_" + s);
                    if (secTitle == null || secTitle.trim().isEmpty()) continue; // might have been removed via JS
                    
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
                        keptSectionIds.add(sectionId);
                        int lessonCount = 0;
                        try {
                            lessonCount = Integer.parseInt(request.getParameter("lessonCount_" + s));
                        } catch (Exception e) {}
                        
                        // 3. Lessons
                        for (int l = 0; l < lessonCount; l++) {
                            String lesTitle = request.getParameter("lessonTitle_" + s + "_" + l);
                            if (lesTitle == null || lesTitle.trim().isEmpty()) continue;
                            
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
                                keptLessonIds.add(lessonId);
                                // Handle specific lesson types
                                if ("script".equals(type) || "text".equals(type) || "text_image".equals(type)) {
                                    StringBuilder htmlContent = new StringBuilder();
                                    int blockCount = 0;
                                    try {
                                        blockCount = Integer.parseInt(request.getParameter("blockCount_" + s + "_" + l));
                                    } catch (Exception e) {}
                                    
                                    String buildPath = getServletContext().getRealPath("");
                                    String uploadPath = buildPath + java.io.File.separator + "assets" + java.io.File.separator + "img";
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
                                                if (fPart.getSize() > 1024 * 1024) {
                                                    throw new IllegalArgumentException("Dung lượng ảnh khối bài học không được vượt quá 1MB!");
                                                }
                                                String fName = java.nio.file.Paths.get(fPart.getSubmittedFileName()).getFileName().toString();
                                                fPart.write(uploadPath + java.io.File.separator + fName);
                                                imgUrl = request.getContextPath() + "/assets/img/" + fName;

                                                // Also save to source directory so it is not lost on server restart/rebuild
                                                try {
                                                    String srcPath = buildPath;
                                                    if (buildPath.contains("target" + java.io.File.separator + "Test")) {
                                                        srcPath = buildPath.replace("target" + java.io.File.separator + "Test", "src" + java.io.File.separator + "main" + java.io.File.separator + "webapp");
                                                    } else if (buildPath.contains("build" + java.io.File.separator + "web")) {
                                                        srcPath = buildPath.replace("build" + java.io.File.separator + "web", "src" + java.io.File.separator + "main" + java.io.File.separator + "webapp");
                                                    }
                                                    if (!srcPath.equals(buildPath)) {
                                                        String srcUploadPath = srcPath + java.io.File.separator + "assets" + java.io.File.separator + "img";
                                                        java.io.File srcUploadDir = new java.io.File(srcUploadPath);
                                                        if (!srcUploadDir.exists()) srcUploadDir.mkdirs();
                                                        java.nio.file.Files.copy(
                                                            fPart.getInputStream(), 
                                                            java.nio.file.Paths.get(srcUploadPath, fName), 
                                                            java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                                        );
                                                    }
                                                } catch (Exception ex) {
                                                    System.out.println("[LessonController] Warning: Could not copy block file to source directory: " + ex.getMessage());
                                                }
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
                                    String qGroupStr = request.getParameter("lessonQuizGroup_" + s + "_" + l);
                                    String qNumStr = request.getParameter("lessonQuizNum_" + s + "_" + l);
                                    String qTimeStr = request.getParameter("lessonQuizTime_" + s + "_" + l);
                                    String qRetakeStr = request.getParameter("lessonQuizRetake_" + s + "_" + l);
                                    String qPassStr = request.getParameter("lessonQuizPass_" + s + "_" + l);
                                    
                                    if (qGroupStr != null && !qGroupStr.isEmpty()) {
                                        try {
                                            int qGroup = Integer.parseInt(qGroupStr);
                                            int qNum = Integer.parseInt(qNumStr);
                                            int qTime = Integer.parseInt(qTimeStr);
                                            int qRetake = Integer.parseInt(qRetakeStr);
                                            int qPass = Integer.parseInt(qPassStr);
                                            lessonDAO.upsertLessonQuiz(lessonId, qNum, qTime, qRetake, qPass, qGroup);
                                        } catch (NumberFormatException e) {
                                            e.printStackTrace();
                                        }
                                    }
                        }
                            }
                        }
                    }
                }
                
                if (isUpdate) {
                    lessonDAO.cleanupRemovedSectionsAndLessons(courseId, keptSectionIds, keptLessonIds);
                }
                
                submitAction = request.getParameter("submitAction");
                session.setAttribute("message", isUpdate ? (isDraft ? "Đã lưu nháp khóa học thành công!" : "Cập nhật khóa học thành công!") : (isDraft ? "Đã tạo và lưu nháp khóa học thành công!" : "Tạo khóa học thành công!"));
                session.setAttribute("messageType", "success");
                
                if ("goto_qbank".equals(submitAction)) {
                    response.sendRedirect(request.getContextPath() + "/question-bank?courseId=" + courseId);
                } else if ("continue".equals(submitAction)) {
                    response.sendRedirect(request.getContextPath() + "/lesson?courseId=" + courseId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
                }
            } else {
                throw new Exception("Failed to save course.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Error saving course: " + e.getMessage());
            session.setAttribute("messageType", "error");
            String cId = request.getParameter("courseId");
            if (cId != null && !cId.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/lesson?courseId=" + cId.trim());
            } else {
                response.sendRedirect(request.getContextPath() + "/lesson");
            }
        }
    }
}









