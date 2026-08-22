package com.controller.auth;

import com.DAO.AccountDAO;
import com.DAO.TeacherProfileDAO;
import com.entity.Account;
import com.entity.TeacherProfile;
import com.validator.TeacherProfileValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;

@WebServlet("/teacher-register-step2")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 5 * 1024 * 1024,   // 5MB
        maxRequestSize = 10 * 1024 * 1024 // 10MB
)
public class TeacherRegisterStep2Controller extends HttpServlet {

    private static final String UPLOAD_DIR = "assets/css/uploads/teacher-cv";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accountIdStr = request.getParameter("accountId");
        if (accountIdStr == null || accountIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        int accountId;
        try {
            accountId = Integer.parseInt(accountIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        AccountDAO accountDAO = new AccountDAO();
        Account account = accountDAO.getAccountById(accountId);

        if (account == null || account.getRoleId() != 2 || account.isActive()) {
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        // Check if profile already exists
        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        TeacherProfile existing = profileDAO.findByTeacherId(accountId);
        if (existing != null) {
            request.setAttribute("errorMessage", "Hồ sơ giáo viên đã tồn tại.");
            request.getRequestDispatcher("/view/authen/teacherRegisterStep2.jsp")
                    .forward(request, response);
            return;
        }

        request.setAttribute("account", account);
        request.getRequestDispatcher("/view/authen/teacherRegisterStep2.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String accountIdStr = request.getParameter("accountId");
        if (accountIdStr == null || accountIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        int accountId;
        try {
            accountId = Integer.parseInt(accountIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        AccountDAO accountDAO = new AccountDAO();
        Account account = accountDAO.getAccountById(accountId);

        if (account == null || account.getRoleId() != 2 || account.isActive()) {
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        // Get form fields
        String headline = request.getParameter("headline");
        String bio = request.getParameter("bio");
        String yearsExperienceStr = request.getParameter("yearsExperience");
        String education = request.getParameter("education");
        String certifications = request.getParameter("certifications");
        String linkedinUrl = request.getParameter("linkedinUrl");
        String websiteUrl = request.getParameter("websiteUrl");
        String avatarUrl = request.getParameter("avatarUrl");

        Part cvFile = request.getPart("cvFile");

        // Validate
        String validationError = TeacherProfileValidator.validate(
                headline, bio, yearsExperienceStr, education, certifications,
                linkedinUrl, websiteUrl, avatarUrl, cvFile
        );

        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            request.setAttribute("account", account);
            // Repopulate form data
            request.setAttribute("headline", headline);
            request.setAttribute("bio", bio);
            request.setAttribute("yearsExperience", yearsExperienceStr);
            request.setAttribute("education", education);
            request.setAttribute("certifications", certifications);
            request.setAttribute("linkedinUrl", linkedinUrl);
            request.setAttribute("websiteUrl", websiteUrl);
            request.setAttribute("avatarUrl", avatarUrl);
            request.getRequestDispatcher("/view/authen/teacherRegisterStep2.jsp")
                    .forward(request, response);
            return;
        }

        // Handle CV upload
        String cvFilePath = null;
        if (cvFile != null && cvFile.getSize() > 0) {
            String contentType = cvFile.getContentType();
            String ext = getFileExtension(contentType);
            String fileName = "cv_" + accountId + "_" + System.currentTimeMillis() + ext;

            String uploadPath = getServletContext().getRealPath("/") + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String filePath = uploadPath + File.separator + fileName;
            cvFile.write(filePath);
            cvFilePath = "/" + UPLOAD_DIR + "/" + fileName;
        }

        // Save teacher profile
        TeacherProfile profile = new TeacherProfile();
        profile.setTeacherId(accountId);
        profile.setHeadline(headline.trim());
        profile.setBio(bio.trim());
        profile.setYearsExperience(Integer.parseInt(yearsExperienceStr.trim()));
        profile.setEducation(education != null ? education.trim() : null);
        profile.setCertifications(certifications != null ? certifications.trim() : null);
        profile.setLinkedinUrl(linkedinUrl != null ? linkedinUrl.trim() : null);
        profile.setWebsiteUrl(websiteUrl != null ? websiteUrl.trim() : null);
        profile.setAvatarUrl(avatarUrl != null ? avatarUrl.trim() : null);
        profile.setCvFilePath(cvFilePath);
        profile.setStatus("pending");

        TeacherProfileDAO profileDAO = new TeacherProfileDAO();
        boolean success = profileDAO.insert(profile);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/login?pendingApproval=true");
        } else {
            request.setAttribute("errorMessage", "Lưu hồ sơ thất bại. Vui lòng thử lại.");
            request.setAttribute("account", account);
            request.getRequestDispatcher("/view/authen/teacherRegisterStep2.jsp")
                    .forward(request, response);
        }
    }

    private String getFileExtension(String contentType) {
        if (contentType == null) return "";
        switch (contentType) {
            case "application/pdf": return ".pdf";
            case "application/msword": return ".doc";
            case "application/vnd.openxmlformats-officedocument.wordprocessingml.document": return ".docx";
            default: return "";
        }
    }
}