using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Threading;
using System.IO;

namespace driverlessTanksClassesGenerator
{
    class Program
    {
        static void Main(string[] args)
        {
            String clipboard = null;
            Exception threadEx = null;
            Thread staThread = new Thread(
                delegate ()
                {
                    try
                    {
                        clipboard = Clipboard.GetText();
                    }

                    catch (Exception ex)
                    {
                        threadEx = ex;
                    }
                });
            staThread.SetApartmentState(ApartmentState.STA);
            staThread.Start();
            staThread.Join();
            
            clipboard = clipboard.TrimStart('[');
            clipboard = clipboard.TrimEnd(']');
            var classes = clipboard.Split(',');

            var path = @"..\..\..";

            var boilerplate = File.ReadAllText(path + @"\configBoilerplate.txt");
            StringBuilder sb = new StringBuilder(boilerplate);

            foreach (var className in classes)
            {
                var classNameTrimmed = className.Trim('\"');
                if (classNameTrimmed.Contains("_dl") || classNameTrimmed.Contains("base") || classNameTrimmed.Contains("tb_"))
                    continue;

                sb.AppendFormat(@"
    class {0};
    class {0}_dl : {0} {{
        scope = 1;
        hasDriver = -1;
    }};", classNameTrimmed);
            }

            sb.AppendLine("\n};");

            var result = sb.ToString();


            System.IO.File.WriteAllText($@"{path}\output\config.cpp", result);

            string[] files = { @"$PBOPREFIX$", "init.sqf", "tankInit.sqf", "getInEH.sqf" };
            foreach (var file in files) {
                System.IO.File.Copy($@"{path}\{file}", $@"{path}\output\{file}", true);
            }

            var absolutePath = Path.GetFullPath(path);

            var strCmdText = $@"/C makePbo -x none {absolutePath}\output {absolutePath}\bh_noDrivers.pbo";
            System.Diagnostics.Process.Start("CMD.exe", strCmdText);
        }
    }
}
