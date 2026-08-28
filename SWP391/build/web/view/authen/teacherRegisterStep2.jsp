<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>OCMS - Hoàn tất đăng ký Giảng viên</title>

    <!-- Global CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/styles.css">

    <!-- Auth CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/authen/login.css">

    <!-- Register CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/authen/register.css">

    <!-- Teacher Register Step 2 CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/authen/teacher-register.css">

</head>

<body>

<div class="login-screen register-screen">

    <!-- Background decorations -->
    <div class="login-decoration login-decoration--one"></div>
    <div class="login-decoration login-decoration--two"></div>


    <main class="login-card register-card">

        <!-- =====================================================
             BRAND
        ====================================================== -->

        <div class="login-brand">

            <div class="login-brand__icon">
                <span class="dot"></span>
            </div>

            <div>

                <span class="login-brand__name">
                    OCMS
                </span>

                <span class="login-brand__tagline">
                    Online Course Management System
                </span>

            </div>

        </div>


        <!-- =====================================================
             HEADING
        ====================================================== -->

        <div class="login-heading register-heading">

            <h1>
                Hoàn tất hồ sơ Giảng viên
            </h1>

            <p>
                Bước 2/2: Thêm thông tin chuyên môn để admin duyệt tài khoản
            </p>

        </div>


        <!-- =====================================================
             PROGRESS STEPS
        ====================================================== -->

        <div class="register-progress">
            <div class="register-progress__step register-progress__step--done">
                <span class="register-progress__num">1</span>
                <span class="register-progress__label">Thông tin cơ bản</span>
            </div>
            <div class="register-progress__line"></div>
            <div class="register-progress__step register-progress__step--active">
                <span class="register-progress__num">2</span>
                <span class="register-progress__label">Hồ sơ chuyên môn</span>
            </div>
        </div>


        <!-- =====================================================
             ERROR MESSAGE
        ====================================================== -->

        <%
            String errorMessage =
                    (String) request.getAttribute("errorMessage");

            if (errorMessage != null) {
        %>

        <div class="login-error" role="alert">

            <span class="login-error__icon">
                &#9888;
            </span>

            <span>
                <%= errorMessage %>
            </span>

        </div>

        <%
            }
        %>


        <!-- =====================================================
             SUCCESS MESSAGE
        ====================================================== -->

        <%
            String successMessage =
                    (String) request.getAttribute("successMessage");

            if (successMessage != null) {
        %>

        <div class="login-success" role="status">

            <span class="login-success__icon">
                &#10003;
            </span>

            <span>
                <%= successMessage %>
            </span>

        </div>

        <%
            }
        %>


        <!-- =====================================================
             TEACHER PROFILE FORM
        ====================================================== -->

        <form
            id="teacherProfileForm"
            method="post"
            action="${pageContext.request.contextPath}/teacher-register-step2"
            enctype="multipart/form-data"
        >

            <input type="hidden" name="accountId" value="<%= request.getAttribute("account") != null ? ((com.entity.Account)request.getAttribute("account")).getId() : request.getParameter("accountId") %>">

            <!-- =================================================
                 SPECIALIZATION (CHUYÊN MÔN)
            ================================================== -->

            <div class="register-field">

                <label for="specialization">
                    Chuyên môn / Tiêu đề <span class="required">*</span>
                </label>

                <input
                    type="text"
                    id="specialization"
                    name="specialization"
                    placeholder="Ví dụ: Senior Java Developer, Giảng viên ĐH..."
                    value="<%= request.getAttribute("specialization") != null ? request.getAttribute("specialization") : "" %>"
                    required
                >

                <small class="field-hint">5-255 ký tự. Hiển thị trên trang giảng viên.</small>

            </div>


            <!-- =================================================
                 BIO
            ================================================== -->

            <div class="register-field">

                <label for="bio">
                    Giới thiệu bản thân <span class="required">*</span>
                </label>

                <textarea
                    id="bio"
                    name="bio"
                    rows="5"
                    placeholder="Giới thiệu về kinh nghiệm, phương pháp giảng dạy, lĩnh vực chuyên môn..."
                    required
                ><%= request.getAttribute("bio") != null ? request.getAttribute("bio") : "" %></textarea>

                <small class="field-hint">50-2000 ký tự. Nội dung hiển thị công khai.</small>

            </div>


            <!-- =================================================
                 EXPERIENCE YEARS
            ================================================== -->

            <div class="register-field">

                <label for="experienceYears">
                    Số năm kinh nghiệm <span class="required">*</span>
                </label>

                <input
                    type="number"
                    id="experienceYears"
                    name="experienceYears"
                    placeholder="Ví dụ: 5"
                    value="<%= request.getAttribute("experienceYears") != null ? request.getAttribute("experienceYears") : "" %>"
                    min="0"
                    max="50"
                    required
                >

                <small class="field-hint">Từ 0 đến 50 năm.</small>

            </div>


            <!-- =================================================
                 PORTFOLIO URL
            ================================================== -->

            <div class="register-field">

                <label for="portfolioUrl">
                    Portfolio / Website cá nhân
                </label>

                <input
                    type="url"
                    id="portfolioUrl"
                    name="portfolioUrl"
                    placeholder="https://tenmien.com / https://github.com/ten-cua-ban"
                    value="<%= request.getAttribute("portfolioUrl") != null ? request.getAttribute("portfolioUrl") : "" %>"
                    maxlength="500"
                >

            </div>


            <!-- =================================================
                 CV FILE UPLOAD
            ================================================== -->

            <div class="register-field">

                <label for="cvFile">
                    File CV (PDF, DOC, DOCX)
                </label>

                <div class="file-upload-wrapper">
                    <input
                        type="file"
                        id="cvFile"
                        name="cvFile"
                        accept=".pdf,.doc,.docx"
                    >
                    <span class="file-upload-text" id="cvFileText">Chọn file CV...</span>
                </div>

                <small class="field-hint">Tối đa 5MB. Định dạng: PDF, DOC, DOCX. Dùng cho admin xem xét.</small>

            </div>


            <!-- =================================================
                 SUBMIT BUTTON
            ================================================== -->

            <button
                type="submit"
                class="login-submit register-submit"
            >

                <span>
                    Gửi duyệt tài khoản
                </span>

                <span class="login-submit__arrow">
                    &rarr;
                </span>

            </button>

        </form>


        <!-- =====================================================
             BACK TO LOGIN
        ====================================================== -->

        <div class="login-register">

            <span>
                Đã có tài khoản?
            </span>

            <a
                href="${pageContext.request.contextPath}/login"
            >
                Đăng nhập
            </a>

        </div>

    </main>

</div>


<!-- =========================================================
     FILE UPLOAD DISPLAY
========================================================== -->

<script>
    document.getElementById('cvFile').addEventListener('change', function() {
        const textEl = document.getElementById('cvFileText');
        if (this.files.length > 0) {
            textEl.textContent = this.files[0].name;
        } else {
            textEl.textContent = 'Chọn file CV...';
        }
    });

    document.getElementById('teacherProfileForm').addEventListener('submit', function(e) {
        const spec = document.getElementById('specialization').value.trim();
        if (spec.length > 255) {
            e.preventDefault();
            alert('Chuyên môn không được vượt quá 255 ký tự.');
            document.getElementById('specialization').focus();
            return false;
        }
    });
</script>

</body>
</html>