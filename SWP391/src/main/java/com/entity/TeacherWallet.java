package com.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class TeacherWallet {
    private int id;
    private int teacherId;
    private BigDecimal balance;
    private BigDecimal totalEarned;
    private BigDecimal totalWithdrawn;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public TeacherWallet() {
        this.balance = BigDecimal.ZERO;
        this.totalEarned = BigDecimal.ZERO;
        this.totalWithdrawn = BigDecimal.ZERO;
        this.status = "active";
    }

    public TeacherWallet(int id, int teacherId, BigDecimal balance, BigDecimal totalEarned, BigDecimal totalWithdrawn, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.teacherId = teacherId;
        this.balance = balance != null ? balance : BigDecimal.ZERO;
        this.totalEarned = totalEarned != null ? totalEarned : BigDecimal.ZERO;
        this.totalWithdrawn = totalWithdrawn != null ? totalWithdrawn : BigDecimal.ZERO;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal balance) { this.balance = balance; }

    public BigDecimal getTotalEarned() { return totalEarned; }
    public void setTotalEarned(BigDecimal totalEarned) { this.totalEarned = totalEarned; }

    public BigDecimal getTotalWithdrawn() { return totalWithdrawn; }
    public void setTotalWithdrawn(BigDecimal totalWithdrawn) { this.totalWithdrawn = totalWithdrawn; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
