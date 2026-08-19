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
                            <div id="reminderStatus" class="small mt-2 text-center fw-bold" style="display:none;"></div>
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

    <script>
        function saveReminderSettings(event) {
            event.preventDefault();
            var ctx = '${pageContext.request.contextPath}';
            var selectedDays = [];
            document.querySelectorAll('#reminderDays .reminder-day:checked').forEach(function (cb) {
                selectedDays.push(cb.value);
            });
            if (selectedDays.length === 0) {
                var status = document.getElementById('reminderStatus');
                status.style.display = 'block';
                status.textContent = 'Please select at least one day.';
                status.style.color = '#dc3545';
                return;
            }
            var body = new URLSearchParams({
                action: 'saveReminder',
                days: selectedDays.join(','),
                reminderTime: document.getElementById('reminderTime').value,
                enabled: document.getElementById('reminderEnabled').checked ? 'true' : 'false'
            });
            fetch(ctx + '/learning-tools', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: body
            })
            .then(function (res) { return res.json(); })
            .then(function (data) {
                var status = document.getElementById('reminderStatus');
                status.style.display = 'block';
                if (data.status === 'success') {
                    status.textContent = 'Reminder settings saved successfully!';
                    status.style.color = '#198754';
                } else {
                    status.textContent = data.message || 'Failed to save settings.';
                    status.style.color = '#dc3545';
                }
            })
            .catch(function (err) {
                var status = document.getElementById('reminderStatus');
                status.style.display = 'block';
                status.textContent = 'Error saving settings.';
                status.style.color = '#dc3545';
            });
        }

        function sendTestReminder() {
            var ctx = '${pageContext.request.contextPath}';
            var status = document.getElementById('reminderStatus');
            status.style.display = 'block';
            status.textContent = 'Sending...';
            status.style.color = '#0d6efd';
            fetch(ctx + '/learning-tools', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: new URLSearchParams({ action: 'testReminder' })
            })
            .then(function (res) { return res.json(); })
            .then(function (data) {
                if (data.status === 'success') {
                    status.textContent = 'Test reminder email sent!';
                    status.style.color = '#198754';
                } else {
                    status.textContent = data.message || 'Failed to send email.';
                    status.style.color = '#dc3545';
                }
            })
            .catch(function (err) {
                status.textContent = 'Error sending email.';
                status.style.color = '#dc3545';
            });
        }

        function nextOccurrence() {
            var timeInput = document.getElementById('reminderTime').value || '20:00';
            var parts = timeInput.split(':');
            var hour = parseInt(parts[0], 10) || 20;
            var minute = parts.length > 1 ? (parseInt(parts[1], 10) || 0) : 0;
            var days = [];
            document.querySelectorAll('#reminderDays .reminder-day:checked').forEach(function (cb) {
                days.push(parseInt(cb.value, 10));
            });
            var now = new Date();
            for (var i = 0; i < 8; i++) {
                var d = new Date();
                d.setDate(d.getDate() + i);
                d.setHours(hour, minute, 0, 0);
                var jsDay = d.getDay();
                var ourDay = jsDay === 0 ? 7 : jsDay;
                if (days.indexOf(ourDay) !== -1 && d > now) {
                    return d;
                }
            }
            return now;
        }

        function googleDate(dt) {
            return dt.toISOString().replace(/[-:]/g, '').replace(/\.\d{3}/, '');
        }

        function outlookDate(dt) {
            var pad = function (n) { return String(n).padStart(2, '0'); };
            return dt.getFullYear() + '-' + pad(dt.getMonth() + 1) + '-' + pad(dt.getDate())
                + 'T' + pad(dt.getHours()) + ':' + pad(dt.getMinutes()) + ':' + pad(dt.getSeconds());
        }

        function syncCalendar(provider) {
            var select = document.getElementById('calendarCourse');
            var courseName = select.value;
            if (!courseName) {
                alert('Please select a course first.');
                return;
            }
            var selectedDays = document.querySelectorAll('#reminderDays .reminder-day:checked');
            if (selectedDays.length === 0) {
                alert('Please set reminder days first.');
                return;
            }
            var start = nextOccurrence();
            var end = new Date(start.getTime() + 60 * 60 * 1000);
            var subject = 'Study: ' + courseName;
            if (provider === 'google') {
                var url = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
                    + '&text=' + encodeURIComponent(subject)
                    + '&dates=' + googleDate(start) + '/' + googleDate(end)
                    + '&details=' + encodeURIComponent('OCMS study session for ' + courseName)
                    + '&location=' + encodeURIComponent('OCMS');
            } else {
                var url = 'https://outlook.live.com/calendar/0/deeplink/compose'
                    + '?subject=' + encodeURIComponent(subject)
                    + '&startdt=' + outlookDate(start)
                    + '&enddt=' + outlookDate(end)
                    + '&body=' + encodeURIComponent('OCMS study session for ' + courseName)
                    + '&path=/calendar/action/compose&rru=addevent';
            }
            window.open(url, '_blank');
        }
    </script>
</body>

</html>
