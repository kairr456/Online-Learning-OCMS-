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
    
    <style>
        :root {
            --primary-dark: #1a1a2e;
            --bg-color: #f4f6f9;
            --white: #ffffff;
            --text-main: #333333;
            --text-muted: #6c757d;
            --border-light: #e9ecef;
            --danger: #dc3545;
        }

        body {
            background-color: var(--bg-color);
            font-family: 'Inter', 'Segoe UI', sans-serif; 
            margin: 0;
            padding: 0;
        }
        
        .delete-preview-container {
            max-width: 800px;
            margin: 60px auto;
            background: var(--white);
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08);
            overflow: hidden;
        }
        
        .preview-header {
            background-color: #fee2e2;
            padding: 20px 30px;
            border-bottom: 1px solid #fecaca;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .preview-header i {
            font-size: 24px;
            color: var(--danger);
        }
        
        .preview-header h2 {
            margin: 0;
            color: var(--danger);
            font-size: 22px;
            font-weight: 700;
        }
        
        .preview-content {
            padding: 40px;
        }
        
        .course-info {
            display: flex;
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .course-thumbnail {
            width: 250px;
            height: 160px;
            border-radius: 12px;
            object-fit: cover;
            border: 1px solid var(--border-light);
        }
        
        .course-details {
            flex: 1;
        }
        
        .course-title {
            font-size: 24px;
            font-weight: 800;
            color: var(--primary-dark);
            margin: 0 0 15px 0;
        }
        
        .course-description {
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 20px;
        }
        
        .course-meta {
            display: flex;
            gap: 20px;
            font-size: 14px;
            color: var(--text-main);
            font-weight: 600;
        }
        
        .course-meta span {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .course-meta i {
            color: var(--text-muted);
        }
        
        .warning-text {
            background-color: #fff3cd;
            color: #856404;
            padding: 20px;
            border-radius: 8px;
            border-left: 5px solid #ffeeba;
            margin-bottom: 30px;
            font-weight: 600;
        }
        
        .action-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            border-top: 1px solid var(--border-light);
            padding-top: 25px;
        }
        
        .btn {
            padding: 12px 25px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 15px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            border: none;
        }
        
        .btn-cancel {
            background-color: var(--border-light);
            color: var(--text-main);
        }
        
        .btn-cancel:hover {
            background-color: #d3d9df;
        }
        
        .btn-confirm {
            background-color: var(--danger);
            color: var(--white);
        }
        
        .btn-confirm:hover {
            background-color: #c82333;
        }
    </style>
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
                        <span><i class="fas fa-dollar-sign" style="color: #28a745;"></i> Price: $${course.price}</span>
                    </div>
                </div>
            </div>
            
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/course-dashboard" class="btn btn-cancel">Cancel</a>
                <form action="${pageContext.request.contextPath}/course-delete" method="post" style="margin: 0;">
                    <input type="hidden" name="id" value="${course.id}">
                    <button type="submit" class="btn btn-confirm"><i class="fas fa-trash"></i> Confirm Delete</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
