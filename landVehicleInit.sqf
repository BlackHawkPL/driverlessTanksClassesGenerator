if ((_this # 0) getVariable ["BH_enableAiDriver", false] && !((_this # 0) isKindOf "StaticWeapon")) then {
	(_this # 0) call BH_enableAIDriverLocal;
};
