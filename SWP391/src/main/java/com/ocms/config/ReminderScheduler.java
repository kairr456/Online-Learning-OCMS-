package com.ocms.config;

import com.DAO.AccountDAO;
import com.DAO.CourseRegistrationDAO;
import com.DAO.ReminderDAO;
import com.entity.Account;
import com.entity.Course;
import com.entity.LearningReminder;
import com.utils.EmailService;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class ReminderScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "ocms-reminder-scheduler");
            t.setDaemon(true);
            return t;
        });
        scheduler.scheduleAtFixedRate(this::runReminders, 30, 60, TimeUnit.SECONDS);
    }

    private void runReminders() {
        try {
            List<LearningReminder> reminders = new ReminderDAO().getAllEnabled();
            if (reminders.isEmpty()) {
                return;
            }
            String today = LocalDate.now().toString();
            int todayDay = LocalDate.now().getDayOfWeek().getValue();
            String nowHHmm = LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm"));

            for (LearningReminder r : reminders) {
                try {
                    if (!r.containsDay(todayDay)) {
                        continue;
                    }
                    if (!nowHHmm.equals(r.getReminderTime())) {
                        continue;
                    }
                    if (today.equals(r.getLastSentDate())) {
                        continue;
                    }

                    Account account = new AccountDAO().getAccountById(r.getAccountId());
                    if (account == null || account.getEmail() == null || account.getEmail().trim().isEmpty()) {
                        continue;
                    }

                    EmailService.sendEmail(account.getEmail(), "OCMS - Learning Reminder", buildBody(account));
                    new ReminderDAO().updateLastSentDate(r.getAccountId());
                } catch (Exception e) {
                    System.err.println("[ReminderScheduler] error for account " + r.getAccountId() + ": " + e.getMessage());
                }
            }
        } catch (Exception e) {
            System.err.println("[ReminderScheduler] run error: " + e.getMessage());
        }
    }

    private String buildBody(Account account) {
        StringBuilder body = new StringBuilder();
        body.append("Hi ").append(account.getFullName() != null ? account.getFullName() : account.getUsername())
                .append(",\n\n");
        body.append("This is your OCMS learning reminder. Here is what you are currently learning:\n\n");
        List<Course> enrolled = new CourseRegistrationDAO().getCoursesByAccountId(account.getId());
        if (enrolled.isEmpty()) {
            body.append("- You have not enrolled in any course yet.\n");
        } else {
            for (Course c : enrolled) {
                body.append("- ").append(c.getName()).append("\n");
            }
        }
        body.append("\nKeep up the good work!\nOCMS");
        return body.toString();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
    }
}