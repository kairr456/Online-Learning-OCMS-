package com.entity;

import java.sql.Timestamp;

public class TeacherBankAccount {
    private int id;
    private int teacherId;
    private String bankCode;
    private String bankName;
    private String accountNumber;
    private String accountHolder;
    private String taxCode;
    private boolean isDefault;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public TeacherBankAccount() {
        this.isDefault = true;
    }

    public TeacherBankAccount(int id, int teacherId, String bankCode, String bankName, String accountNumber, String accountHolder, String taxCode, boolean isDefault, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.teacherId = teacherId;
        this.bankCode = bankCode;
        this.bankName = bankName;
        this.accountNumber = accountNumber;
        this.accountHolder = accountHolder;
        this.taxCode = taxCode;
        this.isDefault = isDefault;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public String getBankCode() { return bankCode; }
    public void setBankCode(String bankCode) { this.bankCode = bankCode; }

    public String getBankName() { return bankName; }
    public void setBankName(String bankName) { this.bankName = bankName; }

    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }

    public String getAccountHolder() { return accountHolder; }
    public void setAccountHolder(String accountHolder) { this.accountHolder = accountHolder; }

    public String getTaxCode() { return taxCode; }
    public void setTaxCode(String taxCode) { this.taxCode = taxCode; }

    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
