<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${not empty blog.title ? blog.title : 'Chi tiết bài viết'}" /> · OCMS</title>
    <!-- FontAwesome & Base CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/blog/blog-detail.css">
</head>
<body>

    <!-- Header chung -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Breadcrumbs -->
    <div class="detail-breadcrumb-bar">
        <div class="detail-breadcrumb">
            <a href="${pageContext.request.contextPath}/"><i class="fa-solid fa-house me-1"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right chevron-sm"></i>
            <a href="${pageContext.request.contextPath}/blogs">Danh sách bài viết</a>
            <i class="fa-solid fa-chevron-right chevron-sm"></i>
            <span class="current"><c:out value="${not empty blog.title ? blog.title : 'Bài viết'}" /></span>
        </div>
    </div>

    <!-- Main Container -->
    <div class="detail-container">
        
        <c:choose>
            <c:when test="${empty blog}">
                <div class="detail-main notfound-box">
                    <i class="fa-regular fa-file-circle-question"></i>
                    <h2>Không tìm thấy bài viết</h2>
                    <p class="blog-empty-msg">Bài viết bạn đang tìm kiếm có thể đã bị xóa hoặc không tồn tại.</p>
                    <a href="${pageContext.request.contextPath}/blogs" class="btn-back-blogs">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại trang danh sách Blog
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <c:set var="catName" value="${not empty blogCategories[blog.categoryId] ? blogCategories[blog.categoryId] : 'Tin tức chung'}" />
                <c:set var="authorName" value="${not empty authorNames[blog.author] ? authorNames[blog.author] : 'Tác giả OCMS'}" />
                <fmt:formatDate value="${blog.createdDate}" pattern="dd/MM/yyyy" var="formattedDate" />

                <article class="detail-main">
                    <span class="article-cat-badge"><i class="fa-solid fa-tag me-1"></i> <c:out value="${catName}" /></span>
                    
                    <h1 class="article-title"><c:out value="${blog.title}" /></h1>

                    <div class="article-meta">
                        <span><i class="fa-regular fa-user"></i> <strong><c:out value="${authorName}" /></strong></span>
                        <span><i class="fa-regular fa-calendar"></i> <c:out value="${not empty formattedDate ? formattedDate : 'Gần đây'}" /></span>
                        <c:if test="${not empty blog.status}">
                            <span><i class="fa-solid fa-circle-check"></i> <c:out value="${blog.status}" /></span>
                        </c:if>
                    </div>

                    <!-- Thumbnail -->
                    <c:if test="${not empty blog.thumbnail}">
                        <div class="article-thumbnail-wrap">
                            <img src="${blog.thumbnail}" alt="${blog.title}">
                        </div>
                    </c:if>

                    <!-- Tóm tắt -->
                    <c:if test="${not empty blog.briefInfo}">
                        <div class="article-lead">
                            <c:out value="${blog.briefInfo}" />
                        </div>
                    </c:if>

                    <!-- Nội dung chi tiết -->
                    <div class="article-content">
                        ${blog.content}
                    </div>

                    <!-- Điều hướng cuối bài -->
                    <div class="article-footer-nav">
                        <a href="${pageContext.request.contextPath}/blogs" class="btn-back-blogs">
                            <i class="fa-solid fa-arrow-left"></i> Xem tất cả bài viết khác
                        </a>
                        <div class="article-footer-actions">
                            <c:if test="${not empty sessionScope.account and ((sessionScope.account.id == blog.author and blog.status != 'Active') or sessionScope.account.roleId == 1)}">
                                <a href="${pageContext.request.contextPath}/blogs-edit?id=${blog.id}" class="btn-back-blogs btn-back-blogs--edit">
                                    <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa bài này
                                </a>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/my-blogs" class="btn-back-blogs btn-back-blogs--list">
                                <i class="fa-solid fa-feather-pointed"></i> Quản lý bài viết của tôi
                            </a>
                        </div>
                    </div>

                    <!-- Bài viết liên quan -->
                    <c:if test="${not empty relatedBlogs}">
                        <div class="related-section">
                            <h3 class="related-section__title">
                                <i class="fa-solid fa-layer-group related-section__icon"></i> Bài viết cùng chủ đề
                            </h3>
                            <div class="related-grid">
                                <c:forEach var="rel" items="${relatedBlogs}">
                                    <fmt:formatDate value="${rel.createdDate}" pattern="dd/MM/yyyy" var="relDate" />
                                    <a href="${pageContext.request.contextPath}/blog-detail?id=${rel.id}" class="related-card">
                                        <div class="related-card__thumb">
                                            <c:choose>
                                                <c:when test="${not empty rel.thumbnail}">
                                                    <img src="${rel.thumbnail}" alt="${rel.title}">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="blog-thumb-fallback blog-thumb-fallback--lg">
                                                        <i class="fa-regular fa-newspaper"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="related-card__body">
                                            <h4 class="related-card__title"><c:out value="${rel.title}" /></h4>
                                            <span class="related-card__date"><i class="fa-regular fa-calendar me-1"></i><c:out value="${relDate}" /></span>
                                        </div>
                                    </a>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </article>
            </c:otherwise>
        </c:choose>

        <!-- Sidebar -->
        <aside class="detail-sidebar">
            <c:if test="${not empty recentBlogs}">
                <div class="detail-widget">
                    <h4 class="detail-widget__title">Bài viết mới nhất</h4>
                    <div class="detail-recent-list">
                        <c:forEach var="rb" items="${recentBlogs}">
                            <fmt:formatDate value="${rb.createdDate}" pattern="dd/MM/yyyy" var="rbDate" />
                            <a href="${pageContext.request.contextPath}/blog-detail?id=${rb.id}" class="detail-recent-item">
                                <div class="detail-recent-item__thumb">
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
                                <div class="detail-recent-item__info">
                                    <h5 class="detail-recent-item__title"><c:out value="${rb.title}" /></h5>
                                    <span class="detail-recent-item__date"><i class="fa-regular fa-calendar me-1"></i><c:out value="${rbDate}" /></span>
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

    <!-- JS riêng biệt cho Blog Detail -->
    <script src="${pageContext.request.contextPath}/assets/js/blog/blog-detail.js"></script>
</body>
</html>
