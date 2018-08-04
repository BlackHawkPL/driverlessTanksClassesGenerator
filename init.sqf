RHS_ENGINE_STARTUP_OFF = true;
BH_removeDrivers = {
	private _vehs = _this;
	if (typeName _vehs != "ARRAY") then {
		_vehs = [_vehs];
	};
	{
		_dir = getDir _x;
		_pos = getPosASL _x;
		_vectorDir = vectorDir _x;
		_vectorUp = vectorUp _x;

		_magazines = magazineCargo _x;
		_weapons = weaponCargo _x;
		_items = itemCargo _x;
		_backpacks = backpackCargo _x;

		_class = typeOf _x;
		_newClass = _class + '_dl';
		if (isClass (configfile >> 'CfgVehicles' >> _newClass)) then {
			deleteVehicle _x;
			_newVeh = _newClass createVehicle [0,0,0];
			_newVeh setDir _dir;
			_newVeh setVectorDirAndUp [_vectorDir, _vectorUp];
			_newVeh setPosASL _pos;

			clearWeaponCargoGlobal _newVeh;
			clearMagazineCargoGlobal _newVeh;
			clearItemCargoGlobal _newVeh;
			clearBackpackCargoGlobal _newVeh;
			
			{_newVeh addMagazineCargoGlobal [_x, 1];} forEach _magazines;
			{_newVeh addWeaponCargoGlobal [_x, 1];} forEach _weapons;
			{_newVeh addItemCargoGlobal [_x, 1];} forEach _items;
			{_newVeh addBackpackCargoGlobal [_x, 1];} forEach _backpacks;
		}
		else {
			systemChat format ["This function works only for tanks, %1 is not a tank", _class];
		};
	} forEach _vehs;
};
BH_removeDriver = BH_removeDrivers;

BH_aidrivers_toggle = {
    params ["_target", "_caller"];
    if (!isNull (_target getVariable ["BH_aidrivers_driver", objNull])) then {
        [_target] call BH_aidrivers_removeUnit;
    } else {
        [_target, _caller] call BH_aidrivers_createUnit;
    };
};

BH_aidrivers_removeUnit = {
    params ["_target"];

    private _driver = _target getVariable ["BH_aidrivers_driver", objNull];
    
    if (!isNull _driver) then {
        deleteVehicle _driver;
        private _handle = _target getVariable ["BH_aidrivers_pfhID", []];
        if ((count _handle) != 0) then {
            [_handle select 1] remoteExec ["CBA_fnc_removePerFrameHandler", _handle select 0];
        };
    };
    BH_aidrivers_AiDriverVehicle = objNull;
    false call BH_aidrivers_fnc_toggleDriverCam;
    hint "Driver removed";
};

BH_aidrivers_createUnit = {
    params ["_target", "_caller"];
    
    if (!isNull driver _target) exitWith {};
    private _turret = (assignedVehicleRole _player) select 1;
    _caller moveInDriver _target;
    _caller moveInTurret [_target, _turret];
    
    private _class = "B_Soldier_F";
    if (side _caller == EAST) then {
        _class = "O_Soldier_F";
    };
    if (side _caller == INDEPENDENT) then {
        _class = "I_Soldier_F";
    };

    _unit = createAgent [_class, [0,0,0], [], 0, "CAN_COLLIDE"];

    removeAllWeapons _unit;
    removeUniform _unit;
    removeVest _unit;
    removeHeadgear _unit;
    removeGoggles _unit;
    
    _unit forceAddUniform uniform _caller;
    _unit addVest vest _caller;
    _unit addHeadGear headGear _caller;
    
    _target setVariable ["BH_aidrivers_driver", _unit, true];

    _unit moveInDriver _target;
    _unit setBehaviour "COMBAT";
    
    doStop _unit;

    BH_aidrivers_AidriverLastTimeIn = time;

    [{vehicle (_this select 0) != _this select 0}, { //waiting for spawned unit to get into vehicle
        private _pfhID = [{
            _this select 0 params ["_unit", "_target", "_caller"];

            private _handle = _this select 1;
            if (vehicle _caller != _target) then {
                false call BH_aidrivers_fnc_toggleDriverCam;
                _unit disableAI "PATH";
                doStop _unit;
            } else {
                _unit enableAI "PATH";
                BH_aidrivers_AidriverLastTimeIn = time;
            };
            if (time > 120 + BH_aidrivers_AidriverLastTimeIn || !alive _target || !alive _caller || !alive _unit || (vehicle _unit) != _target || (driver _target) != _unit) then {
                [_target, _caller] call BH_aidrivers_removeUnit;
            };
        }, 1, _this] call CBA_fnc_addPerFrameHandler;
        (_this select 1) setVariable ["BH_aidrivers_pfhID", [(_this select 2), _pfhID], true];
    }, [_unit, _target, _caller]] call CBA_fnc_WaitUntilAndExecute;

    BH_aidrivers_AiDriverVehicle = _target;
    hint "Driver added";

};

