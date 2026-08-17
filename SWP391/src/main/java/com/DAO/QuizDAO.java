package com.DAO;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
                     "  COUNT(DISTINCT qq.id) AS total_questions, " +
                     "  COUNT(DISTINCT qa.id) AS total_attempts, " +
                     "  COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.id ELSE NULL END) AS passed_attempts " +
                     "FROM lesson l " +
                     "JOIN lesson_quiz lq ON l.id = lq.lesson_id " +
                     "LEFT JOIN quiz_question qq ON lq.id = qq.quiz_id " +
                     "LEFT JOIN quiz_attempt qa ON lq.id = qa.quiz_id " +
                     "WHERE l.created_by = ? AND l.type = 'quiz'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
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
            "COUNT(DISTINCT qq.id) AS question_count, " +
            "COUNT(DISTINCT qa.id) AS attempts_count " +
            "FROM lesson l " +
            "JOIN lesson_quiz lq ON l.id = lq.lesson_id " +
            "LEFT JOIN section s ON l.section_id = s.id " +
            "LEFT JOIN course c ON s.course_id = c.id " +
            "LEFT JOIN quiz_question qq ON lq.id = qq.quiz_id " +
            "LEFT JOIN quiz_attempt qa ON lq.id = qa.quiz_id " +
            "WHERE l.created_by = ? AND l.type = 'quiz' "
        );

        List<Object> params = new ArrayList<>();
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
        
        String sql = "SELECT qa.id, acc.full_name AS student_name, l.title AS quiz_name, " +
                     "qa.score, qa.passed, qa.end_time " +
                     "FROM quiz_attempt qa " +
                     "JOIN account acc ON qa.account_id = acc.id " +
                     "JOIN lesson_quiz lq ON qa.quiz_id = lq.id " +
                     "JOIN lesson l ON lq.lesson_id = l.id " +
                     "WHERE l.created_by = ? " +
                     "ORDER BY qa.end_time DESC LIMIT ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> a = new HashMap<>();
                    a.put("id", rs.getInt("id"));
                    a.put("student_name", rs.getString("student_name"));
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
        String sql = "INSERT INTO quiz_question (quiz_id, question_text, points, order_number, status) VALUES (?, ?, ?, ?, 'active')";
        try (PreparedStatement ps = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, quizId);
            ps.setString(2, text);
            ps.setInt(3, points);
            ps.setInt(4, order);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    // 7. Insert Quiz Answer
    public void insertQuizAnswer(int questionId, String text, boolean isCorrect, int order) throws SQLException {
        String sql = "INSERT INTO quiz_answer (question_id, answer_text, is_correct, order_number) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            ps.setString(2, text);
            ps.setInt(3, isCorrect ? 1 : 0);
            ps.setInt(4, order);
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
        String sql = "SELECT * FROM quiz_question WHERE quiz_id = ? AND status = 'active' ORDER BY id ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("question_text", rs.getString("question_text"));
                    map.put("points", rs.getInt("points"));
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
        String sql = "SELECT * FROM quiz_answer WHERE question_id = ? ORDER BY id ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("answer_text", rs.getString("answer_text"));
                    map.put("is_correct", rs.getBoolean("is_correct"));
                    answers.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return answers;
    }

    public int insertQuizAttempt(int accountId, int quizId, float score, boolean passed) {
        String sql = "INSERT INTO quiz_attempt (account_id, quiz_id, score, passed, start_time, end_time) VALUES (?, ?, ?, ?, NOW(), NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, accountId);
            ps.setInt(2, quizId);
            ps.setFloat(3, score);
            ps.setBoolean(4, passed);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void insertQuizAttemptAnswer(int attemptId, int questionId, int selectedAnswerId) {
        String sql = "INSERT INTO quiz_attempt_answer (attempt_id, question_id, selected_answer_id) VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            ps.setInt(2, questionId);
            ps.setInt(3, selectedAnswerId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

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
        String sql = "SELECT * FROM lesson_quiz WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("lesson_id", rs.getInt("lesson_id"));
                    map.put("passing_score", rs.getInt("passing_score"));
                    map.put("max_retakes", rs.getInt("max_retakes"));
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
                     "WHERE l.created_by = ? AND l.type = 'quiz'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
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
        String sql = "SELECT qaa.question_id, qaa.selected_answer_id, qa.is_correct " +
                     "FROM quiz_attempt_answer qaa " +
                     "JOIN quiz_answer qa ON qaa.selected_answer_id = qa.id " +
                     "WHERE qaa.attempt_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("question_id", rs.getInt("question_id"));
                    map.put("selected_answer_id", rs.getInt("selected_answer_id"));
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
        String sql = "SELECT qa.id, acc.full_name AS student_name, " +
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
                    a.put("student_name", rs.getString("student_name"));
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
                "DELETE FROM quiz_answer WHERE question_id IN (SELECT id FROM quiz_question WHERE quiz_id = ?)",
                "DELETE FROM quiz_question WHERE quiz_id = ?",
                "DELETE FROM lesson_quiz WHERE id = ?",
                "DELETE FROM lesson WHERE id = ?"
            };
            
            try {
                connection.setAutoCommit(false);
                
                for (int i = 0; i < 5; i++) {
                    try (PreparedStatement ps = connection.prepareStatement(sqls[i])) {
                        ps.setInt(1, quizId);
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
        // Cascade delete manually
        String[] sqls = {
            "DELETE FROM quiz_attempt_answer WHERE attempt_id IN (SELECT id FROM quiz_attempt WHERE quiz_id = ?)",
            "DELETE FROM quiz_attempt WHERE quiz_id = ?",
            "DELETE FROM quiz_answer WHERE question_id IN (SELECT id FROM quiz_question WHERE quiz_id = ?)",
            "DELETE FROM quiz_question WHERE quiz_id = ?"
        };
        try {
            for (String sql : sqls) {
                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setInt(1, quizId);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
