package com.DAO;

import com.entity.BlogCategory;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng blog_category.
 * Hỗ trợ các thao tác CRUD, tìm kiếm, phân trang và đếm bài viết thuộc danh mục.
 */
public class BlogCategoryDAO extends DBContext {

    /**
     * Lấy toàn bộ danh sách danh mục blog kèm số lượng bài viết
     */
    public List<BlogCategory> getAllBlogCategories() {
        List<BlogCategory> list = new ArrayList<>();
        String sql = "SELECT bc.id, bc.name, bc.description, bc.created_at, bc.updated_at, "
                + "       (SELECT COUNT(*) FROM blog b WHERE b.category_id = bc.id) AS blog_count "
                + "FROM blog_category bc "
                + "ORDER BY bc.id DESC";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(mapResultSetToCategory(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Tìm kiếm và phân trang danh mục blog
     *
     * @param keyword  Từ khóa tìm kiếm theo tên hoặc mô tả (có thể null hoặc rỗng)
     * @param page     Số trang hiện tại (>= 1)
     * @param pageSize Số lượng bản ghi trên một trang
     */
    public List<BlogCategory> searchBlogCategories(String keyword, int page, int pageSize) {
        List<BlogCategory> list = new ArrayList<>();
        int offset = Math.max(0, (page - 1) * pageSize);
        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());

        StringBuilder sql = new StringBuilder(
                "SELECT bc.id, bc.name, bc.description, bc.created_at, bc.updated_at, "
                + "       (SELECT COUNT(*) FROM blog b WHERE b.category_id = bc.id) AS blog_count "
                + "FROM blog_category bc "
        );

        if (hasKeyword) {
            sql.append("WHERE (bc.name LIKE ? OR bc.description LIKE ?) ");
        }
        sql.append("ORDER BY bc.id DESC LIMIT ? OFFSET ?");

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            int idx = 1;
            if (hasKeyword) {
                String searchPattern = "%" + keyword.trim() + "%";
                statement.setString(idx++, searchPattern);
                statement.setString(idx++, searchPattern);
            }
            statement.setInt(idx++, pageSize);
            statement.setInt(idx, offset);

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(mapResultSetToCategory(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Đếm tổng số danh mục theo từ khóa tìm kiếm
     */
    public int countBlogCategories(String keyword) {
        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM blog_category ");
        if (hasKeyword) {
            sql.append("WHERE (name LIKE ? OR description LIKE ?) ");
        }

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            if (hasKeyword) {
                String searchPattern = "%" + keyword.trim() + "%";
                statement.setString(1, searchPattern);
                statement.setString(2, searchPattern);
            }
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return 0;
    }

    /**
     * Lấy chi tiết một danh mục blog theo ID
     */
    public BlogCategory getBlogCategoryById(int id) {
        String sql = "SELECT bc.id, bc.name, bc.description, bc.created_at, bc.updated_at, "
                + "       (SELECT COUNT(*) FROM blog b WHERE b.category_id = bc.id) AS blog_count "
                + "FROM blog_category bc "
                + "WHERE bc.id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return mapResultSetToCategory(resultSet);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    /**
     * Kiểm tra xem tên danh mục đã tồn tại hay chưa (dùng khi Add hoặc Edit)
     *
     * @param name      Tên danh mục cần kiểm tra
     * @param excludeId ID danh mục bỏ qua kiểm tra (truyền 0 hoặc -1 nếu là Add mới)
     */
    public boolean isCategoryNameExists(String name, int excludeId) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM blog_category WHERE LOWER(TRIM(name)) = LOWER(TRIM(?)) AND id != ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, name.trim());
            statement.setInt(2, excludeId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Thêm mới danh mục blog vào database
     */
    public boolean insertBlogCategory(BlogCategory category) {
        String sql = "INSERT INTO blog_category (name, description, created_at, updated_at) VALUES (?, ?, NOW(), NOW())";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, category.getName().trim());
            statement.setString(2, category.getDescription() != null ? category.getDescription().trim() : null);

            int rows = statement.executeUpdate();
            if (rows > 0) {
                resultSet = statement.getGeneratedKeys();
                if (resultSet.next()) {
                    category.setId(resultSet.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Cập nhật thông tin danh mục blog theo ID
     */
    public boolean updateBlogCategory(BlogCategory category) {
        String sql = "UPDATE blog_category SET name = ?, description = ?, updated_at = NOW() WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, category.getName().trim());
            statement.setString(2, category.getDescription() != null ? category.getDescription().trim() : null);
            statement.setInt(3, category.getId());

            int rows = statement.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Xóa danh mục blog theo ID
     */
    public boolean deleteBlogCategory(int id) {
        String sql = "DELETE FROM blog_category WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            int rows = statement.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Đếm số lượng bài viết thuộc về một danh mục
     */
    public int countBlogsByCategoryId(int categoryId) {
        String sql = "SELECT COUNT(*) FROM blog WHERE category_id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, categoryId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return 0;
    }

    /**
     * Chuyển đổi dữ liệu ResultSet sang đối tượng BlogCategory
     */
    private BlogCategory mapResultSetToCategory(ResultSet rs) throws SQLException {
        BlogCategory cat = new BlogCategory();
        cat.setId(rs.getInt("id"));
        cat.setName(rs.getString("name"));
        cat.setDescription(rs.getString("description"));
        cat.setCreatedAt(rs.getTimestamp("created_at"));
        cat.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            cat.setBlogCount(rs.getInt("blog_count"));
        } catch (SQLException ignored) {
            // Trường blog_count có thể không có trong một số query
        }

        return cat;
    }
}
