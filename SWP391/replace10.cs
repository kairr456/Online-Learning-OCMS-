using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        int idx = content.IndexOf("id=\"rawVideoUrl__\"");
        if (idx > 0) {
            int closeIdx = content.IndexOf(">", idx);
            if (closeIdx > 0) {
                string newInputs = @"
                                                        <c:if test="""">
                                                            <input type=""hidden"" id=""rawQuizNum__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizTime__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizRetake__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizPass__"" value="""">
                                                            <input type=""hidden"" id=""rawQuizGroup__"" value="""">
                                                        </c:if>";
                content = content.Insert(closeIdx + 1, newInputs);
                File.WriteAllText(target, content, new UTF8Encoding(false));
                Console.WriteLine("Injected hidden inputs perfectly!");
            }
        } else {
            Console.WriteLine("Index not found!");
        }
    }
}
