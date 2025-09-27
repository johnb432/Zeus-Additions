#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Makes two units assemble a static weapon.
 *
 * Arguments:
 * 0: Tripod unit and associated backpack <ARRAY>
 * 1: Weapon unit and associated backpack <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [[player, backpackContainer player], [cursorObject, backpackContainer cursorObject]] call zeus_additions_main_fnc_assembleStaticWeapon;
 *
 * Public: No
 */

params ["_base", "_weapon"];
_base params ["_baseUnit", "_baseBackpack"];
_weapon params ["_weaponUnit"];

[[_baseUnit, _weaponUnit], {
    params ["_successful", "_units", "_position", "_baseBackpack"];

    if (!_successful) exitWith {};

    _units doMove ASLToATL _position;

	[{
		params ["_args", "_pfhId"];
		_args params ["_baseUnit", "_weaponUnit", "_baseBackpack"];

		if (!alive _baseUnit || {!alive _weaponUnit} || {isNull _baseBackpack}) exitWith {
			_pfhId call CBA_fnc_removePerFrameHandler;
		};

		if !(moveToCompleted _baseUnit || {moveToCompleted _weaponUnit}) exitWith {};

		_pfhId call CBA_fnc_removePerFrameHandler;

		// Drop base on ground
		_baseUnit action ["PutBag"];

		[{
			(_this select 0) action ["Assemble", _this select 1];
		}, [_weaponUnit, _baseBackpack], 1] call CBA_fnc_waitAndExecute;
	}, 0, [_units select 0, _units select 1, _baseBackpack]] call CBA_fnc_addPerFrameHandler;
}, _baseBackpack, LSTRING(assembleStaticWeaponHere)] call zen_common_fnc_selectPosition;
