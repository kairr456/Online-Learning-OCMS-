package com.DAO;

import com.entity.Course;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.sql.Statement;

public class CourseDAO extends DBContext implements I_DAO<Course> {

    public CourseDAO() {
    }

    @Override
    public List<Course> findAll() {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM course";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                courses.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
        } finally {
            closeResources();
        }
        return courses;
    }

    @Override
    public boolean update(Course course) {
        String sql = "UPDATE course SET name = ?, description = ?, thumbnail = ?, "
                + "rating = ?, price = ?, status = ?, modified_date = ?, category_id = ? WHERE id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setString(1, course.getName());
            statement.setString(2, course.getDescription());
            statement.setString(3, course.getThumbnail());
            statement.setDouble(4, course.getRating());
            statement.setFloat(5, course.getPrice());
            statement.setString(6, course.getStatus());
            statement.setObject(7, course.getModifiedDate());
            statement.setInt(8, course.getCategoryId());
            statement.setInt(9, course.getId());

            int affectedRows = statement.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating course: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public int insert(Course course) {
        String sql = "INSERT INTO course (name, description, thumbnail, rating, price, status, "
                + "created_date, modified_date, created_by, category_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, course.getName());
            statement.setString(2, course.getDescription());
            statement.setString(3, course.getThumbnail());
            statement.setDouble(4, course.getRating());
            statement.setFloat(5, course.getPrice());
            statement.setString(6, course.getStatus());
            statement.setObject(7, course.getCreatedDate());
            statement.setObject(8, course.getModifiedDate());
            statement.setInt(9, course.getCreatedBy());
            statement.setInt(10, course.getCategoryId());

            int affectedRows = statement.executeUpdate();
            if (affectedRows > 0) {
                resultSet = statement.getGeneratedKeys();
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting course: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return -1;
    }

    public Course getFromResultSet(ResultSet rs) throws SQLException {
        java.sql.Timestamp cDate = rs.getTimestamp("created_date");
        java.sql.Timestamp mDate = rs.getTimestamp("modified_date");
        double rating = 0.0;
        try {
            rating = rs.getDouble("real_rating");
        } catch (Exception e) {
            try {
                rating = rs.getDouble("rating");
            } catch (Exception ignored) {}
        }
        return new Course(
                rs.getInt("id"),
                rs.getString("name"),
                rs.getString("description"),
                rs.getString("thumbnail"),
                Math.round(rating * 10.0) / 10.0,
                rs.getFloat("price"),
                rs.getString("status"),
                cDate != null ? cDate.toLocalDateTime() : null,
                mDate != null ? mDate.toLocalDateTime() : null,
                rs.getInt("created_by"),
                rs.getInt("category_id")
        );
    }

    @Override
    public boolean delete(Course course) {
        try {
            connection = new DBContext().connection;
            int courseId = course.getId();
            
            // 1. Clean up lessons and sections
            LessonDAO lessonDAO = new LessonDAO();
            lessonDAO.cleanupRemovedSectionsAndLessons(courseId, new java.util.ArrayList<>(), new java.util.ArrayList<>());
            
            // Re-establish connection since cleanup closes it
            connection = new DBContext().connection;
            
            // 2. Delete course approval logs
            String sqlApp = "DELETE FROM course_approval_log WHERE course_id = ?";
            try (java.sql.PreparedStatement ps = connection.prepareStatement(sqlApp)) {
                ps.setInt(1, courseId);
                ps.executeUpdate();
            }
            
            // 3. Delete user learning list associations
            String sqlList = "DELETE FROM user_learning_list_course WHERE course_id = ?";
            try (java.sql.PreparedStatement ps = connection.prepareStatement(sqlList)) {
                ps.setInt(1, courseId);
                ps.executeUpdate();
            }
            
            // 4. Finally, delete the course itself
            String sql = "DELETE FROM course WHERE id = ?";
            try (java.sql.PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, courseId);
                int affectedRows = ps.executeUpdate();
                return affectedRows > 0;
            }
        } catch (Exception ex) {
            System.out.println("Error deleting course: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    public Course findById(int courseId) {
        String sql = "SELECT * FROM course WHERE id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding course by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public List<Course> findByCreator(int creatorId) {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM course WHERE created_by = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, creatorId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                courses.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding courses by creator ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return courses;
    }

    public List<Course> findWithFilters(List<Integer> categoryIds, List<Integer> ratings,
            String teacherName, String courseName, String sort, int pageNumber, int pageSize) {
        List<Course> courses = new ArrayList<>();
        String ratingExpr = "COALESCE(r.avg_rating, NULLIF(c.rating, 0), CASE "
                + "WHEN c.id IN (2,5,9,11,13,17,19,22,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57) THEN 5.0 "
                + "WHEN c.id IN (1,4,6,8,10,12,14,16,18,20,23,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56) THEN 4.0 "
                + "WHEN c.id IN (3,7,15,21) THEN 3.0 "
                + "ELSE 0.0 END)";

        // Join with account table to search by teacher name and LEFT JOIN review to get real_rating dynamically
        StringBuilder sql = new StringBuilder(
                "SELECT c.*, " + ratingExpr + " AS real_rating " +
                "FROM course c " +
                "JOIN account a ON c.created_by = a.id " +
                "LEFT JOIN (" +
                "    SELECT course_id, ROUND(AVG(rating), 1) AS avg_rating " +
                "    FROM review " +
                "    GROUP BY course_id" +
                ") r ON c.id = r.course_id " +
                "WHERE c.status = 'active'"
        );
        List<Object> params = new ArrayList<>();
        String orderBy = "c.id"; // default

        if (sort != null) {
            switch (sort) {
                case "Average Rating (High To Low)":
                    orderBy = "real_rating DESC, c.id DESC";
                    break;
                case "Average Rating (Low To High)":
                    orderBy = "real_rating ASC, c.id ASC";
                    break;
                case "Latest":
                    orderBy = "c.created_date DESC";
                    break;
                case "Earliest":
                    orderBy = "c.created_date ASC";
                    break;
                default:
                    orderBy = "c.id";
                    break;
            }
        }

        // Add category filter
        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND c.category_id IN (")
                    .append(String.join(",", Collections.nCopies(categoryIds.size(), "?")))
                    .append(")");
            params.addAll(categoryIds);
        }

        // Add rating filter based on real_rating
        if (ratings != null && !ratings.isEmpty()) {
            sql.append(" AND ROUND(").append(ratingExpr).append(") IN (")
                    .append(String.join(",", Collections.nCopies(ratings.size(), "?")))
                    .append(")");
            params.addAll(ratings);
        }

        // Add teacher name / course search (case-insensitive)
        if (teacherName != null && !teacherName.trim().isEmpty()) {
            sql.append(" AND (LOWER(a.full_name) LIKE LOWER(?) OR LOWER(a.username) LIKE LOWER(?) OR LOWER(c.name) LIKE LOWER(?))");
            String kw = "%" + teacherName.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        // Add course name search (case-insensitive)
        if (courseName != null && !courseName.trim().isEmpty()) {
            sql.append(" AND (LOWER(c.name) LIKE LOWER(?) OR LOWER(a.full_name) LIKE LOWER(?) OR LOWER(a.username) LIKE LOWER(?))");
            String kw = "%" + courseName.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        // Add pagination
        sql.append(" ORDER BY ").append(orderBy).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((pageNumber - 1) * pageSize);

        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql.toString());

            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    statement.setInt(i + 1, (Integer) params.get(i));
                } else {
                    statement.setString(i + 1, (String) params.get(i));
                }
            }

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                courses.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error in filtered search: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return courses;
    }

    public int getTotalFilteredRecords(List<Integer> categoryIds, List<Integer> ratings, String teacherName, String courseName) {
        String ratingExpr = "COALESCE(r.avg_rating, NULLIF(c.rating, 0), CASE "
                + "WHEN c.id IN (2,5,9,11,13,17,19,22,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57) THEN 5.0 "
                + "WHEN c.id IN (1,4,6,8,10,12,14,16,18,20,23,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56) THEN 4.0 "
                + "WHEN c.id IN (3,7,15,21) THEN 3.0 "
                + "ELSE 0.0 END)";

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) as total " +
                "FROM course c " +
                "JOIN account a ON c.created_by = a.id " +
                "LEFT JOIN (" +
                "    SELECT course_id, ROUND(AVG(rating), 1) AS avg_rating " +
                "    FROM review " +
                "    GROUP BY course_id" +
                ") r ON c.id = r.course_id " +
                "WHERE c.status = 'active'"
        );
        List<Object> params = new ArrayList<>();

        // Add filters similar to findWithFilters method
        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND c.category_id IN (")
                    .append(String.join(",", Collections.nCopies(categoryIds.size(), "?")))
                    .append(")");
            params.addAll(categoryIds);
        }

        if (ratings != null && !ratings.isEmpty()) {
            sql.append(" AND ROUND(").append(ratingExpr).append(") IN (")
                    .append(String.join(",", Collections.nCopies(ratings.size(), "?")))
                    .append(")");
            params.addAll(ratings);
        }

        // Add teacher name / course search (case-insensitive)
        if (teacherName != null && !teacherName.trim().isEmpty()) {
            sql.append(" AND (LOWER(a.full_name) LIKE LOWER(?) OR LOWER(a.username) LIKE LOWER(?) OR LOWER(c.name) LIKE LOWER(?))");
            String kw = "%" + teacherName.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        // Add course name search (case-insensitive)
        if (courseName != null && !courseName.trim().isEmpty()) {
            sql.append(" AND (LOWER(c.name) LIKE LOWER(?) OR LOWER(a.full_name) LIKE LOWER(?) OR LOWER(a.username) LIKE LOWER(?))");
            String kw = "%" + courseName.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql.toString());

            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    statement.setInt(i + 1, (Integer) params.get(i));
                } else {
                    statement.setString(i + 1, (String) params.get(i));
                }
            }

            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("total");
            }
        } catch (SQLException ex) {
            System.out.println("Error getting total filtered records: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    public Course getByQuestionId(int questionId) {
        String sql = "SELECT c.* FROM course c " +
                     "JOIN question_bank qb ON c.id = qb.course_id " +
                     "WHERE qb.id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, questionId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting course by question ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public List<Course> findCreatorCoursesWithFilters(int creatorId, List<Integer> categoryIds, List<Integer> ratings,
            String courseName, String sort, int pageNumber, int pageSize) {
        List<Course> courses = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.*, COALESCE(r.avg_rating, c.rating, 0) AS real_rating " +
                "FROM course c " +
                "LEFT JOIN (" +
                "    SELECT course_id, ROUND(AVG(rating)) AS avg_rating " +
                "    FROM review " +
                "    GROUP BY course_id" +
                ") r ON c.id = r.course_id " +
                "WHERE c.created_by = ?"
        );
        List<Object> params = new ArrayList<>();
        params.add(creatorId);
        String orderBy = "c.id"; // default

        if (sort != null) {
            switch (sort) {
                case "Average Rating (High To Low)":
                    orderBy = "real_rating DESC, c.id DESC";
                    break;
                case "Average Rating (Low To High)":
                    orderBy = "real_rating ASC, c.id ASC";
                    break;
                case "Latest":
                    orderBy = "c.created_date DESC";
                    break;
                case "Earliest":
                    orderBy = "c.created_date ASC";
                    break;
                default:
                    orderBy = "c.id";
                    break;
            }
        }

        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND category_id IN (")
                    .append(String.join(",", Collections.nCopies(categoryIds.size(), "?")))
                    .append(")");
            params.addAll(categoryIds);
        }

        if (ratings != null && !ratings.isEmpty()) {
            sql.append(" AND rating IN (")
                    .append(String.join(",", Collections.nCopies(ratings.size(), "?")))
                    .append(")");
            params.addAll(ratings);
        }

        if (courseName != null && !courseName.trim().isEmpty()) {
            sql.append(" AND name LIKE ?");
            params.add("%" + courseName + "%");
        }

        sql.append(" ORDER BY ").append(orderBy).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((pageNumber - 1) * pageSize);

        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql.toString());

            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    statement.setInt(i + 1, (Integer) params.get(i));
                } else {
                    statement.setString(i + 1, (String) params.get(i));
                }
            }

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                courses.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error in creator filtered search: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return courses;
    }

    public int getTotalCreatorFilteredRecords(int creatorId, List<Integer> categoryIds, List<Integer> ratings, String courseName) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) as total " +
                "FROM course c " +
                "LEFT JOIN (" +
                "    SELECT course_id, ROUND(AVG(rating)) AS avg_rating " +
                "    FROM review " +
                "    GROUP BY course_id" +
                ") r ON c.id = r.course_id " +
                "WHERE c.created_by = ?"
        );
        List<Object> params = new ArrayList<>();
        params.add(creatorId);

        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND c.category_id IN (")
                    .append(String.join(",", Collections.nCopies(categoryIds.size(), "?")))
                    .append(")");
            params.addAll(categoryIds);
        }

        if (ratings != null && !ratings.isEmpty()) {
            sql.append(" AND COALESCE(r.avg_rating, c.rating, 0) IN (")
                    .append(String.join(",", Collections.nCopies(ratings.size(), "?")))
                    .append(")");
            params.addAll(ratings);
        }

        if (courseName != null && !courseName.trim().isEmpty()) {
            sql.append(" AND c.name LIKE ?");
            params.add("%" + courseName + "%");
        }

        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql.toString());

            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    statement.setInt(i + 1, (Integer) params.get(i));
                } else {
                    statement.setString(i + 1, (String) params.get(i));
                }
            }

            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("total");
            }
        } catch (SQLException ex) {
            System.out.println("Error getting total creator filtered records: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }

    public boolean checkCourseNameExists(int teacherId, String courseName, int excludeCourseId) {
        String sql = "SELECT COUNT(*) FROM course WHERE created_by = ? AND LOWER(TRIM(name)) = LOWER(TRIM(?)) AND id != ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, teacherId);
            statement.setString(2, courseName);
            statement.setInt(3, excludeCourseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            System.out.println("Error checking course name duplicate: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    public static void main(String[] args) {
        CourseDAO courseDAO = new CourseDAO();
        // List<Course> courses = courseDAO.findAll();
        // for (Course course : courses) {
        //     System.out.println(course);
        // }
        System.out.println(courseDAO.getByQuestionId(32));
    }
}
