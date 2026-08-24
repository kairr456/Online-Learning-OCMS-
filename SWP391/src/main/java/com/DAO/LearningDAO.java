package com.DAO;

import com.entity.LessonDocument;
import com.entity.LessonProgress;
import com.entity.LessonVideo;
import com.entity.QuizAnswer;
import com.entity.QuizQuestion;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class LearningDAO extends DBContext {

    public List<LessonVideo> getLessonVideos(int lessonId) {
        List<LessonVideo> list = new ArrayList<>();
        String sql = "SELECT * FROM lesson_video WHERE lesson_id = ? ORDER BY id";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                LessonVideo v = new LessonVideo();
                v.setId(resultSet.getInt("id"));
                v.setLessonId(resultSet.getInt("lesson_id"));
                v.setVideoUrl(resultSet.getString("video_url"));
                v.setVideoProvider(resultSet.getString("video_provider"));
                v.setVideoDuration(resultSet.getInt("video_duration"));
                list.add(v);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting lesson videos: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return list;
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
        return null;
    }

    public LessonDocument getLessonDocument(int lessonId) {
        String sql = "SELECT * FROM lesson_document WHERE lesson_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                LessonDocument d = new LessonDocument();
                d.setLessonId(resultSet.getInt("lesson_id"));
                d.setDocumentUrl(resultSet.getString("document_url"));
                d.setDocumentType(resultSet.getString("document_type"));
                d.setPageCount(resultSet.getInt("page_count"));
                d.setDownloadAllowed(resultSet.getBoolean("download_allowed"));
                return d;
            }
        } catch (SQLException ex) {
            System.out.println("Error getting lesson document: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public int getQuizIdByLessonId(int lessonId) {
        String sql = "SELECT id FROM lesson_quiz WHERE lesson_id = ? LIMIT 1";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("id");
            }
        } catch (SQLException ex) {
            System.out.println("Error getting quiz id: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return -1;
    }

    public int getLessonIdByQuizId(int quizId) {
        String sql = "SELECT lesson_id FROM lesson_quiz WHERE id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, quizId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("lesson_id");
            }
        } catch (SQLException ex) {
            System.out.println("Error getting lesson id: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return -1;
    }

        public List<QuizQuestion> getQuestionsByQuizId(int quizId) {
        List<QuizQuestion> list = new ArrayList<>();
        String sql = "SELECT qb.* FROM question_bank qb " +
                     "JOIN lesson_quiz lq ON qb.group_id = lq.question_group_id " +
                     "WHERE lq.id = ? AND qb.status = 'active'";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, quizId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                QuizQuestion q = new QuizQuestion();
                q.setId(resultSet.getInt("id"));
                q.setCourseId(resultSet.getInt("course_id"));
                q.setLessonId(resultSet.getInt("lesson_id"));
                q.setGroupId(resultSet.getInt("group_id"));
                q.setQuestionText(resultSet.getString("question_text"));
                q.setPoints(resultSet.getInt("points"));
                q.setStatus(resultSet.getString("status"));
                q.setCreatedDate(resultSet.getTimestamp("created_date"));
                list.add(q);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    public List<QuizAnswer> getAnswersByQuestionId(int questionId) {
        List<QuizAnswer> list = new ArrayList<>();
        String sql = "SELECT * FROM question_bank_answer WHERE question_bank_id = ? ORDER BY id ASC";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, questionId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                QuizAnswer a = new QuizAnswer();
                a.setId(resultSet.getInt("id"));
                a.setQuestionId(resultSet.getInt("question_bank_id"));
                a.setAnswerText(resultSet.getString("answer_text"));
                a.setIsCorrect(resultSet.getBoolean("is_correct"));
                a.setOrderNumber(1);
                list.add(a);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting quiz answers: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return list;
    }

    public LessonProgress getLessonProgress(int accountId, int lessonId) {
        String sql = "SELECT * FROM lesson_progress WHERE account_id = ? AND lesson_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            statement.setInt(2, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                LessonProgress p = new LessonProgress();
                p.setId(resultSet.getInt("id"));
                p.setAccountId(resultSet.getInt("account_id"));
                p.setLessonId(resultSet.getInt("lesson_id"));
                p.setCompleted(resultSet.getBoolean("completed"));
                p.setCompletedAt(resultSet.getTimestamp("completed_at"));
                return p;
            }
        } catch (SQLException ex) {
            System.out.println("Error getting lesson progress: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public boolean saveLessonProgress(int accountId, int lessonId, boolean completed) {
        LessonProgress existing = getLessonProgress(accountId, lessonId);
        String sql = existing != null
                ? "UPDATE lesson_progress SET completed = ?, completed_at = ? WHERE account_id = ? AND lesson_id = ?"
                : "INSERT INTO lesson_progress (account_id, lesson_id, completed, completed_at) VALUES (?, ?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            Timestamp now = new Timestamp(System.currentTimeMillis());
            if (existing != null) {
                statement.setBoolean(1, completed);
                statement.setTimestamp(2, now);
                statement.setInt(3, accountId);
                statement.setInt(4, lessonId);
            } else {
                statement.setInt(1, accountId);
                statement.setInt(2, lessonId);
                statement.setBoolean(3, completed);
                statement.setTimestamp(4, now);
            }
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error saving lesson progress: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    public Set<Integer> getCompletedLessonIds(int accountId, int courseId) {
        Set<Integer> set = new HashSet<>();
        String sql = "SELECT lp.lesson_id FROM lesson_progress lp "
                + "JOIN lesson l ON lp.lesson_id = l.id "
                + "JOIN section s ON l.section_id = s.id "
                + "WHERE lp.account_id = ? AND s.course_id = ? AND lp.completed = 1";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            statement.setInt(2, courseId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                set.add(resultSet.getInt("lesson_id"));
            }
        } catch (SQLException ex) {
            System.out.println("Error getting completed lessons: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return set;
    }

    public boolean saveQuizAttempt(int accountId, int quizId, double score, boolean passed) {
        String sql = "INSERT INTO quiz_attempt (account_id, quiz_id, score, passed, start_time, end_time) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            Timestamp now = new Timestamp(System.currentTimeMillis());
            statement.setInt(1, accountId);
            statement.setInt(2, quizId);
            statement.setDouble(3, score);
            statement.setBoolean(4, passed);
            statement.setTimestamp(5, now);
            statement.setTimestamp(6, now);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.out.println("Error saving quiz attempt: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    public Double getBestQuizScore(int accountId, int quizId) {
        String sql = "SELECT MAX(score) AS best FROM quiz_attempt WHERE account_id = ? AND quiz_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            statement.setInt(2, quizId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                double d = resultSet.getDouble("best");
                if (!resultSet.wasNull()) {
                    return d;
                }
            }
        } catch (SQLException ex) {
            System.out.println("Error getting best quiz score: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return null;
    }

    public boolean hasPassedQuiz(int accountId, int quizId) {
        String sql = "SELECT COUNT(*) FROM quiz_attempt WHERE account_id = ? AND quiz_id = ? AND passed = 1";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            statement.setInt(2, quizId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            System.out.println("Error checking passed quiz: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return false;
    }

    /**
     * Trả về phần trăm tiến độ (0-100) theo khóa học cho tài khoản, chỉ tính
     * những khóa học mà tài khoản đã đăng ký hợp lệ.
     */
    public Map<Integer, Integer> getCourseProgressMap(int accountId) {
        Map<Integer, Integer> map = new HashMap<>();
        String sql = "SELECT s.course_id, "
                + "COUNT(l.id) AS total, "
                + "COALESCE(SUM(CASE WHEN lp.completed = 1 THEN 1 ELSE 0 END), 0) AS completed "
                + "FROM lesson l "
                + "JOIN section s ON l.section_id = s.id "
                + "LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.account_id = ? "
                + "WHERE EXISTS (SELECT 1 FROM registration r "
                + "WHERE r.course_id = s.course_id AND r.account_id = ? "
                + "AND r.status IN ('Active', 'Approved', 'Success')) "
                + "GROUP BY s.course_id";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            statement.setInt(2, accountId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                int courseId = resultSet.getInt("course_id");
                int total = resultSet.getInt("total");
                int completed = resultSet.getInt("completed");
                int percent = total > 0 ? (int) Math.round(completed * 100.0 / total) : 0;
                map.put(courseId, percent);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting course progress map: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return map;
    }

    /** Lấy course_id từ lesson_id (JOIN section) — dùng để cấp chứng chỉ khi hoàn thành bài. */
    public int getCourseIdByLessonId(int lessonId) {
        String sql = "SELECT s.course_id FROM lesson l JOIN section s ON l.section_id = s.id WHERE l.id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, lessonId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("course_id");
            }
        } catch (SQLException ex) {
            System.out.println("Error getCourseIdByLessonId: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return -1;
    }

    /** Phần trăm tiến độ (0-100) của 1 khóa học cho 1 tài khoản (giống getCourseProgressMap, chỉ 1 khóa). */
    public int getCourseProgress(int accountId, int courseId) {
        String sql = "SELECT COUNT(l.id) AS total, "
                + "COALESCE(SUM(CASE WHEN lp.completed = 1 THEN 1 ELSE 0 END), 0) AS completed "
                + "FROM lesson l "
                + "JOIN section s ON l.section_id = s.id "
                + "LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.account_id = ? "
                + "WHERE s.course_id = ?";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            statement.setInt(1, accountId);
            statement.setInt(2, courseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                int total = resultSet.getInt("total");
                int completed = resultSet.getInt("completed");
                return total > 0 ? (int) Math.round(completed * 100.0 / total) : 0;
            }
        } catch (SQLException ex) {
            System.out.println("Error getCourseProgress: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return 0;
    }
}
