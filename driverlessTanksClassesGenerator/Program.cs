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

class Extended_PreInit_EventHandlers
{
	class noDrivers
	{
	    init=""RHS_ENGINE_STARTUP_OFF = true;removeDrivers = {{_d = getDir _x;_p = getPosASL _x;_vd = vectorDir _x;_vu = vectorUp _x; _t = (typeOf _x) + '_dl';if (isClass (configfile >> 'CfgVehicles' >> _class)) then {deleteVehicle _x;_n = _t createVehicle [0,0,0];_n setDir _d;_n setVectorDirAndUp [_vd, _vu];_n setPosASL _p;};} forEach _this;};"";

    };
};
class Extended_InitPost_EventHandlers
{
	class Tank
	{
	    init=""if (typeOf (_this select 0) find '_dl' != -1) then {[_this select 0, 1, ['ACE_SelfActions'], ['enable_driving','Enable driving (use if vehicle does not move)','',{[_target, clientOwner] remoteExec ['setOwner', 2]},{vehicle _player == _target && ((assignedVehicleRole _player) select 0) == 'Turret'}] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToObject;};"";

    };
};

class Extended_getIn_EventHandlers
{
	class Tank
	{
	    getin=""if (typeOf (_this select 0) find '_dl' != -1 && {(_this select 2) == effectiveCommander (_this select 0)}) then {[_this select 0, clientOwner] remoteExec ['setOwner', 2]};"";

    };
};

class cfgVehicles
{");

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

            System.IO.File.WriteAllText(@"C:\test\bh_noDrivers\config.cpp", result);

            var strCmdText = @"/C makePbo -x none C:\test\bh_noDrivers C:\test\";
            System.Diagnostics.Process.Start("CMD.exe", strCmdText);
        }
    }
}
