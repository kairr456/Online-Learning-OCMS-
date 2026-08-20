/**
 * OCMS - Public Blogs Listing JavaScript (blogs.js)
 * Quản lý tìm kiếm, phân trang, lọc danh mục và sắp xếp danh sách Blog công khai
 */

function submitSearch() {
    var searchInput = document.getElementById('searchInput');
    var val = searchInput ? searchInput.value.trim() : '';
    var formSearch = document.getElementById('formSearch');
    var formPage = document.getElementById('formPage');
    var filterForm = document.getElementById('blogFilterForm');

    if (formSearch) formSearch.value = val;
    if (formPage) formPage.value = 1;
    if (filterForm) filterForm.submit();
}

function filterCategory(catId) {
    var formCat = document.getElementById('formCategory');
    var formPage = document.getElementById('formPage');
    var filterForm = document.getElementById('blogFilterForm');

    if (formCat) formCat.value = catId > 0 ? catId : '';
    if (formPage) formPage.value = 1;
    if (filterForm) filterForm.submit();
}

function submitSort(sortVal) {
    var formSort = document.getElementById('formSort');
    var formPage = document.getElementById('formPage');
    var filterForm = document.getElementById('blogFilterForm');

    if (formSort) formSort.value = sortVal;
    if (formPage) formPage.value = 1;
    if (filterForm) filterForm.submit();
}

function goToPage(pageNum) {
    var formPage = document.getElementById('formPage');
    var filterForm = document.getElementById('blogFilterForm');

    if (formPage) formPage.value = pageNum;
    if (filterForm) filterForm.submit();
}

document.addEventListener('DOMContentLoaded', function () {
    // Xử lý fallback cho ảnh thumbnail bài viết nếu tải lỗi
    const thumbs = document.querySelectorAll('.blog-item__thumb-wrap img, .blog-recent-item__thumb img');
    thumbs.forEach(function (img) {
        img.addEventListener('error', function () {
            const parent = this.parentElement;
            if (parent) {
                parent.innerHTML = '<div class="blog-thumb-fallback"><i class="fa-regular fa-newspaper"></i></div>';
            }
        });
    });
});
