<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!doctype html>
<html class="no-js" lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Shopping Cart</title>
    <meta name="description" content="Shopping Cart">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    
    <!-- Place favicon.ico in the root directory -->

    <!-- CSS here -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Toast CSS -->
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
    
    <style>
        .cart-item {
            border-bottom: 1px solid #eee;
            padding: 20px 0;
        }
        .cart-item:last-child {
            border-bottom: none;
        }
        .cart-item-image {
            width: 120px;
            height: 80px;
            object-fit: cover;
            border-radius: 5px;
        }
        .cart-summary {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
        }
        .empty-cart {
            text-align: center;
            padding: 50px 0;
        }
        .empty-cart i {
            font-size: 60px;
            color: #ddd;
            margin-bottom: 20px;
        }
.cart-summary .cart-actions {
    display: flex !important;
    gap: 10px;
}

.cart-summary .cart-actions a,
.cart-summary .cart-actions form {
    width: 50%;
}

.cart-summary .cart-actions button,
.cart-summary .cart-actions a {
    width: 100%;
}

        /* Pagination */
        .cart-pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 30px;
            gap: 10px;
            margin-bottom: 20px;
        }
        .cart-pagination .page-link {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 40px;
            border-radius: 50% !important;
            background: #ffffff;
            color: #1a1a2e;
            text-decoration: none;
            font-size: 15px;
            font-weight: 600;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            transition: all 0.25s ease;
            border: 1px solid transparent;
            padding: 0;
        }
        .cart-pagination .page-link:hover {
            background: #eef2f6;
            color: #1a1a2e;
            transform: translateY(-2px);
        }
        .cart-pagination .page-link.active {
            background: #16192b;
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(26, 26, 46, 0.3);
        }
    </style>
</head>

<body>

    <!-- header-area -->
    <jsp:include page="/view/common/header.jsp"></jsp:include>
    <!-- header-area-end -->

    <!-- main-area -->
    <main style="min-height:70vh; padding: 48px 0;">
        <div class="container">
            <h1 style="font-size:28px; font-weight:700; margin-bottom:32px;">Shopping Cart</h1>

            <!-- Toast messages will be shown via JavaScript -->
                
                <div class="row">
                    <div class="col-lg-8">
                        <div class="cart-items-wrapper">
                            <h4 class="mb-4">Your Cart (${itemCount} items)</h4>
                            
                            <c:choose>
                                <c:when test="${empty cartItems}">
                                    <div class="empty-cart">
                                        <i class="fas fa-shopping-cart"></i>
                                        <h5>Your cart is empty</h5>
                                        <p>Looks like you haven't added any courses to your cart yet.</p>
                                        <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary mt-3">Browse Courses</a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${cartItems}" var="item" varStatus="status">
                                        <div class="cart-item">
                                            <div class="row align-items-center">
                                                <c:set var="course" value="${courseDAO.findById(item.courseId)}" />
                                                <div class="col-md-2">
                                                    <img src="${course.thumbnail}" alt="Course thumbnail" class="cart-item-image">
                                                </div>
                                                <div class="col-md-6">
                                                    <h5>${course.name}</h5>
                                                    <small>Added on: <fmt:formatDate value="${item.addedDate}" pattern="MMM dd, yyyy"/></small>
                                                </div>
                                                <div class="col-md-2 text-right">
                                                    <span class="price">$<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></span>
                                                </div>
                                                <div class="col-md-2 text-right">
                                                    <form action="${pageContext.request.contextPath}/cart" method="post" class="remove-item-form" id="removeForm_${item.id}" data-course-name="${course.name}">
                                                        <input type="hidden" name="action" value="remove">
                                                        <input type="hidden" name="itemId" value="${item.id}">
                                                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmRemove(${item.id}, '${course.name}')">
                                                            <i class="fas fa-trash"></i> Remove
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>

                            <!-- Pagination (Max 4 items per page) -->
                            <c:if test="${totalPages > 1}">
                                <div class="cart-pagination">
                                    <!-- First Page -->
                                    <c:if test="${totalPages > 2 && currentPage > 1}">
                                        <a href="${pageContext.request.contextPath}/cart?page=1" class="page-link" title="First Page"><i class="fa-solid fa-angles-left"></i></a>
                                    </c:if>

                                    <!-- Previous Page -->
                                    <c:if test="${currentPage > 1}">
                                        <a href="${pageContext.request.contextPath}/cart?page=${currentPage - 1}" class="page-link" title="Previous Page"><i class="fa-solid fa-angle-left"></i></a>
                                    </c:if>

                                    <!-- Page Numbers -->
                                    <c:forEach var="i" begin="1" end="${totalPages}">
                                        <a href="${pageContext.request.contextPath}/cart?page=${i}" class="page-link ${currentPage == i ? 'active' : ''}">${i}</a>
                                    </c:forEach>

                                    <!-- Next Page -->
                                    <c:if test="${currentPage < totalPages}">
                                        <a href="${pageContext.request.contextPath}/cart?page=${currentPage + 1}" class="page-link" title="Next Page"><i class="fa-solid fa-angle-right"></i></a>
                                    </c:if>

                                    <!-- Last Page -->
                                    <c:if test="${totalPages > 2 && currentPage < totalPages}">
                                        <a href="${pageContext.request.contextPath}/cart?page=${totalPages}" class="page-link" title="Last Page"><i class="fa-solid fa-angles-right"></i></a>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    
                    <div class="col-lg-4">
                        <div class="cart-summary">
                            <h4 class="mb-4">Order Summary</h4>
                            
                            <div class="d-flex justify-content-between mb-3">
                                <span>Subtotal:</span>
                                <span>$<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></span>
                            </div>
                            
                            <hr>
                            
                            <div class="d-flex justify-content-between mb-4">
                                <strong>Total:</strong>
                                <strong>$<fmt:formatNumber value="${cartTotal}" pattern="#,##0.00"/></strong>
                            </div>
