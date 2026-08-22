package com.controller.courseCRUD;

import com.DAO.CategoryDAO;
import com.DAO.CourseDAO;
import com.entity.Account;
import com.entity.Category;
import com.entity.Course;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "TeacherCourseManagerController", urlPatterns = {
    "/course-manager",
    "/course-dashboard",
    "/course-delete",
    "/course-delete-preview"
})
public class CourseManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        if (action == null) action = "";

        if ("/course-delete-preview".equals(path) || "deletePreview".equals(action)) {
            showDeletePreview(request, response);
        } else {
            showDashboard(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        if (action == null) action = "";

        if ("/course-delete".equals(path) || "delete".equals(action)) {
            deleteCourse(request, response);
        } else {
            doGet(request, response);
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        CourseDAO courseDAO = new CourseDAO();
        CategoryDAO categoryDAO = new CategoryDAO();

        int pageSize = 8;
        int pageNumber = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                pageNumber = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                pageNumber = 1;
            }
        }

        String courseName = request.getParameter("courseName");
        String sort = request.getParameter("sort");
        String categoryParam = request.getParameter("category");

        List<Integer> categoryIds = new ArrayList<>();
        if (categoryParam != null && !categoryParam.isEmpty()) {
            try {
                categoryIds.add(Integer.parseInt(categoryParam));
            } catch (NumberFormatException ignored) {}
        }

        List<Integer> ratings = new ArrayList<>();
        List<Course> courses = courseDAO.findCreatorCoursesWithFilters(account.getId(), categoryIds, ratings, courseName, sort, pageNumber, pageSize);
        int totalRecords = courseDAO.getTotalCreatorFilteredRecords(account.getId(), categoryIds, ratings, courseName);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        List<Category> allCategories = categoryDAO.findAll();

        request.setAttribute("courses", courses);
        request.setAttribute("allCategories", allCategories);
        request.setAttribute("currentPage", pageNumber);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("selectedCategory", categoryIds.isEmpty() ? null : categoryIds.get(0));
        request.setAttribute("courseName", courseName);
        request.setAttribute("sort", sort);
        
        request.getRequestDispatcher("/view/courseCRUD/course-dashboard.jsp").forward(request, response);
    }

    private void showDeletePreview(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
            return;
        }

        try {
            int courseId = Integer.parseInt(idStr);
            CourseDAO courseDAO = new CourseDAO();
            Course course = courseDAO.findById(courseId);

            if (course == null || course.getCreatedBy() != account.getId()) {
                response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
                return;
            }

            request.setAttribute("course", course);
            request.getRequestDispatcher("/view/courseCRUD/course-delete-preview.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
        }
    }

    private void deleteCourse(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            session.setAttribute("msg", "Không tìm thấy mã khóa học cần xóa.");
            response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
            return;
        }

        try {
            int courseId = Integer.parseInt(idStr);
            CourseDAO courseDAO = new CourseDAO();
            Course course = courseDAO.findById(courseId);

            if (course != null && course.getCreatedBy() == account.getId()) {
                boolean isDeleted = courseDAO.delete(course);
                if (isDeleted) {
                    session.setAttribute("msg", "Xóa khóa học thành công!");
                    session.setAttribute("message", "Xóa khóa học thành công!");
                } else {
                    session.setAttribute("msg", "Xóa khóa học thất bại. Vui lòng thử lại.");
                    session.setAttribute("message", "Xóa khóa học thất bại. Vui lòng thử lại.");
                }
            } else {
                session.setAttribute("msg", "Khóa học không tồn tại hoặc bạn không có quyền xóa khóa học này.");
            }
        } catch (Exception e) {
            session.setAttribute("msg", "Lỗi khi xóa: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/course-manager?action=dashboard");
    }
}
