package com.entity;

public class LearningReminder {
    private int id;
    private int accountId;
    private String days;
    private String reminderTime;
    private boolean enabled;
    private String lastSentDate;

    public LearningReminder() {
    }

    public LearningReminder(int id, int accountId, String days, String reminderTime, boolean enabled) {
        this.id = id;
        this.accountId = accountId;
        this.days = days;
        this.reminderTime = reminderTime;
        this.enabled = enabled;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getDays() {
        return days;
    }

    public void setDays(String days) {
        this.days = days;
    }

    public String getReminderTime() {
        return reminderTime;
    }

    public void setReminderTime(String reminderTime) {
        this.reminderTime = reminderTime;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getLastSentDate() {
        return lastSentDate;
    }

    public void setLastSentDate(String lastSentDate) {
        this.lastSentDate = lastSentDate;
    }

    public boolean containsDay(int day) {
        if (days == null || days.trim().isEmpty()) {
            return false;
        }
        for (String token : days.split(",")) {
            try {
                if (Integer.parseInt(token.trim()) == day) {
                    return true;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        return false;
    }
}