<div class="cart-actions mt-4">

    <!-- Continue Shopping -->
    <a href="${pageContext.request.contextPath}/courses"
       class="btn btn-outline-secondary"
       style="display: inline-block; margin-right: 10px;">
        Continue Shopping
    </a>

    <!-- Proceed to Checkout -->
    <a href="${pageContext.request.contextPath}/view/common/home/checkout.jsp"
       class="btn btn-primary"
       style="display: flex; align-items: center; justify-content: center; width: 50%; text-decoration: none;">
        Checkout
    </a>

</div>                     

                        </div>
                    </div>
                </div>
            </div>
    </main>
    <!-- main-area-end -->

    <!-- footer-area -->
    <jsp:include page="/view/common/footer.jsp"></jsp:include>
    <!-- footer-area-end -->

    <!-- JS here -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Toast JS -->
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    
    <script>
        // Function to confirm item removal
        function confirmRemove(itemId, courseName) {
            if (confirm('Are you sure you want to remove "' + courseName + '" from your cart?')) {
                document.getElementById('removeForm_' + itemId).submit();
            }
            return false;
        }
        
        // Update the remove buttons to use the confirmation function
        document.addEventListener('DOMContentLoaded', function() {
            const removeForms = document.querySelectorAll('.remove-item-form');
            removeForms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    e.preventDefault();
                    const itemId = this.querySelector('input[name="itemId"]').value;
                    const courseName = this.getAttribute('data-course-name');
                    confirmRemove(itemId, courseName);
                });
            });
        });
        
        // Function to show toast message
        function showToast(message, type) {
            let backgroundColor = "#28a745"; // Default success color
            
            if (type === "error") {
                backgroundColor = "#dc3545"; // Danger color
            } else if (type === "info") {
                backgroundColor = "#17a2b8"; // Info color
            } else if (type === "warning") {
                backgroundColor = "#ffc107"; // Warning color
            }
            
            Toastify({
                text: message,
                duration: 5000,
                close: true,
                gravity: "top",
                position: "right",
                backgroundColor: backgroundColor,
                stopOnFocus: true
            }).showToast();
        }
        
        // Check for session messages and display toast
        <c:if test="${not empty sessionScope.message}">
            document.addEventListener("DOMContentLoaded", function() {
                showToast("${sessionScope.message}", "${sessionScope.messageType}");
            });
            <c:remove var="message" scope="session" />
            <c:remove var="messageType" scope="session" />
        </c:if>
        
        // Handle checkout confirmation
        document.addEventListener('DOMContentLoaded', function() {
            const checkoutForm = document.getElementById('checkoutForm');
            if (checkoutForm) {
                checkoutForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    if (confirm('Are you sure you want to complete your purchase? This will register you for all courses in your cart.')) {
                        this.submit();
                    }
                });
            }
        });
    </script>
</body>

</html>