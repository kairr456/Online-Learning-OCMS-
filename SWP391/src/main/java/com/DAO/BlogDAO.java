package com.DAO;

import com.entity.Blog;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BlogDAO extends DBContext {

    public List<Blog> getAllBlogs() {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT * FROM blog WHERE status = 'Active' ORDER BY created_date DESC";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (rsNext(resultSet)) {
                Blog b = new Blog(
                    resultSet.getInt("id"),
                    resultSet.getString("title"),
                    resultSet.getString("thumbnail"),
                    resultSet.getString("brief_info"),
                    resultSet.getString("content"),
                    resultSet.getInt("category_id"),
                    resultSet.getInt("author"),
                    resultSet.getTimestamp("updated_date"),
                    resultSet.getTimestamp("created_date"),
                    resultSet.getString("status")
                );
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    private boolean rsNext(ResultSet rs) throws SQLException {
        return rs != null && rs.next();
    }

    /**
     * Thêm mới một bài viết blog vào Database
     */
    public boolean insertBlog(Blog blog) {
        String sql = "INSERT INTO blog (title, thumbnail, brief_info, content, category_id, author, status, created_date, updated_date) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, blog.getTitle());
            statement.setString(2, blog.getThumbnail());
            statement.setString(3, blog.getBriefInfo());
            statement.setString(4, blog.getContent());
            if (blog.getCategoryId() > 0) {
                statement.setInt(5, blog.getCategoryId());
            } else {
                statement.setNull(5, java.sql.Types.INTEGER);
            }
            statement.setInt(6, blog.getAuthor());
            statement.setString(7, blog.getStatus() != null ? blog.getStatus() : "Active");

            int rows = statement.executeUpdate();
            if (rows > 0) {
                resultSet = statement.getGeneratedKeys();
                if (resultSet.next()) {
                    blog.setId(resultSet.getInt(1));
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
     * Lấy chi tiết một bài viết theo ID
     */
    public Blog getBlogById(int id) {
        String sql = "SELECT * FROM blog WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return new Blog(
                    resultSet.getInt("id"),
                    resultSet.getString("title"),
                    resultSet.getString("thumbnail"),
                    resultSet.getString("brief_info"),
                    resultSet.getString("content"),
                    resultSet.getInt("category_id"),
                    resultSet.getInt("author"),
                    resultSet.getTimestamp("updated_date"),
                    resultSet.getTimestamp("created_date"),
                    resultSet.getString("status")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    /**
     * Lấy danh sách bài viết của một tác giả cụ thể (Trang Quản lý bài viết cá nhân)
     */
    public List<Blog> getBlogsByAuthor(int authorId) {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT * FROM blog WHERE author = ? ORDER BY created_date DESC, id DESC";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, authorId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Blog b = new Blog(
                    resultSet.getInt("id"),
                    resultSet.getString("title"),
                    resultSet.getString("thumbnail"),
                    resultSet.getString("brief_info"),
                    resultSet.getString("content"),
                    resultSet.getInt("category_id"),
                    resultSet.getInt("author"),
                    resultSet.getTimestamp("updated_date"),
                    resultSet.getTimestamp("created_date"),
                    resultSet.getString("status")
                );
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    /**
     * Cập nhật thông tin bài viết
     */
    public boolean updateBlog(Blog blog) {
        String sql = "UPDATE blog SET title = ?, thumbnail = ?, brief_info = ?, content = ?, category_id = ?, status = ?, updated_date = NOW() "
                   + "WHERE id = ? AND author = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, blog.getTitle());
            statement.setString(2, blog.getThumbnail());
            statement.setString(3, blog.getBriefInfo());
            statement.setString(4, blog.getContent());
            if (blog.getCategoryId() > 0) {
                statement.setInt(5, blog.getCategoryId());
            } else {
                statement.setNull(5, java.sql.Types.INTEGER);
            }
            statement.setString(6, blog.getStatus() != null ? blog.getStatus() : "Active");
            statement.setInt(7, blog.getId());
            statement.setInt(8, blog.getAuthor());

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
     * Xóa một bài viết của tác giả
     */
    public boolean deleteBlog(int id, int authorId) {
        String sql = "DELETE FROM blog WHERE id = ? AND author = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            statement.setInt(2, authorId);
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
     * Lấy danh sách tất cả các danh mục bài viết (bảng blog_category)
     */
    public Map<Integer, String> getBlogCategories() {
        Map<Integer, String> map = new HashMap<>();
        String sql = "SELECT id, name FROM blog_category ORDER BY id ASC";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                map.put(resultSet.getInt("id"), resultSet.getString("name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return map;
    }
}