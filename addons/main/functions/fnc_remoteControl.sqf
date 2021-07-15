#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates a module that allows the Zeus to switch places with the selected AI unit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_remoteControl;
 *
 * Public: No
 */

["Zeus Additions - AI", "Remote Control (Switch Unit)", {
    params ["", "_unit"];

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if !(_unit isKindOf "CAManBase") exitWith {
         ["Select a unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    _unit call FUNC(remoteControlContextMenu);
}, ICON_REMOTECONTROL] call zen_custom_modules_fnc_register;
