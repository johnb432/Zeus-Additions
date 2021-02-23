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
 * call zeus_additions_main_fnc_getRole;
 *
 * Public: No
 */

params ["_unit"];

private _type = 0;

if (isText(configFile >> "CfgVehicles" >> typeOf _unit >> "icon")) then {
    private _icon = getText(configFile >> "CfgVehicles" >> typeOf _unit >> "icon");

    switch (_icon) do {
        case "iconManEngineer": {_type = 6};
        case "iconManMG": {_type = 4};
        case "iconManMedic": {_type = 5};
        case "iconManLeader": {_type = 1};
        default {};
    };
};

if (_type isEqualTo 0) then {
    private _weapon = nil;

    if (!isNil {primaryWeapon _unit}) then {
        _weapon = primaryWeapon _unit
    };

    if (!isNil {secondaryWeapon _unit}) then {
        _weapon = secondaryWeapon _unit
    };

    if (isText(configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) then {
        switch (getText(configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) do {
            case "\A3\weapons_f\data\UI\icon_mg_CA.paa": {_type = 4};
            case "\A3\Weapons_F\Data\UI\icon_aa_CA.paa": {_type = 3};
            case "\A3\Weapons_F\Data\UI\icon_at_CA.paa": {_type = 2};
            default {};
        };
    };
};

_type
