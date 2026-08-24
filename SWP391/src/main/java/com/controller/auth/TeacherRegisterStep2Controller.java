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
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 5 * 1024 * 1024, // 5MB
        maxRequestSize = 10 * 1024 * 1024 // 10MB
)
public class TeacherRegisterStep2Controller extends HttpServlet {

    // Use a fixed upload directory name
    private static final String UPLOAD_DIR_NAME = "teacher-cv";

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
        TeacherProfile existing = profileDAO.findByAccountId(accountId);
        if (existing != null) {
            request.setAttribute("errorMessage", "Hồ sơ giảng viên đã tồn tại.");
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
        String specialization = request.getParameter("specialization");
        String bio = request.getParameter("bio");
        String experienceYearsStr = request.getParameter("experienceYears");
        String portfolioUrl = request.getParameter("portfolioUrl");

        Part cvFile = request.getPart("cvFile");

        // Validate
        String validationError = TeacherProfileValidator.validate(
                specialization, bio, experienceYearsStr, portfolioUrl, cvFile);

        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            request.setAttribute("account", account);
            // Repopulate form data
            request.setAttribute("specialization", specialization);
            request.setAttribute("bio", bio);
            request.setAttribute("experienceYears", experienceYearsStr);
            request.setAttribute("portfolioUrl", portfolioUrl);
            request.getRequestDispatcher("/view/authen/teacherRegisterStep2.jsp")
                    .forward(request, response);
            return;
        }

        // Handle CV upload - save to a fixed location
        String cvUrl = null;
        if (cvFile != null && cvFile.getSize() > 0) {
            String contentType = cvFile.getContentType();
            String ext = getFileExtension(contentType);
            String fileName = "cv_" + accountId + "_" + System.currentTimeMillis() + ext;

            // Use a fixed upload directory under the webapp
            String webappRoot = getServletContext().getRealPath("/");
            if (webappRoot == null) {
                // Fallback: use system temp dir
                webappRoot = System.getProperty("java.io.tmpdir");
            }
            String uploadPath = webappRoot + File.separator + "assets" + File.separator + "css"
                    + File.separator + "uploads" + File.separator + UPLOAD_DIR_NAME;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                if (!uploadDir.mkdirs() && !uploadDir.isDirectory()) {
                    throw new IOException("Could not create teacher CV upload directory");
                }
            }

            String filePath = uploadPath + File.separator + fileName;
            cvFile.write(filePath);
            // Store relative URL for serving
            cvUrl = request.getContextPath() + "/assets/css/uploads/" + UPLOAD_DIR_NAME + "/" + fileName;
        }

        // Save teacher profile
        TeacherProfile profile = new TeacherProfile();
        profile.setAccountId(accountId);
        profile.setSpecialization(specialization.trim());
        profile.setBio(bio.trim());
        profile.setExperienceYears(Integer.parseInt(experienceYearsStr.trim()));
        profile.setCvUrl(cvUrl);
        profile.setPortfolioUrl(portfolioUrl != null ? portfolioUrl.trim() : null);
        profile.setApprovalStatus("PENDING");

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
        if (contentType == null)
            return "";
        switch (contentType) {
            case "application/pdf":
                return ".pdf";
            case "application/msword":
                return ".doc";
            case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
                return ".docx";
            default:
                return "";
        }
    }
}