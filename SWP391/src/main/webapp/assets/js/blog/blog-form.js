/**
 * OCMS - Blog Form Builder JavaScript (blog-form.js)
 * Quản lý thêm/xóa dynamic section, preview ảnh và biên dịch HTML khi tạo/sửa Blog
 */

var sectionCounter = 0;

/**
 * 1. Thêm một khối nội dung bổ sung (Heading + Ảnh + Chú thích + Đoạn văn bản)
 */
function addBlogSection(headingVal, imgUrlVal, captionVal, textVal) {
    sectionCounter++;
    var currentId = sectionCounter;

    var heading = headingVal || '';
    var imgUrl = imgUrlVal || '';
    var caption = captionVal || '';
    var text = textVal || '';

    var container = document.getElementById('blogSectionsContainer');
    if (!container) return;

    var card = document.createElement('div');
    card.className = 'blog-section-card';
    card.id = 'blogSectionCard_' + currentId;

    var html = `
        <div class="blog-section-header">
            <span class="blog-section-title">
                <i class="fa-regular fa-clone"></i> Khối nội dung bổ sung
            </span>
            <button type="button" class="btn-remove-section" onclick="removeBlogSection(${currentId})">
                <i class="fa-regular fa-trash-can"></i> Xóa khối này
            </button>
        </div>

        <div class="form-group mb-3">
            <label class="form-label">Tiêu đề đoạn (Phụ đề mục này) <span class="required" style="color: #D64545;">*</span></label>
            <input type="text" class="form-control section-heading-input" 
                   placeholder="VD: 1. Giới thiệu tổng quan hoặc Những điều cần lưu ý..." 
                   value="${escapeHtmlAttr(heading)}">
        </div>

        <div class="form-group mb-3">
            <label class="form-label">Hình ảnh minh họa cho đoạn này</label>
            <input type="file" class="form-control section-file-input" 
                   id="sectionFileInput_${currentId}"
                   accept="image/png, image/jpeg, image/jpg, image/webp, image/gif"
                   onchange="previewSectionImageFile(${currentId}, this)">
            <input type="hidden" class="section-image-data" id="sectionImgData_${currentId}" value="${escapeHtmlAttr(imgUrl)}">
            <div class="form-hint">Chọn file hình ảnh từ thiết bị của bạn (hỗ trợ JPG, PNG, WebP, GIF - tối đa 10MB).</div>
            <div class="section-image-preview-wrap" id="sectionImgPreviewWrap_${currentId}" style="margin-top: 10px;">
                <img id="sectionImg_${currentId}" class="section-image-preview" src="${escapeHtmlAttr(imgUrl)}" alt="Xem trước hình ảnh" 
                     onerror="handleSectionImgError(${currentId})" style="${imgUrl ? 'display: block;' : 'display: none;'}">
                <div id="sectionPlaceholder_${currentId}" class="section-preview-placeholder" style="${imgUrl ? 'display: none;' : 'display: flex;'}">
                    <i class="fa-regular fa-image"></i> Xem trước hình ảnh của đoạn này
                </div>
            </div>
        </div>

        <div class="form-group mb-3">
            <label class="form-label">Chú thích hình ảnh (Tùy chọn)</label>
            <input type="text" class="form-control section-caption-input" 
                   placeholder="VD: Hình ảnh minh họa cấu trúc hệ thống hoặc sơ đồ luồng..." 
                   value="${escapeHtmlAttr(caption)}">
        </div>

        <div class="form-group mb-0">
            <label class="form-label">Đoạn văn bản chi tiết (Nội dung của mục này)</label>
            <textarea class="form-control section-text-input" rows="5" 
                      placeholder="Nhập nội dung văn bản chi tiết cho mục này...">${escapeHtmlText(text)}</textarea>
        </div>
    `;

    card.innerHTML = html;
    container.appendChild(card);
}

/**
 * Xóa một khối nội dung bổ sung
 */
function removeBlogSection(secId) {
    var card = document.getElementById('blogSectionCard_' + secId);
    if (card) {
        card.remove();
    }
}

/**
 * 2. Preview Ảnh Thumbnail chính khi chọn file từ máy tính
 */
