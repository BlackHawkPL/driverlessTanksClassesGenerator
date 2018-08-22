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

            var path = @"..\..\..";
            String classFile = File.ReadAllText(path + @"\classes.txt");

            classFile = classFile.TrimStart('[');
            classFile = classFile.TrimEnd(']');
            var classes = classFile.Split(',');

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

            string[] files = { @"$PBOPREFIX$", "preInit.sqf", "tankInit.sqf", "getInEH.sqf", "landVehicleInit.sqf" };
            foreach (var file in files) {
                System.IO.File.Copy($@"{path}\{file}", $@"{path}\output\{file}", true);
            }

            var absolutePath = Path.GetFullPath(path);

            var strCmdText = $@"/C makePbo -x none {absolutePath}\output {absolutePath}\bh_noDrivers.pbo";
            System.Diagnostics.Process.Start("CMD.exe", strCmdText);
        }
    }
}
