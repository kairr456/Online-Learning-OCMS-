<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.entity.Blog" %>
<%@ page import="com.DAO.BlogDAO" %>
<%@ page import="java.util.List" %>
<%
    // Homepage carousel shows the most recent blogs; the dedicated /blogs
    // page shows all of them. getAllBlogs() already orders by created_date
    // DESC, so the first few are simply the newest.
    List<Blog> homeBlogs = new BlogDAO().getAllBlogs();
    int blogLimit = Math.min(homeBlogs.size(), 8);
    List<Blog> homeBlogsPreview = homeBlogs.subList(0, blogLimit);
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Homepage</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home/homepage.css">
    </head>
    <body>
        <jsp:include page="/view/common/header.jsp" />

        <section class="blog-section">
            <div class="blog-section__inner">

                <div class="blog-section__head">
                    <h2>Blogs</h2>
                    <a class="blog-section__more" href="<%= ctx %>/blogs">Look for more</a>
                </div>

                <div class="blog-carousel">
                    <button type="button" class="blog-carousel__arrow blog-carousel__arrow--prev" id="blogPrev" aria-label="Previous">
                        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M15 5 8 12l7 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </button>

                    <div class="blog-carousel__track" id="blogTrack">
                        <% if (homeBlogsPreview.isEmpty()) { %>
                        <p class="blog-carousel__empty">No blog posts yet.</p>
                        <% } %>
                        <% for (Blog blog : homeBlogsPreview) { %>
                        <a class="blog-card" href="<%= ctx %>/view/blogs/blog-detail.jsp?id=<%= blog.getId() %>">
                            <div class="blog-card__thumb">
                                <% if (blog.getThumbnail() != null && !blog.getThumbnail().isEmpty()) { %>
                                    <img src="<%= blog.getThumbnail() %>" alt="">
                                <% } else { %>
                                    <span class="blog-card__thumb-fallback">
                                        <span class="dot"></span>
                                    </span>
                                <% } %>
                            </div>
                            <span class="blog-card__label"><%= blog.getTitle() %></span>
                        </a>
                        <% } %>
                    </div>

                    <button type="button" class="blog-carousel__arrow blog-carousel__arrow--next" id="blogNext" aria-label="Next">
                        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M9 5l7 7-7 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </button>
                </div>

            </div>
        </section>

        <jsp:include page="/view/common/footer.jsp" />

        <script>
        (function () {
            var track = document.getElementById('blogTrack');
            var prev = document.getElementById('blogPrev');
            var next = document.getElementById('blogNext');
            if (!track || !prev || !next) return;

            function cardStep() {
                var card = track.querySelector('.blog-card');
                if (!card) return 260;
                var style = window.getComputedStyle(track);
                var gap = parseFloat(style.columnGap || style.gap || 20);
                return card.getBoundingClientRect().width + gap;
            }

            prev.addEventListener('click', function () {
                track.scrollBy({ left: -cardStep(), behavior: 'smooth' });
            });
            next.addEventListener('click', function () {
                track.scrollBy({ left: cardStep(), behavior: 'smooth' });
            });
        })();
        </script>
    </body>
</html>
