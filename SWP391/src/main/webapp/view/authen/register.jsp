<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Register</title>
</head>

<body>

<h2>Register</h2>

<!--
    Display registration error from Servlet
    Example:
    request.setAttribute("errorMessage", "Username already exists");
-->
<%
    String errorMessage = (String) request.getAttribute("errorMessage");

    if (errorMessage != null) {
%>

    <p style="color:red;">
        <%= errorMessage %>
    </p>

<%
    }
%>


<!--
    Register form

    Change "register" if your Servlet mapping uses
    a different URL.
-->
<form
    method="post"
    action="${pageContext.request.contextPath}/register"
>


    <!-- =========================
         USERNAME
    ========================== -->

    <div>
        <label for="username">
            User Name *
        </label>

        <input
            type="text"
            id="username"
            name="username"
            value="<%= request.getParameter("username") != null
                    ? request.getParameter("username")
                    : "" %>"
            required
        >
    </div>


    <br>


    <!-- =========================
         FULL NAME
    ========================== -->

    <div>
        <label for="fullName">
            Full Name *
        </label>

        <input
            type="text"
            id="fullName"
            name="fullName"
            value="<%= request.getParameter("fullName") != null
                    ? request.getParameter("fullName")
                    : "" %>"
            required
        >
    </div>


    <br>


    <!-- =========================
         PASSWORD
    ========================== -->

    <div>
        <label for="password">
            Password *
        </label>

        <input
            type="password"
            id="password"
            name="password"
            required
        >
    </div>


    <br>


    <!-- =========================
         CONFIRM PASSWORD
    ========================== -->

    <div>
        <label for="confirmPassword">
            Confirm Password *
        </label>

        <input
            type="password"
            id="confirmPassword"
            name="confirmPassword"
            required
        >
    </div>


    <br>


    <!-- =========================
         EMAIL
    ========================== -->

    <div>
        <label for="email">
            Email *
        </label>

        <input
            type="email"
            id="email"
            name="email"
            value="<%= request.getParameter("email") != null
                    ? request.getParameter("email")
                    : "" %>"
            required
        >
    </div>


    <br>


    <!-- =========================
         PHONE
    ========================== -->

    <div>
        <label for="phone">
            Phone *
        </label>

        <input
            type="tel"
            id="phone"
            name="phone"
            value="<%= request.getParameter("phone") != null
                    ? request.getParameter("phone")
                    : "" %>"
            required
        >
    </div>


    <br>


    <!-- =========================
         ROLE
    ========================== -->

    <div>
        <label for="role">
            Please select role *
        </label>

        <select
            id="role"
            name="role"
            required
        >

            <option value="">
                Registered as
            </option>

            <option value="teacher">
                Teacher
            </option>

            <option value="student">
                Student/User
            </option>

        </select>
    </div>


    <br>


    <!-- =========================
         GENDER
    ========================== -->

    <div>
        <label for="gender">
            Please select gender *
        </label>

        <select
            id="gender"
            name="gender"
            required
        >

            <option value="">
                Select Gender
            </option>

            <option value="male">
                Male
            </option>

            <option value="female">
                Female
            </option>

        </select>
    </div>


    <br>
    <br>


    <!-- =========================
         SUBMIT
    ========================== -->

    <button type="submit">
        Register
    </button>

</form>


<br>


<!-- =========================
     LOGIN LINK
========================== -->

<div>
    <span>
        Already have an account?
    </span>

    <a href="${pageContext.request.contextPath}/login">
        Login
    </a>
</div>


</body>

</html>