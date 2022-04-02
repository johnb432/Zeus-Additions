#include "script_component.hpp"

/*
 * Author: johnb43
 * Find a selected unit's role.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Role number <NUMBER>
 *
 * Example:
 * [player] call zeus_additions_main_fnc_getRole;
 *
 * Public: No
 */

private _type = switch (toLowerANSI getText (configOf _this >> "icon")) do {
    case "iconmanengineer": {6};
    case "iconmanmedic": {5};
    case "iconmanmg": {4};
    case "iconmanleader": {1};
    default {0};
};

if (_type isNotEqualTo 0) exitWith {
    _type;
};

private _weapon = "";

if (primaryWeapon _this isNotEqualTo "") then {
    _weapon = primaryWeapon _this;
};

// Tertiary weapon overwrites primary weapons
if (secondaryWeapon _this isNotEqualTo "") then {
    _weapon = secondaryWeapon _this;
};

if (_weapon isEqualTo "") exitWith {
    0;
};

switch (toLowerANSI getText (configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) do {
    case "\a3\weapons_f\data\ui\icon_mg_ca.paa": {4};
    case "\a3\weapons_f\data\ui\icon_aa_ca.paa": {3};
    case "\a3\weapons_f\data\ui\icon_at_ca.paa": {2};
    default {0};
};
