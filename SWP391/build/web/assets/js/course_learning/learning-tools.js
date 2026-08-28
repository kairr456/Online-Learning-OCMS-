// Learning Tools page (view/course_learning/learning_tools.jsp)
const CTX = document.body.getAttribute('data-ctx') || '';

function showNotification(message, isError) {
    var modal = document.getElementById('notificationModal');
    document.getElementById('notificationTitle').textContent = isError ? 'Error' : 'Notification';
    var msg = document.getElementById('notificationMessage');
    msg.textContent = message;
    msg.style.color = isError ? '#dc3545' : '#212529';
    modal.classList.add('show');
}

function closeNotificationModal() {
    document.getElementById('notificationModal').classList.remove('show');
}

function saveReminderSettings(event) {
    event.preventDefault();
    var selectedDays = [];
    document.querySelectorAll('#reminderDays .reminder-day:checked').forEach(function (cb) {
        selectedDays.push(cb.value);
    });
    if (selectedDays.length === 0) {
        showNotification('Please select at least one day.', true);
        return;
    }
    var body = new URLSearchParams({
        action: 'saveReminder',
        days: selectedDays.join(','),
        reminderTime: document.getElementById('reminderTime').value,
        enabled: document.getElementById('reminderEnabled').checked ? 'true' : 'false'
    });
    fetch(CTX + '/learning-tools', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: body
    })
    .then(function (res) { return res.json(); })
    .then(function (data) {
        if (data.status === 'success') {
            showNotification('Reminder settings saved successfully!', false);
        } else {
            showNotification(data.message || 'Failed to save settings.', true);
        }
    })
    .catch(function (err) {
        showNotification('Error saving settings.', true);
    });
}

function sendTestReminder() {
    fetch(CTX + '/learning-tools', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: new URLSearchParams({ action: 'testReminder' })
    })
    .then(function (res) { return res.json(); })
    .then(function (data) {
        if (data.status === 'success') {
            showNotification('Test reminder email sent!', false);
        } else {
            showNotification(data.message || 'Failed to send email.', true);
        }
    })
    .catch(function (err) {
        showNotification('Error sending email.', true);
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
        showNotification('Please select a course first.', true);
        return;
    }
    var selectedDays = document.querySelectorAll('#reminderDays .reminder-day:checked');
    if (selectedDays.length === 0) {
        showNotification('Please set reminder days first.', true);
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