function previewThumbnailFile(input) {
    var img = document.getElementById('thumbnailPreview');
    var placeholder = document.getElementById('previewPlaceholder');

    if (!img || !placeholder) return;

    if (input.files && input.files[0]) {
        var file = input.files[0];
        
        // Kiểm tra loại file ảnh
        if (!file.type.match('image.*')) {
            alert('Vui lòng chọn đúng định dạng file hình ảnh (JPG, PNG, GIF, WebP)!');
            input.value = '';
            return;
        }

        // Kiểm tra dung lượng (10MB)
        if (file.size > 10 * 1024 * 1024) {
            alert('Dung lượng hình ảnh quá lớn (> 10MB). Vui lòng chọn ảnh nhỏ hơn!');
            input.value = '';
            return;
        }

        var reader = new FileReader();
        reader.onload = function(e) {
            img.src = e.target.result;
            img.style.display = 'block';
            placeholder.style.display = 'none';
        };
        reader.readAsDataURL(file);
    } else {
        var existing = document.getElementById('existingThumbnail');
        if (existing && existing.value && existing.value.trim().length > 5) {
            img.src = existing.value.trim();
            img.style.display = 'block';
            placeholder.style.display = 'none';
        } else {
            img.src = '';
            img.style.display = 'none';
            placeholder.style.display = 'flex';
            placeholder.innerHTML = '<i class="fa-regular fa-image"></i> Xem trước hình ảnh Thumbnail';
        }
    }
}

