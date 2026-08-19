<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>FAQs</title>

</head>

<body>


<h1>FAQs (USER)</h1>


<!-- =========================
     CATEGORY FILTER
========================= -->

<div>

    <label for="faqCategory">
        Select Category:
    </label>

    <select
        id="faqCategory"
        name="category"
    >

        <option value="">
            All Categories
        </option>

        <option value="course">
            Course
        </option>

        <option value="payment">
            Payment
        </option>

        <option value="account">
            Account
        </option>

    </select>

</div>


<br>


<!-- =========================
     SEARCH
========================= -->

<div>

    <label for="faqSearch">
        Search:
    </label>

    <input
        type="text"
        id="faqSearch"
        name="search"
        placeholder="Search"
    >

</div>


<br>
<hr>
<br>


<!-- =========================
     FAQ QUESTIONS
========================= -->

<table border="1">

    <thead>

        <tr>

            <th>
                Question
            </th>

        </tr>

    </thead>


    <tbody>

        <tr>

            <td>

                <a href="#">
                    How do I enroll?
                </a>

            </td>

        </tr>


        <tr>

            <td>

                <a href="#">
                    How do I pay?
                </a>

            </td>

        </tr>


        <tr>

            <td>

                <a href="#">
                    How do I reset password?
                </a>

            </td>

        </tr>

    </tbody>

</table>


<br>
<hr>
<br>


<!-- =========================
     FAQ DETAIL
========================= -->

<h2>FAQ Details</h2>


<div>

    <label>
        Question:
    </label>

    <p>
        How do I pay for this course?
    </p>

</div>


<br>


<div>

    <label>
        Answer:
    </label>

    <p>
        Select the course you want to purchase and continue
        to the payment page. Choose one of the available
        payment methods to complete the payment.
    </p>

</div>


</body>

</html>