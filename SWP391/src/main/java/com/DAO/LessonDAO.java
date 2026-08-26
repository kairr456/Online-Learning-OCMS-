package com.DAO;

import com.entity.Lesson;
import com.entity.Section;
import java.sql.SQLException;
import java.sql.Statement;

public class LessonDAO extends DBContext {

    public int insertSection(Section section) {
        String sql = "INSERT INTO section (course_id, title, order_number) VALUES (?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, section.getCourseId());
            statement.setString(2, section.getTitle());
            statement.setInt(3, section.getOrderNumber());
            
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
        String sql = "INSERT INTO lesson (section_id, title, type, order_number, status) VALUES (?, ?, ?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, lesson.getSectionId());
            statement.setString(2, lesson.getTitle());
            statement.setString(3, lesson.getType());
            statement.setInt(4, lesson.getOrderNumber());
            statement.setString(5, lesson.getStatus());
            
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
<<<<<<< Updated upstream
=======
        DbTextValidator.validateLength(content, 5000, "Nội dung bài học dạng văn bản");

>>>>>>> Stashed changes
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
                lesson.setDescription(resultSet.getString("description"));
                lesson.setType(resultSet.getString("type"));
                lesson.setOrderNumber(resultSet.getInt("order_number"));
                lesson.setDurationMinutes(resultSet.getInt("duration_minutes"));
                lesson.setStatus(resultSet.getString("status"));
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

    public String getLessonFileUrl(int lessonId) {
        String sql = "SELECT file_url FROM lesson_file WHERE lesson_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString("file_url");
            }
        } catch (SQLException ex) {
            System.out.println("Error getting lesson file: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return "";
    }

    public void updateSection(Section section) {
        String sql = "UPDATE section SET title = ?, description = ?, order_number = ? WHERE id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setString(1, section.getTitle());
            statement.setString(2, section.getDescription());
            statement.setInt(3, section.getOrderNumber());
            statement.setInt(4, section.getId());
            statement.executeUpdate();
        } catch (SQLException ex) {
            System.out.println("Error updating section: " + ex.getMessage());
        } finally {
            closeResources();
        }
    }

