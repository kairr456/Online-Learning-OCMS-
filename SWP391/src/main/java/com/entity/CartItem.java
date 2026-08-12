package com.entity;

import java.math.BigDecimal;
import java.sql.Date;

/**
 * Entity class for cart_item table
 */

public class CartItem {
    private Integer id;
    private Integer cartId;
    private Integer courseId;
    private BigDecimal price;
    private Date addedDate;

    public CartItem(Integer id, Integer cartId, Integer courseId, BigDecimal price, Date addedDate) {
        this.id = id;
        this.cartId = cartId;
        this.courseId = courseId;
        this.price = price;
        this.addedDate = addedDate;
    }

    public CartItem() {
    }
     
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getCartId() {
        return cartId;
    }

    public void setCartId(Integer cartId) {
        this.cartId = cartId;
    }

    public Integer getCourseId() {
        return courseId;
    }

    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Date getAddedDate() {
        return addedDate;
    }

    public void setAddedDate(Date addedDate) {
        this.addedDate = addedDate;
    }
    
} 