<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>FAQ Management</title>
</head>

<body>

<h1>FAQ MANAGEMENT</h1>

<!-- =========================
     FILTER SECTION
========================= -->

<div>

    <label for="category">
        Category:
    </label>

    <select id="category" name="category">
        <option value="all">All</option>
        <option value="course">Course</option>
        <option value="payment">Payment</option>
        <option value="account">Account</option>
    </select>

</div>

<br>

<div>

    <label for="status">
        Status:
    </label>

    <select id="status" name="status">
        <option value="active">Active</option>
        <option value="inactive">Inactive</option>
    </select>

</div>

<br>

<div>

    <label for="search">
        Search:
    </label>

    <input
        type="text"
        id="search"
        name="search"
        placeholder="Search"
    >

</div>

<br>

<!-- =========================
     ADD FAQ BUTTON
========================= -->

<button type="button">
    Add FAQ
</button>

<br>
<br>


<!-- =========================
     FAQ LIST
========================= -->

<table border="1">

    <thead>

        <tr>

            <th>Order</th>

            <th>Question</th>

            <th>Category</th>

            <th>Status</th>

            <th>Action</th>

        </tr>

    </thead>


    <tbody>

        <!-- FAQ 1 -->

        <tr>

            <td>1</td>

            <td>
                How do I enroll?
            </td>

            <td>
                Course
            </td>

            <td>
                Active
            </td>

            <td>

                <a href="#">
                    Edit
                </a>

                |

                <a href="#">
                    Delete
                </a>

            </td>

        </tr>


        <!-- FAQ 2 -->

        <tr>

            <td>2</td>

            <td>
                How do I pay?
            </td>

            <td>
                Payment
            </td>

            <td>
                Active
            </td>

            <td>

                <a href="#">
                    Edit
                </a>

                |

                <a href="#">
                    Delete
                </a>

            </td>

        </tr>


        <!-- FAQ 3 -->

        <tr>

            <td>3</td>

            <td>
                How do I reset password?
            </td>

            <td>
                Account
            </td>

            <td>
                Active
            </td>

            <td>

                <a href="#">
                    Edit
                </a>

                |

                <a href="#">
                    Delete
                </a>

            </td>

        </tr>

    </tbody>

</table>


<br>
<hr>
<br>


<!-- =========================
     FAQ DETAIL FORM
========================= -->

<h2>FAQ Details</h2>

<form>

    <div>

        <label for="detailCategory">
            Category:
        </label>

        <select
            id="detailCategory"
            name="category"
        >

            <option value="payment">
                Payment
            </option>

            <option value="course">
                Course
            </option>

            <option value="account">
                Account
            </option>

        </select>

    </div>

    <br>


    <div>

        <label for="question">
            Question:
        </label>

        <input
            type="text"
            id="question"
            name="question"
            value="How do I pay for this course?"
        >

    </div>

    <br>


    <div>

        <label for="answer">
            Answer:
        </label>

        <br>

        <textarea
            id="answer"
            name="answer"
            rows="8"
            cols="50"
        ></textarea>

    </div>

    <br>


    <div>

        <label for="displayOrder">
            Display Order:
        </label>

        <input
            type="number"
            id="displayOrder"
            name="displayOrder"
            value="1"
            min="0"
        >

    </div>
    <br>
    <div>
        <label for="detailStatus">
            Status:
        </label>
        <select
            id="detailStatus"
            name="status"
        >

            <option value="ACTIVE">
                Active
            </option>

            <option value="INACTIVE">
                Inactive
            </option>

        </select>

    </div>

    <br>

    <button type="submit">
        Save
    </button>

    <button type="button">
        Cancel
    </button>

</form>

</body>

</html>