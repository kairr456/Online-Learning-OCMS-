<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="isEdit" value="${not empty blog and blog.id > 0}" />
<c:set var="formTitle" value="${not empty draft ? draft.title : (not empty blog ? blog.title : '')}" />
<c:set var="formThumbnail" value="${not empty draft ? draft.thumbnail : (not empty blog ? blog.thumbnail : '')}" />
<c:set var="formBriefInfo" value="${not empty draft ? draft.briefInfo : (not empty blog ? blog.briefInfo : '')}" />
<c:set var="formContent" value="${not empty draft ? draft.content : (not empty blog ? blog.content : '')}" />
<c:set var="formCategoryId" value="${not empty draft ? draft.categoryId : (not empty blog ? blog.categoryId : 0)}" />
<c:set var="formStatus" value="${not empty draft ? draft.status : (not empty blog ? blog.status : (sessionScope.account.roleId == 1 ? 'Active' : 'Draft'))}" />

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

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/blog/blog-form.css?v=9">
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
            
            <c:if test="${isEdit and (blog.status == 'Rejected' or blog.status == 'Reject')}">
                <div class="alert-danger" style="background:#FEF2F2; border:1px solid #FECACA; color:#B91C1C; flex-direction:column; align-items:flex-start; gap:6px;">
                    <div style="display:flex; align-items:center; gap:8px; font-weight:700;">
                        <i class="fa-solid fa-triangle-exclamation" style="color:#DC2626;"></i>
                        <span>Bài viết này đã bị Admin từ chối phê duyệt</span>
                    </div>
                    <c:if test="${not empty blog.rejectReason}">
                        <div style="font-size:13.5px; color:#1E293B; margin-left:24px;">
                            <strong>Lý do từ chối:</strong> <c:out value="${blog.rejectReason}" />
                        </div>
                    </c:if>
                    <div style="font-size:12.5px; color:#7F1D1D; margin-left:24px;">
                        * Vui lòng chỉnh sửa nội dung bài viết trước khi gửi duyệt lại. Nếu không có thay đổi so với bản cũ, hệ thống sẽ tiếp tục giữ nguyên trạng thái <strong>Bị từ chối</strong>.
                    </div>
                </div>
            </c:if>

            <!-- Form xử lý chung -->
            <form id="blogForm" action="${pageContext.request.contextPath}${isEdit ? '/blogs-edit' : '/blogs-new'}" method="post" enctype="multipart/form-data" onsubmit="return compileAndValidateForm(event)" novalidate>
                <c:if test="${isEdit}">
                    <input type="hidden" name="id" value="${blog.id}">
                </c:if>

                <!-- Tiêu đề bài viết -->
                <div class="form-group">
                    <label for="title">Tiêu đề bài viết <span class="required">*</span></label>
                    <input type="text" id="title" name="title" class="form-control ${not empty errorTitle ? 'has-error' : ''}" 
                           placeholder="Nhập tiêu đề bài viết (ví dụ: Lộ trình học Java từ con số 0)..." 
<<<<<<< HEAD
                           value="<c:out value='${formTitle}' />" maxlength="255" required
=======
                           value="<c:out value='${formTitle}' />" required
>>>>>>> main
                           style="${not empty errorTitle ? 'border-color: #D64545;' : ''}">
                    <c:if test="${not empty errorTitle}">
                        <div class="field-error-feedback"><i class="fa-solid fa-circle-exclamation"></i> <span><c:out value="${errorTitle}" /></span></div>
                    </c:if>
                </div>

                <!-- Danh mục bài viết -->
                <div class="form-group">
                    <label for="categoryId">Danh mục bài viết <span class="required">*</span></label>
                    <select id="categoryId" name="categoryId" class="form-select ${not empty errorCategory ? 'has-error' : ''}"
                            style="${not empty errorCategory ? 'border-color: #D64545;' : ''}">
                        <option value="">-- Chọn danh mục --</option>
                        <c:if test="${not empty categories}">
                            <c:forEach var="entry" items="${categories}">
                                <option value="${entry.key}" ${formCategoryId == entry.key ? 'selected' : ''}><c:out value="${entry.value}" /></option>
                            </c:forEach>
                        </c:if>
                    </select>
                    <c:if test="${not empty errorCategory}">
                        <div class="field-error-feedback"><i class="fa-solid fa-circle-exclamation"></i> <span><c:out value="${errorCategory}" /></span></div>
                    </c:if>
                </div>

                <!-- Hidden Input lưu trạng thái bài viết (Draft hoặc Inactive/Active tùy theo nút bấm) -->
                <input type="hidden" name="status" id="blogStatusInput" value="<c:out value='${formStatus}' />">

                <!-- Chọn file ảnh Thumbnail -->
                <div class="form-group">
                    <label for="thumbnailFile">Ảnh Thumbnail bài viết</label>
                    <input type="file" id="thumbnailFile" name="thumbnailFile" class="form-control" 
                           accept="image/png, image/jpeg, image/jpg, image/webp, image/gif" 
                           onchange="previewThumbnailFile(this)">
                    <input type="hidden" id="existingThumbnail" name="existingThumbnail" value="<c:out value='${formThumbnail}' />">
                    <input type="hidden" id="thumbnail" name="thumbnail" value="<c:out value='${formThumbnail}' />">
                    <div class="form-hint">Chọn file hình ảnh từ thiết bị của bạn (hỗ trợ JPG, PNG, WebP, GIF - tối đa 10MB).</div>
                    
                    <div class="thumb-preview-wrap" id="previewWrap" style="margin-top: 12px;">
                        <span class="placeholder-text" id="previewPlaceholder"><i class="fa-regular fa-image"></i> Xem trước hình ảnh Thumbnail</span>
                        <img id="thumbnailPreview" src="<c:out value='${formThumbnail}' />" alt="Thumbnail preview" onerror="handleThumbError()">
                    </div>
                </div>

                <!-- Tóm tắt bài viết -->
                <div class="form-group">
                    <label for="briefInfo">Mô tả tóm tắt (Brief Info) <span class="required">*</span></label>
                    <textarea id="briefInfo" name="briefInfo" class="form-control ${not empty errorBrief ? 'has-error' : ''}" rows="3" 
