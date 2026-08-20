using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        string anchor = @"value="""">";
        if (content.Contains(anchor) && !content.Contains("rawQuizGroup_")) {
            string newInputs = @"
                                                        <c:if test="""">
                                                            <input type=""hidden"" id=""rawQuizNum__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizTime__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizRetake__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizPass__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizGroup__"" value="""">
                                                        </c:if>";
            content = content.Replace(anchor, anchor + newInputs);
            File.WriteAllText(target, content, new UTF8Encoding(false));
            Console.WriteLine("Successfully added hidden inputs for Quiz!");
        } else {
            Console.WriteLine("Anchor not found or already added.");
        }
    }
}
