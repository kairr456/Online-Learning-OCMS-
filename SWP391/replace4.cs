using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        content = content.Replace(@"\${lessonKey}", @"${lessonKey}");
        content = content.Replace(@"\${optionsHtml}", @"${optionsHtml}");
        content = content.Replace(@"\${quizData", @"${quizData");
        content = content.Replace(@"\${maxCount}", @"${maxCount}");
        
        File.WriteAllText(target, content, new UTF8Encoding(false));
        Console.WriteLine("Fixed escaping bug!");
    }
}
