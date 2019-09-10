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

            Directory.CreateDirectory($@"{path}\output");
            System.IO.File.WriteAllText($@"{path}\output\config.cpp", boilerplate);

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
