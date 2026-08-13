package com.controller;

import com.DAO.CartDAO;
import com.DAO.CartItemDAO;
import com.DAO.CheckoutDAO;
import com.DAO.CourseDAO;
import com.DAO.RegistrationDAO;
import com.entity.Account;
import com.entity.Cart;
import com.entity.CartItem;
import com.ocms.config.GlobalConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

@WebServlet("/checkout")
public class CheckoutController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private CartDAO cartDAO;
    private CartItemDAO cartItemDAO;
    private CourseDAO courseDAO;
    private RegistrationDAO registrationDAO;
    private CheckoutDAO checkoutDAO;

    private static final String CHECKOUT_JSP =
            "view/common/home/checkout.jsp";

    @Override
    public void init() throws ServletException {

        cartDAO = new CartDAO();
        cartItemDAO = new CartItemDAO();
        courseDAO = new CourseDAO();
        registrationDAO = new RegistrationDAO();
        checkoutDAO = new CheckoutDAO();
    }


    // =========================================================
    // GET /checkout
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Account account =
                (Account) session.getAttribute(
                        GlobalConfig.SESSION_ACCOUNT
                );

        System.out.println("===== CHECKOUT GET =====");
        System.out.println("Account: " + account);

        if (account == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/authen?action=login"
            );

            return;
        }

        showCheckout(
                request,
                response,
                account
        );
    }


    // =========================================================
    // POST /checkout
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();

        Account account =
                (Account) session.getAttribute(
                        GlobalConfig.SESSION_ACCOUNT
                );

        System.out.println("===== CHECKOUT POST =====");
        System.out.println("Account: " + account);

        if (account == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/authen?action=login"
            );

            return;
        }

        String action =
                request.getParameter("action");

        System.out.println("Action: " + action);

        if ("pay".equals(action)) {

            processPayment(
                    request,
                    response,
                    account
            );

        } else {

            response.sendRedirect(
                    request.getContextPath()
                            + "/checkout"
            );
        }
    }


    // =========================================================
    // SHOW CHECKOUT
    // =========================================================

    private void showCheckout(
            HttpServletRequest request,
            HttpServletResponse response,
            Account account)
            throws ServletException, IOException {

        Cart cart =
                cartDAO.findByAccountId(
                        account.getId()
                );

        if (cart == null) {

            setError(
                    request,
                    "Your cart is empty."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }

        List<CartItem> cartItems =
                cartItemDAO.getCartItemsWithCourseDetails(
                        cart.getId()
                );

        if (cartItems == null ||
                cartItems.isEmpty()) {

            setError(
                    request,
                    "Your cart is empty. Please add courses before checkout."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }


        // =====================================================
        // CHECK DUPLICATE REGISTERED COURSE
        // =====================================================

        List<CartItem> duplicateItems =
                new ArrayList<>();

        for (CartItem item : cartItems) {

            boolean alreadyRegistered =
                    registrationDAO.isAlreadyRegistered(
                            account.getId(),
                            item.getCourseId()
                    );

            if (alreadyRegistered) {

                duplicateItems.add(item);
            }
        }


        if (!duplicateItems.isEmpty()) {

            cartItems.removeAll(
                    duplicateItems
            );

            for (CartItem item : duplicateItems) {

                cartItemDAO.delete(item);
            }


            if (cartItems.isEmpty()) {

                setError(
                        request,
                        "All courses in your cart are already registered."
                );

                response.sendRedirect(
                        request.getContextPath()
                                + "/cart"
                );

                return;
            }
        }


        // =====================================================
        // CALCULATE TOTAL
        // =====================================================

        BigDecimal total =
                BigDecimal.ZERO;

        for (CartItem item : cartItems) {

            if (item.getPrice() != null) {

                total =
                        total.add(
                                item.getPrice()
                        );
            }
        }


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
                "cart",
                cart
        );

        request.setAttribute(
                "cartItems",
                cartItems
        );

        request.setAttribute(
                "cartTotal",
                total
        );

        request.setAttribute(
                "itemCount",
                cartItems.size()
        );

        request.setAttribute(
                "courseDAO",
                courseDAO
        );


        request.getRequestDispatcher(
                CHECKOUT_JSP
        ).forward(
                request,
                response
        );
    }


    // =========================================================
    // PROCESS PAYMENT
    // =========================================================

    private void processPayment(
            HttpServletRequest request,
            HttpServletResponse response,
            Account account)
            throws ServletException, IOException {


        // =====================================================
        // 1. GET FORM DATA
        // =====================================================

        String country =
                trim(request.getParameter("country"));

        String fullName =
                trim(request.getParameter("fullName"));

        String email =
                trim(request.getParameter("email"));

        String phone =
                trim(request.getParameter("phone"));

        String gender =
                trim(request.getParameter("gender"));

        String address =
                trim(request.getParameter("address"));

        String city =
                trim(request.getParameter("city"));

        String postalCode =
                trim(request.getParameter("postalCode"));

        String cardNumber =
                trim(request.getParameter("cardNumber"));

        String expiry =
                trim(request.getParameter("expiry"));

        String cvc =
                trim(request.getParameter("cvc"));

        String cardName =
                trim(request.getParameter("cardName"));


        System.out.println("===== PAYMENT DATA =====");

        System.out.println(
                "Country: " + country
        );

        System.out.println(
                "Full name: " + fullName
        );

        System.out.println(
                "Email: " + email
        );

        System.out.println(
                "Phone: " + phone
        );

        System.out.println(
                "Gender: " + gender
        );

        System.out.println(
                "Address: " + address
        );

        System.out.println(
                "City: " + city
        );


        // =====================================================
        // 2. SERVER VALIDATION
        // =====================================================

        String validationError =
                validateCheckoutData(
                        country,
                        fullName,
                        email,
                        phone,
                        gender,
                        address,
                        city,
                        postalCode,
                        cardNumber,
                        expiry,
                        cvc,
                        cardName
                );


        if (validationError != null) {

            request.setAttribute(
                    "error",
                    validationError
            );

            // Load lại checkout
            showCheckout(
                    request,
                    response,
                    account
            );

            return;
        }


        // =====================================================
        // 3. GET CART
        // =====================================================

        Cart cart =
                cartDAO.findByAccountId(
                        account.getId()
                );

        if (cart == null) {

            setError(
                    request,
                    "Your cart is empty."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }


        List<CartItem> cartItems =
                cartItemDAO.getCartItemsWithCourseDetails(
                        cart.getId()
                );


        if (cartItems == null ||
                cartItems.isEmpty()) {

            setError(
                    request,
                    "Your cart is empty."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }


        // =====================================================
        // 4. CHECK REGISTERED COURSE AGAIN
        // =====================================================

        List<CartItem> validItems =
                new ArrayList<>();

        for (CartItem item : cartItems) {

            boolean alreadyRegistered =
                    registrationDAO.isAlreadyRegistered(
                            account.getId(),
                            item.getCourseId()
                    );

            if (!alreadyRegistered) {

                validItems.add(item);
            }
        }


        if (validItems.isEmpty()) {

            setError(
                    request,
                    "All courses in your cart are already registered."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/cart"
            );

            return;
        }


        // =====================================================
        // 5. CALCULATE TOTAL
        // =====================================================

        BigDecimal total =
                BigDecimal.ZERO;

        for (CartItem item : validItems) {

            if (item.getPrice() != null) {

                total =
                        total.add(
                                item.getPrice()
                        );
            }
        }


        // =====================================================
        // 6. CALL CHECKOUT DAO
        // =====================================================

        boolean success;

        try {

            success =
                    checkoutDAO.checkout(
                            account.getId(),
                            account.getEmail(),
                            cart.getId(),
                            validItems
                    );

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "An error occurred while processing your payment."
            );

            showCheckout(
                    request,
                    response,
                    account
            );

            return;
        }


        // =====================================================
        // 7. SUCCESS
        // =====================================================

        if (success) {

            HttpSession session =
                    request.getSession();

            session.setAttribute(
                    "message",
                    "Payment successful! You can now access your courses."
            );

            session.setAttribute(
                    "messageType",
                    "success"
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/my-courses"
            );

        } else {

            request.setAttribute(
                    "error",
                    "An error occurred while processing your payment."
            );

            showCheckout(
                    request,
                    response,
                    account
            );
        }
    }


    // =========================================================
    // VALIDATE CHECKOUT
    // =========================================================

    private String validateCheckoutData(

            String country,
            String fullName,
            String email,
            String phone,
            String gender,
            String address,
            String city,
            String postalCode,
            String cardNumber,
            String expiry,
            String cvc,
            String cardName) {


        // =====================================================
        // COUNTRY
        // =====================================================

        if (country == null ||
                country.isEmpty()) {

            return "Please select your country.";
        }


        // =====================================================
        // FULL NAME
        // =====================================================

        if (fullName == null ||
                fullName.length() < 2) {

            return "Full name must contain at least 2 characters.";
        }


        if (!fullName.matches(
                "^[\\p{L} .'-]+$")) {

            return "Full name contains invalid characters.";
        }


        // =====================================================
        // EMAIL
        // =====================================================

        if (email == null ||
                email.isEmpty()) {

            return "Email is required.";
        }


        if (!Pattern.matches(
                "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$",
                email)) {

            return "Please enter a valid email address.";
        }


        // =====================================================
        // PHONE
        // =====================================================

        if (phone == null ||
                phone.isEmpty()) {

            return "Phone number is required.";
        }


        String phoneClean =
                phone.replaceAll(
                        "[\\s-]",
                        ""
                );


        if (!phoneClean.matches(
                "^\\+?[0-9]{9,15}$")) {

            return "Please enter a valid phone 10 number .";
        }


        // =====================================================
        // GENDER
        // =====================================================

        if (gender == null ||
                gender.isEmpty()) {

            return "Please select your gender.";
        }


        if (!gender.equals("Male") &&
                !gender.equals("Female") &&
                !gender.equals("Other")) {

            return "Invalid gender.";
        }


        // =====================================================
        // ADDRESS
        // =====================================================

        if (address == null ||
                address.length() < 5) {

            return "Address must contain at least 5 characters.";
        }


        // =====================================================
        // CITY
        // =====================================================

        if (city == null ||
                city.length() < 2) {

            return "City must contain at least 2 characters.";
        }


        // =====================================================
        // POSTAL CODE
        // =====================================================

        if (postalCode != null &&
                !postalCode.isEmpty()) {

            if (!postalCode.matches(
                    "^[0-9A-Za-z -]{3,10}$")) {

                return "Invalid postal code.";
            }
        }


        // =====================================================
        // CARD NUMBER
        // =====================================================

        if (cardNumber == null ||
                cardNumber.isEmpty()) {

            return "Card number is required.";
        }


        String cardClean =
                cardNumber.replaceAll(
                        "\\s",
                        ""
                );


        if (!cardClean.matches(
                "^\\d{16}$")) {

            return "Card number must contain exactly 16 digits.";
        }


        // =====================================================
        // EXPIRY
        // =====================================================

        if (expiry == null ||
                expiry.isEmpty()) {

            return "Expiry date is required.";
        }


        if (!isValidExpiry(expiry)) {

            return "Expiry date is invalid or has M/D.";
        }


        // =====================================================
        // CVC
        // =====================================================

        if (cvc == null ||
                cvc.isEmpty()) {

            return "CVC/CVV is required.";
        }


        if (!cvc.matches(
                "^\\d{3,4}$")) {

            return "CVC/CVV must contain 3 or 4 digits.";
        }


        // =====================================================
        // CARD NAME
        // =====================================================

        if (cardName == null ||
                cardName.length() < 2) {

            return "Name on card is required.";
        }


        if (!cardName.matches(
                "^[\\p{L} .'-]+$")) {

            return "Name on card contains invalid characters.";
        }


        return null;
    }


    // =========================================================
    // VALIDATE EXPIRY
    // =========================================================

    private boolean isValidExpiry(
            String expiry) {

        if (!expiry.matches(
                "^\\d{2}/\\d{4}$")) {

            return false;
        }


        String[] parts =
                expiry.split("/");


        int month;

        int year;


        try {

            month =
                    Integer.parseInt(
                            parts[0]
                    );

            year =
                    Integer.parseInt(
                            parts[1]
                    );

        } catch (NumberFormatException e) {

            return false;
        }


        if (month < 1 ||
                month > 12) {

            return false;
        }


        java.util.Calendar now =
                java.util.Calendar.getInstance();


        int currentYear =
                now.get(
                        java.util.Calendar.YEAR
                ) % 100;


        int currentMonth =
                now.get(
                        java.util.Calendar.MONTH
                ) + 1;


        if (year < currentYear) {

            return false;
        }


        if (year == currentYear &&
                month < currentMonth) {

            return false;
        }


        return true;
    }


    // =========================================================
    // TRIM
    // =========================================================

    private String trim(String value) {

        if (value == null) {

            return "";
        }

        return value.trim();
    }


    // =========================================================
    // ERROR MESSAGE
    // =========================================================

    private void setError(
            HttpServletRequest request,
            String message) {

        request.getSession().setAttribute(
                "message",
                message
        );

        request.getSession().setAttribute(
                "messageType",
                "warning"
        );
    }
}