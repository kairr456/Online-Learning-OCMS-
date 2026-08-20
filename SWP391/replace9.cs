using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        string anchor = "<input type=\"hidden\" id=\"rawVideoUrl__\" value=\"\">";
        if (content.Contains(anchor)) {
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
            Console.WriteLine("Injected hidden inputs!");
        } else {
            Console.WriteLine("Anchor not found!");
        }
    }
}
