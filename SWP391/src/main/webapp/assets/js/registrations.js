// OCMS — admin: trang Quản lý đăng ký khóa học (registrations.jsp)
// Xử lý lọc & phân trang của trang này.

// Đổi filter (search/status) → về trang 1 rồi submit form GET
function submitFilter() {
    document.getElementById('pageInput').value = 1;
    document.getElementById('filterForm').submit();
}

// Chuyển trang: set input hidden "page" rồi submit (giữ nguyên search/filter)
function goToPage(page) {
    document.getElementById('pageInput').value = page;
    document.getElementById('filterForm').submit();
}