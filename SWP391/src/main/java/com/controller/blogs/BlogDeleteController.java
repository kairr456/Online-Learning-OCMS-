package com.controller.blogs;

import com.DAO.BlogDAO;
import com.entity.Account;
import com.entity.Blog;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "BlogDeleteController", urlPatterns = {"/blogs-delete"})
public class BlogDeleteController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doDeleteAction(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doDeleteAction(request, response);
    }

    private void doDeleteAction(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/my-blogs");
            return;
        }

        int blogId = 0;
        try {
            blogId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/my-blogs");
            return;
        }

        BlogDAO blogDAO = new BlogDAO();
        Blog blog = blogDAO.getBlogById(blogId);

        if (blog != null) {
            // Chỉ tác giả hoặc admin mới có quyền xóa
            if (blog.getAuthor() == account.getId() || account.getRoleId() == 1) {
                boolean success = blogDAO.deleteBlog(blogId, blog.getAuthor());
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/my-blogs?message=deleted");
                    return;
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/my-blogs?error=unauthorized");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/my-blogs?error=delete_failed");
    }
}
