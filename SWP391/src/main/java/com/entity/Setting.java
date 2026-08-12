package com.entity;

public class Setting {
    private Integer id;       // ID của cài đặt
    private String type;      // Loại cài đặt (System, User, Payment, etc.)
    private String value;     // Giá trị cụ thể của cài đặt
    private Integer order;    // Thứ tự hiển thị
    private String status;    // Trạng thái: "Active" hoặc "Inactive"
    private String createdAt; // Thời gian tạo
    private String updatedAt; // Thời gian cập nhật

    public Setting() {
    }

    public Setting(Integer id, String type, String value, Integer order, String status, String createdAt, String updatedAt) {
        this.id = id;
        this.type = type;
        this.value = value;
        this.order = order;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Integer getOrder() {
        return order;
    }

    public void setOrder(Integer order) {
        this.order = order;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }
    
}
