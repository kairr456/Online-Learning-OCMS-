package com.DAO;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.entity.QuizQuestion;
import com.validator.DbTextValidator;

public class QuizDAO extends DBContext {

    // 1. Get KPI Summary
    public Map<String, Object> getQuizSummary(int teacherId) {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalQuizzes", 0);
        summary.put("totalQuestions", 0);
        summary.put("totalAttempts", 0);
        summary.put("passRate", 0.0);

            String sql = "SELECT " +
                     "  COUNT(DISTINCT lq.id) AS total_quizzes, " +
                     "  COUNT(DISTINCT qb.id) AS total_questions, " +
                     "  COUNT(DISTINCT qa.id) AS total_attempts, " +
                     "  COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.id ELSE NULL END) AS passed_attempts " +
                     "FROM lesson l " +
                     "JOIN lesson_quiz lq ON l.id = lq.lesson_id " +
                     "LEFT JOIN section s ON l.section_id = s.id " +
                     "LEFT JOIN course c ON s.course_id = c.id " +
                     "LEFT JOIN question_bank qb ON lq.question_group_id = qb.group_id " +
                     "LEFT JOIN quiz_attempt qa ON lq.id = qa.quiz_id " +
                     "WHERE (l.created_by = ? OR c.created_by = ?) AND l.type = 'quiz' AND c.status = 'active'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ps.setInt(2, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalAttempts = rs.getInt("total_attempts");
                    int passedAttempts = rs.getInt("passed_attempts");
                    double passRate = totalAttempts > 0 ? ((double) passedAttempts / totalAttempts) * 100 : 0.0;

                    summary.put("totalQuizzes", rs.getInt("total_quizzes"));
                    summary.put("totalQuestions", rs.getInt("total_questions"));
                    summary.put("totalAttempts", totalAttempts);
                    summary.put("passRate", Math.round(passRate * 10.0) / 10.0);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return summary;
    }

    // 2. Get Quiz Data Table List
    public List<Map<String, Object>> getQuizzesByTeacher(int teacherId, String search, String courseId, String status) {
        List<Map<String, Object>> quizzes = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT lq.id AS quiz_id, l.title AS lesson_title, c.name AS course_name, " +
            "l.duration_minutes, l.status, " +
            "lq.passing_score, " +
            "COUNT(DISTINCT qb.id) AS question_count, " +
            "COUNT(DISTINCT qa.id) AS attempts_count " +
            "FROM lesson l " +
            "JOIN lesson_quiz lq ON l.id = lq.lesson_id " +
            "LEFT JOIN section s ON l.section_id = s.id " +
            "LEFT JOIN course c ON s.course_id = c.id " +
            "LEFT JOIN question_bank qb ON lq.question_group_id = qb.group_id " +
            "LEFT JOIN quiz_attempt qa ON lq.id = qa.quiz_id " +
            "WHERE (l.created_by = ? OR c.created_by = ?) AND l.type = 'quiz' AND c.status = 'active' "
        );

