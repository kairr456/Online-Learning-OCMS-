package com.controller.home;

import com.DAO.BlogDAO;
import com.entity.Blog;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "BlogController", urlPatterns = {"/blogs"})
public class BlogController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        BlogDAO blogDAO = new BlogDAO();
        List<Blog> blogList = blogDAO.getAllBlogs();
        
        request.setAttribute("blogList", blogList);
        
        // Trỏ đúng về đường dẫn chứa file JSP trong thư mục view/common
        request.getRequestDispatcher("/view/common/blog-list.jsp").forward(request, response);
    }
}