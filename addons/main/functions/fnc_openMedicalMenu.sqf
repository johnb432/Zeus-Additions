#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module that allows you to open the medical menu of a unit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_openMedicalMenu;
 *
 * Public: No
 */

["Zeus Additions - Medical", "Open ACE Medical Menu", {
    params ["", "_unit"];

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if !(_unit isKindOf "CAManBase") exitWith {
         ["Select a unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    [_unit, MEDICAL_MENU] call FUNC(openACEMenu);
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