<<<<<<< HEAD
                              placeholder="Tóm tắt ngắn gọn nội dung bài viết trong 2 - 3 câu (tối đa 500 ký tự)..." maxlength="500" required
=======
                              placeholder="Tóm tắt ngắn gọn nội dung bài viết trong 2 - 3 câu..." required
>>>>>>> main
                              style="${not empty errorBrief ? 'border-color: #D64545;' : ''}"><c:out value="${formBriefInfo}" /></textarea>
                    <c:if test="${not empty errorBrief}">
                        <div class="field-error-feedback"><i class="fa-solid fa-circle-exclamation"></i> <span><c:out value="${errorBrief}" /></span></div>
                    </c:if>
<<<<<<< HEAD
                    <div class="form-hint">Mô tả này sẽ xuất hiện trên thẻ bài viết ngoài trang danh sách (Tối đa 500 ký tự).</div>
=======
                    <div class="form-hint">Mô tả này sẽ xuất hiện trên thẻ bài viết ngoài trang danh sách.</div>
>>>>>>> main
                </div>

                <!-- Nội dung chi tiết chính của bài viết -->
                <div class="form-group">
                    <label for="mainContent">Nội dung chi tiết (Content) <span class="required">*</span></label>
                    <textarea id="mainContent" name="mainContent" class="form-control ${not empty errorContent ? 'has-error' : ''}" rows="8" 
                              placeholder="Nhập nội dung bài viết tại đây..." required
                              style="${not empty errorContent ? 'border-color: #D64545;' : ''}"><c:out value="${formContent}" /></textarea>
                    <c:if test="${not empty errorContent}">
                        <div class="field-error-feedback"><i class="fa-solid fa-circle-exclamation"></i> <span><c:out value="${errorContent}" /></span></div>
                    </c:if>
                </div>

                <!-- Vùng chứa các khối Ảnh & Nội dung bổ sung được thêm bằng dấu [+] -->
                <div id="blogSectionsContainer">
                    <!-- Được thêm động qua blog-form.js -->
                </div>

                <!-- Nút dấu [+] để viết thêm ảnh và nội dung mới -->
                <div style="margin: 20px 0 28px;">
                    <button type="button" class="btn-add-section-big" onclick="addBlogSection()">
                        <i class="fa-solid fa-plus"></i> Thêm ảnh &amp; đoạn nội dung (Add more image &amp; content)
                    </button>
                </div>

                <!-- Hidden Input lưu toàn bộ nội dung đã biên dịch để submit lên server -->
                <input type="hidden" name="content" id="finalContentInput" value="<c:out value='${formContent}' />">

                <!-- Nút Submit / Cancel -->
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/my-blogs" class="btn-cancel">Hủy bỏ</a>
                    
                    <button type="submit" name="status" value="Draft" class="btn-draft" onclick="return handleFormSubmit(event, 'Draft')">
                        <i class="fa-solid fa-floppy-disk"></i> Lưu bài viết
                    </button>

                    <button type="submit" name="status" value="${sessionScope.account.roleId == 1 ? 'Active' : 'Inactive'}" class="btn-submit" onclick="return handleFormSubmit(event, '${sessionScope.account.roleId == 1 ? 'Active' : 'Inactive'}')">
                        <i class="fa-solid fa-paper-plane"></i> Gửi bài viết
                    </button>
                </div>
            </form>

        </div>
    </div>

    <!-- Footer dùng chung -->
    <jsp:include page="/view/common/footer.jsp" />
    <!-- JS riêng biệt cho Blog Form -->
    <script src="${pageContext.request.contextPath}/assets/js/blog/blog-form.js?v=9"></script>
</body>
</html>
