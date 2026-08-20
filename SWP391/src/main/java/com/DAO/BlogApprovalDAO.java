package com.DAO;

import com.entity.Blog;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý luồng duyệt bài viết Blog cho Admin (chuyển đổi giữa Inactive và Active).
 * Sử dụng đúng cấu trúc bảng blog hiện có (status enum 'Active', 'Inactive').
 */
public class BlogApprovalDAO extends DBContext {

    public BlogApprovalDAO() {
        // Không thực hiện bất kỳ DDL nào
    }

    /**
     * Đếm tổng số bài viết theo trạng thái ('Active', 'Inactive', hoặc tất cả)
     */
    public int countByStatus(String status) {
        String sql;
        if (status == null || status.trim().isEmpty() || "all".equalsIgnoreCase(status)) {
            sql = "SELECT COUNT(*) FROM blog";
        } else {
            sql = "SELECT COUNT(*) FROM blog WHERE status = ?";
        }

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
                statement.setString(1, status.trim());
            }
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[BlogApprovalDAO] countByStatus error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    /**
     * Đếm số bài viết phù hợp với bộ lọc tìm kiếm
     */
    public int countBlogs(String keyword, String status, Integer categoryId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM blog b LEFT JOIN account a ON b.author = a.id WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND b.status = ?");
            params.add(status.trim());
        }

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND b.category_id = ?");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(b.title) LIKE ? OR LOWER(b.brief_info) LIKE ? OR LOWER(a.full_name) LIKE ? OR LOWER(a.email) LIKE ?)");
            String pat = "%" + keyword.trim().toLowerCase() + "%";
            params.add(pat);
            params.add(pat);
            params.add(pat);
            params.add(pat);
        }

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[BlogApprovalDAO] countBlogs error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    /**
     * Tìm kiếm và phân trang danh sách bài viết duyệt
     */
    public List<Blog> searchBlogs(String keyword, String status, Integer categoryId, int page, int pageSize) {
        List<Blog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT b.*, a.full_name AS author_name, a.email AS author_email, bc.name AS category_name "
                + "FROM blog b "
                + "LEFT JOIN account a ON b.author = a.id "
                + "LEFT JOIN blog_category bc ON b.category_id = bc.id "
                + "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND b.status = ?");
            params.add(status.trim());
        }

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND b.category_id = ?");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(b.title) LIKE ? OR LOWER(b.brief_info) LIKE ? OR LOWER(a.full_name) LIKE ? OR LOWER(a.email) LIKE ?)");
            String pat = "%" + keyword.trim().toLowerCase() + "%";
            params.add(pat);
            params.add(pat);
            params.add(pat);
            params.add(pat);
        }

        // Sắp xếp: Ưu tiên Inactive (chờ duyệt) lên đầu, sau đó theo ngày tạo mới nhất
        sql.append(" ORDER BY CASE WHEN b.status = 'Inactive' THEN 0 ELSE 1 END, b.created_date DESC, b.id DESC");

        if (page > 0 && pageSize > 0) {
            int offset = (page - 1) * pageSize;
            sql.append(" LIMIT ? OFFSET ?");
            params.add(pageSize);
            params.add(offset);
        }

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Blog b = new Blog();
                b.setId(resultSet.getInt("id"));
                b.setTitle(resultSet.getString("title"));
                b.setThumbnail(resultSet.getString("thumbnail"));
                b.setBriefInfo(resultSet.getString("brief_info"));
                b.setContent(resultSet.getString("content"));
                b.setCategoryId(resultSet.getInt("category_id"));
                b.setAuthor(resultSet.getInt("author"));
                b.setUpdatedDate(resultSet.getTimestamp("updated_date"));
                b.setCreatedDate(resultSet.getTimestamp("created_date"));
                b.setStatus(resultSet.getString("status"));

                b.setAuthorName(resultSet.getString("author_name"));
                b.setAuthorEmail(resultSet.getString("author_email"));
                b.setCategoryName(resultSet.getString("category_name"));

                list.add(b);
            }
        } catch (SQLException e) {
            System.err.println("[BlogApprovalDAO] searchBlogs error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Lấy chi tiết blog kèm thông tin tác giả và danh mục để xem trước trên Modal
     */
    public Blog getBlogDetail(int id) {
        String sql = "SELECT b.*, a.full_name AS author_name, a.email AS author_email, bc.name AS category_name "
                   + "FROM blog b "
                   + "LEFT JOIN account a ON b.author = a.id "
                   + "LEFT JOIN blog_category bc ON b.category_id = bc.id "
                   + "WHERE b.id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                Blog b = new Blog();
                b.setId(resultSet.getInt("id"));
                b.setTitle(resultSet.getString("title"));
                b.setThumbnail(resultSet.getString("thumbnail"));
                b.setBriefInfo(resultSet.getString("brief_info"));
                b.setContent(resultSet.getString("content"));
                b.setCategoryId(resultSet.getInt("category_id"));
                b.setAuthor(resultSet.getInt("author"));
                b.setUpdatedDate(resultSet.getTimestamp("updated_date"));
                b.setCreatedDate(resultSet.getTimestamp("created_date"));
                b.setStatus(resultSet.getString("status"));

                b.setAuthorName(resultSet.getString("author_name"));
                b.setAuthorEmail(resultSet.getString("author_email"));
                b.setCategoryName(resultSet.getString("category_name"));
                return b;
            }
        } catch (SQLException e) {
            System.err.println("[BlogApprovalDAO] getBlogDetail error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    /**
     * Duyệt bài viết: chuyển status từ Inactive sang Active
     */
    public boolean approveBlog(int blogId) {
        String sql = "UPDATE blog SET status = 'Active', updated_date = NOW() WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, blogId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BlogApprovalDAO] approveBlog error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Hủy duyệt / Ẩn / Từ chối bài viết: chuyển status sang Inactive
     */
    public boolean deactivateBlog(int blogId) {
        String sql = "UPDATE blog SET status = 'Inactive', updated_date = NOW() WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, blogId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BlogApprovalDAO] deactivateBlog error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Xóa bài viết khỏi cơ sở dữ liệu
     */
    public boolean deleteBlog(int blogId) {
        String sql = "DELETE FROM blog WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, blogId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BlogApprovalDAO] deleteBlog error: " + e.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }
}
