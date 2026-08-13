package com.DAO;

import com.entity.Blog;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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
        }
        return list;
    }
}