package com.DAO;

import com.entity.BlogCategory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng blog_category.
 * Hỗ trợ các thao tác CRUD, tìm kiếm, phân trang, kiểm tra số lượng bài viết và Xóa mềm (Soft Delete).
 */
public class BlogCategoryDAO extends DBContext {

    @Override
    public Connection getConnection() {
        try {
            if (connection == null || connection.isClosed()) {
                connection = new DBContext().getConnection();
            }
        } catch (SQLException e) {
            connection = new DBContext().getConnection();
        }
        return connection;
    }

    public BlogCategoryDAO() {
        super();
        ensureTableStructure();
    }

    /**
     * Tự động đảm bảo cấu trúc bảng blog_category:
     * - Thêm cột is_deleted nếu chưa có
     * - Đảm bảo cột name có kiểu VARCHAR(100) NOT NULL
     */
    private void ensureTableStructure() {
        Statement st = null;
        try {
            Connection conn = getConnection();
            if (conn != null) {
                st = conn.createStatement();
                try {
                    st.executeUpdate("ALTER TABLE blog_category ADD COLUMN is_deleted TINYINT(1) NOT NULL DEFAULT 0");
                } catch (Exception ignored) {
                    // Cột đã tồn tại
                }
                try {
                    st.executeUpdate("ALTER TABLE blog_category MODIFY COLUMN name VARCHAR(100) NOT NULL");
                } catch (Exception ignored) {
                    // Đã được cấu hình phù hợp
                }
            }
        } catch (Exception ignored) {
        } finally {
            if (st != null) {
                try { st.close(); } catch (Exception ignored) {}
            }
        }
    }

    /**
     * Lấy toàn bộ danh sách danh mục blog chưa bị xóa mềm
     */
    public List<BlogCategory> getAllBlogCategories() {
        return searchBlogCategories(null, 1, 1000);
    }

    /**
     * Tìm kiếm và phân trang danh mục blog chưa bị xóa mềm
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
                + "WHERE (bc.is_deleted = 0 OR bc.is_deleted IS NULL) "
        );

        if (hasKeyword) {
            sql.append("AND (bc.name LIKE ? OR bc.description LIKE ?) ");
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
            System.err.println("[BlogCategoryDAO] Lỗi searchBlogCategories: " + e.getMessage());
            // Fallback nếu cột is_deleted chưa tồn tại trong MySQL
            list = searchBlogCategoriesFallback(keyword, offset, pageSize, hasKeyword);
        } finally {
            closeResources();
        }
        return list;
    }

    private List<BlogCategory> searchBlogCategoriesFallback(String keyword, int offset, int pageSize, boolean hasKeyword) {
        List<BlogCategory> list = new ArrayList<>();
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
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Đếm tổng số danh mục chưa bị xóa mềm theo từ khóa tìm kiếm
     */
    public int countBlogCategories(String keyword) {
        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM blog_category WHERE (is_deleted = 0 OR is_deleted IS NULL) ");
        if (hasKeyword) {
            sql.append("AND (name LIKE ? OR description LIKE ?) ");
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
            System.err.println("[BlogCategoryDAO] Lỗi countBlogCategories: " + e.getMessage());
            return countBlogCategoriesFallback(keyword, hasKeyword);
        } finally {
            closeResources();
        }
        return 0;
    }

    private int countBlogCategoriesFallback(String keyword, boolean hasKeyword) {
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
        } catch (SQLException ex) {
            ex.printStackTrace();
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
     * Kiểm tra xem tên danh mục đã tồn tại hay chưa trong các danh mục chưa bị xóa mềm
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
     * XÓA MỀM (Soft Delete) danh mục blog theo ID: cập nhật is_deleted = 1
     */
    public boolean deleteBlogCategory(int id) {
        String sql = "UPDATE blog_category SET is_deleted = 1, updated_at = NOW() WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            int rows = statement.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            // Fallback nếu không có cột is_deleted
            System.err.println("[BlogCategoryDAO] Lỗi soft delete: " + e.getMessage());
            return deleteBlogCategoryFallback(id);
        } finally {
            closeResources();
        }
    }

    private boolean deleteBlogCategoryFallback(int id) {
        String sql = "DELETE FROM blog_category WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
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
