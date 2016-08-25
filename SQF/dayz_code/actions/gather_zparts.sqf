private ["_item","_type","_hasHarvested","_config","_knifeArray","_playerNear","_isListed","_activeKnife","_text","_sharpnessRemaining","_qty","_chance","_string"];
if (dayz_actionInProgress) exitWith {localize "str_epoch_player_31" call dayz_rollingMessages;};
dayz_actionInProgress = true;

_item = _this select 3;
_type = typeOf _item;
_hasHarvested = _item getVariable ["meatHarvested",false];
//_config = configFile >> "CfgSurvival" >> "Meat" >> _type;
_knifeArray = [];
player removeAction s_player_butcher;
s_player_butcher = -1;

_playerNear = {isPlayer _x} count ((getPosATL _item) nearEntities ["CAManBase", 10]) > 1;
if (_playerNear) exitWith {localize "str_pickup_limit_5" call dayz_rollingMessages; dayz_actionInProgress = false;};

//Count how many active tools the player has
{
	if (_x in items player) then {_knifeArray set [count _knifeArray, _x];};
} count Dayz_Gutting;

if ((count _knifeArray) < 1) exitWith {format[localize "str_missing_to_do_this",localize "STR_EQUIP_NAME_4"] call dayz_rollingMessages; dayz_actionInProgress = false; };

if ((count _knifeArray > 0) && !_hasHarvested) then {
	private "_qty";
	
	//Select random can from array
	_activeKnife = _knifeArray call BIS_fnc_selectRandom; 
	
	//Get Zombie Type
	//_isListed = isClass _config;
	_text = getText (configFile >> "CfgVehicles" >> _type >> "displayName");

	player playActionNow "Medic";
	[player,"gut",0,false,10] call dayz_zombieSpeak;
	[player,10,true,(getPosATL player)] call player_alertZombies;
	["Working",0,[20,40,15,0]] call dayz_NutritionSystem; // Added Nutrition-Factor for work

	_item setVariable ["meatHarvested",true,true];

	_qty = 2; //not used for gutting zombies
	if (_activeKnife == "ItemKnifeBlunt") then { _qty = round(_qty / 2); };

	if (local _item) then {
		[_item,_qty] spawn local_gutObjectZ; //leave as spawn (sleeping in loops will work but can freeze the script)
	} else {		
		PVDZE_plr_GutBodyZ = [_item,_qty];	
		publicVariable "PVDZE_plr_GutBodyZ";
	};
	
	if (dayz_knifeDulling) then {
		_sharpnessRemaining = getText (configFile >> "cfgWeapons" >> _activeKnife >> "sharpnessRemaining");
		switch _activeKnife do {
			case "ItemKnife" : { 
				//_chance = getNumber (configFile >> "cfgWeapons" >> _activeKnife >> "chance");
				if ([0.2] call fn_chance) then {
					player removeWeapon _activeKnife;
					player addWeapon _sharpnessRemaining;
					
					//systemChat (localize "str_info_bluntknife");
					localize "str_info_bluntknife" call dayz_rollingMessages;
				};	
			};
			case "ItemKnifeBlunt" : { 
				//do nothing
			};
			default { 
				player removeWeapon _activeKnife;
				player addWeapon _sharpnessRemaining;
			};
		};
	};
	// Reduce humanity for gutting zeds
	_humanity = player getVariable ["humanity",0];
	_humanity = _humanity - 10;
	player setVariable ["humanity",_humanity,true];
	
	uiSleep 6;
	_string = format[localize "str_success_gutted_zombie",_text]; //%1 has been gutted, zombie parts are now on the carcass
	closeDialog 0;
	uiSleep 0.02;
	_string call dayz_rollingMessages;
};
dayz_actionInProgress = false;