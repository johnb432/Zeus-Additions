#include "..\script_component.hpp"
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
 * player call zeus_additions_main_fnc_getRole;
 *
 * Public: No
 */

params ["_unit"];

// Use unit traits first
private _type = switch (true) do {
    case (_unit getVariable ["ace_medical_medicClass", parseNumber (_unit getUnitTrait "medic")] > 0): {5};
    case (_unit getVariable ["ACE_isEOD", _unit getUnitTrait "explosiveSpecialist"]): {6};
    case (_unit getVariable ["ACE_IsEngineer", parseNumber (_unit getUnitTrait "engineer")] > 0): {6};
    default {0};
};

if (_type != 0) exitWith {
    _type
};

// Check icons
_type = switch (toLowerANSI getText (configOf _unit >> "icon")) do {
    // "iconmanat" exists, but it's used for both AT and AA
    case "iconmanengineer": {6};
    case "iconmanmedic": {5};
    case "iconmanmg": {4};
    case "iconmanleader": {1};
    default {0};
};

if (_type != 0) exitWith {
    _type
};

// Tertiary weapon overwrites primary weapons
private _weapon = secondaryWeapon _unit;

if (_weapon == "") then {
    _weapon = primaryWeapon _unit;
};

if (_weapon == "") exitWith {
    0
};

switch (toLowerANSI getText (configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) do {
    case "\a3\weapons_f\data\ui\icon_mg_ca.paa": {4};
    case "\a3\weapons_f\data\ui\icon_aa_ca.paa": {3};
    case "\a3\weapons_f\data\ui\icon_at_ca.paa": {2};
    default {0};
};
