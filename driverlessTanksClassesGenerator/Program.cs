using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Threading;

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

            StringBuilder sb = new StringBuilder(@"class CfgPatches {
    class noDrivers {
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = { ""A3_Armor_F"" };
        version = 1;
        };
    };

    class cfgVehicles
    {");

            foreach (var className in classes)
            {
                var classNameTrimmed = className.Trim('\"');
                if (classNameTrimmed.Contains("_dl") || classNameTrimmed.Contains("base"))
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

            System.IO.File.WriteAllText(@"C:\test\noDrivers\config.cpp", result);

            var strCmdText = @"/C makePbo -x none C:\test\noDrivers C:\test\";
            System.Diagnostics.Process.Start("CMD.exe", strCmdText);
        }
    }
}
