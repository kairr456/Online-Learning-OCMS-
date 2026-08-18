<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Blog" %>
<%@ page import="com.entity.Account" %>
<%@ page import="com.DAO.BlogDAO" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%
    String ctx = request.getContextPath();
    Account currentUser = (Account) session.getAttribute("account");
    if (currentUser == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    // Nhận blog từ request (nếu đang ở chế độ Edit) hoặc từ draft (nếu Submit bị lỗi)
    Blog blog = (Blog) request.getAttribute("blog");
    Blog draft = (Blog) request.getAttribute("draft");
    String idParam = request.getParameter("id");

    if (blog == null && idParam != null && !idParam.trim().isEmpty()) {
        try {
            int blogId = Integer.parseInt(idParam.trim());
            BlogDAO bDAO = new BlogDAO();
            blog = bDAO.getBlogById(blogId);
        } catch (Exception ignored) {}
    }

    boolean isEdit = (blog != null && blog.getId() > 0);

    // Kiểm tra quyền sở hữu nếu là Edit
    if (isEdit && blog.getAuthor() != currentUser.getId() && currentUser.getRoleId() != 1) {
        response.sendRedirect(ctx + "/my-blogs?error=unauthorized");
        return;
    }

    // Giá trị các trường trong Form
    int blogId = isEdit ? blog.getId() : 0;
    String formTitle = "";
    String formThumbnail = "";
    String formBriefInfo = "";
    String formContent = "";
    int formCategoryId = 0;
    String formStatus = "Active";

    if (draft != null) {
        formTitle = draft.getTitle() != null ? draft.getTitle() : "";
        formThumbnail = draft.getThumbnail() != null ? draft.getThumbnail() : "";
        formBriefInfo = draft.getBriefInfo() != null ? draft.getBriefInfo() : "";
        formContent = draft.getContent() != null ? draft.getContent() : "";
        formCategoryId = draft.getCategoryId();
        formStatus = draft.getStatus() != null ? draft.getStatus() : "Active";
    } else if (isEdit) {
        formTitle = blog.getTitle() != null ? blog.getTitle() : "";
        formThumbnail = blog.getThumbnail() != null ? blog.getThumbnail() : "";
        formBriefInfo = blog.getBriefInfo() != null ? blog.getBriefInfo() : "";
        formContent = blog.getContent() != null ? blog.getContent() : "";
        formCategoryId = blog.getCategoryId();
        formStatus = blog.getStatus() != null ? blog.getStatus() : "Active";
    }

    // Lấy danh mục blog
    Map<Integer, String> categories = (Map<Integer, String>) request.getAttribute("categories");
    if (categories == null) {
        BlogDAO bDAO = new BlogDAO();
        categories = bDAO.getBlogCategories();
    }

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Chỉnh Sửa Bài Viết" : "Tạo Bài Viết Mới" %> · OCMS</title>
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

    <!-- Header dùng chung (Rule 4) -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Hero Section (Dùng chung cho cả Create & Update) -->
    <section class="blogform-hero">
        <div class="blogform-hero__inner">
            <div class="blogform-breadcrumb">
                <a href="<%= ctx %>/"><i class="fa-solid fa-house"></i> Trang chủ</a>
                <span>/</span>
                <a href="<%= ctx %>/blogs">Blogs</a>
                <span>/</span>
                <a href="<%= ctx %>/my-blogs">Bài viết của tôi</a>
                <span>/</span>
                <span><%= isEdit ? "Chỉnh sửa bài viết" : "Viết bài mới" %></span>
            </div>
            <h1 class="blogform-hero__title">
                <% if (isEdit) { %>
                    <i class="fa-solid fa-pen-to-square"></i> Chỉnh Sửa Bài Viết
                <% } else { %>
                    <i class="fa-solid fa-pen-nib"></i> Tạo Bài Viết Mới
                <% } %>
            </h1>
            <p class="blogform-hero__desc">
                <%= isEdit ? "Cập nhật nội dung, hình ảnh hoặc trạng thái bài viết của bạn." : "Chia sẻ kiến thức, kinh nghiệm và tin tức hữu ích đến cộng đồng học viên OCMS." %>
            </p>
        </div>
    </section>

    <!-- Main Container -->
    <div class="blogform-container">
        <div class="blogform-card">
            
            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <!-- Form xử lý chung (Action thay đổi linh hoạt theo chế độ Create / Edit) -->
            <form action="<%= isEdit ? (ctx + "/blogs-edit") : (ctx + "/blogs-new") %>" method="post">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= blogId %>">
                <% } %>

                <!-- Tiêu đề bài viết -->
                <div class="form-group">
                    <label for="title">Tiêu đề bài viết <span class="required">*</span></label>
                    <input type="text" id="title" name="title" class="form-control" 
                           placeholder="Nhập tiêu đề bài viết (ví dụ: Lộ trình học Java từ con số 0)..." 
                           value="<%= formTitle.replace("\"", "&quot;") %>" required>
                </div>

                <!-- Danh mục & Trạng thái -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="categoryId">Danh mục bài viết</label>
                        <select id="categoryId" name="categoryId" class="form-select">
                            <option value="">-- Chọn danh mục --</option>
                            <% if (categories != null) { 
                                for (Map.Entry<Integer, String> entry : categories.entrySet()) { 
                                    boolean selected = (formCategoryId == entry.getKey());
                            %>
                                <option value="<%= entry.getKey() %>" <%= selected ? "selected" : "" %>><%= entry.getValue() %></option>
                            <%  } 
                               } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="status">Trạng thái xuất bản</label>
                        <select id="status" name="status" class="form-select">
                            <option value="Active" <%= "Active".equalsIgnoreCase(formStatus) ? "selected" : "" %>>Active (Công khai)</option>
                            <option value="Inactive" <%= "Inactive".equalsIgnoreCase(formStatus) ? "selected" : "" %>>Inactive (Bản nháp / Ẩn)</option>
                        </select>
                    </div>
                </div>

                <!-- Link ảnh Thumbnail -->
                <div class="form-group">
                    <label for="thumbnail">Đường dẫn ảnh Thumbnail (URL)</label>
                    <input type="text" id="thumbnail" name="thumbnail" class="form-control" 
                           placeholder="https://example.com/images/blog-thumb.jpg" 
                           value="<%= formThumbnail.replace("\"", "&quot;") %>"
                           oninput="previewThumbnail(this.value)">
                    <div class="form-hint">Nhập liên kết hình ảnh minh họa cho bài viết.</div>
                    
                    <div class="thumb-preview-wrap" id="previewWrap">
                        <span class="placeholder-text" id="previewPlaceholder"><i class="fa-regular fa-image"></i> Xem trước hình ảnh Thumbnail</span>
                        <img id="previewImg" src="" alt="Thumbnail preview" onerror="handlePreviewError()">
                    </div>
                </div>

                <!-- Tóm tắt ngắn -->
                <div class="form-group">
                    <label for="briefInfo">Mô tả tóm tắt (Brief Info) <span class="required">*</span></label>
                    <textarea id="briefInfo" name="briefInfo" class="form-control" rows="3" 
                              placeholder="Tóm tắt ngắn gọn nội dung bài viết trong 2 - 3 câu..." required><%= formBriefInfo %></textarea>
                </div>

                <!-- Nội dung chi tiết -->
                <div class="form-group">
                    <label for="content">Nội dung chi tiết (Content) <span class="required">*</span></label>
                    <textarea id="content" name="content" class="form-control" rows="12" 
                              placeholder="Nhập toàn bộ nội dung bài viết tại đây..." required><%= formContent %></textarea>
                </div>

                <!-- Nút Submit / Cancel -->
                <div class="form-actions">
                    <a href="<%= ctx %>/my-blogs" class="btn-cancel">Hủy bỏ</a>
                    <button type="submit" class="btn-submit" id="btnSubmitForm">
                        <% if (isEdit) { %>
                            <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                        <% } else { %>
                            <i class="fa-solid fa-plus"></i> Tạo bài viết mới
                        <% } %>
                    </button>
                </div>
            </form>

        </div>
    </div>

    <!-- Footer dùng chung (Rule 4) -->
    <jsp:include page="/view/common/footer.jsp" />

    <script>
        function previewThumbnail(url) {
            var wrap = document.getElementById('previewWrap');
            var img = document.getElementById('previewImg');
            var placeholder = document.getElementById('previewPlaceholder');

            if (url && url.trim().length > 5) {
                img.src = url.trim();
                img.style.display = 'block';
                placeholder.style.display = 'none';
            } else {
                img.src = '';
                img.style.display = 'none';
                placeholder.style.display = 'flex';
            }
        }

        function handlePreviewError() {
            var img = document.getElementById('previewImg');
            var placeholder = document.getElementById('previewPlaceholder');
            img.style.display = 'none';
            placeholder.style.display = 'flex';
            placeholder.innerHTML = '<i class="fa-solid fa-triangle-exclamation blog-form-error-icon"></i> Không thể tải hình ảnh từ đường dẫn này';
        }

        document.addEventListener('DOMContentLoaded', function() {
            var thumbInput = document.getElementById('thumbnail');
            if (thumbInput && thumbInput.value) {
                previewThumbnail(thumbInput.value);
            }
        });
    </script>
</body>
</html>
