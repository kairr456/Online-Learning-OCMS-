<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blogs & Tin Tức · OCMS</title>
    <!-- Fonts & Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/blog/blogs.css">
</head>
<body>

    <!-- Header dùng chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Hero Banner -->
    <section class="blog-hero">
        <div class="blog-hero__inner">
            <span class="blog-hero__badge"><i class="fa-solid fa-bolt me-1"></i> Kiến thức & Chia sẻ</span>
            <h1 class="blog-hero__title">Bài Viết & Tin Tức Mới Nhất</h1>
            <p class="blog-hero__desc">Khám phá các bài viết hữu ích, hướng dẫn chuyên sâu và xu hướng công nghệ mới từ các chuyên gia.</p>
        </div>
    </section>

    <!-- Main Container -->
    <div class="blog-container">

        <!-- Hidden form phục vụ tìm kiếm, lọc danh mục, sắp xếp và phân trang -->
        <form id="blogFilterForm" action="${pageContext.request.contextPath}/blogs" method="get" style="display: none;">
            <input type="hidden" name="search" id="formSearch" value="<c:out value='${searchKeyword}' />">
            <input type="hidden" name="category" id="formCategory" value="${categoryFilter > 0 ? categoryFilter : ''}">
            <input type="hidden" name="sort" id="formSort" value="${sortParam}">
            <input type="hidden" name="page" id="formPage" value="${currentPage}">
        </form>

        <!-- Main Blog List -->
        <main class="blog-main">
            <!-- Toolbar -->
            <div class="blog-toolbar">
                <div class="blog-toolbar__count">
                    Hiển thị <strong>${totalBlogs}</strong> bài viết <c:if test="${categoryFilter > 0}">trong danh mục này</c:if>
                </div>
                <div class="blog-toolbar-row">
                    <a href="${pageContext.request.contextPath}/my-blogs" class="btn-create-blog btn-create-blog--link">
                        <i class="fa-solid fa-feather-pointed"></i> Bài viết của tôi
                    </a>
                    <div class="blog-toolbar__sort">
                        <label for="sortSelect"><i class="fa-solid fa-arrow-down-short-wide"></i> Sắp xếp:</label>
                        <select id="sortSelect" class="blog-toolbar__select" onchange="submitSort(this.value);">
                            <option value="newest" ${sortParam == 'newest' ? 'selected' : ''}>Mới nhất</option>
                            <option value="oldest" ${sortParam == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                            <option value="title_asc" ${sortParam == 'title_asc' ? 'selected' : ''}>Tiêu đề (A - Z)</option>
                            <option value="title_desc" ${sortParam == 'title_desc' ? 'selected' : ''}>Tiêu đề (Z - A)</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Blog Grid -->
            <c:choose>
                <c:when test="${empty pagedBlogs}">
                    <div class="blog-empty">
                        <i class="fa-regular fa-folder-open"></i>
                        <h4>Không tìm thấy bài viết nào</h4>
                        <p>Hãy thử tìm kiếm với từ khóa khác hoặc xóa bộ lọc để xem toàn bộ bài viết.</p>
                        <a href="${pageContext.request.contextPath}/blogs" class="blog-empty__btn">
                            <i class="fa-solid fa-rotate-left me-1"></i> Xem tất cả bài viết
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="blog-grid">
                        <c:forEach var="blog" items="${pagedBlogs}">
                            <c:set var="catName" value="${not empty blogCategories[blog.categoryId] ? blogCategories[blog.categoryId] : 'Chung'}" />
                            <c:set var="authorName" value="${not empty authorNames[blog.author] ? authorNames[blog.author] : 'Tác giả OCMS'}" />
                            <fmt:formatDate value="${blog.createdDate}" pattern="dd/MM/yyyy" var="formattedDate" />

                            <article class="blog-item">
                                <div class="blog-item__thumb-wrap">
                                    <c:choose>
                                        <c:when test="${not empty blog.thumbnail}">
                                            <img src="${blog.thumbnail}" alt="${blog.title}">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="blog-item__fallback-thumb">
                                                <i class="fa-regular fa-newspaper"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="blog-item__cat-badge"><c:out value="${catName}" /></span>
                                </div>

                                <div class="blog-item__body">
                                    <div class="blog-item__meta">
                                        <span><i class="fa-regular fa-user"></i> <c:out value="${authorName}" /></span>
                                        <span><i class="fa-regular fa-calendar"></i> <c:out value="${not empty formattedDate ? formattedDate : 'Gần đây'}" /></span>
                                    </div>

                                    <h3 class="blog-item__title">
                                        <a href="${pageContext.request.contextPath}/blog-detail?id=${blog.id}">
                                            <c:out value="${blog.title}" />
                                        </a>
                                    </h3>

                                    <p class="blog-item__brief">
                                        <c:out value="${blog.briefInfo}" />
                                    </p>

                                    <div class="blog-item__footer">
                                        <a href="${pageContext.request.contextPath}/blog-detail?id=${blog.id}" class="blog-item__link">
                                            Đọc tiếp <i class="fa-solid fa-arrow-right"></i>
                                        </a>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <div class="blog-pagination">
                            <c:if test="${currentPage > 1}">
                                <a href="javascript:void(0)" onclick="goToPage(1)" title="Trang đầu"><i class="fa-solid fa-angles-left"></i></a>
                                <a href="javascript:void(0)" onclick="goToPage(${currentPage - 1})" title="Trang trước"><i class="fa-solid fa-angle-left"></i></a>
                            </c:if>

                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <c:choose>
                                    <c:when test="${p == currentPage}">
                                        <span class="active">${p}</span>
                                    </c:when>
                                    <c:when test="${p >= currentPage - 2 && p <= currentPage + 2}">
                                        <a href="javascript:void(0)" onclick="goToPage(${p})">${p}</a>
                                    </c:when>
                                </c:choose>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <a href="javascript:void(0)" onclick="goToPage(${currentPage + 1})" title="Trang sau"><i class="fa-solid fa-angle-right"></i></a>
                                <a href="javascript:void(0)" onclick="goToPage(${totalPages})" title="Trang cuối"><i class="fa-solid fa-angles-right"></i></a>
                            </c:if>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </main>

        <!-- Sidebar -->
        <aside class="blog-sidebar">
            <!-- Widget Search -->
            <div class="blog-widget">
                <h4 class="blog-widget__title">Tìm kiếm</h4>
                <div class="blog-search-box">
                    <input type="text" id="searchInput" placeholder="Tìm kiếm bài viết..." value="<c:out value='${searchKeyword}' />" onkeydown="if(event.key === 'Enter'){ event.preventDefault(); submitSearch(); }">
                    <button type="button" onclick="submitSearch();" aria-label="Search">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </button>
                </div>
            </div>

            <!-- Widget Categories -->
            <div class="blog-widget">
                <h4 class="blog-widget__title">Danh mục bài viết</h4>
                <ul class="blog-cat-list">
                    <li>
                        <a href="javascript:void(0)" onclick="filterCategory(0)" class="${categoryFilter == 0 ? 'active' : ''}">
                            <span><i class="fa-solid fa-border-all me-2"></i> Tất cả danh mục</span>
                            <i class="fa-solid fa-chevron-right"></i>
                        </a>
                    </li>
                    <c:forEach var="entry" items="${blogCategories}">
                        <li>
                            <a href="javascript:void(0)" onclick="filterCategory(${entry.key})" class="${categoryFilter == entry.key ? 'active' : ''}">
                                <span><i class="fa-solid fa-tag me-2"></i> <c:out value="${entry.value}" /></span>
                                <i class="fa-solid fa-chevron-right"></i>
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>

            <!-- Widget Recent Posts -->
            <c:if test="${not empty recentBlogs}">
                <div class="blog-widget">
                    <h4 class="blog-widget__title">Bài viết mới nhất</h4>
                    <div class="blog-recent-list">
                        <c:forEach var="rb" items="${recentBlogs}">
                            <fmt:formatDate value="${rb.createdDate}" pattern="dd/MM/yyyy" var="rbDate" />
                            <a href="${pageContext.request.contextPath}/blog-detail?id=${rb.id}" class="blog-recent-item">
                                <div class="blog-recent-item__thumb">
                                    <c:choose>
                                        <c:when test="${not empty rb.thumbnail}">
                                            <img src="${rb.thumbnail}" alt="${rb.title}">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="blog-thumb-fallback">
                                                <i class="fa-regular fa-newspaper"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="blog-recent-item__info">
                                    <h5 class="blog-recent-item__title"><c:out value="${rb.title}" /></h5>
                                    <span class="blog-recent-item__date"><i class="fa-regular fa-calendar me-1"></i><c:out value="${rbDate}" /></span>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </aside>

    </div>

    <!-- Footer chung -->
    <jsp:include page="/view/common/footer.jsp" />

    <!-- JS riêng biệt cho Blogs -->
    <script src="${pageContext.request.contextPath}/assets/js/blog/blogs.js"></script>
</body>
</html>
