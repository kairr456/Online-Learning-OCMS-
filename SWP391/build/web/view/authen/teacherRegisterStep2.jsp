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
                    max="60"
                    required
                >

                <small class="field-hint">Từ 0 đến 60 năm.</small>

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
                 SUBMIT & BACK BUTTONS
            ================================================== -->

            <div style="display: flex; gap: 12px; align-items: center; width: 100%; margin-top: 16px;">

                <a
                    href="${pageContext.request.contextPath}/register?backToStep1=true"
                    style="display: inline-flex; align-items: center; justify-content: center; padding: 12px 18px; border: 1px solid #d0d5dd; border-radius: 8px; background-color: #ffffff; color: #344054; font-size: 0.95rem; font-weight: 600; text-decoration: none; transition: all 0.2s ease; white-space: nowrap;"
                    onmouseover="this.style.backgroundColor='#f9fafb'; this.style.borderColor='#98a2b3';"
                    onmouseout="this.style.backgroundColor='#ffffff'; this.style.borderColor='#d0d5dd';"
                >
                    &larr; Quay lại Bước 1
                </a>

                <button
                    type="submit"
                    class="login-submit register-submit"
                    style="flex: 1; margin-top: 0;"
                >

                    <span>
                        Gửi duyệt tài khoản
                    </span>

                    <span class="login-submit__arrow">
                        &rarr;
                    </span>

                </button>

            </div>

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
    const MAX_CV_SIZE = 5 * 1024 * 1024; // 5MB

    function setupCharLimitFeedback(inputElem, maxLen, fieldName) {
        if (!inputElem || inputElem.dataset.charLimitBound) return;
        inputElem.dataset.charLimitBound = "true";
        inputElem.setAttribute('maxlength', maxLen);

        let fieldContainer = inputElem.closest('.register-field');
        if (!fieldContainer) fieldContainer = inputElem.parentElement;

        let counterElem = fieldContainer.querySelector('.char-limit-feedback');
        if (!counterElem) {
            counterElem = document.createElement('div');
            counterElem.className = 'char-limit-feedback';
            counterElem.style.cssText = 'display:flex; justify-content:space-between; align-items:center; font-size:0.78rem; margin-top:4px; font-family:sans-serif; width:100%; box-sizing:border-box;';
            fieldContainer.appendChild(counterElem);
        }

        function updateFeedback() {
            const currentLen = inputElem.value ? inputElem.value.length : 0;
            if (currentLen >= maxLen) {
                counterElem.innerHTML = '<span style="color:#ff6b6b; font-weight:bold;">&#9888; Đã đạt giới hạn tối đa ' + maxLen + ' ký tự cho ' + fieldName + '!</span><span style="background-color:#dc3545; color:#fff; border-radius:4px; padding:1px 6px; font-size:0.75rem; font-weight:bold;">' + currentLen + '/' + maxLen + '</span>';
            } else {
                const isNear = currentLen >= (maxLen * 0.85);
                const badgeStyle = isNear ? 'background-color:#ffc107; color:#000; font-weight:bold;' : 'background-color:rgba(255,255,255,0.1); color:#ced4da; border:1px solid rgba(255,255,255,0.2);';
                counterElem.innerHTML = '<span style="color:#ced4da;">' + fieldName + ' (tối đa ' + maxLen + ' ký tự)</span><span style="border-radius:4px; padding:1px 6px; font-size:0.75rem; ' + badgeStyle + '">' + currentLen + '/' + maxLen + '</span>';
            }
        }

        inputElem.addEventListener('input', updateFeedback);
        updateFeedback();
    }

    document.addEventListener('DOMContentLoaded', function() {
        setupCharLimitFeedback(document.getElementById('specialization'), 255, "Chuyên môn");
        setupCharLimitFeedback(document.getElementById('bio'), 2000, "Giới thiệu bản thân");
        setupCharLimitFeedback(document.getElementById('portfolioUrl'), 500, "Portfolio / Website");
    });

    const cvInput = document.getElementById('cvFile');
    const cvText = document.getElementById('cvFileText');

    let cvErrorElem = document.getElementById('cvFileError');
    if (!cvErrorElem && cvInput) {
        cvErrorElem = document.createElement('div');
        cvErrorElem.id = 'cvFileError';
        cvErrorElem.style.cssText = 'color:#ff6b6b; font-size:0.82rem; margin-top:6px; font-weight:600; display:none; word-break:break-word;';
        cvInput.closest('.register-field').appendChild(cvErrorElem);
    }

    if (cvInput) {
        cvInput.addEventListener('change', function() {
            cvErrorElem.style.display = 'none';

            if (this.files.length > 0) {
                const file = this.files[0];
                if (cvText) {
                    cvText.textContent = file.name;
                    cvText.title = file.name;
                }

                if (file.size > MAX_CV_SIZE) {
                    const fileSizeMB = (file.size / (1024 * 1024)).toFixed(2);
                    cvErrorElem.innerHTML = '&#9888; File CV quá lớn (' + fileSizeMB + 'MB). Dung lượng tối đa cho phép là 5MB!';
                    cvErrorElem.style.display = 'block';
                    this.value = ''; // Reset invalid file
                    if (cvText) {
                        cvText.textContent = 'Chọn file CV...';
                        cvText.removeAttribute('title');
                    }
                }
            } else {
                if (cvText) {
                    cvText.textContent = 'Chọn file CV...';
                    cvText.removeAttribute('title');
                }
            }
        });
    }

    document.getElementById('teacherProfileForm').addEventListener('submit', function(e) {
        const spec = document.getElementById('specialization').value.trim();
        if (spec.length < 5 || spec.length > 255) {
            e.preventDefault();
            alert('Chuyên môn phải từ 5 đến 255 ký tự.');
            document.getElementById('specialization').focus();
            return false;
        }

        const bio = document.getElementById('bio').value.trim();
        if (bio.length < 50 || bio.length > 2000) {
            e.preventDefault();
            alert('Giới thiệu bản thân phải từ 50 đến 2000 ký tự.');
            document.getElementById('bio').focus();
            return false;
        }

        const expVal = parseInt(document.getElementById('experienceYears').value.trim(), 10);
        if (isNaN(expVal) || expVal < 0 || expVal > 60) {
            e.preventDefault();
            alert('Số năm kinh nghiệm phải từ 0 đến 60 năm.');
            document.getElementById('experienceYears').focus();
            return false;
        }

        if (cvInput && cvInput.files.length > 0) {
            if (cvInput.files[0].size > MAX_CV_SIZE) {
                e.preventDefault();
                cvErrorElem.innerHTML = '&#9888; File CV quá lớn. Vui lòng chọn file dưới 5MB!';
                cvErrorElem.style.display = 'block';
                return false;
            }
        }
    });
</script>

</body>
</html>