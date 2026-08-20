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
            <label class="form-label">Tiêu đề đoạn (Phụ đề mục này - Tùy chọn)</label>
            <input type="text" class="form-control section-heading-input" 
                   placeholder="VD: 1. Giới thiệu tổng quan hoặc Những điều cần lưu ý..." 
                   value="${escapeHtmlAttr(heading)}">
        </div>

        <div class="form-group mb-3">
            <label class="form-label">Đường dẫn hình ảnh minh họa (Image URL)</label>
            <div class="input-with-icon">
                <i class="fa-regular fa-image input-icon"></i>
                <input type="url" class="form-control section-image-input" 
                       id="sectionImgInput_${currentId}"
                       placeholder="https://images.unsplash.com/photo-... hoặc liên kết ảnh" 
                       value="${escapeHtmlAttr(imgUrl)}"
                       oninput="previewSectionImage(${currentId}, this.value)">
            </div>
            <div class="section-image-preview-wrap" id="sectionImgPreviewWrap_${currentId}">
                <img id="sectionImg_${currentId}" class="section-image-preview" src="" alt="Xem trước hình ảnh" 
                     onerror="handleSectionImgError(${currentId})" style="display: none;">
                <div id="sectionPlaceholder_${currentId}" class="section-preview-placeholder">
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

    if (imgUrl) {
        previewSectionImage(currentId, imgUrl);
    }
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
 * 2. Preview Ảnh Thumbnail chính
 */
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
        placeholder.innerHTML = '<i class="fa-regular fa-image"></i> Xem trước ảnh đại diện bài viết';
    }
}

function handleThumbError() {
    var img = document.getElementById('thumbnailPreview');
    var placeholder = document.getElementById('previewPlaceholder');
    if (img && placeholder) {
        img.style.display = 'none';
        placeholder.style.display = 'flex';
        placeholder.innerHTML = '<i class="fa-solid fa-triangle-exclamation blog-form-error-icon"></i> Không thể tải hình ảnh từ URL này';
    }
}

/**
 * Preview Ảnh trong từng Section bổ sung
 */
function previewSectionImage(secId, url) {
    var img = document.getElementById('sectionImg_' + secId);
    var placeholder = document.getElementById('sectionPlaceholder_' + secId);

    if (!img || !placeholder) return;

    if (url && url.trim().length > 5) {
        img.src = url.trim();
        img.style.display = 'block';
        placeholder.style.display = 'none';
    } else {
        img.src = '';
        img.style.display = 'none';
        placeholder.style.display = 'flex';
        placeholder.innerHTML = '<i class="fa-regular fa-image"></i> Xem trước hình ảnh của đoạn này';
    }
}

function handleSectionImgError(secId) {
    var img = document.getElementById('sectionImg_' + secId);
    var placeholder = document.getElementById('sectionPlaceholder_' + secId);
    if (img && placeholder) {
        img.style.display = 'none';
        placeholder.style.display = 'flex';
        placeholder.innerHTML = '<i class="fa-solid fa-triangle-exclamation blog-form-error-icon"></i> Không thể tải hình ảnh từ đường dẫn này';
    }
}

/**
 * 3. Biên dịch toàn bộ nội dung khi Submit Form
 */
function compileAndValidateForm() {
    var mainContentEl = document.getElementById('mainContent');
    var mainContent = mainContentEl ? mainContentEl.value.trim() : '';
    if (!mainContent) {
        alert('Vui lòng nhập Nội dung chi tiết của bài viết!');
        if (mainContentEl) mainContentEl.focus();
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

    // 2. Thêm các khối bổ sung (nếu có)
    var cards = document.querySelectorAll('.blog-section-card');
    for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var heading = card.querySelector('.section-heading-input').value.trim();
        var imgUrl = card.querySelector('.section-image-input').value.trim();
        var caption = card.querySelector('.section-caption-input').value.trim();
        var text = card.querySelector('.section-text-input').value.trim();

        if (heading || imgUrl || text) {
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
    var thumbInput = document.getElementById('thumbnail');
    if (thumbInput && thumbInput.value) {
        previewThumbnail(thumbInput.value);
    }

    var finalContentInput = document.getElementById('finalContentInput');
    if (finalContentInput) {
        var initialContent = finalContentInput.value;
        parseExistingContent(initialContent);
    }
});
