<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>My Request</title>
</head>

<body>

<!-- =========================================================
     MY REQUEST
========================================================= -->

<h1>MY REQUEST</h1>

<button type="button">
    New request
</button>

<br>
<br>


<table border="1">

    <thead>
        <tr>
            <th>Subject</th>
            <th>Category</th>
            <th>Status</th>
        </tr>
    </thead>

    <tbody>

        <tr>
            <td>
                payment failed
            </td>

            <td>
                course
            </td>

            <td>
                Replied
            </td>
        </tr>


        <tr>
            <td>
                Account problem
            </td>

            <td>
                account
            </td>

            <td>
                Open
            </td>
        </tr>

    </tbody>

</table>


<br>
<hr>
<br>


<!-- =========================================================
     NEW REQUEST
========================================================= -->

<h2>NEW REQUEST</h2>

<form
    method="post"
    action="${pageContext.request.contextPath}/contact"
>


    <!-- =====================================================
         CATEGORY
    ====================================================== -->

    <div>

        <label for="category">
            Category *
        </label>

        <select
            id="category"
            name="category"
            required
        >

            <option value="">
                Select category
            </option>

            <option value="payment">
                Payment
            </option>

            <option value="course">
                Course
            </option>

            <option value="account">
                Account
            </option>

            <option value="technical">
                Technical
            </option>

        </select>

    </div>


    <br>


    <!-- =====================================================
         RELATED COURSE
    ====================================================== -->

    <div>

        <label for="relatedCourse">
            Related Course
        </label>

        <select
            id="relatedCourse"
            name="relatedCourse"
        >

            <option value="">
                Can be None
            </option>

            <option value="1">
                Java Programming
            </option>

            <option value="2">
                Web Development
            </option>

            <option value="3">
                Database Fundamentals
            </option>

        </select>

    </div>


    <br>


    <!-- =====================================================
         SUBJECT
    ====================================================== -->

    <div>

        <label for="subject">
            Subject *
        </label>

        <input
            type="text"
            id="subject"
            name="subject"
            placeholder="Enter subject"
            required
        >

    </div>


    <br>


    <!-- =====================================================
         MESSAGE
    ====================================================== -->

    <div>

        <label for="message">
            Message *
        </label>

        <br>

        <textarea
            id="message"
            name="message"
            rows="8"
            cols="50"
            placeholder="Describe your problem..."
            required
        ></textarea>

    </div>


    <br>


    <!-- =====================================================
         BUTTONS
    ====================================================== -->

    <button type="submit">
        Save
    </button>

    <button
        type="button"
        onclick="history.back()"
    >
        Cancel
    </button>

</form>

</body>

</html>