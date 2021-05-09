#include "script_component.hpp"

/*
 * Author: johnb43
 * Find a selected unit's role
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

params ["_unit"];

private _type = 0;

switch (toLower getText (configOf _unit >> "icon")) do {
    case "iconmanengineer": {_type = 6};
    case "iconmanmedic": {_type = 5};
    case "iconmanmg": {_type = 4};
    case "iconmanleader": {_type = 1};
    default {};
};

if (_type isEqualTo 0) then {
    private _weapon = nil;

    if (!isNil {primaryWeapon _unit}) then {
        _weapon = primaryWeapon _unit
    };

    if (!isNil {secondaryWeapon _unit}) then {
        _weapon = secondaryWeapon _unit
    };

    switch (toLower getText (configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) do {
        case "\a3\weapons_f\data\ui\icon_mg_ca.paa": {_type = 4};
        case "\a3\weapons_f\data\ui\icon_aa_ca.paa": {_type = 3};
        case "\a3\weapons_f\data\ui\icon_at_ca.paa": {_type = 2};
        default {};
    };
};

_type
