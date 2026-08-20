<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="isEdit" value="${not empty blog and blog.id > 0}" />
<c:set var="formTitle" value="${not empty draft ? draft.title : (not empty blog ? blog.title : '')}" />
<c:set var="formThumbnail" value="${not empty draft ? draft.thumbnail : (not empty blog ? blog.thumbnail : '')}" />
<c:set var="formBriefInfo" value="${not empty draft ? draft.briefInfo : (not empty blog ? blog.briefInfo : '')}" />
<c:set var="formContent" value="${not empty draft ? draft.content : (not empty blog ? blog.content : '')}" />
<c:set var="formCategoryId" value="${not empty draft ? draft.categoryId : (not empty blog ? blog.categoryId : 0)}" />
<c:set var="formStatus" value="${not empty draft ? draft.status : (not empty blog ? blog.status : 'Active')}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isEdit ? 'Chỉnh Sửa Bài Viết' : 'Tạo Bài Viết Mới'} · OCMS</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- FontAwesome & Base CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/blog/blog-form.css">
</head>
<body>

    <!-- Header dùng chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Hero Section -->
    <section class="blogform-hero">
        <div class="blogform-hero__inner">
            <div class="blogform-breadcrumb">
                <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/blogs">Blogs</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/my-blogs">Bài viết của tôi</a>
                <span>/</span>
                <span>${isEdit ? 'Chỉnh sửa bài viết' : 'Viết bài mới'}</span>
            </div>
            <h1 class="blogform-hero__title">
                <c:choose>
                    <c:when test="${isEdit}">
                        <i class="fa-solid fa-pen-to-square"></i> Chỉnh Sửa Bài Viết
                    </c:when>
                    <c:otherwise>
                        <i class="fa-solid fa-pen-nib"></i> Tạo Bài Viết Mới
                    </c:otherwise>
                </c:choose>
            </h1>
            <p class="blogform-hero__desc">
                ${isEdit ? 'Cập nhật nội dung, hình ảnh hoặc trạng thái bài viết của bạn.' : 'Chia sẻ kiến thức, kinh nghiệm và tin tức hữu ích đến cộng đồng học viên OCMS.'}
            </p>
        </div>
    </section>

    <!-- Main Container -->
    <div class="blogform-container">
        <div class="blogform-card">
            
            <c:if test="${not empty error}">
                <div class="alert-danger">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span><c:out value="${error}" /></span>
                </div>
            </c:if>

            <!-- Form xử lý chung -->
            <form action="${pageContext.request.contextPath}${isEdit ? '/blogs-edit' : '/blogs-new'}" method="post">
                <c:if test="${isEdit}">
                    <input type="hidden" name="id" value="${blog.id}">
                </c:if>

                <!-- Tiêu đề bài viết -->
                <div class="form-group">
                    <label for="title">Tiêu đề bài viết <span class="required">*</span></label>
                    <input type="text" id="title" name="title" class="form-control" 
                           placeholder="Nhập tiêu đề bài viết (ví dụ: Lộ trình học Java từ con số 0)..." 
                           value="<c:out value='${formTitle}' />" required>
                </div>

                <!-- Danh mục & Trạng thái -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="categoryId">Danh mục bài viết</label>
                        <select id="categoryId" name="categoryId" class="form-select">
                            <option value="">-- Chọn danh mục --</option>
                            <c:if test="${not empty categories}">
                                <c:forEach var="entry" items="${categories}">
                                    <option value="${entry.key}" ${formCategoryId == entry.key ? 'selected' : ''}><c:out value="${entry.value}" /></option>
                                </c:forEach>
                            </c:if>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="status">Trạng thái xuất bản</label>
                        <select id="status" name="status" class="form-select">
                            <option value="Active" ${formStatus == 'Active' ? 'selected' : ''}>Active (Công khai)</option>
                            <option value="Inactive" ${formStatus == 'Inactive' ? 'selected' : ''}>Inactive (Bản nháp / Ẩn)</option>
                        </select>
                    </div>
                </div>

                <!-- Link ảnh Thumbnail -->
                <div class="form-group">
                    <label for="thumbnail">Đường dẫn ảnh Thumbnail (URL)</label>
                    <input type="text" id="thumbnail" name="thumbnail" class="form-control" 
                           placeholder="https://example.com/images/blog-thumb.jpg" 
                           value="<c:out value='${formThumbnail}' />"
                           oninput="previewThumbnail(this.value)">
                    <div class="form-hint">Nhập liên kết hình ảnh minh họa cho bài viết.</div>
                    
                    <div class="thumb-preview-wrap" id="previewWrap">
                        <span class="placeholder-text" id="previewPlaceholder"><i class="fa-regular fa-image"></i> Xem trước hình ảnh Thumbnail</span>
                        <img id="thumbnailPreview" src="" alt="Thumbnail preview" onerror="handleThumbError()">
                    </div>
                </div>

                <!-- Tóm tắt ngắn -->
                <div class="form-group">
                    <label for="briefInfo">Mô tả tóm tắt (Brief Info) <span class="required">*</span></label>
                    <textarea id="briefInfo" name="briefInfo" class="form-control" rows="3" 
                              placeholder="Tóm tắt ngắn gọn nội dung bài viết trong 2 - 3 câu..." required><c:out value="${formBriefInfo}" /></textarea>
                </div>

                <!-- Nội dung chi tiết chính của bài viết -->
                <div class="form-group">
                    <label for="mainContent">Nội dung chi tiết (Content) <span class="required">*</span></label>
                    <textarea id="mainContent" class="form-control" rows="8" 
                              placeholder="Nhập nội dung bài viết tại đây..." required><c:out value="${formContent}" /></textarea>
                </div>

                <!-- Vùng chứa các khối Ảnh & Nội dung bổ sung được thêm bằng dấu [+] -->
                <div id="blogSectionsContainer">
                    <!-- Được thêm động qua blog-form.js -->
                </div>

                <!-- Nút dấu [+] để viết thêm ảnh và nội dung mới -->
                <div style="margin: 20px 0 28px;">
                    <button type="button" class="btn-add-section-big" onclick="addBlogSection()">
                        <i class="fa-solid fa-plus"></i> Thêm ảnh & đoạn nội dung (Add more image & content)
                    </button>
                </div>

                <!-- Hidden Input lưu toàn bộ nội dung đã biên dịch để submit lên server -->
                <input type="hidden" name="content" id="finalContentInput" value="<c:out value='${formContent}' />">

                <!-- Nút Submit / Cancel -->
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/my-blogs" class="btn-cancel">Hủy bỏ</a>
                    <button type="submit" class="btn-submit" id="btnSubmitForm" onclick="return compileAndValidateForm()">
                        <c:choose>
                            <c:when test="${isEdit}">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-plus"></i> Tạo bài viết mới
                            </c:otherwise>
                        </c:choose>
                    </button>
                </div>
            </form>

        </div>
    </div>

    <!-- Footer dùng chung -->
    <jsp:include page="/view/common/footer.jsp" />
    <!-- JS riêng biệt cho Blog Form -->
    <script src="${pageContext.request.contextPath}/assets/js/blog/blog-form.js"></script>
</body>
</html>
