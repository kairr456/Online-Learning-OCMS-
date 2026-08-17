<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Blog" %>
<%@ page import="com.entity.Account" %>
<%@ page import="com.DAO.DBContext" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%
    String ctx = request.getContextPath();
    Account currentUser = (Account) session.getAttribute("account");

    // Lấy danh mục từ request attribute hoặc query trực tiếp từ database nếu truy cập thẳng vào JSP
    Map<Integer, String> categories = (Map<Integer, String>) request.getAttribute("categories");
    if (categories == null) {
        categories = new LinkedHashMap<>();
        DBContext db = new DBContext();
        try {
            if (db.getConnection() != null) {
                PreparedStatement ps = db.getConnection().prepareStatement("SELECT id, name FROM blog_category ORDER BY id ASC");
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    categories.put(rs.getInt("id"), rs.getString("name"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.closeResources();
        }
    }

    Blog draft = (Blog) request.getAttribute("draft");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Viết Bài Mới · OCMS</title>
    <!-- FontAwesome & Base CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">

    <style>
        :root {
            --primary-navy: #0F1E33;
            --secondary-navy: #16273F;
            --accent-amber: #D8A24A;
            --accent-amber-hover: #b9812e;
            --surface-bg: #F6F7FA;
            --card-bg: #FFFFFF;
            --text-dark: #0F1E33;
            --text-muted: #5B6B82;
            --border-color: #E3E7EE;
            --radius-md: 12px;
            --radius-lg: 16px;
            --shadow-subtle: 0 4px 20px rgba(15, 30, 51, 0.05);
            --shadow-hover: 0 12px 30px rgba(15, 30, 51, 0.12);
        }

        body {
            background-color: var(--surface-bg) !important;
            color: var(--text-dark) !important;
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            color-scheme: light !important;
        }

        /* Hero Header */
        .newblog-hero {
            background: linear-gradient(135deg, var(--primary-navy) 0%, var(--secondary-navy) 100%);
            color: #ffffff;
            padding: 40px 20px;
            text-align: center;
        }
        .newblog-hero__inner {
            max-width: 800px;
            margin: 0 auto;
        }
        .newblog-hero__title {
            font-family: var(--font-display, 'Space Grotesk', sans-serif);
            font-size: 30px;
            font-weight: 700;
            margin: 0 0 8px;
            color: #ffffff !important;
        }
        .newblog-hero__desc {
            font-size: 15px;
            color: rgba(255, 255, 255, 0.8) !important;
            margin: 0;
        }

        /* Container */
        .newblog-container {
            max-width: 900px;
            margin: 36px auto 60px;
            padding: 0 20px;
        }

        /* Form Card */
        .newblog-card {
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            padding: 36px;
            box-shadow: var(--shadow-subtle);
        }

        .alert-danger {
            background: #FCEAEA;
            border: 1px solid #D64545;
            color: #D64545;
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-group {
            margin-bottom: 22px;
        }
        .form-group label {
            display: block;
            font-size: 14.5px;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 8px;
        }
        .form-group label .required {
            color: #D64545;
            margin-left: 2px;
        }
        .form-hint {
            font-size: 12.5px;
            color: var(--text-muted);
            margin-top: 5px;
        }

        .form-control,
        .form-select {
            width: 100%;
            padding: 12px 16px;
            border-radius: 8px;
            border: 1.5px solid var(--border-color);
            background: #ffffff !important;
            color: #0F1E33 !important;
            font-size: 14.5px;
            font-family: inherit;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            box-sizing: border-box;
            caret-color: #0F1E33 !important;
        }
        .form-control::placeholder {
            color: #8C99AC !important;
        }
        .form-control:focus,
        .form-select:focus {
            border-color: var(--accent-amber);
            box-shadow: 0 0 0 3px rgba(216, 162, 74, 0.15);
        }

        textarea.form-control {
            resize: vertical;
            min-height: 100px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        /* Image Preview Box */
        .thumb-preview-wrap {
            margin-top: 10px;
            width: 100%;
            height: 180px;
            border-radius: 8px;
            border: 1px dashed var(--border-color);
            background: var(--surface-bg);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }
        .thumb-preview-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: none;
        }
        .thumb-preview-wrap .placeholder-text {
            color: var(--text-muted);
            font-size: 13.5px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* Form Actions */
        .form-actions {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 14px;
            margin-top: 32px;
            padding-top: 24px;
            border-top: 1px solid var(--border-color);
        }

        .btn-cancel {
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 14.5px;
            font-weight: 600;
            color: var(--text-muted);
            background: var(--surface-bg);
            border: 1px solid var(--border-color);
            text-decoration: none;
            transition: all 0.2s;
            cursor: pointer;
        }
        .btn-cancel:hover {
            background: #e9ecef;
            color: var(--text-dark);
        }

        .btn-submit {
            padding: 12px 28px;
            border-radius: 8px;
            font-size: 14.5px;
            font-weight: 700;
            color: #ffffff;
            background: var(--primary-navy);
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
        }
        .btn-submit:hover {
            background: var(--accent-amber-hover);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(216, 162, 74, 0.3);
        }

        @media (max-width: 600px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            .newblog-card {
                padding: 22px;
            }
        }
    </style>
</head>
<body>

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Hero -->
    <section class="newblog-hero">
        <div class="newblog-hero__inner">
            <h1 class="newblog-hero__title"><i class="fa-solid fa-pen-nib me-2"></i> Tạo Bài Viết Mới</h1>
            <p class="newblog-hero__desc">Chia sẻ kiến thức, kinh nghiệm và tin tức hữu ích đến cộng đồng học viên OCMS.</p>
        </div>
    </section>

    <!-- Main Container -->
    <div class="newblog-container">
        <div class="newblog-card">
            
            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-danger">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <form action="<%= ctx %>/blogs-new" method="post">
                <!-- Tiêu đề bài viết -->
                <div class="form-group">
                    <label for="title">Tiêu đề bài viết <span class="required">*</span></label>
                    <input type="text" id="title" name="title" class="form-control" 
                           placeholder="Nhập tiêu đề bài viết (ví dụ: Lộ trình học Java từ con số 0)..." 
                           value="<%= draft != null && draft.getTitle() != null ? draft.getTitle() : "" %>" required>
                </div>

                <!-- Danh mục & Trạng thái -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="categoryId">Danh mục bài viết</label>
                        <select id="categoryId" name="categoryId" class="form-select">
                            <option value="">-- Chọn danh mục --</option>
                            <% if (categories != null) { 
                                for (Map.Entry<Integer, String> entry : categories.entrySet()) { 
                                    boolean selected = (draft != null && draft.getCategoryId() == entry.getKey());
                            %>
                                <option value="<%= entry.getKey() %>" <%= selected ? "selected" : "" %>><%= entry.getValue() %></option>
                            <%  } 
                               } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="status">Trạng thái xuất bản</label>
                        <select id="status" name="status" class="form-select">
                            <option value="Active" <%= draft == null || "Active".equals(draft.getStatus()) ? "selected" : "" %>>Active (Công khai ngay)</option>
                            <option value="Inactive" <%= draft != null && "Inactive".equals(draft.getStatus()) ? "selected" : "" %>>Inactive (Bản nháp / Ẩn)</option>
                        </select>
                    </div>
                </div>

                <!-- Link ảnh Thumbnail -->
                <div class="form-group">
                    <label for="thumbnail">Đường dẫn ảnh Thumbnail (URL)</label>
                    <input type="text" id="thumbnail" name="thumbnail" class="form-control" 
                           placeholder="https://example.com/images/blog-thumb.jpg hoặc /assets/img/blog1.jpg" 
                           value="<%= draft != null && draft.getThumbnail() != null ? draft.getThumbnail() : "" %>"
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
                              placeholder="Tóm tắt ngắn gọn nội dung bài viết trong 2 - 3 câu..." required><%= draft != null && draft.getBriefInfo() != null ? draft.getBriefInfo() : "" %></textarea>
                </div>

                <!-- Nội dung chi tiết -->
                <div class="form-group">
                    <label for="content">Nội dung chi tiết (Content) <span class="required">*</span></label>
                    <textarea id="content" name="content" class="form-control" rows="12" 
                              placeholder="Nhập toàn bộ nội dung bài viết tại đây..." required><%= draft != null && draft.getContent() != null ? draft.getContent() : "" %></textarea>
                </div>

                <!-- Nút Submit / Cancel / Draft notice -->
                <div class="form-actions" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:14px;">
                    <div style="display:flex; align-items:center; gap:8px;">
                        <button type="button" id="btnClearDraft" class="btn-cancel" onclick="clearDraftStorage()" style="display:none; color:#D64545; border-color:#f5c2c7; background:#fdf2f2;">
                            <i class="fa-solid fa-trash-can me-1"></i> Xóa bản nháp đã lưu
                        </button>
                        <span id="draftSavedStatus" style="font-size:13px; color:#2F9E64; display:none;">
                            <i class="fa-solid fa-cloud-arrow-up me-1"></i> Đã tự động lưu bản nháp
                        </span>
                    </div>
                    <div style="display:flex; align-items:center; gap:12px;">
                        <a href="<%= ctx %>/view/common/home/blogs.jsp" class="btn-cancel">Hủy bỏ</a>
                        <button type="submit" class="btn-submit" id="btnSubmitForm">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu bài viết
                        </button>
                    </div>
                </div>
            </form>

        </div>
    </div>

    <!-- Footer chung -->
    <jsp:include page="/view/common/footer.jsp" />

    <script>
        var STORAGE_KEY = 'ocms_blog_new_draft';

        function previewThumbnail(url) {
            var img = document.getElementById('previewImg');
            var placeholder = document.getElementById('previewPlaceholder');
            if (url && url.trim().length > 0) {
                img.src = url.trim();
                img.style.display = 'block';
                placeholder.style.display = 'none';
            } else {
                img.src = '';
                img.style.display = 'none';
                placeholder.style.display = 'flex';
                placeholder.innerHTML = '<i class="fa-regular fa-image"></i> Xem trước hình ảnh Thumbnail';
            }
        }

        function handlePreviewError() {
            var img = document.getElementById('previewImg');
            var placeholder = document.getElementById('previewPlaceholder');
            img.style.display = 'none';
            placeholder.style.display = 'flex';
            placeholder.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="color:#D64545;"></i> Không thể tải hình ảnh từ URL đã nhập';
        }

        // Tự động lưu nội dung vào localStorage
        function autoSaveDraft() {
            var draftData = {
                title: document.getElementById('title').value,
                categoryId: document.getElementById('categoryId').value,
                status: document.getElementById('status').value,
                thumbnail: document.getElementById('thumbnail').value,
                briefInfo: document.getElementById('briefInfo').value,
                content: document.getElementById('content').value,
                savedAt: new Date().toLocaleTimeString()
            };

            // Chỉ lưu khi có ít nhất 1 trường có dữ liệu
            var hasData = draftData.title.trim() || draftData.briefInfo.trim() || draftData.content.trim() || draftData.thumbnail.trim();
            if (hasData) {
                localStorage.setItem(STORAGE_KEY, JSON.stringify(draftData));
                var statusEl = document.getElementById('draftSavedStatus');
                var btnClear = document.getElementById('btnClearDraft');
                if (statusEl) {
                    statusEl.style.display = 'inline-block';
                    statusEl.innerHTML = '<i class="fa-solid fa-check me-1"></i> Đã lưu nháp lúc ' + draftData.savedAt;
                }
                if (btnClear) btnClear.style.display = 'inline-block';
            }
        }

        // Khôi phục bản nháp từ localStorage khi vào lại trang
        function restoreDraft() {
            var isServerError = <%= (error != null && !error.isEmpty()) ? "true" : "false" %>;
            // Nếu server đã có draft (do vừa submit lỗi), ưu tiên dữ liệu từ server
            if (isServerError) return;

            var raw = localStorage.getItem(STORAGE_KEY);
            if (!raw) return;

            try {
                var draftData = JSON.parse(raw);
                if (draftData) {
                    if (draftData.title && !document.getElementById('title').value) {
                        document.getElementById('title').value = draftData.title;
                    }
                    if (draftData.categoryId && !document.getElementById('categoryId').value) {
                        document.getElementById('categoryId').value = draftData.categoryId;
                    }
                    if (draftData.status) {
                        document.getElementById('status').value = draftData.status;
                    }
                    if (draftData.thumbnail && !document.getElementById('thumbnail').value) {
                        document.getElementById('thumbnail').value = draftData.thumbnail;
                        previewThumbnail(draftData.thumbnail);
                    }
                    if (draftData.briefInfo && !document.getElementById('briefInfo').value) {
                        document.getElementById('briefInfo').value = draftData.briefInfo;
                    }
                    if (draftData.content && !document.getElementById('content').value) {
                        document.getElementById('content').value = draftData.content;
                    }

                    var statusEl = document.getElementById('draftSavedStatus');
                    var btnClear = document.getElementById('btnClearDraft');
                    if (statusEl && draftData.savedAt) {
                        statusEl.style.display = 'inline-block';
                        statusEl.innerHTML = '<i class="fa-solid fa-clock-rotate-left me-1"></i> Đã khôi phục bản nháp (' + draftData.savedAt + ')';
                    }
                    if (btnClear) btnClear.style.display = 'inline-block';
                }
            } catch (e) {
                console.error("Lỗi khi đọc draft từ localStorage", e);
            }
        }

        function clearDraftStorage() {
            if (confirm("Bạn có chắc chắn muốn xóa bản nháp đã lưu này không?")) {
                localStorage.removeItem(STORAGE_KEY);
                document.getElementById('title').value = '';
                document.getElementById('categoryId').value = '';
                document.getElementById('status').value = 'Active';
                document.getElementById('thumbnail').value = '';
                document.getElementById('briefInfo').value = '';
                document.getElementById('content').value = '';
                previewThumbnail('');
                var statusEl = document.getElementById('draftSavedStatus');
                var btnClear = document.getElementById('btnClearDraft');
                if (statusEl) statusEl.style.display = 'none';
                if (btnClear) btnClear.style.display = 'none';
            }
        }

        // Lắng nghe sự kiện gõ phím để tự động lưu nháp (auto-save debounce)
        var saveTimer = null;
        function onInputChange() {
            clearTimeout(saveTimer);
            saveTimer = setTimeout(autoSaveDraft, 500);
        }

        window.addEventListener('DOMContentLoaded', function() {
            restoreDraft();

            var inputs = ['title', 'categoryId', 'status', 'thumbnail', 'briefInfo', 'content'];
            inputs.forEach(function(id) {
                var el = document.getElementById(id);
                if (el) {
                    el.addEventListener('input', onInputChange);
                    el.addEventListener('change', onInputChange);
                }
            });

            var form = document.querySelector('form');
            if (form) {
                form.addEventListener('submit', function() {
                    // Xóa draft storage khi người dùng đã submit thành công
                    localStorage.removeItem(STORAGE_KEY);
                });
            }
        });
    </script>
</body>
</html>
