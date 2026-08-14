package com.utils;

import java.util.List;

public class AccountFilterBuilder {

    /**
     * Thêm điều kiện WHERE cho bảng Account vào sql,
     * đồng thời gom tham số vào params.
     * Dùng chung cho searchAccounts() và countAccounts().
     */
    public static void appendFilters(StringBuilder sql, String keyword,
                                     String roleId, String status,
                                     List<Object> params) {

        // Tìm theo username / email / full_name
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (username LIKE ? OR email LIKE ? OR full_name LIKE ?)");
            String p = "%" + keyword.trim() + "%";
            params.add(p); params.add(p); params.add(p);
        }

        // Lọc theo role
        if (roleId != null && !roleId.trim().isEmpty()) {
            sql.append(" AND role_id = ?");
            params.add(Integer.parseInt(roleId));
        }

        // Lọc theo status (is_active)
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND is_active = ?");
            params.add(Integer.parseInt(status));
        }
    }
}
