package com.entity;

import java.sql.Timestamp;

public class SupportedBank {
    private int id;
    private String bankCode;
    private String bankName;
    private String shortName;
    private String status; // 'active' or 'inactive'
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int accountCount; // Số lượng tài khoản giảng viên đang liên kết với ngân hàng này

    public SupportedBank() {
        this.status = "active";
    }

    public SupportedBank(String bankCode, String bankName, String shortName) {
        this.bankCode = bankCode;
        this.bankName = bankName;
        this.shortName = shortName;
        this.status = "active";
    }

    public SupportedBank(String bankCode, String bankName, String shortName, String status) {
        this.bankCode = bankCode;
        this.bankName = bankName;
        this.shortName = shortName;
        this.status = status != null ? status : "active";
    }

    public SupportedBank(int id, String bankCode, String bankName, String shortName, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.bankCode = bankCode;
        this.bankName = bankName;
        this.shortName = shortName;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBankCode() {
        return bankCode;
    }

    public void setBankCode(String bankCode) {
        this.bankCode = bankCode;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getShortName() {
        return shortName;
    }

    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getAccountCount() {
        return accountCount;
    }

    public void setAccountCount(int accountCount) {
        this.accountCount = accountCount;
    }
}
