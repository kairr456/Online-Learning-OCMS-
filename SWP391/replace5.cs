using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string content = File.ReadAllText(target, Encoding.UTF8);
        
        // Restore JSP escaping for ES6 template literals
        content = content.Replace(@"${lessonKey}", @"\${lessonKey}");
        content = content.Replace(@"${optionsHtml}", @"\${optionsHtml}");
        content = content.Replace(@"${quizData", @"\${quizData");
        content = content.Replace(@"${maxCount}", @"\${maxCount}");
        
        // Also fix qGroup.groupName to g.name!
        // The c:forEach uses var="qGroup" or "g"?
        // Let's check what it uses. It was qGroup in my replaced version.
        content = content.Replace(@"qGroup.groupName", @"qGroup.name");
        
        File.WriteAllText(target, content, new UTF8Encoding(false));
        Console.WriteLine("Fixed JSP EL escaping and name property!");
    }
}
