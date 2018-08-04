if (typeOf (_this select 0) find '_dl' != -1) then {
	[
		_this select 0,
		1,
		['ACE_SelfActions'],
		['enable_driving','Enable driving (use if vehicle does not move)',
		'',
		{[_target, clientOwner] remoteExec ['setOwner', 2]},
		{vehicle _player == _target && ((assignedVehicleRole _player) select 0) == 'Turret' && _player == effectiveCommander _target}
	] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToObject;

	_this # 0 addAction [
		"engine off",
		{[_this # 0, false] remoteExec ["engineOn", _this # 0]},
		[],
		1.5,
		false,
		true,
		"",
		"isEngineOn _target && _target == vehicle _this"
	];
};
