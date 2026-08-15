package com.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ocms.config.GlobalConfig;
import com.DAO.CartDAO;
import com.DAO.CartItemDAO;
import com.DAO.CheckoutDAO;
import com.DAO.CourseDAO;
import com.entity.Account;
import com.entity.Cart;
import com.entity.CartItem;

@WebServlet("/checkout")
public class CheckoutController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CartDAO cartDAO;
    private CartItemDAO cartItemDAO;
    private CourseDAO courseDAO;
    private CheckoutDAO checkoutDAO;

    private static final String CHECKOUT_JSP = "/view/common/home/checkout.jsp";

    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO();
        cartItemDAO = new CartItemDAO();
        courseDAO = new CourseDAO();
        checkoutDAO = new CheckoutDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute(GlobalConfig.SESSION_ACCOUNT);
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Cart cart = cartDAO.findByAccountId(account.getId());
        if (cart == null) {
            cart = cartDAO.getOrCreateCart(account.getId());
        }

        List<CartItem> cartItems = cartItemDAO.getCartItemsWithCourseDetails(cart.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            session.setAttribute("message", "Giỏ hàng của bạn đang trống.");
            session.setAttribute("messageType", "warning");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        BigDecimal cartTotal = cartItemDAO.getCartTotal(cart.getId());

        request.setAttribute("cart", cart);
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("itemCount", cartItems.size());
        request.setAttribute("courseDAO", courseDAO);

        request.getRequestDispatcher(CHECKOUT_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute(GlobalConfig.SESSION_ACCOUNT);
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Cart cart = cartDAO.findByAccountId(account.getId());
        if (cart == null) {
            session.setAttribute("message", "Không tìm thấy giỏ hàng.");
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        List<CartItem> cartItems = cartItemDAO.getCartItemsWithCourseDetails(cart.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            session.setAttribute("message", "Giỏ hàng của bạn đang trống.");
            session.setAttribute("messageType", "warning");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "Card";
        }

        // Nếu thanh toán qua Card -> Done (hoặc Approved)
        // Nếu thanh toán qua mã QR -> Pending (chờ Admin đối soát duyệt sang Done)
        String status = "QR_CODE".equalsIgnoreCase(paymentMethod) ? "Pending" : "Done";

        boolean success = checkoutDAO.checkout(account.getId(), account.getEmail(), cart.getId(), cartItems, paymentMethod, status);
        if (success) {
            if ("QR_CODE".equalsIgnoreCase(paymentMethod)) {
                session.setAttribute("message", "Gửi yêu cầu thanh toán mã QR thành công! Trạng thái đơn hàng: Pending (Chờ Admin duyệt).");
                session.setAttribute("messageType", "info");
            } else {
                session.setAttribute("message", "Thanh toán thẻ thành công! Bạn có thể học ngay.");
                session.setAttribute("messageType", "success");
            }
            response.sendRedirect(request.getContextPath() + "/my-learning");
        } else {
            request.setAttribute("error", "Thanh toán không thành công. Vui lòng thử lại.");
            BigDecimal cartTotal = cartItemDAO.getCartTotal(cart.getId());
            request.setAttribute("cart", cart);
            request.setAttribute("cartItems", cartItems);
            request.setAttribute("cartTotal", cartTotal);
            request.setAttribute("itemCount", cartItems.size());
            request.setAttribute("courseDAO", courseDAO);
            request.getRequestDispatcher(CHECKOUT_JSP).forward(request, response);
        }
    }
}
