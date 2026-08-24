package com.controller.shopcart;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.ocms.config.GlobalConfig;
import com.validator.checkoutValidator;
import com.DAO.AccountDAO;
import com.DAO.CartDAO;
import com.DAO.CartItemDAO;
import com.DAO.CheckoutDAO;
import com.DAO.CourseDAO;
import com.DAO.CourseRegistrationDAO;
import com.entity.Account;
import com.entity.Cart;
import com.entity.CartItem;
import com.entity.Course;

@WebServlet(urlPatterns = {"/checkout", "/checkout-success", "/order-success"})
public class CheckoutController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String CHECKOUT_JSP = "/view/shopcart/checkout.jsp";
    private static final String SUCCESS_JSP = "/view/shopcart/order-success.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute(GlobalConfig.SESSION_ACCOUNT);
        if (account == null) {
            account = (Account) session.getAttribute("account");
        }
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
            return;
        }

        String servletPath = request.getServletPath();
        if ("/checkout-success".equals(servletPath) || "/order-success".equals(servletPath)) {
            handleOrderSuccess(request, response, account);
            return;
        }

        Cart cart = new CartDAO().findByAccountId(account.getId());
        if (cart == null) {
            cart = new CartDAO().getOrCreateCart(account.getId());
        }

        // Tự động dọn dẹp các khóa học đã bị deactive trước khi thanh toán
        new CartItemDAO().cleanupInactiveCartItems(cart.getId());

        List<CartItem> cartItems = new CartItemDAO().getCartItemsWithCourseDetails(cart.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            session.setAttribute("message", "Giỏ hàng của bạn đang trống.");
            session.setAttribute("messageType", "warning");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        BigDecimal cartTotal = new CartItemDAO().getCartTotal(cart.getId());
        prepareCheckoutView(request, cart, cartItems, cartTotal);
        request.getRequestDispatcher(CHECKOUT_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute(GlobalConfig.SESSION_ACCOUNT);
        if (account == null) {
            account = (Account) session.getAttribute("account");
        }
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/view/authen/login.jsp");
            return;
        }

        Cart cart = new CartDAO().findByAccountId(account.getId());
        if (cart == null) {
            cart = new CartDAO().getOrCreateCart(account.getId());
        }

        // Tự động dọn dẹp các khóa học đã bị deactive trước khi xử lý thanh toán
        new CartItemDAO().cleanupInactiveCartItems(cart.getId());

        List<CartItem> cartItems = new CartItemDAO().getCartItemsWithCourseDetails(cart.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            session.setAttribute("message", "Giỏ hàng của bạn đang trống.");
            session.setAttribute("messageType", "warning");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String country = request.getParameter("country");
        String paymentMethod = request.getParameter("paymentMethod");
        String cardNumber = request.getParameter("cardNumber");
        String expiry = request.getParameter("expiry");
        String cvc = request.getParameter("cvc");
        String cardName = request.getParameter("cardName");

        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "Card";
        }

        BigDecimal cartTotal = new CartItemDAO().getCartTotal(cart.getId());
        if (cartTotal == null) {
            cartTotal = BigDecimal.ZERO;
        }

        String validationError = checkoutValidator.validate(fullName, email, address, country,
                paymentMethod, cardNumber, expiry, cvc, cardName);

        if (validationError != null) {
            request.setAttribute("error", validationError);
            request.setAttribute("paramFullName", fullName);
            request.setAttribute("paramEmail", email);
            request.setAttribute("paramAddress", address);
            request.setAttribute("paramCountry", country);
            request.setAttribute("paramPaymentMethod", paymentMethod);
            request.setAttribute("paramCardNumber", cardNumber);
            request.setAttribute("paramExpiry", expiry);
            request.setAttribute("paramCvc", cvc);
            request.setAttribute("paramCardName", cardName);

            prepareCheckoutView(request, cart, cartItems, cartTotal);
            request.getRequestDispatcher(CHECKOUT_JSP).forward(request, response);
            return;
        }

        if (email == null || email.trim().isEmpty()) {
            email = account.getEmail();
        }

        CourseDAO cDao = new CourseDAO();
        AccountDAO accountDao = new AccountDAO();
        Map<Integer, String> authorNames = accountDao.getAuthorNames();
        List<Map<String, Object>> purchasedItems = new ArrayList<>();
        for (CartItem item : cartItems) {
            Map<String, Object> itemMap = new HashMap<>();
            itemMap.put("courseId", item.getCourseId());
            itemMap.put("price", item.getPrice() != null ? item.getPrice() : BigDecimal.ZERO);

            Course c = cDao.findById(item.getCourseId());
            if (c != null) {
                itemMap.put("courseName", c.getName());
                itemMap.put("thumbnail", c.getThumbnail());
                String author = authorNames.get(c.getCreatedBy());
                itemMap.put("teacherName", (author != null) ? author : "Giảng viên OCMS");
            } else {
                itemMap.put("courseName", "Khóa học #" + item.getCourseId());
                itemMap.put("thumbnail", "");
                itemMap.put("teacherName", "OCMS");
            }
            purchasedItems.add(itemMap);
        }

        String status = "Approved";

        boolean success = new CheckoutDAO().checkout(account.getId(), email != null ? email.trim() : "", cart.getId(), cartItems, paymentMethod, status);
        if (success) {
            String orderCode = "OCMS" + (System.currentTimeMillis() % 100000000L);
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            String orderDate = sdf.format(new java.util.Date());

            Map<String, Object> orderSuccessData = new HashMap<>();
            orderSuccessData.put("orderCode", orderCode);
            orderSuccessData.put("orderDate", orderDate);
            orderSuccessData.put("fullName", (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : account.getFullName());
            orderSuccessData.put("email", (email != null && !email.trim().isEmpty()) ? email.trim() : account.getEmail());
            orderSuccessData.put("address", address);
            orderSuccessData.put("country", country);
            orderSuccessData.put("paymentMethod", paymentMethod);
            orderSuccessData.put("totalAmount", cartTotal);
            orderSuccessData.put("items", purchasedItems);
            orderSuccessData.put("itemCount", purchasedItems.size());

            session.setAttribute("lastOrderSuccess", orderSuccessData);

            if ("QR_CODE".equalsIgnoreCase(paymentMethod)) {
                session.setAttribute("message", "Xác nhận thanh toán mã QR thành công! Các khóa học đã được kích hoạt.");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Thanh toán thành công! Bạn có thể bắt đầu học ngay.");
                session.setAttribute("messageType", "success");
            }
            response.sendRedirect(request.getContextPath() + "/checkout-success");
        } else {
            request.setAttribute("error", "Thanh toán không thành công. Vui lòng thử lại.");
            prepareCheckoutView(request, cart, cartItems, cartTotal);
            request.getRequestDispatcher(CHECKOUT_JSP).forward(request, response);
        }
    }

    /**
     * Helper nạp dữ liệu giỏ hàng và danh sách khóa học hiển thị lên trang checkout.jsp
     */
    private void prepareCheckoutView(HttpServletRequest request, Cart cart, List<CartItem> cartItems, BigDecimal cartTotal) {
        Map<Integer, Course> courseMap = new HashMap<>();
        CourseDAO courseDAO = new CourseDAO();
        if (cartItems != null) {
            for (CartItem ci : cartItems) {
                Course c = courseDAO.findById(ci.getCourseId());
                if (c != null) {
                    courseMap.put(ci.getCourseId(), c);
                }
            }
        }
        request.setAttribute("cart", cart);
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("courseMap", courseMap);
        request.setAttribute("cartTotal", cartTotal != null ? cartTotal : BigDecimal.ZERO);
        request.setAttribute("itemCount", cartItems != null ? cartItems.size() : 0);
    }

    /**
     * Hiển thị trang thanh toán / mua khóa học thành công (Order Confirmation / Success)
     */
    private void handleOrderSuccess(HttpServletRequest request, HttpServletResponse response, Account account)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        @SuppressWarnings("unchecked")
        Map<String, Object> orderSuccessData = (Map<String, Object>) session.getAttribute("lastOrderSuccess");

        if (orderSuccessData == null) {
            orderSuccessData = new HashMap<>();
            String orderCode = "OCMS" + (System.currentTimeMillis() % 100000000L);
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            orderSuccessData.put("orderCode", orderCode);
            orderSuccessData.put("orderDate", sdf.format(new java.util.Date()));
            orderSuccessData.put("fullName", (account.getFullName() != null && !account.getFullName().trim().isEmpty()) ? account.getFullName() : account.getUsername());
            orderSuccessData.put("email", account.getEmail());
            orderSuccessData.put("paymentMethod", "Card");

            CourseRegistrationDAO regDAO = new CourseRegistrationDAO();
            List<Course> myCourses = regDAO.getCoursesByAccountId(account.getId());
            List<Map<String, Object>> fallbackItems = new ArrayList<>();
            BigDecimal totalFallback = BigDecimal.ZERO;

            if (myCourses != null && !myCourses.isEmpty()) {
                for (Course c : myCourses) {
                    Map<String, Object> it = new HashMap<>();
                    it.put("courseId", c.getId());
                    it.put("courseName", c.getName());
                    it.put("thumbnail", c.getThumbnail());
                    it.put("price", BigDecimal.valueOf(c.getPrice()));
                    it.put("teacherName", "Giảng viên OCMS");
                    fallbackItems.add(it);
                    totalFallback = totalFallback.add(BigDecimal.valueOf(c.getPrice()));
                }
            }
            orderSuccessData.put("items", fallbackItems);
            orderSuccessData.put("itemCount", fallbackItems.size());
            orderSuccessData.put("totalAmount", totalFallback);
        }

        // Xác định tên và icon phương thức thanh toán thân thiện
        String rawPaymentMethod = (String) orderSuccessData.get("paymentMethod");
        String paymentMethodName = "Thẻ tín dụng / Ghi nợ quốc tế (Card)";
        String paymentMethodIcon = "fa-regular fa-credit-card";
        if (rawPaymentMethod != null) {
            if ("QR_CODE".equalsIgnoreCase(rawPaymentMethod) || "QR".equalsIgnoreCase(rawPaymentMethod)) {
                paymentMethodName = "Chuyển khoản QR Code (VietQR / Ngân hàng)";
                paymentMethodIcon = "fa-solid fa-qrcode";
            } else if ("VNPAY".equalsIgnoreCase(rawPaymentMethod)) {
                paymentMethodName = "Ví điện tử VNPAY (ATM / QR Pay)";
                paymentMethodIcon = "fa-solid fa-wallet";
            } else if ("WALLET".equalsIgnoreCase(rawPaymentMethod)) {
                paymentMethodName = "Số dư Ví OCMS";
                paymentMethodIcon = "fa-solid fa-wallet";
            }
        }

        request.setAttribute("order", orderSuccessData);
        request.setAttribute("orderData", orderSuccessData);
        request.setAttribute("paymentMethodName", paymentMethodName);
        request.setAttribute("paymentMethodIcon", paymentMethodIcon);
        request.getRequestDispatcher(SUCCESS_JSP).forward(request, response);
    }
}
