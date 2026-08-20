/**
 * OCMS - Blog Detail JavaScript (blog-detail.js)
 * Quản lý tương tác trên trang chi tiết bài viết Blog
 */

document.addEventListener('DOMContentLoaded', function () {
    // 1. Xử lý ảnh thumbnail bài viết chính nếu lỗi
    const mainThumb = document.querySelector('.article-thumbnail-wrap img');
    if (mainThumb) {
        mainThumb.addEventListener('error', function () {
            const parent = this.parentElement;
            if (parent) {
                parent.style.display = 'none';
            }
        });
    }

    // 2. Xử lý ảnh bài viết liên quan & bài viết mới nhất nếu lỗi
    const relatedImages = document.querySelectorAll('.related-card__thumb img, .detail-recent-item__thumb img');
    relatedImages.forEach(function (img) {
        img.addEventListener('error', function () {
            const parent = this.parentElement;
            if (parent) {
                parent.innerHTML = '<div class="blog-thumb-fallback"><i class="fa-regular fa-newspaper"></i></div>';
            }
        });
    });
});