    public void updateLesson(Lesson lesson) {
        String sql = "UPDATE lesson SET title = ?, type = ?, order_number = ? WHERE id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setString(1, lesson.getTitle());
            statement.setString(2, lesson.getType());
            statement.setInt(3, lesson.getOrderNumber());
            statement.setInt(4, lesson.getId());
            statement.executeUpdate();
        } catch (SQLException ex) {
            System.out.println("Error updating lesson: " + ex.getMessage());
        } finally {
            closeResources();
        }
    }

    public void upsertLessonVideo(int lessonId, String videoUrl) {
        String sqlCheck = "SELECT lesson_id FROM lesson_video WHERE lesson_id = ?";
        boolean exists = false;
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sqlCheck);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) exists = true;
        } catch (Exception e) {} finally { closeResources(); }
        
        if (exists) {
            String sqlUpdate = "UPDATE lesson_video SET video_url = ? WHERE lesson_id = ?";
            try {
                connection = new DBContext().connection;
                statement = connection.prepareStatement(sqlUpdate);
                statement.setString(1, videoUrl);
                statement.setInt(2, lessonId);
                statement.executeUpdate();
            } catch (Exception e) {} finally { closeResources(); }
        } else {
            insertLessonVideo(lessonId, videoUrl);
        }
    }

    public void upsertLessonFile(int lessonId, String fileUrl) {
        String sqlCheck = "SELECT lesson_id FROM lesson_file WHERE lesson_id = ?";
        boolean exists = false;
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sqlCheck);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) exists = true;
        } catch (Exception e) {} finally { closeResources(); }
        
        if (exists) {
            String sqlUpdate = "UPDATE lesson_file SET file_url = ? WHERE lesson_id = ?";
            try {
                connection = new DBContext().connection;
                statement = connection.prepareStatement(sqlUpdate);
                statement.setString(1, fileUrl);
                statement.setInt(2, lessonId);
                statement.executeUpdate();
            } catch (Exception e) {} finally { closeResources(); }
        } else {
            insertLessonFile(lessonId, fileUrl);
        }
    }

    public void upsertLessonText(int lessonId, String content) {
<<<<<<< Updated upstream
=======
        DbTextValidator.validateLength(content, 5000, "Nội dung bài học dạng văn bản");

>>>>>>> Stashed changes
        String sqlCheck = "SELECT lesson_id FROM lesson_text WHERE lesson_id = ?";
        boolean exists = false;
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sqlCheck);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) exists = true;
        } catch (Exception e) {} finally { closeResources(); }
        
        if (exists) {
            String sqlUpdate = "UPDATE lesson_text SET content = ? WHERE lesson_id = ?";
            try {
                connection = new DBContext().connection;
                statement = connection.prepareStatement(sqlUpdate);
                statement.setString(1, content);
                statement.setInt(2, lessonId);
                statement.executeUpdate();
            } catch (Exception e) {} finally { closeResources(); }
        } else {
            insertLessonText(lessonId, content);
        }
    }

    public void cleanupRemovedSectionsAndLessons(int courseId, java.util.List<Integer> keptSectionIds, java.util.List<Integer> keptLessonIds) {
        try {
            connection = new DBContext().connection;
            
            // 1. Find all lessons belonging to this course
            String getLessonsSql = "SELECT l.id FROM lesson l JOIN section s ON l.section_id = s.id WHERE s.course_id = ?";
            java.util.List<Integer> allCourseLessonIds = new java.util.ArrayList<>();
            statement = connection.prepareStatement(getLessonsSql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                allCourseLessonIds.add(resultSet.getInt("id"));
            }
            
            // 2. Delete lessons that are NOT in keptLessonIds
            for (int lid : allCourseLessonIds) {
                if (!keptLessonIds.contains(lid)) {
                    // Manual cascade deletes
                    try (java.sql.PreparedStatement ps = connection.prepareStatement("DELETE FROM lesson_text WHERE lesson_id = ?")) {
                        ps.setInt(1, lid); ps.executeUpdate();
                    }
                    try (java.sql.PreparedStatement ps = connection.prepareStatement("DELETE FROM lesson_video WHERE lesson_id = ?")) {
                        ps.setInt(1, lid); ps.executeUpdate();
                    }
                    try (java.sql.PreparedStatement ps = connection.prepareStatement("DELETE FROM lesson_quiz WHERE lesson_id = ?")) {
                        ps.setInt(1, lid); ps.executeUpdate();
                    }
                    try (java.sql.PreparedStatement ps = connection.prepareStatement("DELETE FROM lesson WHERE id = ?")) {
                        ps.setInt(1, lid); ps.executeUpdate();
                    }
                }
            }
            
            // 3. Find all sections belonging to this course
            String getSectionsSql = "SELECT id FROM section WHERE course_id = ?";
            java.util.List<Integer> allCourseSectionIds = new java.util.ArrayList<>();
            statement = connection.prepareStatement(getSectionsSql);
            statement.setInt(1, courseId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                allCourseSectionIds.add(resultSet.getInt("id"));
            }
            
            // 4. Delete sections that are NOT in keptSectionIds
            for (int sid : allCourseSectionIds) {
                if (!keptSectionIds.contains(sid)) {
                    try (java.sql.PreparedStatement ps = connection.prepareStatement("DELETE FROM section WHERE id = ?")) {
                        ps.setInt(1, sid); ps.executeUpdate();
                    }
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
    }

    public com.entity.LessonQuizz getLessonQuizConfig(int lessonId) {
        String sql = "SELECT * FROM lesson_quiz WHERE lesson_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                com.entity.LessonQuizz q = new com.entity.LessonQuizz();
                q.setId(resultSet.getInt("id"));
                q.setLessonId(resultSet.getInt("lesson_id"));
                q.setNumberOfQuestions(resultSet.getInt("number_of_questions"));
                q.setTimeLimitMinutes(resultSet.getInt("time_limit_minutes"));
                q.setMaxRetakes(resultSet.getInt("max_retakes"));
                q.setPassingScore(resultSet.getInt("passing_score"));
                q.setQuestionGroupId(resultSet.getInt("question_group_id"));
                return q;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    public void upsertLessonQuiz(int lessonId, int numQuestions, int timeLimit, int maxRetakes, int passScore, int groupId) {
        String checkSql = "SELECT id FROM lesson_quiz WHERE lesson_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(checkSql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                String upSql = "UPDATE lesson_quiz SET number_of_questions=?, time_limit_minutes=?, max_retakes=?, passing_score=?, question_group_id=? WHERE lesson_id=?";
                java.sql.PreparedStatement ps = connection.prepareStatement(upSql);
                ps.setInt(1, numQuestions);
                ps.setInt(2, timeLimit);
                ps.setInt(3, maxRetakes);
                ps.setInt(4, passScore);
                ps.setInt(5, groupId);
                ps.setInt(6, lessonId);
                ps.executeUpdate();
                ps.close();
            } else {
                String inSql = "INSERT INTO lesson_quiz (lesson_id, number_of_questions, time_limit_minutes, max_retakes, passing_score, question_group_id) VALUES (?, ?, ?, ?, ?, ?)";
                java.sql.PreparedStatement ps = connection.prepareStatement(inSql);
                ps.setInt(1, lessonId);
                ps.setInt(2, numQuestions);
                ps.setInt(3, timeLimit);
                ps.setInt(4, maxRetakes);
                ps.setInt(5, passScore);
                ps.setInt(6, groupId);
                ps.executeUpdate();
                ps.close();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            closeResources();
        }
    }
}
