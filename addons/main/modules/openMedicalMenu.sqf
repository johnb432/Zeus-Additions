/*
 * Author: johnb43
 * Adds a module that allows you to open the medical menu of a unit.
 */

["Zeus Additions - Medical", "Open ACE Medical Menu", {
    params ["", "_unit"];

    // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
    if (alive _unit) then {
        _unit = effectiveCommander _unit;
    };

    if !(_unit isKindOf "CAManBase") exitWith {
         ["Select a unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    [_unit, MEDICAL_MENU] call FUNC(openACEMenu);
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
