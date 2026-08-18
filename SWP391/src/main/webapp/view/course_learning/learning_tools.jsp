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

<body>

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
                                <label class="form-label fw-bold small">Frequency</label>
                                <select class="form-select" id="reminderFrequency">
                                    <option value="daily">Daily</option>
                                    <option value="weekly" selected>Weekly (Recommended)</option>
                                    <option value="weekends">Weekends Only</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold small">Reminder Time</label>
                                <input type="time" class="form-control" id="reminderTime" value="20:00">
                            </div>
                            <button type="submit" class="btn-purple w-100">Save Reminder Settings</button>
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
                        <p class="small text-secondary">Export your course deadlines and study events into your favorite personal calendar application.</p>
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

    <script>
        function saveReminderSettings(event) {
            event.preventDefault();
            alert('Learning reminder settings saved successfully!');
        }

        function syncCalendar(provider) {
            alert('Syncing with ' + provider.toUpperCase() + ' Calendar...');
        }
    </script>
</body>

</html>
