using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\java\com\DAO\QuizDAO.java";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        string oldMap = @"                    Map<String, Object> map = new HashMap<>();
                    map.put(""id"", rs.getInt(""id""));
                    map.put(""passing_score"", rs.getInt(""passing_score""));
                    map.put(""max_retakes"", rs.getInt(""max_retakes""));
                    return map;";
                    
        string newMap = @"                    Map<String, Object> map = new HashMap<>();
                    map.put(""id"", rs.getInt(""id""));
                    map.put(""passing_score"", rs.getInt(""passing_score""));
                    map.put(""max_retakes"", rs.getInt(""max_retakes""));
                    map.put(""number_of_questions"", rs.getInt(""number_of_questions""));
                    map.put(""time_limit_minutes"", rs.getInt(""time_limit_minutes""));
                    map.put(""question_group_id"", rs.getInt(""question_group_id""));
                    map.put(""lesson_id"", rs.getInt(""lesson_id""));
                    return map;";
                    
        if (content.Contains("map.put(\"id\", rs.getInt(\"id\"));") && !content.Contains("number_of_questions")) {
            content = content.Replace(oldMap, newMap);
            File.WriteAllText(target, content, new UTF8Encoding(false));
            Console.WriteLine("QuizDAO updated successfully!");
        } else {
            Console.WriteLine("Could not update QuizDAO!");
        }
    }
}
