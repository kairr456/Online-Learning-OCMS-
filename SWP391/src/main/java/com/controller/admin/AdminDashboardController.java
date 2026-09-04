package com.controller.admin;

import com.DAO.AdminDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;

@WebServlet(name = "AdminDashboardController", urlPatterns = { "/admin/dashboard" })
public class AdminDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        jakarta.servlet.http.HttpSession session = request.getSession(false);
        com.entity.Account account = (session != null) ? (com.entity.Account) session.getAttribute("account") : null;
        if (account == null || account.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String period = request.getParameter("period");
        if (!"today".equals(period) && !"week".equals(period)
                && !"month".equals(period) && !"quarter".equals(period)) {
            period = "month";
        }

        DateRange current = getDateRange(period, LocalDate.now());
        DateRange previous = getPreviousDateRange(period, current);
        AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

        // Lấy dữ liệu từ DAO
        int totalUsers = dashboardDAO.getTotalUsers();
        int totalCourses = dashboardDAO.getTotalCourses();
        int totalRegistrations = dashboardDAO.getTotalRegistrations();

        // Gửi dữ liệu sang JSP
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalCourses", totalCourses);
        request.setAttribute("totalRegistrations", totalRegistrations);
        double revenue = dashboardDAO.getRevenueBetween(current.from(), current.to());
        double previousRevenue = dashboardDAO.getRevenueBetween(previous.from(), previous.to());
        request.setAttribute("totalRevenue", revenue);
        double revenueGrowth = calculateGrowth(revenue, previousRevenue);
        request.setAttribute("revenueGrowth", revenueGrowth);
        request.setAttribute("revenueGrowthAvailable", !Double.isNaN(revenueGrowth));
        request.setAttribute("period", period);
        request.setAttribute("periodLabel", getPeriodLabel(period));
        request.setAttribute("userCountsByRole", dashboardDAO.getUserCountByRole());
        request.setAttribute("courseCountsByStatus", dashboardDAO.getCourseCountByStatus());
        request.setAttribute("registrationsByMonth",
                dashboardDAO.getRegistrationsByMonth(current.from(), current.to()));
        request.setAttribute("monthlyTrend",
                dashboardDAO.getTrend(current.from(), current.to(), "today".equals(period) || "week".equals(period)));
        request.setAttribute("quizPassRate", dashboardDAO.getQuizPassRate());
        request.setAttribute("registrationCountsByStatus", dashboardDAO.getRegistrationCountByStatus());
        request.setAttribute("lessonCompletionRate", dashboardDAO.getLessonCompletionRate());
        request.setAttribute("topSellingCourses", dashboardDAO.getTopSellingCourses(current.from(), current.to()));
        request.setAttribute("pendingTeacherApprovals", dashboardDAO.getPendingTeacherApprovals());
        request.setAttribute("pendingCourseApprovals", dashboardDAO.getPendingCourseApprovals());
        // Trong AdminDashboardController.java
        request.setAttribute("contentPage", "dashboard.jsp");

        // Forward nội bộ từ Servlet vào WEB-INF
        request.getRequestDispatcher("/view/admin/common/admin_layout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private DateRange getDateRange(String period, LocalDate date) {
        switch (period) {
            case "today":
                return new DateRange(date, date.plusDays(1));
            case "week":
                LocalDate weekStart = date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
                return new DateRange(weekStart, weekStart.plusWeeks(1));
            case "quarter":
                int firstQuarterMonth = ((date.getMonthValue() - 1) / 3) * 3 + 1;
                LocalDate quarterStart = LocalDate.of(date.getYear(), firstQuarterMonth, 1);
                return new DateRange(quarterStart, quarterStart.plusMonths(3));
            default:
                LocalDate monthStart = date.withDayOfMonth(1);
                return new DateRange(monthStart, monthStart.plusMonths(1));
        }
    }

    private DateRange getPreviousDateRange(String period, DateRange current) {
        switch (period) {
            case "today":
                return new DateRange(current.from().minusDays(1), current.from());
            case "week":
                return new DateRange(current.from().minusWeeks(1), current.from());
            case "quarter":
                return new DateRange(current.from().minusMonths(3), current.from());
            default:
                return new DateRange(current.from().minusMonths(1), current.from());
        }
    }

    private double calculateGrowth(double current, double previous) {
        if (previous == 0)
            return current == 0 ? 0 : Double.NaN;
        return ((current - previous) / previous) * 100;
    }

    private String getPeriodLabel(String period) {
        switch (period) {
            case "today":
                return "Hôm nay";
            case "week":
                return "Tuần này";
            case "quarter":
                return "Quý này";
            default:
                return "Tháng này";
        }
    }

    private record DateRange(LocalDate from, LocalDate to) {
    }
}
