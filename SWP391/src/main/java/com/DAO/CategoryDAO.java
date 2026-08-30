package com.DAO;

import com.entity.Category;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class CategoryDAO extends DBContext implements I_DAO<Category> {

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

    public CategoryDAO() {
        super();
        ensureTableStructure();
    }

    private void ensureTableStructure() {
        Statement st = null;
        try {
            Connection conn = getConnection();
            if (conn != null) {
                st = conn.createStatement();
                try {
                    st.executeUpdate("ALTER TABLE category ADD COLUMN is_deleted TINYINT(1) NOT NULL DEFAULT 0");
                } catch (Exception ignored) {}
                try {
                    st.executeUpdate("ALTER TABLE category ADD COLUMN description TEXT DEFAULT NULL");
                } catch (Exception ignored) {}
                try {
                    st.executeUpdate("ALTER TABLE category ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
                } catch (Exception ignored) {}
                try {
                    st.executeUpdate("ALTER TABLE category ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP");
                } catch (Exception ignored) {}
            }
        } catch (Exception ignored) {
        } finally {
            if (st != null) {
                try { st.close(); } catch (Exception ignored) {}
            }
        }
    }

    @Override
    public List<Category> findAll() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM category WHERE (is_deleted = 0 OR is_deleted IS NULL) ORDER BY name ASC";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                categories.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error in findAll categories: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return categories;
    }

    public List<Category> searchCourseCategories(String keyword, int page, int pageSize) {
        List<Category> list = new ArrayList<>();
        int offset = Math.max(0, (page - 1) * pageSize);
        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());

        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.name, c.description, c.created_at, c.updated_at, "
                + "       (SELECT COUNT(*) FROM course cr WHERE cr.category_id = c.id) AS course_count "
                + "FROM category c "
                + "WHERE (c.is_deleted = 0 OR c.is_deleted IS NULL) "
        );

        if (hasKeyword) {
            sql.append("AND (c.name LIKE ? OR c.description LIKE ?) ");
        }
        sql.append("ORDER BY c.id DESC LIMIT ? OFFSET ?");

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            int idx = 1;
            if (hasKeyword) {
                String kw = "%" + keyword.trim() + "%";
                statement.setString(idx++, kw);
                statement.setString(idx++, kw);
            }
            statement.setInt(idx++, pageSize);
            statement.setInt(idx, offset);

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Category cat = getFromResultSet(resultSet);
                try {
                    cat.setCourseCount(resultSet.getInt("course_count"));
                } catch (Exception ignored) {}
                list.add(cat);
            }
        } catch (SQLException ex) {
            System.out.println("Error searching course categories: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return list;
    }

    public int countCourseCategories(String keyword) {
        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM category WHERE (is_deleted = 0 OR is_deleted IS NULL) "
        );
        if (hasKeyword) {
            sql.append("AND (name LIKE ? OR description LIKE ?)");
        }

        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql.toString());
            if (hasKeyword) {
                String kw = "%" + keyword.trim() + "%";
                statement.setString(1, kw);
                statement.setString(2, kw);
            }
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            System.out.println("Error counting course categories: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    public int countCoursesByCategoryId(int categoryId) {
        String sql = "SELECT COUNT(*) FROM course WHERE category_id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, categoryId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            System.out.println("Error counting courses by category ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    public boolean isCategoryNameExists(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM category WHERE LOWER(name) = LOWER(?) AND (is_deleted = 0 OR is_deleted IS NULL) AND id != ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, name.trim());
            statement.setInt(2, excludeId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            System.out.println("Error checking category name exists: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    @Override
    public boolean update(Category category) {
        String sql = "UPDATE category SET name = ?, description = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, category.getName());
            statement.setString(2, category.getDescription());
            statement.setInt(3, category.getId());
            
            int affectedRows = statement.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating category: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public int insert(Category category) {
        String sql = "INSERT INTO category (name, description, is_deleted) VALUES (?, ?, 0)";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, category.getName());
            statement.setString(2, category.getDescription());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                return -1;
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting category: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return -1;
    }

    @Override
    public boolean delete(Category category) {
        return deleteCourseCategory(category.getId());
    }

    public boolean deleteCourseCategory(int id) {
        String sql = "UPDATE category SET is_deleted = 1 WHERE id = ?";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error soft-deleting course category: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public Category getFromResultSet(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setId(rs.getInt("id"));
        category.setName(rs.getString("name"));
        try {
            category.setDescription(rs.getString("description"));
        } catch (Exception ignored) {}
        try {
            category.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (Exception ignored) {}
        try {
            category.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (Exception ignored) {}
        try {
            category.setDeleted(rs.getBoolean("is_deleted"));
        } catch (Exception ignored) {}
        return category;
    }

    public Category findById(int categoryId) {
        String sql = "SELECT * FROM category WHERE id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, categoryId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding category by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public Category findByName(String categoryName) {
        String sql = "SELECT * FROM category WHERE LOWER(name) = LOWER(?) AND (is_deleted = 0 OR is_deleted IS NULL)";
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            statement.setString(1, categoryName);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding category by name: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public Map<Integer, String> findNames(Set<Integer> categoryIds) {
        Map<Integer, String> categoryNames = new HashMap<>();
        if (categoryIds == null || categoryIds.isEmpty()) {
            return categoryNames;
        }

        String sql = "SELECT id, name FROM category WHERE id IN (" + 
                    String.join(",", Collections.nCopies(categoryIds.size(), "?")) + ")";
        
        try {
            connection = getConnection();
            statement = connection.prepareStatement(sql);
            int index = 1;
            for (Integer id : categoryIds) {
                statement.setInt(index++, id);
            }
            
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                categoryNames.put(resultSet.getInt("id"), resultSet.getString("name"));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding category names: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return categoryNames;
    }

    public String getCategoryName(int categoryId) {
        Category category = findById(categoryId);
        return category != null ? category.getName() : null;
    }
}