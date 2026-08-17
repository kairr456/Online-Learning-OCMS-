package com.DAO;

import com.entity.Lesson;
import com.entity.Section;
import java.sql.SQLException;
import java.sql.Statement;

public class LessonDAO extends DBContext {

    public int insertSection(Section section) {
        String sql = "INSERT INTO section (course_id, title, description, order_number, status) VALUES (?, ?, ?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, section.getCourseId());
            statement.setString(2, section.getTitle());
            statement.setString(3, section.getDescription());
            statement.setInt(4, section.getOrderNumber());
            statement.setString(5, section.getStatus());
            
            int affected = statement.executeUpdate();
            if (affected > 0) {
                resultSet = statement.getGeneratedKeys();
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting section: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return -1;
    }

    public int insertLesson(Lesson lesson) {
        String sql = "INSERT INTO lesson (section_id, title, type, order_number, duration_minutes, status) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, lesson.getSectionId());
            statement.setString(2, lesson.getTitle());
            statement.setString(3, lesson.getType());
            statement.setInt(4, lesson.getOrderNumber());
            statement.setInt(5, lesson.getDurationMinutes());
            statement.setString(6, lesson.getStatus());
            
            int affected = statement.executeUpdate();
            if (affected > 0) {
                resultSet = statement.getGeneratedKeys();
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting lesson: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return -1;
    }

    public void insertLessonVideo(int lessonId, String videoUrl) {
        String sql = "INSERT INTO lesson_video (lesson_id, video_url, video_provider) VALUES (?, ?, 'youtube')";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            statement.setString(2, videoUrl);
            statement.executeUpdate();
        } catch (SQLException ex) {
            System.out.println("Error inserting lesson_video: " + ex.getMessage());
        } finally {
            closeResources();
        }
    }

    public void insertLessonFile(int lessonId, String fileUrl) {
        String sql = "INSERT INTO lesson_file (lesson_id, file_url) VALUES (?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            statement.setString(2, fileUrl);
            statement.executeUpdate();
        } catch (SQLException ex) {
            System.out.println("Error inserting lesson_file: " + ex.getMessage());
        } finally {
            closeResources();
        }
    }

    public void insertLessonText(int lessonId, String content) {
        String sql = "INSERT INTO lesson_text (lesson_id, content) VALUES (?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            statement.setString(2, content);
            statement.executeUpdate();
        } catch (SQLException ex) {
            System.out.println("Error inserting lesson_text: " + ex.getMessage());
        } finally {
            closeResources();
        }
    }

    public java.util.List<Section> getSectionsByCourseId(int courseId) {
        java.util.List<Section> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM section WHERE course_id = ? ORDER BY order_number";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Section s = new Section();
                s.setId(resultSet.getInt("id"));
                s.setCourseId(resultSet.getInt("course_id"));
                s.setTitle(resultSet.getString("title"));
                s.setOrderNumber(resultSet.getInt("order_number"));
                list.add(s);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    public java.util.List<Lesson> getLessonsBySectionId(int sectionId) {
        java.util.List<Lesson> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM lesson WHERE section_id = ? ORDER BY order_number";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, sectionId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Lesson l = new Lesson();
                l.setId(resultSet.getInt("id"));
                l.setSectionId(resultSet.getInt("section_id"));
                l.setTitle(resultSet.getString("title"));
                l.setType(resultSet.getString("type"));
                l.setOrderNumber(resultSet.getInt("order_number"));
                list.add(l);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    public int getCourseIdBySectionId(int sectionId) {
        String sql = "SELECT course_id FROM section WHERE id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, sectionId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("course_id");
            }
        } catch (java.sql.SQLException ex) {
            System.out.println("Error getting course id: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return -1;
    }

    public String getLessonYoutube(int lessonId) {
        String url = "";
        String sql = "SELECT video_url FROM lesson_video WHERE lesson_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                url = resultSet.getString("video_url");
            }
        } catch (Exception ex) {} finally { closeResources(); }
        return url;
    }

    public Lesson getLessonById(int lessonId) {
        String sql = "SELECT * FROM lesson WHERE id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                Lesson lesson = new Lesson();
                lesson.setId(resultSet.getInt("id"));
                lesson.setSectionId(resultSet.getInt("section_id"));
                lesson.setTitle(resultSet.getString("title"));
                lesson.setType(resultSet.getString("type"));
                lesson.setOrderNumber(resultSet.getInt("order_number"));
                return lesson;
            }
        } catch (SQLException ex) {
            System.out.println("Error getting lesson: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public String getLessonText(int lessonId) {
        String sql = "SELECT content FROM lesson_text WHERE lesson_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString("content");
            }
        } catch (SQLException ex) {
            System.out.println("Error getting lesson text: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return "";
    }
}
