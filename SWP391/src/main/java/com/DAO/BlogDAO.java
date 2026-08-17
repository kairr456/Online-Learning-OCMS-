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
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Blog b = new Blog(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("thumbnail"),
                    rs.getString("brief_info"),
                    rs.getString("content"),
                    rs.getInt("category_id"),
                    rs.getInt("author"),
                    rs.getTimestamp("updated_date"),
                    rs.getTimestamp("created_date"),
                    rs.getString("status")
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
     * Thêm mới một bài viết blog vào Database
     */
    public boolean insertBlog(Blog blog) {
        String sql = "INSERT INTO blog (title, thumbnail, brief_info, content, category_id, author, status, created_date, updated_date) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try {
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
     * Lấy danh sách tất cả các danh mục bài viết (bảng blog_category)
     */
    public Map<Integer, String> getBlogCategories() {
        Map<Integer, String> map = new HashMap<>();
        String sql = "SELECT id, name FROM blog_category ORDER BY id ASC";
        try {
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