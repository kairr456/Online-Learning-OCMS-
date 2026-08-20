using System;
using System.IO;
using System.Text;

class Program {
    static void Main() {
        string target = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\lesson.jsp";
        string fix = @"C:\Users\cuong\OneDrive\Desktop\Online-Learning-OCMS-\SWP391\src\main\webapp\view\courseCRUD\fix_quiz.txt";
        
        string content = File.ReadAllText(target, Encoding.UTF8);
        string fixContent = File.ReadAllText(fix, Encoding.UTF8);
        
        int start = content.IndexOf("} else if (type === 'quiz') {");
        int end = content.IndexOf("function addBlock(secId, lesId, type, initialValue = '') {");
        
        if (start > 0 && end > start) {
            content = content.Substring(0, start) + fixContent + "\r\n\r\n        " + content.Substring(end);
            File.WriteAllText(target, content, new UTF8Encoding(false));
            Console.WriteLine("Replaced using C#!");
        } else {
            Console.WriteLine("Could not find boundaries.");
        }
    }
}
