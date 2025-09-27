#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Returns children actions for assembling static weapons.
 *
 * Arguments:
 * 0: Objects <OBJECT>
 *
 * Return Value:
 * Actions <ARRAY>
 *
 * Example:
 * [units cursorObject] call zeus_additions_main_fnc_assembleStaticWeaponActions;
 *
 * Public: No
 */

params ["_objects"];

// Get all backpacks that can be used to assemble a static weapon
private _unitBackpacks = [];

{
    private _backpack = backpackContainer _x;

    if (!isNull _backpack && {!isNull (configOf _backpack >> "assembleInfo")}) then {
        _unitBackpacks pushBack [_x, backpackContainer _x];
    };
} forEach (_objects select {alive _x && {_x isKindOf "CAManBase"}});

private _validPairs = [];

// Check if there are any other units that have valid backpacks
{
    _x params ["_unit", "_backpack"];

    private _backpackType = typeOf _backpack;

    {
       if (((getArray (configOf (_x select 1) >> "assembleInfo" >> "base")) findIf {_backpackType == _x}) != -1) then {
           _validPairs pushBack [[_unit, _backpack], _x];
       };
    } forEach _unitBackpacks;
} forEach _unitBackpacks;

private _cfgVehicles = configFile >> "CfgVehicles";

_validPairs apply {
    _x params ["", "_weapon"];

    private _staticConfig = _cfgVehicles >> getText (configOf (_weapon select 1) >> "assembleInfo" >> "assembleTo");

    [
        [
            hashValue (_weapon select 1),
            getText (_staticConfig >> "displayName"),
            getText (_staticConfig >> "picture"),
            {
                _args call FUNC(assembleStaticWeapon);
            },
            {true},
            _x
        ] call zen_context_menu_fnc_createAction,
        [],
        0
    ]
} // return
