Run this code in debug console. It will dump all tank classnames to clipboard. When you run this program, it will automatically grab clipboard content and use it to generate config and then pack it into PBO.

```_arr = [];
{
    _arr pushBack format ["%1", configName _x];
} forEach ("configName _x isKindOf 'Tank'" configClasses (configFile / "CfgVehicles"));
copyToClipboard str _arr;```