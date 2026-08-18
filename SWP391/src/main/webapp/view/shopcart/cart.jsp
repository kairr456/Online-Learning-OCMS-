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

    <!-- CSS here -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Toast CSS -->
    <link href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" rel="stylesheet">
    
    <!-- Cart CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkoutcart/cart.css">
</head>

<body>

    <!-- header-area -->
    <jsp:include page="/view/common/header.jsp"></jsp:include>
    <!-- header-area-end -->

    <!-- main-area -->
    <main class="cart-main">
        <div class="container">
            <h1 class="cart-title">Shopping Cart</h1>

            <!-- Toast messages will be shown via JavaScript -->
                
            <div class="row">
                <div class="col-lg-8">
                    <div class="cart-items-wrapper">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">Your Cart (${totalCartItems != null ? totalCartItems : itemCount} items)</h4>
                        </div>
                        
                        <c:choose>
                            <%-- Giỏ hàng hoàn toàn trống --%>
                            <c:when test="${(empty totalCartItems || totalCartItems == 0) && empty search}">
                                <div class="empty-cart">
                                    <i class="fas fa-shopping-cart"></i>
                                    <h5>Your cart is empty</h5>
                                    <p>Looks like you haven't added any courses to your cart yet.</p>
                                    <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary mt-3">Browse Courses</a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <!-- Cart Toolbar (Search & Sort) -->
                                <div class="cart-toolbar">
                                    <!-- Ô Tìm Kiếm -->
                                    <div class="cart-search-box">
                                        <form action="${pageContext.request.contextPath}/cart" method="get" class="cart-search-form" id="cartSearchForm">
                                            <input type="hidden" name="sort" value="<c:out value="${sort}"/>">
                                            <input type="text" name="search" id="cartSearchInput" class="cart-search-input" 
                                                   placeholder="Tìm kiếm khóa học..." value="<c:out value="${search}"/>" 
                                                   onkeydown="if(event.key === 'Enter'){ event.preventDefault(); document.getElementById('cartSearchForm').submit(); }">
                                            <c:if test="${not empty search}">
                                                <a href="${pageContext.request.contextPath}/cart?sort=<c:out value="${sort}"/>" class="cart-clear-btn" title="Xóa tìm kiếm">
                                                    <i class="fa-solid fa-xmark"></i>
                                                </a>
                                            </c:if>
                                            <button type="submit" class="cart-search-btn" title="Tìm kiếm">
                                                <i class="fa-solid fa-magnifying-glass"></i>
                                            </button>
                                        </form>
                                    </div>

                                    <!-- Bộ Sắp Xếp (Mới nhất / Cũ nhất) -->
                                    <div class="cart-sort-wrap">
                                        <label for="cartSortSelect">
                                            <i class="fa-solid fa-arrow-down-short-wide"></i> Sắp xếp:
                                        </label>
                                        <select id="cartSortSelect" class="cart-sort-select" onchange="applyCartSort(this.value)">
                                            <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                            <option value="oldest" ${sort == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                        </select>
                                    </div>
                                </div>

                                <c:choose>
                                    <%-- Khi tìm kiếm không có kết quả phù hợp --%>
                                    <c:when test="${empty cartItems}">
<div class="empty-cart empty-cart-compact">
<i class="fa-solid fa-magnifying-glass empty-cart-icon"></i>
                                            <h5>Không tìm thấy khóa học nào phù hợp</h5>
                                            <p class="text-muted mb-3">Không có khóa học nào trong giỏ hàng khớp với từ khóa "<strong><c:out value="${search}"/></strong>".</p>
                                            <a href="${pageContext.request.contextPath}/cart?sort=<c:out value="${sort}"/>" class="btn btn-sm btn-outline-primary">
                                                <i class="fa-solid fa-rotate-left me-1"></i> Xem tất cả trong giỏ hàng
                                            </a>
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
                                                            <input type="hidden" name="search" value="<c:out value="${search}"/>">
                                                            <input type="hidden" name="sort" value="<c:out value="${sort}"/>">
                                                            <input type="hidden" name="page" value="${currentPage}">
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
                            </c:otherwise>
                        </c:choose>

                        <!-- Pagination (Max 4 items per page) -->
                        <c:if test="${totalPages > 1}">
                            <div class="cart-pagination">
                                <!-- First Page -->
                                <c:if test="${totalPages > 2 && currentPage > 1}">
                                    <c:url var="firstPageUrl" value="/cart">
                                        <c:param name="page" value="1"/>
                                        <c:if test="${not empty search}"><c:param name="search" value="${search}"/></c:if>
                                        <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
                                    </c:url>
                                    <a href="${firstPageUrl}" class="page-link" title="First Page"><i class="fa-solid fa-angles-left"></i></a>
                                </c:if>

                                <!-- Previous Page -->
                                <c:if test="${currentPage > 1}">
                                    <c:url var="prevPageUrl" value="/cart">
                                        <c:param name="page" value="${currentPage - 1}"/>
                                        <c:if test="${not empty search}"><c:param name="search" value="${search}"/></c:if>
                                        <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
                                    </c:url>
                                    <a href="${prevPageUrl}" class="page-link" title="Previous Page"><i class="fa-solid fa-angle-left"></i></a>
                                </c:if>

                                <!-- Page Numbers -->
                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <c:url var="itemPageUrl" value="/cart">
                                        <c:param name="page" value="${i}"/>
                                        <c:if test="${not empty search}"><c:param name="search" value="${search}"/></c:if>
                                        <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
                                    </c:url>
                                    <a href="${itemPageUrl}" class="page-link ${currentPage == i ? 'active' : ''}">${i}</a>
                                </c:forEach>

                                <!-- Next Page -->
                                <c:if test="${currentPage < totalPages}">
                                    <c:url var="nextPageUrl" value="/cart">
                                        <c:param name="page" value="${currentPage + 1}"/>
                                        <c:if test="${not empty search}"><c:param name="search" value="${search}"/></c:if>
                                        <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
                                    </c:url>
                                    <a href="${nextPageUrl}" class="page-link" title="Next Page"><i class="fa-solid fa-angle-right"></i></a>
                                </c:if>

                                <!-- Last Page -->
                                <c:if test="${totalPages > 2 && currentPage < totalPages}">
                                    <c:url var="lastPageUrl" value="/cart">
                                        <c:param name="page" value="${totalPages}"/>
                                        <c:if test="${not empty search}"><c:param name="search" value="${search}"/></c:if>
                                        <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
                                    </c:url>
                                    <a href="${lastPageUrl}" class="page-link" title="Last Page"><i class="fa-solid fa-angles-right"></i></a>
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
                                class="btn btn-outline-secondary btn-continue-shopping">
                                Continue Shopping
                            </a>

                            <!-- Proceed to Checkout -->
                            <a href="${pageContext.request.contextPath}/checkout"
                                class="btn btn-primary btn-checkout-link">
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
        // Function to apply sorting
        function applyCartSort(sortVal) {
            const searchInput = document.getElementById('cartSearchInput');
            const searchVal = searchInput ? searchInput.value.trim() : '';
            let url = '${pageContext.request.contextPath}/cart?page=1&sort=' + encodeURIComponent(sortVal);
            if (searchVal) {
                url += '&search=' + encodeURIComponent(searchVal);
            }
            window.location.href = url;
        }

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
