<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Contact Request</title>

</head>


<body>


<div class="contact-response-page">


    <!-- =========================================================
         PAGE TITLE
    ========================================================== -->

    <h1 class="page-title">
        CONTACT RESPONSE
    </h1>


    <!-- =========================================================
         REQUEST LIST
    ========================================================== -->

    <div class="request-table-wrapper">

        <table class="request-table">

            <thead>

                <tr>

                    <th>
                        User
                    </th>

                    <th>
                        Subject
                    </th>

                    <th>
                        Category
                    </th>

                    <th>
                        Status
                    </th>

                </tr>

            </thead>


            <tbody>

                <!-- Request 1 -->

                <tr class="selected">

                    <td>
                        Messina Cake
                    </td>

                    <td>
                        payment failed
                    </td>

                    <td>
                        course
                    </td>

                    <td>

                        <span class="status-badge status-open">
                            Open
                        </span>

                    </td>

                </tr>


                <!-- Request 2 -->

                <tr>

                    <td>
                        User1
                    </td>

                    <td>
                        Account problem
                    </td>

                    <td>
                        account
                    </td>

                    <td>

                        <span class="status-badge status-replied">
                            Replied
                        </span>

                    </td>

                </tr>

            </tbody>

        </table>

    </div>


    <!-- =========================================================
         REQUEST DETAIL
    ========================================================== -->

    <div class="request-detail">


        <!-- =====================================================
             REQUEST INFORMATION
        ====================================================== -->

        <section class="request-content">

            <h2 class="section-title">
                Request Details
            </h2>


            <!-- USER INFORMATION -->

            <div class="user-card">

                <h3 class="user-card-title">
                    User Information
                </h3>


                <div class="user-item">

                    <span class="user-label">
                        User Name
                    </span>

                    <span class="user-value">
                        Messina Cake
                    </span>

                </div>


                <div class="user-item">

                    <span class="user-label">
                        Email Address
                    </span>

                    <a
                        class="user-value user-email"
                        href="mailto:user@example.com"
                    >
                        user@example.com
                    </a>

                </div>

            </div>


            <!-- SUBJECT -->

            <div class="field">

                <label for="subject">
                    Subject
                </label>

                <input
                    type="text"
                    id="subject"
                    value="payment failed"
                    readonly
                    class="readonly-field"
                >

            </div>


            <!-- CATEGORY -->

            <div class="field">

                <label for="category">
                    Category
                </label>

                <input
                    type="text"
                    id="category"
                    value="course"
                    readonly
                    class="readonly-field"
                >

            </div>


            <!-- RELATED COURSE -->

            <div class="field">

                <label for="relatedCourse">
                    Related Course
                </label>

                <input
                    type="text"
                    id="relatedCourse"
                    value="Java Programming"
                    readonly
                    class="readonly-field"
                >

            </div>


            <!-- ORIGINAL MESSAGE -->

            <div class="field">

                <label for="message">
                    Message
                </label>

                <textarea
                    id="message"
                    readonly
                    class="readonly-field"
                >My payment for this course has failed. I tried several times but the transaction did not complete.</textarea>

            </div>

        </section>


        <!-- =====================================================
             STATUS PANEL
        ====================================================== -->

        <section class="status-panel">

            <h2 class="section-title">
                Request Status
            </h2>


            <label for="changeStatus">
                Change Status
            </label>


            <select
                id="changeStatus"
                name="changeStatus"
            >

                <option value="OPEN" selected>
                    Open
                </option>

                <option value="IN_PROGRESS">
                    In Progress
                </option>

                <option value="RESOLVED">
                    Resolved
                </option>

                <option value="CLOSED">
                    Closed
                </option>

            </select>


            <button
                type="button"
                class="save-button"
            >
                Save Status
            </button>


            <!-- Admin can respond outside OCMS -->
            <a
                class="email-button"
                href="mailto:user@example.com"
            >
                Email User
            </a>

        </section>

    </div>

</div>


</body>
</html>