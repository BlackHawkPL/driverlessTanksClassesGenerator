if (!local (_this # 2)) exitWith {};

if (
	typeOf (_this # 0) find '_dl' != -1 &&
	{(_this # 2) == effectiveCommander (_this # 0)}
) then {
	[_this # 0, clientOwner] remoteExec ['setOwner', 2];
};
