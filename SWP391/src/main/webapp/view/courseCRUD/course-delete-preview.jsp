<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Delete Course Confirmation</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_crud/course-delete-preview.css">
</head>
<body>
    <jsp:include page="/view/common/header.jsp" />
    
    <div class="delete-preview-container">
        <div class="preview-header">
            <i class="fas fa-exclamation-triangle"></i>
            <h2>Confirm Course Deletion</h2>
        </div>
        
        <div class="preview-content">
            <div class="warning-text">
                Are you sure you want to delete this course? This action is permanent and cannot be undone. All associated lessons, materials, and student progress might be affected.
            </div>
            
            <div class="course-info">
                <img src="${course.thumbnail != null ? course.thumbnail : 'https://via.placeholder.com/250x160.png?text=No+Image'}" alt="Course Thumbnail" class="course-thumbnail">
                
                <div class="course-details">
                    <h3 class="course-title">${course.name}</h3>
                    <div class="course-description">
                        ${course.description}
                    </div>
                    
                    <div class="course-meta">
                        <span><i class="fas fa-star" style="color: #ffc107;"></i> Rating: ${course.rating}</span>
                        <span><i class="fas fa-dollar-sign" style="color: #28a745;"></i> Price: ${course.price}₫</span>
                    </div>
                </div>
            </div>
            
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/course-dashboard" class="btn btn-cancel">Cancel</a>
                <form action="${pageContext.request.contextPath}/course-delete" method="post" class="inline-form">
                    <input type="hidden" name="id" value="${course.id}">
                    <button type="submit" class="btn btn-confirm"><i class="fas fa-trash"></i> Confirm Delete</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
