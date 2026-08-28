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
        maxFileSize = 20 * 1024 * 1024, // 20MB to safely catch oversized files in servlet
        maxRequestSize = 25 * 1024 * 1024 // 25MB
)
public class TeacherRegisterStep2Controller extends HttpServlet {

    // Use a fixed upload directory name
    private static final String UPLOAD_DIR_NAME = "teacher-cv";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        jakarta.servlet.http.HttpSession session = request.getSession(false);
        Account pendingAccount = (session != null) ? (Account) session.getAttribute("pendingTeacherAccount") : null;

        String accountIdStr = request.getParameter("accountId");

        if (pendingAccount == null && (accountIdStr == null || accountIdStr.trim().isEmpty())) {
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        Account account = null;

        if (pendingAccount != null) {
            account = pendingAccount;
        } else {
            // Backward compatibility for old flow
            try {
                int accountId = Integer.parseInt(accountIdStr.trim());
                Account dbAccount = new AccountDAO().getAccountById(accountId);
                if (dbAccount != null && dbAccount.getRoleId() == 2 && !dbAccount.isActive()) {
                    TeacherProfile existing = new TeacherProfileDAO().findByAccountId(accountId);
                    if (existing == null) {
                        account = dbAccount;
                    }
                }
            } catch (NumberFormatException ignored) {}
        }

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/register");
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

        jakarta.servlet.http.HttpSession session = request.getSession(false);
        Account pendingAccount = (session != null) ? (Account) session.getAttribute("pendingTeacherAccount") : null;

        String accountIdStr = request.getParameter("accountId");
        Account dbAccount = null;

        if (pendingAccount == null && accountIdStr != null && !accountIdStr.trim().isEmpty()) {
            try {
                int accountId = Integer.parseInt(accountIdStr.trim());
                Account found = new AccountDAO().getAccountById(accountId);
                if (found != null && found.getRoleId() == 2 && !found.isActive()) {
                    dbAccount = found;
                }
            } catch (NumberFormatException ignored) {}
        }

        Account currentAccount = (pendingAccount != null) ? pendingAccount : dbAccount;

        if (currentAccount == null) {
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        // Get form fields
        String specialization = request.getParameter("specialization");
        String bio = request.getParameter("bio");
        String experienceYearsStr = request.getParameter("experienceYears");
        String portfolioUrl = request.getParameter("portfolioUrl");

        Part cvFile = null;
        try {
            cvFile = request.getPart("cvFile");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Dung lượng file CV không được vượt quá 5MB.");
            request.setAttribute("account", currentAccount);
            request.setAttribute("specialization", specialization);
            request.setAttribute("bio", bio);
            request.setAttribute("experienceYears", experienceYearsStr);
            request.setAttribute("portfolioUrl", portfolioUrl);
            request.getRequestDispatcher("/view/authen/teacherRegisterStep2.jsp")
                    .forward(request, response);
            return;
        }

        // Validate
        String validationError = TeacherProfileValidator.validate(
                specialization, bio, experienceYearsStr, portfolioUrl, cvFile);

        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            request.setAttribute("account", currentAccount);
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
            String prefix = (pendingAccount != null) ? pendingAccount.getUsername() : String.valueOf(dbAccount.getId());
            String fileName = "cv_" + prefix + "_" + System.currentTimeMillis() + ext;

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

        boolean success = false;

        if (pendingAccount != null) {
            // NEW FLOW: Save Account to DB first, then save TeacherProfile
            if (new AccountDAO().isUsernameExists(pendingAccount.getUsername())) {
                request.setAttribute("errorMessage", "Tên đăng nhập đã tồn tại trong hệ thống.");
                request.setAttribute("account", currentAccount);
                request.getRequestDispatcher("/view/authen/teacherRegisterStep2.jsp").forward(request, response);
                return;
            }
            if (new AccountDAO().isEmailExists(pendingAccount.getEmail())) {
                request.setAttribute("errorMessage", "Email đã tồn tại trong hệ thống.");
                request.setAttribute("account", currentAccount);
                request.getRequestDispatcher("/view/authen/teacherRegisterStep2.jsp").forward(request, response);
                return;
            }

            boolean accountSaved = new AccountDAO().registerPendingTeacher(pendingAccount);
            if (accountSaved && pendingAccount.getId() > 0) {
                TeacherProfile profile = new TeacherProfile();
                profile.setAccountId(pendingAccount.getId());
                profile.setSpecialization(specialization.trim());
                profile.setBio(bio.trim());
                profile.setExperienceYears(Integer.parseInt(experienceYearsStr.trim()));
                profile.setCvUrl(cvUrl);
                profile.setPortfolioUrl(portfolioUrl != null ? portfolioUrl.trim() : null);
                profile.setApprovalStatus("PENDING");

                TeacherProfileDAO profileDAO = new TeacherProfileDAO();
                success = profileDAO.insert(profile);

                if (success && session != null) {
                    session.removeAttribute("pendingTeacherAccount");
                }
            }
        } else if (dbAccount != null) {
            // OLD FLOW: Account is already in DB, just insert TeacherProfile
            TeacherProfile profile = new TeacherProfile();
            profile.setAccountId(dbAccount.getId());
            profile.setSpecialization(specialization.trim());
            profile.setBio(bio.trim());
            profile.setExperienceYears(Integer.parseInt(experienceYearsStr.trim()));
            profile.setCvUrl(cvUrl);
            profile.setPortfolioUrl(portfolioUrl != null ? portfolioUrl.trim() : null);
            profile.setApprovalStatus("PENDING");

            TeacherProfileDAO profileDAO = new TeacherProfileDAO();
            success = profileDAO.insert(profile);
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/login?pendingApproval=true");
        } else {
            request.setAttribute("errorMessage", "Lưu hồ sơ thất bại. Vui lòng thử lại.");
            request.setAttribute("account", currentAccount);
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