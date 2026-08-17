<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>OCMS - Checkout</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/img/favicon.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <!-- Bootstrap CSS for layout utilities -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .checkout-summary {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
        }
        .checkout-item {
            border-bottom: 1px solid #eee;
            padding: 20px 0;
        }
        .checkout-item:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>

    <!-- header-area -->
    <jsp:include page="/view/common/header.jsp"></jsp:include>
    <!-- header-area-end -->

    <!-- main-area -->
    <main class="main-area fix">
        <section class="breadcrumb-area breadcrumb-bg" data-background="${pageContext.request.contextPath}/assets/img/bg/breadcrumb_bg.jpg">
            <div class="container">
                <div class="row">
                    <div class="col-12">
                        <div class="breadcrumb-content">
                            <h3 class="title">Checkout</h3>
                            <nav class="breadcrumb">
                                <span property="itemListElement" typeof="ListItem">
                                    <a href="${pageContext.request.contextPath}/cart">Cart</a>
                                </span>
                                <span class="breadcrumb-separator"><i class="fas fa-angle-right"></i></span>
                                <span property="itemListElement" typeof="ListItem">Checkout</span>
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="checkout-area section-py-120">
            <div class="container">
                <div class="row">
                    <div class="col-lg-8">
                        <div class="checkout-items-wrapper">
                            <h4 class="mb-4">Order Summary (${sessionScope.checkoutItemCount} courses)</h4>

                            <c:forEach items="${sessionScope.checkoutCartItems}" var="item" varStatus="status">
                                <c:set var="course" value="${courseDAO.findById(item.courseId)}" />
                                <div class="checkout-item">
                                    <div class="row align-items-center">
                                        <div class="col-md-8">
                                            <h5>${course.name}</h5>
                                            <small>Course ID: ${item.courseId}</small>
                                        </div>
                                        <div class="col-md-4 text-right">
                                            <span class="price">$<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></span>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>

                            <c:if test="${empty sessionScope.checkoutCartItems}">
                                <div class="alert alert-warning">
                                    Your checkout session has expired. Please try again.
                                </div>
                                <a href="${pageContext.request.contextPath}/cart" class="btn btn-primary">Back to Cart</a>
                            </c:if>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="checkout-summary">
                            <h4 class="mb-4">Payment Details</h4>

                            <div class="d-flex justify-content-between mb-3">
                                <span>Subtotal:</span>
                                <span>$<fmt:formatNumber value="${sessionScope.checkoutCartTotal}" pattern="#,##0.00"/></span>
                            </div>

                            <hr>

                            <div class="d-flex justify-content-between mb-4">
                                <strong>Total:</strong>
                                <strong>$<fmt:formatNumber value="${sessionScope.checkoutCartTotal}" pattern="#,##0.00"/></strong>
                            </div>

                            <c:if test="${not empty sessionScope.checkoutCartItems}">
                                <form action="${pageContext.request.contextPath}/cart" method="post" id="checkoutConfirmForm">
                                    <input type="hidden" name="action" value="complete-checkout">
                                    <button type="submit" class="btn btn-primary btn-block" id="checkoutConfirmBtn">
                                        Complete Checkout
                                    </button>
                                </form>
                            </c:if>

                            <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-secondary btn-block mt-3">
                                Back to Cart
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>
    <!-- main-area-end -->

    <!-- footer-area -->
    <jsp:include page="/view/common/footer.jsp"></jsp:include>
    <!-- footer-area-end -->

    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var form = document.getElementById('checkoutConfirmForm');
            if (form) {
                form.addEventListener('submit', function (e) {
                    e.preventDefault();
                    if (confirm('Are you sure you want to complete this purchase? This will register you for all courses in your cart.')) {
                        this.submit();
                    }
                });
            }
        });
    </script>
</body>
</html>