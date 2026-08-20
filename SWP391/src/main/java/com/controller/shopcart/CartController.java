package com.controller.shopcart;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
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
import com.DAO.CartDAO;
import com.DAO.CartItemDAO;
import com.DAO.CourseDAO;
import com.DAO.CourseRegistrationDAO;
import com.entity.Account;
import com.entity.Cart;
import com.entity.CartItem;
import com.entity.Course;

@WebServlet("/cart")
public class CartController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CartDAO cartDAO;
    private CartItemDAO cartItemDAO;
    private CourseDAO courseDAO;
    private CourseRegistrationDAO registrationDAO;

    private static final String CART_JSP = "/view/shopcart/cart.jsp";

    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO();    
        cartItemDAO = new CartItemDAO();
        courseDAO = new CourseDAO();
        registrationDAO = new CourseRegistrationDAO();
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

        // Lấy hoặc tạo giỏ hàng cho tài khoản
        Cart cart = cartDAO.getOrCreateCart(account.getId());

        // Lấy tham số tìm kiếm & sắp xếp
        String search = request.getParameter("search");
        String sort = request.getParameter("sort");
        if (sort == null || sort.trim().isEmpty()) {
            sort = "newest";
        }

        // Lấy danh sách khóa học trong giỏ có lọc và sắp xếp
        List<CartItem> cartItems = cartItemDAO.getCartItemsWithFilters(cart.getId(), search, sort);

        // Đếm tổng số khóa học thực tế trong giỏ
        int totalCartItems = cartItemDAO.countCartItems(cart.getId());

        // Tính tổng tiền giỏ hàng
        BigDecimal cartTotal = cartItemDAO.getCartTotal(cart.getId());

        // Phân trang: tối đa 4 khóa học mỗi trang
        int pageSize = 4;
        int totalFilteredItems = (cartItems != null) ? cartItems.size() : 0;
        int totalPages = (int) Math.ceil((double) totalFilteredItems / pageSize);
        if (totalPages == 0) {
            totalPages = 1;
        }

        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) currentPage = 1;
                if (currentPage > totalPages) currentPage = totalPages;
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        List<CartItem> pagedItems;
        if (cartItems != null && !cartItems.isEmpty()) {
            int fromIndex = (currentPage - 1) * pageSize;
            int toIndex = Math.min(fromIndex + pageSize, totalFilteredItems);
            if (fromIndex < totalFilteredItems) {
                pagedItems = cartItems.subList(fromIndex, toIndex);
            } else {
                pagedItems = new ArrayList<>();
            }
        } else {
            pagedItems = new ArrayList<>();
        }

        // Tạo Map thông tin Course để hiển thị trên JSP mà không cần gọi DAO trong view
        Map<Integer, Course> courseMap = new HashMap<>();
        for (CartItem ci : pagedItems) {
            Course c = courseDAO.findById(ci.getCourseId());
            if (c != null) {
                courseMap.put(ci.getCourseId(), c);
            }
        }

        // Xử lý flash message từ session trực tiếp trong controller
        String sessionMsg = (String) session.getAttribute("message");
        String sessionMsgType = (String) session.getAttribute("messageType");
        if (sessionMsg != null) {
            request.setAttribute("toastMessage", sessionMsg);
            request.setAttribute("toastType", sessionMsgType != null ? sessionMsgType : "info");
            session.removeAttribute("message");
            session.removeAttribute("messageType");
        }

        // Gán dữ liệu cho JSP hiển thị
        request.setAttribute("cart", cart);
        request.setAttribute("cartItems", pagedItems);
        request.setAttribute("courseMap", courseMap);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("itemCount", totalFilteredItems);
        request.setAttribute("totalCartItems", totalCartItems);
        request.setAttribute("search", search != null ? search : "");
        request.setAttribute("sort", sort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher(CART_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action != null) {
            switch (action) {
                case "add":
                    addToCart(request, response);
                    break;

                case "remove":
                    removeFromCart(request, response);
                    break;

                case "checkout":
                    response.sendRedirect(request.getContextPath() + "/checkout");
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/cart");
                    break;
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute(GlobalConfig.SESSION_ACCOUNT);

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String courseId = request.getParameter("courseId");

        if (courseId != null && !courseId.trim().isEmpty()) {
            try {
                int courseIdInt = Integer.parseInt(courseId.trim());

                // Lấy thông tin Course trực tiếp từ DB
                Course course = courseDAO.findById(courseIdInt);
                if (course == null) {
                    session.setAttribute("message", "Course not found.");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/cart");
                    return;
                }

                BigDecimal price = BigDecimal.valueOf(course.getPrice());

                // Kiểm tra xem người dùng đã sở hữu khóa học này chưa
                boolean alreadyRegistered = registrationDAO.isAlreadyRegistered(account.getId(), courseIdInt);
                
                if (alreadyRegistered) {
                    session.setAttribute("message", "You have already registered for this course.");
                    session.setAttribute("messageType", "warning");
                    response.sendRedirect(request.getContextPath() + "/cart");
                    return;
                }

                // Lấy hoặc tạo giỏ hàng cho tài khoản
                Cart cart = cartDAO.getOrCreateCart(account.getId());
                if (cart == null || cart.getId() == null) {
                    session.setAttribute("message", "Could not initialize cart.");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/cart");
                    return;
                }

                // Kiểm tra xem khóa học đã nằm trong giỏ chưa
                if (!cartItemDAO.isInCart(cart.getId(), courseIdInt)) {
                    CartItem cartItem = new CartItem();
                    cartItem.setCartId(cart.getId());
                    cartItem.setCourseId(courseIdInt);
                    cartItem.setPrice(price);

                    int result = cartItemDAO.insert(cartItem);

                    if (result > 0) {
                        session.setAttribute("message", "Course added to cart successfully!");
                        session.setAttribute("messageType", "success");
                    } else {
                        session.setAttribute("message", "Failed to add course to cart.");
                        session.setAttribute("messageType", "error");
                    }
                } else {
                    session.setAttribute("message", "This course is already in your cart.");
                    session.setAttribute("messageType", "info");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("message", "Invalid course information.");
                session.setAttribute("messageType", "error");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("message", "Error adding course: " + e.getMessage());
                session.setAttribute("messageType", "error");
            }
        } else {
            session.setAttribute("message", "Missing course information.");
            session.setAttribute("messageType", "error");
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void removeFromCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute(GlobalConfig.SESSION_ACCOUNT);

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String itemId = request.getParameter("itemId");

        if (itemId != null && !itemId.isEmpty()) {
            try {
                int itemIdInt = Integer.parseInt(itemId);

                Cart cart = cartDAO.findByAccountId(account.getId());

                if (cart != null) {
                    CartItem cartItem = cartItemDAO.getById(itemIdInt);

                    if (cartItem != null && cartItem.getCartId().equals(cart.getId())) {
                        boolean removed = cartItemDAO.delete(cartItem);

                        if (removed) {
                            session.setAttribute("message", "Course removed from cart successfully!");
                            session.setAttribute("messageType", "success");
                        } else {
                            session.setAttribute("message", "Failed to remove course from cart.");
                            session.setAttribute("messageType", "error");
                        }
                    } else {
                        session.setAttribute("message", "Item not found in your cart.");
                        session.setAttribute("messageType", "error");
                    }
                } else {
                    session.setAttribute("message", "Cart not found.");
                    session.setAttribute("messageType", "error");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("message", "Invalid item information.");
                session.setAttribute("messageType", "error");
            }
        } else {
            session.setAttribute("message", "Missing required information.");
            session.setAttribute("messageType", "error");
        }

        // Giữ lại tham số phân trang, tìm kiếm và sắp xếp khi redirect về trang giỏ hàng
        String search = request.getParameter("search");
        String sort = request.getParameter("sort");
        String page = request.getParameter("page");

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/cart?");
        if (page != null && !page.trim().isEmpty()) {
            redirectUrl.append("page=").append(page.trim()).append("&");
        }
        if (sort != null && !sort.trim().isEmpty()) {
            redirectUrl.append("sort=").append(sort.trim()).append("&");
        }
        if (search != null && !search.trim().isEmpty()) {
            redirectUrl.append("search=").append(URLEncoder.encode(search.trim(), "UTF-8")).append("&");
        }
        String finalUrl = redirectUrl.toString();
        if (finalUrl.endsWith("?") || finalUrl.endsWith("&")) {
            finalUrl = finalUrl.substring(0, finalUrl.length() - 1);
        }
        response.sendRedirect(finalUrl);
    }
}
