using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        string anchorStr = "id=\"rawVideoUrl_${sStat.index}_${lStat.index}\"";
        
        if (!content.Contains("id=\"rawQuizGroup_${sStat.index}_${lStat.index}\"")) {
            int anchorIdx = content.IndexOf(anchorStr);
            if (anchorIdx > 0) {
                int endOfTag = content.IndexOf(">", anchorIdx);
                if (endOfTag > 0) {
                    string newInputs = "\n" +
"                                                        <c:if test=\"${lesson.quizConfig != null}\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizNum_${sStat.index}_${lStat.index}\" value=\"${lesson.quizConfig.numberOfQuestions}\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizTime_${sStat.index}_${lStat.index}\" value=\"${lesson.quizConfig.timeLimitMinutes}\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizRetake_${sStat.index}_${lStat.index}\" value=\"${lesson.quizConfig.maxRetakes}\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizPass_${sStat.index}_${lStat.index}\" value=\"${lesson.quizConfig.passingScore}\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizGroup_${sStat.index}_${lStat.index}\" value=\"${lesson.quizConfig.questionGroupId}\">\n" +
"                                                        </c:if>";
                    content = content.Insert(endOfTag + 1, newInputs);
                    File.WriteAllText(target, content, new UTF8Encoding(false));
                    Console.WriteLine("Injected successfully!!!");
                }
            } else {
                Console.WriteLine("Could not find anchor!");
            }
        } else {
            Console.WriteLine("Already contains rawQuizGroup!");
        }
    }
}
