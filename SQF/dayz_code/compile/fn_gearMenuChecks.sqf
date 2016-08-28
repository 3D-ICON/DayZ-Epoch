private ["_cTarget","_dis","_display","_friendlies","_rID"];

DZE_abortGearMenu = false;

// players inside vehicle can always access its gear
if ((vehicle player) == player) then {
	disableSerialization;
	_display = _this select 0;	
	_cTarget = cursorTarget;
	_dis = if (_cTarget isKindOf "USEC_ch53_E" || _cTarget isKindOf "MV22") then {25} else {12};

	if ((locked _cTarget) && {(_cTarget isKindOf "LandVehicle") or {_cTarget isKindOf "Air"} or {_cTarget isKindOf "Ship"}} && {(player distance _cTarget) < _dis}) then {
		localize "str_epoch_player_7" call dayz_rollingMessages;
		DZE_abortGearMenu = true;
		_display closeDisplay 2;
	};

	if (DZE_BackpackAntiTheft) then {
		_friendlies	= player getVariable ["friendlies",[]];
		_rID = if (DZE_permanentPlot) then { getPlayerUID _cTarget } else { _cTarget getVariable ["CharacterID","0"] };
		if ((!canbuild or isInTraderCity) && {_cTarget isKindOf "Man"} && {alive _cTarget} && {isPlayer _cTarget} && {!(_rID in _friendlies)} && {(player distance _cTarget) < 12}) then {
			localize "STR_EPOCH_PLAYER_316" call dayz_rollingMessages;
			DZE_abortGearMenu = true;
			_display closeDisplay 2;
		};
	};
};