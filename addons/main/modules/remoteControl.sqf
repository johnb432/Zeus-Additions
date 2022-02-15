/*
 * Author: johnb43
 * Creates a module that allows the Zeus to switch places with the selected AI unit.
 */

["Zeus Additions - AI", "Remote Control (Switch Unit)", {
    params ["", "_unit"];

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if !(alive _unit && {_unit isKindOf "CAManBase"}) exitWith {
        ["Select a living unit!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    if (isPlayer _unit) exitWith {
        ["Select a non-player unit!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    _unit call FUNC(remoteControlContextMenu);
}, ICON_REMOTECONTROL] call zen_custom_modules_fnc_register;