BH_aidrivers_fnc_toggleDriverCam = {
    if (_this) then {
        BH_aidrivers_driverCam = "camera" camCreate [0,0,0];
        BH_aidrivers_driverCam cameraEffect ["INTERNAL", "BACK","BH_aidrivers_rtt"];
        BH_aidrivers_driverCam camSetFov 0.9;
        BH_aidrivers_driverCam camCommit 0;

        BH_aidrivers_pipNvEnabled = false;
        
        _veh = vehicle player;
        _mempoint = getText ( configfile >> "CfgVehicles" >> (typeOf _veh) >> "memoryPointDriverOptics" );
        BH_aidrivers_driverCam attachTo [_veh,[0,0,0], _mempoint];
        
        with uiNamespace do {
            "BH_aidrivers_pipDriver" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
            BH_aidrivers_pipDisplay = uiNamespace getVariable "RscTitleDisplayEmpty";
            BH_aidrivers_driverPipDisplay = BH_aidrivers_pipDisplay ctrlCreate ["RscPicture", -1];
            BH_aidrivers_driverPipDisplay ctrlSetPosition [0.1,1,0.75,0.5];
            BH_aidrivers_driverPipDisplay ctrlCommit 0;
            BH_aidrivers_driverPipDisplay ctrlSetText "#(argb,512,512,1)r2t(BH_aidrivers_rtt,1.0)";
        };

    } else {
        if (!isNil "BH_aidrivers_driverCam" && {!isNull BH_aidrivers_driverCam}) then {
            with uiNamespace do {
                BH_aidrivers_pipDisplay closeDisplay 2;
            };
            detach BH_aidrivers_driverCam;
            BH_aidrivers_driverCam cameraEffect ["terminate", "back", "BH_aidrivers_rtt"];
            camDestroy BH_aidrivers_driverCam;
        };
    };
};

BH_enableAIDriverLocal = {
    private _vehs = _this;
    if (typeName _vehs != "ARRAY") then {
        _vehs = [_vehs];
    };

    //AI driver action
    private _action = ["ai_driver","Add/Remove AI driver","",{
        [_target, _player] call BH_aidrivers_toggle;
    },
    {
        vehicle _player == _target && ((assignedVehicleRole _player) select 0) == "Turret" && BH_aidrivers_AiDriverVehicle in [objNull, vehicle _player]
    }] call ace_interact_menu_fnc_createAction;

    //unflip action
    private _unflipAction = ["ai_driver_unflip","Unflip vehicle","",{
        [_target, surfaceNormal position _target] remoteExec ["setVectorUp", _target, false];
        _target setPos [getpos _target select 0, getpos _target select 1, (getpos _target select 2) + 2];
    },
    {
        vehicle _player == _target && ((assignedVehicleRole _player) select 0) == "Turret" && (vectorUp _target) select 2 < 0
    }] call ace_interact_menu_fnc_createAction;

    //engine off action
    private _engineOffAction = ["ai_driver_engineoff","Turn off engine","",{
        [_target, false] remoteExec ["engineOn", _target];
    },
    {
        vehicle _player == _target && ((assignedVehicleRole _player) select 0) == "Turret" && isEngineOn _target
    }] call ace_interact_menu_fnc_createAction;

    //PIP action
    private _pipAction = ["ai_driver_pip","Enable/Disable driver's view","",{
        (isNil "BH_aidrivers_driverCam" || {isNull BH_aidrivers_driverCam}) call BH_aidrivers_fnc_toggleDriverCam;
    },
    {
        vehicle _player == _target && ((assignedVehicleRole _player) select 0) == "Turret" && !isNull (_target getVariable ["BH_aidrivers_driver", objNull])
    }] call ace_interact_menu_fnc_createAction;

    //toggle NV for PIP
    private _pipNvAction = ["ai_driver_pip_nv","Enable/Disable NV in driver's view","",{
        if (isNil "BH_aidrivers_pipNvEnabled") then {
            BH_aidrivers_pipNvEnabled = false;
        };
        "BH_aidrivers_rtt" setPiPEffect ([[1], [0]] select BH_aidrivers_pipNvEnabled);
        BH_aidrivers_pipNvEnabled = !BH_aidrivers_pipNvEnabled;
    },
    {
        vehicle _player == _target &&
        ((assignedVehicleRole _player) select 0) == "Turret" &&
        (!isNil "BH_aidrivers_driverCam" && {!isNull BH_aidrivers_driverCam})
    }] call ace_interact_menu_fnc_createAction;


    {
        [_x, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;
        [_x, 1, ["ACE_SelfActions"], _unflipAction] call ace_interact_menu_fnc_addActionToObject;
        [_x, 1, ["ACE_SelfActions"], _engineOffAction] call ace_interact_menu_fnc_addActionToObject;
        [_x, 1, ["ACE_SelfActions"], _pipAction] call ace_interact_menu_fnc_addActionToObject;
        [_x, 1, ["ACE_SelfActions"], _pipNvAction] call ace_interact_menu_fnc_addActionToObject;
    } foreach _vehs;

};

BH_enableAIDriver = {
	_this remoteExec ["BH_enableAIDriverLocal", 0, true];
};

BH_aidrivers_AiDriverVehicle = objNull;

