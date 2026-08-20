using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        string oldHtml = @"<input type=""hidden"" id=""rawVideoUrl__"" value="""">";
        string newHtml = oldHtml + @"
                                                        <c:if test="""">
                                                            <input type=""hidden"" id=""rawQuizNum__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizTime__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizRetake__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizPass__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizGroup__"" value="""">
                                                        </c:if>";
        
        if (content.Contains(oldHtml) && !content.Contains("rawQuizGroup__")) {
            content = content.Replace(oldHtml, newHtml);
            File.WriteAllText(target, content, new UTF8Encoding(false));
            Console.WriteLine("Added hidden inputs back!");
        } else {
            Console.WriteLine("Could not add hidden inputs. Either already there or oldHtml not found.");
        }
    }
}
