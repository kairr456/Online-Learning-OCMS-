<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Learning | OCMS</title>

    <!-- System CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course_learning.css">
</head>

<body data-ctx="${pageContext.request.contextPath}">

    <!-- Common Header -->
    <jsp:include page="/view/common/header.jsp" />

    <!-- Navigation Header -->
    <div class="my-learning-header">
        <div class="container">
            <h1>Learning Tools</h1>
        </div>
    </div>

    <main class="py-4">
        <div class="container py-2">
            <div class="row">
                <div class="col-md-6 mb-4">
                    <div class="tool-card">
                        <div class="d-flex align-items-center mb-3">
                            <i class="fas fa-bell fa-2x text-primary me-3"></i>
                            <div>
                                <h5 class="fw-bold mb-1">Learning Reminders</h5>
                                <p class="text-muted small mb-0">Set regular notifications to stay on track with your courses.</p>
                            </div>
                        </div>
                        <hr>
                        <form id="reminderForm" onsubmit="saveReminderSettings(event)">
                            <div class="mb-3">
                                <label class="form-label fw-bold small">Reminder Days</label>
                                <div class="d-flex flex-wrap gap-2" id="reminderDays">
                                    <label class="form-check form-check-inline mb-1">
                                        <input type="checkbox" class="form-check-input reminder-day" value="1" ${not empty reminder && reminder.containsDay(1) ? 'checked' : ''}>
                                        <span class="form-check-label small">Mon</span>
                                    </label>
                                    <label class="form-check form-check-inline mb-1">
                                        <input type="checkbox" class="form-check-input reminder-day" value="2" ${not empty reminder && reminder.containsDay(2) ? 'checked' : ''}>
                                        <span class="form-check-label small">Tue</span>
                                    </label>
                                    <label class="form-check form-check-inline mb-1">
                                        <input type="checkbox" class="form-check-input reminder-day" value="3" ${not empty reminder && reminder.containsDay(3) ? 'checked' : ''}>
                                        <span class="form-check-label small">Wed</span>
                                    </label>
                                    <label class="form-check form-check-inline mb-1">
                                        <input type="checkbox" class="form-check-input reminder-day" value="4" ${not empty reminder && reminder.containsDay(4) ? 'checked' : ''}>
                                        <span class="form-check-label small">Thu</span>
                                    </label>
                                    <label class="form-check form-check-inline mb-1">
                                        <input type="checkbox" class="form-check-input reminder-day" value="5" ${not empty reminder && reminder.containsDay(5) ? 'checked' : ''}>
                                        <span class="form-check-label small">Fri</span>
                                    </label>
                                    <label class="form-check form-check-inline mb-1">
                                        <input type="checkbox" class="form-check-input reminder-day" value="6" ${not empty reminder && reminder.containsDay(6) ? 'checked' : ''}>
                                        <span class="form-check-label small">Sat</span>
                                    </label>
                                    <label class="form-check form-check-inline mb-1">
                                        <input type="checkbox" class="form-check-input reminder-day" value="7" ${not empty reminder && reminder.containsDay(7) ? 'checked' : ''}>
                                        <span class="form-check-label small">Sun</span>
                                    </label>
                                </div>
                                <div class="form-text small">Tick at least one day. Reminders are sent on the selected days at the reminder time.</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold small">Reminder Time</label>
                                <input type="time" class="form-control" id="reminderTime" value="${not empty reminder ? reminder.reminderTime : '20:00'}">
                            </div>
                            <div class="form-check mb-3">
                                <input type="checkbox" class="form-check-input" id="reminderEnabled" ${empty reminder || reminder.enabled ? 'checked' : ''}>
                                <label class="form-check-label fw-bold small" for="reminderEnabled">Enable reminders</label>
                            </div>
                            <button type="submit" class="btn-purple w-100 mb-2">Save Reminder Settings</button>
                            <button type="button" class="btn btn-outline-dark fw-bold w-100" onclick="sendTestReminder()">
                                <i class="fas fa-paper-plane me-1"></i> Send Test Reminder
                            </button>
                        </form>
                    </div>
                </div>

                <div class="col-md-6 mb-4">
                    <div class="tool-card">
                        <div class="d-flex align-items-center mb-3">
                            <i class="fas fa-calendar-alt fa-2x text-success me-3"></i>
                            <div>
                                <h5 class="fw-bold mb-1">Calendar Integration</h5>
                                <p class="text-muted small mb-0">Sync your learning schedule directly with Google or Outlook Calendar.</p>
                            </div>
                        </div>
                        <hr>
                        <p class="small text-secondary">Pick a course and add its next study session directly to your Google or Outlook calendar.</p>
                        <div class="mb-3">
                            <label class="form-label fw-bold small">Select a Course</label>
                            <select class="form-select" id="calendarCourse">
                                <option value="">Select a course...</option>
                                <c:forEach var="c" items="${myCourses}">
                                    <option value="${c.name}">${c.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="d-grid gap-2">
                            <button type="button" class="btn btn-outline-dark fw-bold" onclick="syncCalendar('google')">
                                <i class="fab fa-google me-2"></i> Sync Google Calendar
                            </button>
                            <button type="button" class="btn btn-outline-primary fw-bold" onclick="syncCalendar('outlook')">
                                <i class="fab fa-windows me-2"></i> Sync Outlook Calendar
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- ===== Notification Popup ===== -->
    <div class="custom-modal-backdrop" id="notificationModal">
        <div class="custom-modal-content">
            <div class="custom-modal-header">
                <h5 class="fw-bold mb-0" id="notificationTitle">Notification</h5>
                <button type="button" class="btn-close" onclick="closeNotificationModal()"></button>
            </div>
            <div class="custom-modal-body">
                <p id="notificationMessage" class="mb-0"></p>
            </div>
            <div class="custom-modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeNotificationModal()">Close</button>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/course_learning/learning-tools.js"></script>
</body>

</html>
