using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        string anchorStr = "id=\"rawVideoUrl__\"";
        
        if (!content.Contains("id=\"rawQuizGroup__\"")) {
            int anchorIdx = content.IndexOf(anchorStr);
            if (anchorIdx > 0) {
                int endOfTag = content.IndexOf(">", anchorIdx);
                if (endOfTag > 0) {
                    string newInputs = "\n" +
"                                                        <c:if test=\"\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizNum__\" value=\"\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizTime__\" value=\"\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizRetake__\" value=\"\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizPass__\" value=\"\">\n" +
"                                                            <input type=\"hidden\" id=\"rawQuizGroup__\" value=\"\">\n" +
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
