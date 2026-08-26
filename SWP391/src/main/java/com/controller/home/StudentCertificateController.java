package com.controller.home;

import com.DAO.CertificateDAO;
import com.entity.Account;
import com.entity.Certificate;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Chứng chỉ của học viên.
 * - GET /my-certificates : danh sách khóa đã có chứng chỉ (dropdown My Learning).
 * - GET /certificate?code=... : xem 1 chứng chỉ (chỉ chủ sở hữu).
 */
@WebServlet(name = "StudentCertificateController", urlPatterns = {"/my-certificates", "/certificate"})
public class StudentCertificateController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        CertificateDAO dao = new CertificateDAO();

        if ("/certificate".equals(request.getServletPath())) {
            String code = request.getParameter("code");
            Certificate cert = (code != null && !code.trim().isEmpty()) ? dao.getCertificateByCode(code.trim()) : null;
            if (cert == null || cert.getAccountId() != account.getId()) {
                response.sendRedirect(request.getContextPath() + "/my-certificates");
                return;
            }
            request.setAttribute("cert", cert);
            request.getRequestDispatcher("/view/course_learning/certificate_view.jsp").forward(request, response);
            return;
        }

        // Tự động kiểm tra và cấp chứng chỉ bổ sung cho các khóa đã đạt 100% tiến độ nhưng chưa được cấp
        dao.autoIssuePendingCertificatesForStudent(account.getId());

        List<Certificate> certificates = dao.getCertificatesByAccount(account.getId());
        request.setAttribute("certificates", certificates);
        request.getRequestDispatcher("/view/course_learning/my-certificates.jsp").forward(request, response);
    }
}