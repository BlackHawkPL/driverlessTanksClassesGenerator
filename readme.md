Code below ran in debug console will dump all tank classnames to clipboard. When the program is ran, it will automatically grab clipboard content and use it to generate config and then pack it into a PBO.

```sqf
_arr = [];
{
    _arr pushBack format ["%1", configName _x];
} forEach ("configName _x isKindOf 'Tank'" configClasses (configFile / "CfgVehicles"));
copyToClipboard str _arr;
```
