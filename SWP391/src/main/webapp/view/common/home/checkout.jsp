<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>Checkout</title>

    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <jsp:include page="css-home.jsp" />

    <style>

        .checkout-wrapper {
            padding: 80px 0;
            background: #fff;
        }

        .checkout-title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 35px;
        }

        .checkout-box {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 25px;
            background: #fff;
        }

        .checkout-box h4 {
            font-weight: 700;
            margin-bottom: 25px;
        }

        .payment-box {
            border: 1px solid #ddd;
            border-radius: 6px;
            padding: 20px;
            margin-top: 25px;
        }

        .payment-header {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 18px;
            font-weight: 600;
        }

        .payment-header input {
            width: 18px;
            height: 18px;
        }

        .form-control {
            height: 50px;
            border-radius: 5px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .country-select {
            width: 100%;
            height: 50px;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 0 15px;
            font-size: 15px;
            background: white;
        }

        .gender-group {
            display: flex;
            gap: 30px;
            align-items: center;
            margin-top: 8px;
        }

        .gender-item {
            display: flex;
            align-items: center;
            gap: 7px;
            font-weight: 400 !important;
            margin-bottom: 0 !important;
            cursor: pointer;
        }

        .gender-item input {
            width: 17px;
            height: 17px;
        }

        .course-item {
            padding: 15px 0;
            border-bottom: 1px solid #eee;
        }

        .course-item:last-child {
            border-bottom: none;
        }

        .summary-box {
            background: #f7f7f8;
            padding: 30px;
            border-radius: 8px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
        }

        .summary-total {
            border-top: 1px solid #ddd;
            padding-top: 20px;
            margin-top: 20px;
            font-size: 22px;
            font-weight: 700;
        }

        .pay-button {
            width: 100%;
            border: none;
            padding: 18px;
            background: #6f2bd9;
            color: white;
            font-size: 18px;
            font-weight: 700;
            border-radius: 8px;
            margin-top: 25px;
            cursor: pointer;
        }

        .pay-button:hover {
            opacity: .9;
        }

        .guarantee {
            margin-top: 40px;
            padding: 25px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }

        .error-message {
            background: #ffe5e5;
            color: #c00;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .success-message {
            background: #e5ffe9;
            color: #198754;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .field-error {
            color: #dc3545;
            font-size: 13px;
            margin-top: 5px;
            display: none;
        }

        .input-error {
            border: 1px solid #dc3545 !important;
        }

        .section-title {
            font-size: 20px;
            font-weight: 700;
            margin-top: 30px;
            margin-bottom: 20px;
        }

    </style>

</head>


<body>

    <!-- HEADER -->

    <jsp:include page="header-home.jsp" />


    <main class="main-area">

        <section class="checkout-wrapper">

            <div class="container">

                <h1 class="checkout-title">
                    Checkout
                </h1>


                <!-- SERVER ERROR -->

                <c:if test="${not empty error}">

                    <div class="error-message">
                        ${error}
                    </div>

                </c:if>


                <div class="row">


                    <!-- ========================= -->
                    <!-- LEFT -->
                    <!-- ========================= -->

                    <div class="col-lg-7">


                        <form
                            action="${pageContext.request.contextPath}/checkout"
                            method="post"
                            id="checkoutForm">

                            <input
                                type="hidden"
                                name="action"
                                value="pay">


                            <!-- ========================= -->
                            <!-- BILLING -->
                            <!-- ========================= -->

                            <div class="checkout-box">

                                <h4>
                                    Billing address
                                </h4>


                                <!-- COUNTRY -->

                                <div class="form-group">

                                    <label for="country">
                                        Country
                                    </label>

                                    <select
                                        id="country"
                                        name="country"
                                        class="country-select"
                                        required>

                                        <option value="">
                                            Select your country
                                        </option>

                                        <option value="Vietnam"
                                            ${param.country == 'Vietnam' ? 'selected' : ''}>
                                            🇻🇳 Vietnam
                                        </option>

                                        <option value="Japan"
                                            ${param.country == 'Japan' ? 'selected' : ''}>
                                            🇯🇵 Japan
                                        </option>

                                        <option value="South Korea"
                                            ${param.country == 'South Korea' ? 'selected' : ''}>
                                            🇰🇷 South Korea
                                        </option>

                                        <option value="China"
                                            ${param.country == 'China' ? 'selected' : ''}>
                                            🇨🇳 China
                                        </option>

                                        <option value="Thailand"
                                            ${param.country == 'Thailand' ? 'selected' : ''}>
                                            🇹🇭 Thailand
                                        </option>

                                        <option value="Singapore"
                                            ${param.country == 'Singapore' ? 'selected' : ''}>
                                            🇸🇬 Singapore
                                        </option>

                                        <option value="Malaysia"
                                            ${param.country == 'Malaysia' ? 'selected' : ''}>
                                            🇲🇾 Malaysia
                                        </option>

                                        <option value="Indonesia"
                                            ${param.country == 'Indonesia' ? 'selected' : ''}>
                                            🇮🇩 Indonesia
                                        </option>

                                        <option value="Philippines"
                                            ${param.country == 'Philippines' ? 'selected' : ''}>
                                            🇵🇭 Philippines
                                        </option>

                                        <option value="India"
                                            ${param.country == 'India' ? 'selected' : ''}>
                                            🇮🇳 India
                                        </option>

                                        <option value="United States"
                                            ${param.country == 'United States' ? 'selected' : ''}>
                                            🇺🇸 United States
                                        </option>

                                        <option value="Canada"
                                            ${param.country == 'Canada' ? 'selected' : ''}>
                                            🇨🇦 Canada
                                        </option>

                                        <option value="United Kingdom"
                                            ${param.country == 'United Kingdom' ? 'selected' : ''}>
                                            🇬🇧 United Kingdom
                                        </option>

                                        <option value="France"
                                            ${param.country == 'France' ? 'selected' : ''}>
                                            🇫🇷 France
                                        </option>

                                        <option value="Germany"
                                            ${param.country == 'Germany' ? 'selected' : ''}>
                                            🇩🇪 Germany
                                        </option>

                                        <option value="Italy"
                                            ${param.country == 'Italy' ? 'selected' : ''}>
                                            🇮🇹 Italy
                                        </option>

                                        <option value="Spain"
                                            ${param.country == 'Spain' ? 'selected' : ''}>
                                            🇪🇸 Spain
                                        </option>

                                        <option value="Netherlands"
                                            ${param.country == 'Netherlands' ? 'selected' : ''}>
                                            🇳🇱 Netherlands
                                        </option>

                                        <option value="Switzerland"
                                            ${param.country == 'Switzerland' ? 'selected' : ''}>
                                            🇨🇭 Switzerland
                                        </option>

                                        <option value="Australia"
                                            ${param.country == 'Australia' ? 'selected' : ''}>
                                            🇦🇺 Australia
                                        </option>

                                        <option value="New Zealand"
                                            ${param.country == 'New Zealand' ? 'selected' : ''}>
                                            🇳🇿 New Zealand
                                        </option>

                                        <option value="Brazil"
                                            ${param.country == 'Brazil' ? 'selected' : ''}>
                                            🇧🇷 Brazil
                                        </option>

                                        <option value="Mexico"
                                            ${param.country == 'Mexico' ? 'selected' : ''}>
                                            🇲🇽 Mexico
                                        </option>

                                    </select>

                                    <div
                                        id="countryError"
                                        class="field-error">
                                        Please select your country.
                                    </div>

                                </div>


                                <p style="color:#777; font-size:14px;">

                                    Udemy is required by law to collect
                                    applicable transaction taxes for
                                    purchases made in certain tax
                                    jurisdictions.

                                </p>


                                <!-- ========================= -->
                                <!-- PERSONAL INFORMATION -->
                                <!-- ========================= -->

                                <div class="section-title">

                                    Personal information

                                </div>


                                <!-- FULL NAME -->

                                <div class="form-group">

                                    <label for="fullName">
                                        Full name
                                    </label>

                                    <input
                                        type="text"
                                        id="fullName"
                                        name="fullName"
                                        class="form-control"
                                        value="${param.fullName}"
                                        placeholder="Enter your full name"
                                        required>

                                    <div
                                        id="fullNameError"
                                        class="field-error">

                                        Full name must contain at least
                                        2 characters.

                                    </div>

                                </div>


                                <!-- EMAIL + PHONE -->

                                <div class="row">

                                    <div class="col-md-6">

                                        <div class="form-group">

                                            <label for="email">
                                                Email
                                            </label>

                                            <input
                                                type="email"
                                                id="email"
                                                name="email"
                                                class="form-control"
                                                value="${param.email}"
                                                placeholder="example@gmail.com"
                                                required>

                                            <div
                                                id="emailError"
                                                class="field-error">

                                                Please enter a valid email.

                                            </div>

                                        </div>

                                    </div>


                                    <div class="col-md-6">

                                        <div class="form-group">

                                            <label for="phone">
                                                Phone number
                                            </label>

                                            <input
                                                type="tel"
                                                id="phone"
                                                name="phone"
                                                class="form-control"
                                                value="${param.phone}"
                                                placeholder="+84 123 456 789"
                                                required>

                                            <div
                                                id="phoneError"
                                                class="field-error">

                                                Please enter a valid phone
                                                number.

                                            </div>

                                        </div>

                                    </div>

                                </div>


                                <!-- GENDER -->

                                <div class="form-group">

                                    <label>
                                        Gender
                                    </label>

                                    <div class="gender-group">

                                        <label class="gender-item">

                                            <input
                                                type="radio"
                                                name="gender"
                                                value="Male"
                                                ${param.gender == 'Male' ? 'checked' : ''}
                                                required>

                                            Male

                                        </label>


                                        <label class="gender-item">

                                            <input
                                                type="radio"
                                                name="gender"
                                                value="Female"
                                                ${param.gender == 'Female' ? 'checked' : ''}>

                                            Female

                                        </label>


                                        <label class="gender-item">

                                            <input
                                                type="radio"
                                                name="gender"
                                                value="Other"
                                                ${param.gender == 'Other' ? 'checked' : ''}>

                                            Other

                                        </label>

                                    </div>

                                    <div
                                        id="genderError"
                                        class="field-error">

                                        Please select your gender.

                                    </div>

                                </div>


                                <!-- ADDRESS -->

                                <div class="form-group">

                                    <label for="address">
                                        Address / Location
                                    </label>

                                    <input
                                        type="text"
                                        id="address"
                                        name="address"
                                        class="form-control"
                                        value="${param.address}"
                                        placeholder="Street address, district..."
                                        required>

                                    <div
                                        id="addressError"
                                        class="field-error">

                                        Please enter your address.

                                    </div>

                                </div>


                                <!-- CITY + POSTAL -->

                                <div class="row">

                                    <div class="col-md-8">

                                        <div class="form-group">

                                            <label for="city">
                                                City
                                            </label>

                                            <input
                                                type="text"
                                                id="city"
                                                name="city"
                                                class="form-control"
                                                value="${param.city}"
                                                placeholder="Enter your city"
                                                required>

                                            <div
                                                id="cityError"
                                                class="field-error">

                                                 City must contain only letters and spaces.

                                            </div>

                                        </div>

                                    </div>


                                    <div class="col-md-4">

                                        <div class="form-group">

                                            <label for="postalCode">
                                                Postal code
                                            </label>

                                            <input
                                                type="text"
                                                id="postalCode"
                                                name="postalCode"
                                                class="form-control"
                                                value="${param.postalCode}"
                                                placeholder="100000">

                                        </div>

                                    </div>

                                </div>


                                <!-- ========================= -->
                                <!-- PAYMENT -->
                                <!-- ========================= -->

                                <div class="payment-box">

                                    <div class="payment-header">

                                        <input
                                            type="radio"
                                            checked>

                                        <span>
                                            💳 Cards
                                        </span>

                                    </div>

                                    <hr>


                                    <!-- CARD NUMBER -->

                                    <div class="form-group">

                                        <label for="cardNumber">
                                            Card number
                                        </label>

                                        <input
                                            type="text"
                                            id="cardNumber"
                                            class="form-control"
                                            name="cardNumber"
                                            value="${param.cardNumber}"
                                            placeholder="1234 5678 9012 3456"
                                            maxlength="19"
                                            required>

                                        <div
                                            id="cardNumberError"
                                            class="field-error">

                                            Card number must contain
                                            16 digits.

                                        </div>

                                    </div>


                                    <!-- EXPIRY + CVC -->

                                    <div class="row">

                                        <div class="col-md-6">

                                            <div class="form-group">

                                                <label for="expiry">
                                                    Expiry date
                                                </label>

                                                <input
                                                    type="text"
                                                    id="expiry"
                                                    class="form-control"
                                                    name="expiry"
                                                    value="${param.expiry}"
                                                    placeholder="MM/YYYY"
                                                    maxlength="7"
                                                    inputmode="numeric"
                                                    autocomplete="cc-exp"
                                                    required>

                                                <div
                                                    id="expiryError"
                                                    class="field-error">

                                                    Expiry date must be in
                                                    MM/YYYY format and must
                                                    not be expired.

                                                </div>

                                            </div>

                                        </div>


                                        <div class="col-md-6">

                                            <div class="form-group">

                                                <label for="cvc">
                                                    CVC/CVV
                                                </label>

                                                <input
                                                    type="password"
                                                    id="cvc"
                                                    class="form-control"
                                                    name="cvc"
                                                    placeholder="CVC"
                                                    maxlength="4"
                                                    inputmode="numeric"
                                                    required>

                                                <div
                                                    id="cvcError"
                                                    class="field-error">

                                                    CVC must contain
                                                    3 or 4 digits.

                                                </div>

                                            </div>

                                        </div>

                                    </div>


                                    <!-- NAME ON CARD -->

                                    <div class="form-group">

                                        <label for="cardName">
                                            Name on card
                                        </label>

                                        <input
                                            type="text"
                                            id="cardName"
                                            class="form-control"
                                            name="cardName"
                                            value="${param.cardName}"
                                            placeholder="Name on card"
                                            required>

                                        <div
                                            id="cardNameError"
                                            class="field-error">

                                            Please enter the name on card.

                                        </div>

                                    </div>


                                    <!-- SAVE CARD -->

                                    <div class="form-group">

                                        <label>

                                            <input
                                                type="checkbox"
                                                name="saveCard"
                                                ${param.saveCard != null ? 'checked' : ''}>

                                            Securely save this card
                                            for my later purchase

                                        </label>

                                    </div>

                                </div>

                            </div>

                        </form>

                    </div>


                    <!-- ========================= -->
                    <!-- RIGHT -->
                    <!-- ========================= -->

                    <div class="col-lg-5">

                        <div class="summary-box">

                            <h3>
                                Order summary
                            </h3>


                            <!-- COURSES -->

                            <c:forEach
                                items="${cartItems}"
                                var="item">

                                <c:set
                                    var="course"
                                    value="${courseDAO.findById(item.courseId)}" />

                                <div class="course-item">

                                    <div>

                                        <strong>
                                            ${course.name}
                                        </strong>

                                    </div>

                                    <div>

                                        ₫

                                        <fmt:formatNumber
                                            value="${item.price}"
                                            pattern="#,##0.00"/>

                                    </div>

                                </div>

                            </c:forEach>


                            <!-- ORIGINAL PRICE -->

                            <div
                                class="summary-row"
                                style="margin-top:25px;">

                                <span>
                                    Original Price:
                                </span>

                                <span>

                                    ₫

                                    <fmt:formatNumber
                                        value="${cartTotal}"
                                        pattern="#,##0.00"/>

                                </span>

                            </div>


                            <!-- DISCOUNT -->

                            <div class="summary-row">

                                <span>
                                    Discounts:
                                </span>

                                <span>
                                    ₫0.00
                                </span>

                            </div>


                            <!-- TOTAL -->

                            <div
                                class="summary-row summary-total">

                                <span>

                                    Total (${itemCount}
                                    course<c:if
                                        test="${itemCount > 1}">s</c:if>):

                                </span>

                                <span>

                                    ₫

                                    <fmt:formatNumber
                                        value="${cartTotal}"
                                        pattern="#,##0.00"/>

                                </span>

                            </div>


                            <p
                                style="font-size:14px;
                                       color:#666;
                                       margin-top:20px;">

                                By completing your purchase,
                                you agree to these

                                <a href="#">
                                    Terms of Use
                                </a>.

                            </p>


                            <!-- PAY -->

                            <button
                                type="submit"
                                form="checkoutForm"
                                class="pay-button">

                                🔒 Pay ₫

                                <fmt:formatNumber
                                    value="${cartTotal}"
                                    pattern="#,##0.00"/>

                            </button>


                            <!-- GUARANTEE -->

                            <div class="guarantee">

                                <h4>
                                    🔥 30-Day Money-Back Guarantee
                                </h4>

                                <p>

                                    Not satisfied?
                                    Get a full refund within
                                    30 days.

                                    Simple and straightforward!

                                </p>

                            </div>

                        </div>

                    </div>

                </div>

            </div>

        </section>

    </main>


    <!-- FOOTER -->

    <jsp:include page="footer-home.jsp" />

    <jsp:include page="js-home.jsp" />


    <!-- ========================= -->
    <!-- JAVASCRIPT VALIDATION -->
    <!-- ========================= -->

    <script>

        const form = document.getElementById("checkoutForm");


        form.addEventListener("submit", function(event) {

            let valid = true;

            clearErrors();


            // =========================
            // COUNTRY
            // =========================

            const country =
                document.getElementById("country").value;

            if (country === "") {

                showError(
                    "country",
                    "countryError"
                );

                valid = false;
            }


            // =========================
            // FULL NAME
            // =========================

            const fullName =
                document.getElementById("fullName")
                .value.trim();

            if (fullName.length < 2) {

                showError(
                    "fullName",
                    "fullNameError"
                );

                valid = false;
            }


            // =========================
            // EMAIL
            // =========================

            const email =
                document.getElementById("email")
                .value.trim();

            const emailRegex =
                /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

            if (!emailRegex.test(email)) {

                showError(
                    "email",
                    "emailError"
                );

                valid = false;
            }


            // =========================
            // PHONE
            // =========================

            const phone =
                document.getElementById("phone")
                .value.trim();

            const phoneRegex =
                /^\+?[0-9\s-]{9,15}$/;

            if (!phoneRegex.test(phone)) {

                showError(
                    "phone",
                    "phoneError"
                );

                valid = false;
            }


            // =========================
            // GENDER
            // =========================

            const gender =
                document.querySelector(
                    'input[name="gender"]:checked'
                );

            if (!gender) {

                document.getElementById(
                    "genderError"
                ).style.display = "block";

                valid = false;
            }


            // =========================
            // ADDRESS
            // =========================

            const address =
                document.getElementById("address")
                .value.trim();

            if (address.length < 5) {

                showError(
                    "address",
                    "addressError"
                );

                valid = false;
            }


            // =========================
// CITY
// =========================

const city = document
    .getElementById("city")
    .value
    .trim();

// Chỉ cho phép chữ cái và khoảng trắng
const cityRegex = /^[A-Za-zÀ-ỹ\s]+$/;

if (city.length < 2 || !cityRegex.test(city)) {

    showError(
        "city",
        "cityError"
    );

    valid = false;
}


            // =========================
            // CARD NUMBER
            // =========================

            const cardNumber =
                document.getElementById("cardNumber")
                .value
                .replace(/\s/g, "");

            if (!/^\d{16}$/.test(cardNumber)) {

                showError(
                    "cardNumber",
                    "cardNumberError"
                );

                valid = false;
            }


            // =========================
            // EXPIRY
            // =========================

            const expiry =
                document.getElementById("expiry")
                .value.trim();

            if (!validateExpiry(expiry)) {

                showError(
                    "expiry",
                    "expiryError"
                );

                valid = false;
            }


            // =========================
            // CVC
            // =========================

            const cvc =
                document.getElementById("cvc")
                .value.trim();

            if (!/^\d{3,4}$/.test(cvc)) {

                showError(
                    "cvc",
                    "cvcError"
                );

                valid = false;
            }


            // =========================
            // CARD NAME
            // =========================

            const cardName =
                document.getElementById("cardName")
                .value.trim();

            if (cardName.length < 2) {

                showError(
                    "cardName",
                    "cardNameError"
                );

                valid = false;
            }


            // =========================
            // STOP SUBMIT
            // =========================

            if (!valid) {

                event.preventDefault();

                const firstError =
                    document.querySelector(
                        ".input-error"
                    );

                if (firstError) {
                    firstError.focus();
                }

                return;
            }


            // =========================
            // CONFIRM PAYMENT
            // =========================

            const confirmPay = confirmPayment();

            if (!confirmPay) {

                event.preventDefault();

            }

        });


        // =========================
        // CONFIRM PAYMENT
        // =========================

        function confirmPayment() {

            return confirm(
                "Are you sure you want to complete your purchase?"
            );

        }


        // =========================
        // SHOW ERROR
        // =========================

        function showError(inputId, errorId) {

            const input =
                document.getElementById(inputId);

            const error =
                document.getElementById(errorId);

            if (input) {

                input.classList.add("input-error");

            }

            if (error) {

                error.style.display = "block";

            }

        }


        // =========================
        // CLEAR ERROR
        // =========================

        function clearErrors() {

            document
                .querySelectorAll(".field-error")
                .forEach(function(error) {

                    error.style.display = "none";

                });


            document
                .querySelectorAll(".input-error")
                .forEach(function(input) {

                    input.classList.remove("input-error");

                });

        }


        // =========================
        // EXPIRY VALIDATION
        // FORMAT: MM/YYYY
        // =========================

        function validateExpiry(value) {

            /*
             * Phải đúng:
             * MM/YYYY
             *
             * Ví dụ:
             * 08/2026
             * 12/2027
             *
             * Không chấp nhận:
             * 8/2026
             * 08/26
             * 13/2026
             * 00/2026
             */

            if (!/^\d{2}\/\d{4}$/.test(value)) {

                return false;

            }


            const parts = value.split("/");


            const month =
                parseInt(parts[0], 10);

            const year =
                parseInt(parts[1], 10);


            // =========================
            // CHECK MONTH
            // =========================

            if (month < 1 || month > 12) {

                return false;

            }


            // =========================
            // CURRENT DATE
            // =========================

            const now = new Date();

            const currentYear =
                now.getFullYear();

            const currentMonth =
                now.getMonth() + 1;


            // =========================
            // CHECK YEAR
            // =========================

            if (year < currentYear) {

                return false;

            }


            // =========================
            // SAME YEAR
            // CHECK MONTH
            // =========================

            if (
                year === currentYear &&
                month < currentMonth
            ) {

                return false;

            }


            return true;

        }


        // =========================
        // CARD NUMBER FORMAT
        // =========================

        document
            .getElementById("cardNumber")
            .addEventListener(
                "input",
                function() {

                    let value =
                        this.value
                        .replace(/\D/g, "");

                    value =
                        value.substring(0, 16);

                    let formatted = "";


                    for (
                        let i = 0;
                        i < value.length;
                        i++
                    ) {

                        if (
                            i > 0 &&
                            i % 4 === 0
                        ) {

                            formatted += " ";

                        }

                        formatted += value[i];

                    }


                    this.value = formatted;

                }
            );


        // =========================
        // EXPIRY FORMAT
        // MM/YYYY
        // =========================

        document
            .getElementById("expiry")
            .addEventListener(
                "input",
                function() {

                    let value =
                        this.value
                        .replace(/\D/g, "");


                    // Chỉ cho phép tối đa 6 số
                    // MMYYYY

                    value =
                        value.substring(0, 6);


                    // Sau khi nhập 2 số
                    // tự động thêm /

                    if (value.length >= 3) {

                        value =
                            value.substring(0, 2)
                            + "/"
                            + value.substring(2);

                    }


                    this.value = value;

                }
            );


        // =========================
        // CVC ONLY NUMBER
        // =========================

        document
            .getElementById("cvc")
            .addEventListener(
                "input",
                function() {

                    this.value =
                        this.value
                        .replace(/\D/g, "")
                        .substring(0, 4);

                }
            );
    // =========================
// CITY ONLY LETTERS
// =========================

document
    .getElementById("city")
    .addEventListener("input", function () {

        this.value = this.value.replace(
            /[^A-Za-zÀ-ỹ\s]/g,
            ""
        );

    });

    </script>

</body>

</html>