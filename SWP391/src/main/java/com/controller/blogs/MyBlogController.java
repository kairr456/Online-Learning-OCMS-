package com.controller.blogs;

import com.DAO.BlogDAO;
import com.entity.Account;
import com.entity.Blog;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MyBlogController", urlPatterns = {"/my-blogs"})
public class MyBlogController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        // Nếu chưa đăng nhập, chuyển hướng đến trang đăng nhập
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Blog> myBlogs = new BlogDAO().getBlogsByAuthor(account.getId());
        Map<Integer, String> categories = new BlogDAO().getBlogCategories();

        request.setAttribute("myBlogs", myBlogs);
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/view/blogs/my-blogs.jsp").forward(request, response);
    }
}