        List<Object> params = new ArrayList<>();
        params.add(teacherId);
        params.add(teacherId);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND l.title LIKE ?");
            params.add("%" + search.trim() + "%");
        }
        if (courseId != null && !courseId.isEmpty() && !"-1".equals(courseId)) {
            sql.append(" AND c.id = ?");
            params.add(Integer.parseInt(courseId));
        }
        if (status != null && !status.isEmpty() && !"-1".equals(status)) {
            sql.append(" AND l.status = ?");
            params.add(status);
        }

        sql.append(" GROUP BY lq.id, l.title, c.name, l.duration_minutes, l.status, lq.passing_score ORDER BY lq.id DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> q = new HashMap<>();
                    q.put("quiz_id", rs.getInt("quiz_id"));
                    q.put("lesson_title", rs.getString("lesson_title"));
                    q.put("course_name", rs.getString("course_name"));
                    q.put("duration_minutes", rs.getInt("duration_minutes"));
                    q.put("status", rs.getString("status"));
                    q.put("question_count", rs.getInt("question_count"));
                    q.put("attempts_count", rs.getInt("attempts_count"));
                    q.put("passing_score", rs.getInt("passing_score"));
                    quizzes.add(q);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return quizzes;
    }

    // 3. Get Recent Attempts
    public List<Map<String, Object>> getRecentAttempts(int teacherId, int limit) {
        List<Map<String, Object>> attempts = new ArrayList<>();
        
        String sql = "SELECT qa.id, acc.full_name AS student_name, acc.username, l.title AS quiz_name, " +
                     "qa.score, qa.passed, qa.end_time " +
                     "FROM quiz_attempt qa " +
                     "JOIN account acc ON qa.account_id = acc.id " +
                     "JOIN lesson_quiz lq ON qa.quiz_id = lq.id " +
                     "JOIN lesson l ON lq.lesson_id = l.id " +
                     "LEFT JOIN section s ON l.section_id = s.id " +
                     "LEFT JOIN course c ON s.course_id = c.id " +
                     "WHERE (l.created_by = ? OR c.created_by = ?) AND c.status = 'active' " +
                     "ORDER BY qa.end_time DESC LIMIT ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ps.setInt(2, teacherId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> a = new HashMap<>();
                    a.put("id", rs.getInt("id"));
                    String studentName = rs.getString("student_name");
                    if (studentName == null || studentName.trim().isEmpty()) {
                        studentName = rs.getString("username");
                    }
                    a.put("student_name", studentName);
                    a.put("quiz_name", rs.getString("quiz_name"));
                    a.put("score", rs.getDouble("score"));
                    a.put("passed", rs.getInt("passed") == 1);
                    a.put("end_time", rs.getTimestamp("end_time"));
                    attempts.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attempts;
    }

    // 4. Create new Quiz (Lesson)
    public int insertQuizLesson(com.entity.Lesson lesson, int createdBy) {
        DbTextValidator.validateLength(lesson.getTitle(), 255, "Tiêu đề bài học");
        DbTextValidator.validateLength(lesson.getDescription(), 65535, "Mô tả bài học");
        DbTextValidator.validateLength(lesson.getStatus(), 20, "Trạng thái bài học");

        int lessonId = -1;
        String sql = "";
        
        if (lesson.getSectionId() == 0) {
            sql = "INSERT INTO lesson (title, description, type, order_number, duration_minutes, status, created_by) " +
                  "VALUES (?, ?, 'quiz', ?, ?, ?, ?)";
        } else {
            sql = "INSERT INTO lesson (section_id, title, description, type, order_number, duration_minutes, status, created_by) " +
                  "VALUES (?, ?, ?, 'quiz', ?, ?, ?, ?)";
        }
        
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            int paramIdx = 1;
            if (lesson.getSectionId() != 0) {
                ps.setInt(paramIdx++, lesson.getSectionId());
            }
            ps.setString(paramIdx++, lesson.getTitle());
            ps.setString(paramIdx++, lesson.getDescription());
            ps.setInt(paramIdx++, lesson.getOrderNumber());
            ps.setInt(paramIdx++, lesson.getDurationMinutes());
            ps.setString(paramIdx++, lesson.getStatus());
            ps.setInt(paramIdx++, createdBy);
            
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    lessonId = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lessonId;
    }

    // 5. Create Lesson_Quiz mapping with passing_score and max_retakes
    public int insertLessonQuiz(int lessonId, int passingScore, int maxRetakes) throws SQLException {
        String sql = "INSERT INTO lesson_quiz (lesson_id, passing_score, max_retakes) VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, lessonId);
            ps.setInt(2, passingScore);
            ps.setInt(3, maxRetakes);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    // 6. Insert Quiz Question
    public int insertQuizQuestion(int quizId, String text, int points, int order) throws SQLException {
        DbTextValidator.validateLength(text, 10000000, "Nội dung câu hỏi");

        // Find course_id and lesson_id
        int courseId = 0;
        int lessonId = 0;
        String getInfoSql = "SELECT lq.lesson_id, c.id as course_id FROM lesson_quiz lq " +
                            "JOIN lesson l ON lq.lesson_id = l.id " +
                            "LEFT JOIN section s ON l.section_id = s.id " +
                            "LEFT JOIN course c ON s.course_id = c.id " +
                            "WHERE lq.id = ?";
        try (PreparedStatement psInfo = connection.prepareStatement(getInfoSql)) {
            psInfo.setInt(1, quizId);
            try (ResultSet rsInfo = psInfo.executeQuery()) {
                if (rsInfo.next()) {
                    courseId = rsInfo.getInt("course_id");
                    lessonId = rsInfo.getInt("lesson_id");
                }
            }
        }
        
        String sql = "INSERT INTO question_bank (course_id, lesson_id, question_text, points, status) VALUES (?, ?, ?, ?, 'active')";
        try (PreparedStatement ps = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            if (courseId > 0) {
                ps.setInt(1, courseId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            if (lessonId > 0) {
                ps.setInt(2, lessonId);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, text);
            ps.setInt(4, points);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    // 7. Insert Quiz Answer
    public void insertQuizAnswer(int questionId, String text, boolean isCorrect, int order) throws SQLException {
        String sql = "INSERT INTO question_bank_answer (question_bank_id, answer_text, is_correct) VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            ps.setString(2, text);
            ps.setBoolean(3, isCorrect);
            ps.executeUpdate();
        }
    }

    public Map<String, Object> getLessonQuizByLessonId(int lessonId) {
        String sql = "SELECT * FROM lesson_quiz WHERE lesson_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("passing_score", rs.getInt("passing_score"));
                    map.put("max_retakes", rs.getInt("max_retakes"));
                    map.put("number_of_questions", rs.getInt("number_of_questions"));
                    map.put("time_limit_minutes", rs.getInt("time_limit_minutes"));
                    map.put("question_group_id", rs.getInt("question_group_id"));
                    map.put("lesson_id", rs.getInt("lesson_id"));
                    return map;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

        public List<Map<String, Object>> getQuestionsByQuizId(int quizId) {
        List<Map<String, Object>> questions = new ArrayList<>();
        String sql = "SELECT qb.* FROM question_bank qb " +
                     "JOIN lesson_quiz lq ON qb.group_id = lq.question_group_id " +
                     "WHERE lq.id = ? AND qb.status = 'active'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("course_id", rs.getInt("course_id"));
                    map.put("group_id", rs.getInt("group_id"));
                    map.put("question_text", rs.getString("question_text"));
                    map.put("points", rs.getInt("points"));
                    map.put("status", rs.getString("status"));
                    questions.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return questions;
    }

    public List<Map<String, Object>> getAnswersByQuestionId(int questionId) {
        List<Map<String, Object>> answers = new ArrayList<>();
        String sql = "SELECT * FROM question_bank_answer WHERE question_bank_id = ? ORDER BY id ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("question_id", rs.getInt("question_bank_id"));
                    map.put("answer_text", rs.getString("answer_text"));
                    map.put("is_correct", rs.getBoolean("is_correct"));
                    map.put("order_number", 1); // Not used
                    answers.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return answers;
    }

    public int insertQuizAttempt(int accountId, int quizId, float score, boolean passed) {
        int attemptNumber = countUserAttemptsForQuiz(accountId, quizId) + 1;
        String sql = "INSERT INTO quiz_attempt (account_id, quiz_id, attempt_number, score, passed, start_time, end_time) VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, accountId);
            ps.setInt(2, quizId);
            ps.setInt(3, attemptNumber);
            ps.setFloat(4, score);
            ps.setBoolean(5, passed);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void insertQuizAttemptAnswer(int attemptId, int questionId, int selectedAnswerId) {
        String sql = "INSERT INTO quiz_attempt_answer (attempt_id, question_bank_id, selected_answer_id) VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            ps.setInt(2, questionId);
            ps.setInt(3, selectedAnswerId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // --- OTHER METHODS (unchanged) ---
    // (omitted from replace for brevity, we can just replace the specific methods)

    public int countUserAttemptsForQuiz(int accountId, int quizId) {
        String sql = "SELECT COUNT(*) FROM quiz_attempt WHERE account_id = ? AND quiz_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Map<String, Object> getLessonQuizById(int quizId) {
        String sql = "SELECT lq.*, l.title AS lesson_title, c.name AS course_name, c.id AS course_id FROM lesson_quiz lq " +
                     "JOIN lesson l ON lq.lesson_id = l.id " +
                     "LEFT JOIN section s ON l.section_id = s.id " +
                     "LEFT JOIN course c ON s.course_id = c.id " +
                     "WHERE lq.id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("lesson_id", rs.getInt("lesson_id"));
                    map.put("lesson_title", rs.getString("lesson_title"));
                    map.put("course_name", rs.getString("course_name"));
                    map.put("course_id", rs.getInt("course_id"));
                    map.put("passing_score", rs.getInt("passing_score"));
                    map.put("max_retakes", rs.getInt("max_retakes"));
                    map.put("number_of_questions", rs.getInt("number_of_questions"));
                    map.put("time_limit_minutes", rs.getInt("time_limit_minutes"));
                    map.put("question_group_id", rs.getInt("question_group_id"));
                    return map;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Map<String, Object>> getQuizBankByTeacher(int teacherId) {
        List<Map<String, Object>> quizzes = new ArrayList<>();
        String sql = "SELECT lq.id AS quiz_id, l.title AS lesson_title " +
                     "FROM lesson l " +
                     "JOIN lesson_quiz lq ON l.id = lq.lesson_id " +
                     "LEFT JOIN section s ON l.section_id = s.id " +
                     "LEFT JOIN course c ON s.course_id = c.id " +
                     "WHERE (l.created_by = ? OR c.created_by = ?) AND l.type = 'quiz'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ps.setInt(2, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("quiz_id", rs.getInt("quiz_id"));
                    map.put("lesson_title", rs.getString("lesson_title"));
                    quizzes.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return quizzes;
    }

    public List<Map<String, Object>> getAttemptAnswers(int attemptId) {
        List<Map<String, Object>> ans = new ArrayList<>();
        String sql = "SELECT qaa.question_bank_id AS question_id, qaa.selected_answer_id, qa.answer_text AS selected_answer_text, qa.is_correct " +
                     "FROM quiz_attempt_answer qaa " +
                     "JOIN question_bank_answer qa ON qaa.selected_answer_id = qa.id " +
                     "WHERE qaa.attempt_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("question_id", rs.getInt("question_id"));
                    map.put("selected_answer_id", rs.getInt("selected_answer_id"));
                    map.put("selected_answer_text", rs.getString("selected_answer_text"));
                    map.put("is_correct", rs.getBoolean("is_correct"));
                    ans.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ans;
    }

    public List<Map<String, Object>> getAttemptsByQuizId(int quizId) {
        List<Map<String, Object>> attempts = new ArrayList<>();
        String sql = "SELECT qa.id, acc.full_name AS student_name, acc.username, " +
                     "qa.score, qa.passed, qa.end_time " +
                     "FROM quiz_attempt qa " +
                     "JOIN account acc ON qa.account_id = acc.id " +
                     "WHERE qa.quiz_id = ? " +
                     "ORDER BY qa.end_time DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> a = new HashMap<>();
                    a.put("id", rs.getInt("id"));
                    String studentName = rs.getString("student_name");
                    if (studentName == null || studentName.trim().isEmpty()) {
                        studentName = rs.getString("username");
                    }
                    a.put("student_name", studentName);
                    a.put("score", rs.getDouble("score"));
                    a.put("passed", rs.getInt("passed") == 1);
                    a.put("end_time", rs.getTimestamp("end_time"));
                    attempts.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attempts;
    }

    public boolean deleteQuiz(int quizId) {
        Map<String, Object> quiz = getLessonQuizById(quizId);
        if (quiz != null) {
            int lessonId = (Integer) quiz.get("lesson_id");
            
            // Cascade delete manually since foreign keys might not have ON DELETE CASCADE
            String[] sqls = {
                "DELETE FROM quiz_attempt_answer WHERE attempt_id IN (SELECT id FROM quiz_attempt WHERE quiz_id = ?)",
                "DELETE FROM quiz_attempt WHERE quiz_id = ?",
                "DELETE FROM question_bank_answer WHERE question_bank_id IN (SELECT id FROM question_bank WHERE lesson_id = ?)",
                "DELETE FROM question_bank WHERE lesson_id = ?",
                "DELETE FROM lesson_quiz WHERE id = ?",
                "DELETE FROM lesson WHERE id = ?"
            };
            
            try {
                connection.setAutoCommit(false);
                
                for (int i = 0; i < 5; i++) {
                    try (PreparedStatement ps = connection.prepareStatement(sqls[i])) {
                        if (i == 2 || i == 3) ps.setInt(1, lessonId);
                        else ps.setInt(1, quizId);
                        ps.executeUpdate();
                    }
                }
                
                // Delete lesson
                try (PreparedStatement ps = connection.prepareStatement(sqls[5])) {
                    ps.setInt(1, lessonId);
                    ps.executeUpdate();
                }
                
                connection.commit();
                return true;
            } catch (SQLException e) {
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
                e.printStackTrace();
            } finally {
                try {
                    connection.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    public void updateQuizLesson(com.entity.Lesson lesson) {
        DbTextValidator.validateLength(lesson.getTitle(), 255, "Tiêu đề bài học");
        DbTextValidator.validateLength(lesson.getDescription(), 65535, "Mô tả bài học");
        DbTextValidator.validateLength(lesson.getStatus(), 20, "Trạng thái bài học");

        String sql = "UPDATE lesson SET title = ?, description = ?, duration_minutes = ?, status = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, lesson.getTitle());
            ps.setString(2, lesson.getDescription());
            ps.setInt(3, lesson.getDurationMinutes());
            ps.setString(4, lesson.getStatus());
            ps.setInt(5, lesson.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateLessonQuiz(int quizId, int passingScore, int maxRetakes) {
        String sql = "UPDATE lesson_quiz SET passing_score = ?, max_retakes = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, passingScore);
            ps.setInt(2, maxRetakes);
            ps.setInt(3, quizId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void clearQuizQuestions(int quizId) {
        // Find lesson_id from quiz_id
        int lessonId = -1;
        String findLessonSql = "SELECT lesson_id FROM lesson_quiz WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(findLessonSql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    lessonId = rs.getInt("lesson_id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        if (lessonId == -1) return;

        // Cascade delete manually
        String[] sqls = {
            "DELETE FROM quiz_attempt_answer WHERE attempt_id IN (SELECT id FROM quiz_attempt WHERE quiz_id = ?)",
            "DELETE FROM quiz_attempt WHERE quiz_id = ?",
            "DELETE FROM question_bank_answer WHERE question_bank_id IN (SELECT id FROM question_bank WHERE lesson_id = ?)",
            "DELETE FROM question_bank WHERE lesson_id = ?"
        };
        try {
            for (int i = 0; i < sqls.length; i++) {
                try (PreparedStatement ps = connection.prepareStatement(sqls[i])) {
                    if (i < 2) ps.setInt(1, quizId);
                    else ps.setInt(1, lessonId);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public List<Map<String, Object>> getUserAttemptsForQuiz(int accountId, int quizId) {
        List<Map<String, Object>> attempts = new ArrayList<>();
        String sql = "SELECT id, score, passed, start_time, end_time " +
                     "FROM quiz_attempt " +
                     "WHERE account_id = ? AND quiz_id = ? " +
                     "ORDER BY end_time ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                int attemptNumber = 1;
                while (rs.next()) {
                    Map<String, Object> a = new HashMap<>();
                    a.put("id", rs.getInt("id"));
                    a.put("attempt_number", attemptNumber++);
                    a.put("score", rs.getFloat("score"));
                    a.put("passed", rs.getInt("passed") == 1);
                    a.put("start_time", rs.getTimestamp("start_time"));
                    a.put("end_time", rs.getTimestamp("end_time"));
                    attempts.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attempts;
    }

    public Map<String, Object> getQuizAttemptById(int attemptId) {
        String sql = "SELECT id, account_id, quiz_id, score, passed, start_time, end_time " +
                     "FROM quiz_attempt " +
                     "WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> a = new HashMap<>();
                    a.put("id", rs.getInt("id"));
                    a.put("account_id", rs.getInt("account_id"));
                    a.put("quiz_id", rs.getInt("quiz_id"));
                    a.put("score", rs.getFloat("score"));
                    a.put("passed", rs.getInt("passed") == 1);
                    a.put("start_time", rs.getTimestamp("start_time"));
                    a.put("end_time", rs.getTimestamp("end_time"));
                    return a;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<QuizQuestion> getQuestionsByGroupId(int groupId) {
        List<QuizQuestion> questions = new ArrayList<>();
        String sql = "SELECT * FROM question_bank WHERE group_id = ? ORDER BY id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    questions.add(new QuizQuestion(
                        rs.getInt("id"),
                        rs.getInt("course_id"),
                        rs.getInt("lesson_id"),
                        rs.getInt("group_id"),
                        rs.getString("question_text"),
                        rs.getInt("points"),
                        rs.getString("status"),
                        rs.getTimestamp("created_date")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return questions;
    }

    public int insertQuestion(int courseId, int groupId, String questionText, int points) throws SQLException {
        DbTextValidator.validateLength(questionText, 10000000, "Nội dung câu hỏi");

        String sql = "INSERT INTO question_bank (course_id, group_id, question_text, points, status) VALUES (?, ?, ?, ?, 'active')";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, courseId);
            ps.setInt(2, groupId);
            ps.setString(3, questionText);
            ps.setInt(4, points);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public void updateQuestion(int questionId, String questionText, int points) throws SQLException {
        DbTextValidator.validateLength(questionText, 10000000, "Nội dung câu hỏi");

        String sql = "UPDATE question_bank SET question_text = ?, points = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, questionText);
            ps.setInt(2, points);
            ps.setInt(3, questionId);
            ps.executeUpdate();
        }
    }

    public void deleteQuestion(int questionId) throws SQLException {
        String sql1 = "DELETE FROM question_bank_answer WHERE question_bank_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql1)) {
            ps.setInt(1, questionId);
            ps.executeUpdate();
        }
        String sql2 = "DELETE FROM question_bank WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql2)) {
            ps.setInt(1, questionId);
            ps.executeUpdate();
        }
    }

    public boolean checkQuestionExistsInGroup(int groupId, String questionText) {
        String sql = "SELECT COUNT(*) FROM question_bank WHERE group_id = ? AND LOWER(TRIM(question_text)) = LOWER(TRIM(?)) AND status = 'active'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setString(2, questionText);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}