function previewThumbnail(url) {
    var img = document.getElementById('thumbnailPreview');
    var placeholder = document.getElementById('previewPlaceholder');

    if (!img || !placeholder) return;

    if (url && url.trim().length > 5) {
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

function handleThumbError() {
    var img = document.getElementById('thumbnailPreview');
    var placeholder = document.getElementById('previewPlaceholder');
    if (img && placeholder) {
        img.style.display = 'none';
        placeholder.style.display = 'flex';
        placeholder.innerHTML = '<i class="fa-solid fa-triangle-exclamation blog-form-error-icon"></i> Không thể tải hình ảnh xem trước';
    }
}

/**
 * Preview Ảnh trong từng Section bổ sung khi chọn file từ máy tính
 */
function previewSectionImageFile(secId, input) {
    var img = document.getElementById('sectionImg_' + secId);
    var placeholder = document.getElementById('sectionPlaceholder_' + secId);
    var hiddenData = document.getElementById('sectionImgData_' + secId);

    if (!img || !placeholder) return;

    if (input.files && input.files[0]) {
        var file = input.files[0];

        // 1. Kiểm tra loại file ảnh
        if (!file.type || !file.type.match('image.*')) {
            alert('Vui lòng chọn đúng định dạng file hình ảnh (JPG, PNG, GIF, WebP)!');
            input.value = '';
            return;
        }

        // 2. Kiểm tra dung lượng (10MB)
        if (file.size > 10 * 1024 * 1024) {
            alert('Dung lượng hình ảnh quá lớn (> 10MB). Vui lòng chọn ảnh nhỏ hơn!');
            input.value = '';
            return;
        }

        var reader = new FileReader();
        reader.onload = function(e) {
            var dataUrl = e.target.result;
            img.src = dataUrl;
            img.style.display = 'block';
            placeholder.style.display = 'none';
            if (hiddenData) {
                hiddenData.value = dataUrl;
            }
        };
        reader.readAsDataURL(file);
    } else {
        if (hiddenData && hiddenData.value && hiddenData.value.trim().length > 5) {
            img.src = hiddenData.value.trim();
            img.style.display = 'block';
            placeholder.style.display = 'none';
        } else {
            img.src = '';
            img.style.display = 'none';
            placeholder.style.display = 'flex';
            placeholder.innerHTML = '<i class="fa-regular fa-image"></i> Xem trước hình ảnh của đoạn này';
            if (hiddenData) {
                hiddenData.value = '';
            }
        }
    }
}

function handleSectionImgError(secId) {
    var img = document.getElementById('sectionImg_' + secId);
    var placeholder = document.getElementById('sectionPlaceholder_' + secId);
    if (img && placeholder) {
        img.style.display = 'none';
        placeholder.style.display = 'flex';
        placeholder.innerHTML = '<i class="fa-solid fa-triangle-exclamation blog-form-error-icon"></i> Không thể tải hình ảnh xem trước';
    }
}

/**
 * Các hàm hỗ trợ escape HTML
 */
function escapeHtmlAttr(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

function escapeHtmlText(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

/**
 * 3. Hiển thị thông báo lỗi trực tiếp bên dưới khung điền (Field-level error)
 */
function clearAllFieldErrors() {
    var existingErrors = document.querySelectorAll('.field-error-feedback');
    for (var i = 0; i < existingErrors.length; i++) {
        existingErrors[i].remove();
    }
    var redInputs = document.querySelectorAll('.form-control, .form-select, .blog-section-card');
    for (var j = 0; j < redInputs.length; j++) {
        redInputs[j].style.borderColor = '';
        redInputs[j].classList.remove('has-error');
    }
}

function showFormValidationError(el, message) {
    clearAllFieldErrors();

    if (!el) return;

    // Tạo phần tử thông báo lỗi màu đỏ dưới khung điền
    var errorDiv = document.createElement('div');
    errorDiv.className = 'field-error-feedback';
    
    var icon = document.createElement('i');
    icon.className = 'fa-solid fa-circle-exclamation';
    errorDiv.appendChild(icon);

    var textSpan = document.createElement('span');
    textSpan.textContent = message;
    errorDiv.appendChild(textSpan);

    // Xác định vị trí chèn thông báo ngay dưới ô nhập liệu
    var isCard = el.classList && el.classList.contains('blog-section-card');
    if (isCard) {
        el.classList.add('has-error');
        el.style.borderColor = '#D64545';
        el.appendChild(errorDiv);
        var firstInput = el.querySelector('input, textarea');
        if (firstInput && typeof firstInput.focus === 'function') {
            firstInput.focus();
        }
    } else {
        el.style.borderColor = '#D64545';
        var parent = el.parentElement;
        if (parent && parent.classList.contains('input-with-icon')) {
            parent.parentElement.insertBefore(errorDiv, parent.nextSibling);
        } else if (parent) {
            parent.insertBefore(errorDiv, el.nextSibling);
        }
        if (typeof el.focus === 'function') {
            el.focus();
        }
    }

    // Cuộn màn hình tới ô bị lỗi
    el.scrollIntoView({ behavior: 'smooth', block: 'center' });

    // Tự động ẩn thông báo lỗi khi người dùng bắt đầu gõ hoặc thay đổi giá trị
    var onInputHandler = function () {
        el.style.borderColor = '';
        if (isCard) {
            el.classList.remove('has-error');
        }
        if (errorDiv && errorDiv.parentNode) {
            errorDiv.remove();
        }
        el.removeEventListener('input', onInputHandler);
        el.removeEventListener('change', onInputHandler);
    };
    el.addEventListener('input', onInputHandler);
    el.addEventListener('change', onInputHandler);
}

/**
 * Xử lý khi bấm nút Lưu bài viết (Draft) hoặc Gửi bài viết (Inactive / Active)
 */
function handleFormSubmit(e, statusVal) {
    var statusInput = document.getElementById('blogStatusInput');
    if (statusInput && statusVal) {
        statusInput.value = statusVal;
    }
    return compileAndValidateForm(e);
}

function compileAndValidateForm(e) {
    // 1. Kiểm tra Tiêu đề bài viết
    var titleEl = document.getElementById('title');
    var title = titleEl ? titleEl.value.trim() : '';
    if (!title) {
        if (e && typeof e.preventDefault === 'function') e.preventDefault();
        showFormValidationError(titleEl, 'Vui lòng nhập Tiêu đề bài viết (không được để trống hoặc chỉ chứa khoảng trắng)!');
        return false;
    }

    // 2. Kiểm tra Danh mục bài viết
    var categoryIdEl = document.getElementById('categoryId');
    var categoryId = categoryIdEl ? categoryIdEl.value.trim() : '';
    if (!categoryId || categoryId === '0') {
        if (e && typeof e.preventDefault === 'function') e.preventDefault();
        showFormValidationError(categoryIdEl, 'Vui lòng chọn Danh mục bài viết!');
        return false;
    }

    // 3. Kiểm tra Mô tả tóm tắt (Brief Info)
    var briefInfoEl = document.getElementById('briefInfo');
    var briefInfo = briefInfoEl ? briefInfoEl.value.trim() : '';
    if (!briefInfo) {
        if (e && typeof e.preventDefault === 'function') e.preventDefault();
        showFormValidationError(briefInfoEl, 'Vui lòng nhập Mô tả tóm tắt của bài viết (không được để trống hoặc chỉ chứa khoảng trắng)!');
        return false;
    }

    // 4. Kiểm tra Nội dung chi tiết (Content)
    var mainContentEl = document.getElementById('mainContent');
    var mainContent = mainContentEl ? mainContentEl.value.trim() : '';
    if (!mainContent) {
        if (e && typeof e.preventDefault === 'function') e.preventDefault();
        showFormValidationError(mainContentEl, 'Vui lòng nhập Nội dung chi tiết của bài viết (không được để trống hoặc chỉ chứa khoảng trắng)!');
        return false;
    }

    var compiledHtml = '';

    // 1. Thêm nội dung chính trước
    var mainParagraphs = mainContent.split('\n\n');
    for (var m = 0; m < mainParagraphs.length; m++) {
        var mClean = mainParagraphs[m].trim();
        if (mClean) {
            if (mClean.startsWith('<p>') || mClean.startsWith('<div>') || mClean.startsWith('<h')) {
                compiledHtml += mClean + '\n';
            } else {
                compiledHtml += '<p style="margin-bottom: 1.4em; line-height: 1.8;">' + mClean.replace(/\n/g, '<br>') + '</p>\n';
            }
        }
    }

    // 2. Kiểm tra và thêm các khối bổ sung (nếu người dùng đã bấm thêm khối)
    var cards = document.querySelectorAll('.blog-section-card');
    for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var headingInput = card.querySelector('.section-heading-input');
        var hiddenData = card.querySelector('.section-image-data');
        var fileInput = card.querySelector('.section-file-input');
        var captionInput = card.querySelector('.section-caption-input');
        var textInput = card.querySelector('.section-text-input');

        var heading = headingInput ? headingInput.value.trim() : '';
        var imgUrl = hiddenData ? hiddenData.value.trim() : '';
        var caption = captionInput ? captionInput.value.trim() : '';
        var text = textInput ? textInput.value.trim() : '';

        var sectionIndex = i + 1;

        // Tiêu đề đoạn bắt buộc phải có
        if (!heading) {
            if (e && typeof e.preventDefault === 'function') e.preventDefault();
            showFormValidationError(
                headingInput,
                'Vui lòng nhập Tiêu đề đoạn của khối nội dung bổ sung số ' + sectionIndex + ' (không được để trống hoặc chỉ chứa khoảng trắng)!'
            );
            return false;
        }

        // Cần có ít nhất hình ảnh hoặc đoạn văn bản chi tiết
        if (!imgUrl && !text) {
            if (e && typeof e.preventDefault === 'function') e.preventDefault();
            showFormValidationError(
                textInput || fileInput,
                'Khối nội dung bổ sung số ' + sectionIndex + ' cần có ít nhất "Hình ảnh" hoặc "Đoạn văn bản chi tiết" (không được để trống hoặc chỉ chứa khoảng trắng)!'
            );
            return false;
        }

        if (heading) {
            compiledHtml += '<h2 style="color: #0F1E33; font-size: 22px; font-weight: 700; margin-top: 32px; margin-bottom: 14px;">' + escapeHtmlText(heading) + '</h2>\n';
        }

        if (imgUrl) {
            compiledHtml += '<figure style="text-align: center; margin: 24px 0;">\n' +
                            '    <img src="' + escapeHtmlAttr(imgUrl) + '" alt="' + escapeHtmlAttr(caption || heading || 'Hình ảnh minh họa bài viết') + '" style="max-width: 100%; height: auto; border-radius: 10px; box-shadow: 0 4px 16px rgba(15, 30, 51, 0.08); display: block; margin: 0 auto;" />\n';
            if (caption) {
                compiledHtml += '    <figcaption style="font-size: 13.5px; color: #5B6B82; margin-top: 8px; font-style: italic;">' + escapeHtmlText(caption) + '</figcaption>\n';
            }
            compiledHtml += '</figure>\n';
        }

        if (text) {
            var paragraphs = text.split('\n\n');
            for (var p = 0; p < paragraphs.length; p++) {
                var pClean = paragraphs[p].trim();
                if (pClean) {
                    compiledHtml += '<p style="margin-bottom: 1.4em; line-height: 1.8;">' + pClean.replace(/\n/g, '<br>') + '</p>\n';
                }
            }
        }
    }

    var finalContentInput = document.getElementById('finalContentInput');
    if (finalContentInput) {
        finalContentInput.value = compiledHtml.trim();
    }
    return true;
}

function escapeHtmlAttr(str) {
    return (str || '').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
}

function escapeHtmlText(str) {
    return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/**
 * 4. Phân tích nội dung cũ (khi ở chế độ Edit bài viết)
 */
function parseExistingContent(rawHtml) {
    if (!rawHtml || !rawHtml.trim()) {
        return;
    }

    try {
        var parser = new DOMParser();
        var doc = parser.parseFromString(rawHtml, 'text/html');
        var nodes = Array.from(doc.body.children);

        if (nodes.length === 0) {
            var mainEl = document.getElementById('mainContent');
            if (mainEl) mainEl.value = rawHtml;
            return;
        }

        var hasExtra = false;
        for (var i = 0; i < nodes.length; i++) {
            var tag = nodes[i].tagName.toLowerCase();
            if (tag === 'figure' || tag === 'img' || tag === 'h2' || tag === 'h3') {
                hasExtra = true;
                break;
            }
        }

        if (!hasExtra) {
            var txt = rawHtml.replace(/<br\s*[\/]?>/gi, '\n').replace(/<\/?[^>]+(>|$)/g, "").trim();
            var mainEl = document.getElementById('mainContent');
            if (mainEl) mainEl.value = txt || rawHtml;
            return;
        }

        var currentHeading = '';
        var currentImg = '';
        var currentCaption = '';
        var currentTexts = [];
        var isFirst = true;

        nodes.forEach(function(node) {
            var tag = node.tagName.toLowerCase();
            if (tag === 'h2' || tag === 'h3' || tag === 'h1') {
                if (!isFirst && (currentHeading || currentImg || currentTexts.length > 0)) {
                    addBlogSection(currentHeading, currentImg, currentCaption, currentTexts.join('\n\n'));
                    currentHeading = '';
                    currentImg = '';
                    currentCaption = '';
                    currentTexts = [];
                } else if (isFirst && currentTexts.length > 0) {
                    var mainEl = document.getElementById('mainContent');
                    if (mainEl) mainEl.value = currentTexts.join('\n\n');
                    currentTexts = [];
                    isFirst = false;
                }
                currentHeading = node.innerText.trim();
            } else if (tag === 'figure') {
                var img = node.querySelector('img');
                var cap = node.querySelector('figcaption');
                if (img) currentImg = img.getAttribute('src') || '';
                if (cap) currentCaption = cap.innerText.trim();
                isFirst = false;
            } else if (tag === 'img') {
                currentImg = node.getAttribute('src') || '';
                isFirst = false;
            } else if (tag === 'p' || tag === 'blockquote' || tag === 'div') {
                var txt = node.innerHTML.replace(/<br\s*[\/]?>/gi, '\n').replace(/<\/?[^>]+(>|$)/g, "").trim();
                if (txt) currentTexts.push(txt);
            }
        });

        if (isFirst) {
            var mainEl = document.getElementById('mainContent');
            if (mainEl) mainEl.value = currentTexts.join('\n\n');
        } else if (currentHeading || currentImg || currentTexts.length > 0) {
            addBlogSection(currentHeading, currentImg, currentCaption, currentTexts.join('\n\n'));
        }
    } catch (e) {
        console.error("Lỗi parse nội dung cũ:", e);
        var mainEl = document.getElementById('mainContent');
        if (mainEl) mainEl.value = rawHtml;
    }
}

document.addEventListener('DOMContentLoaded', function() {
    var existingInput = document.getElementById('existingThumbnail');
    var thumbInput = document.getElementById('thumbnail');
    var initThumb = (existingInput && existingInput.value) ? existingInput.value : (thumbInput ? thumbInput.value : '');
    if (initThumb && initThumb.trim().length > 5) {
        previewThumbnail(initThumb.trim());
    }

    var finalContentInput = document.getElementById('finalContentInput');
    if (finalContentInput) {
        var initialContent = finalContentInput.value;
        parseExistingContent(initialContent);
    }
});
