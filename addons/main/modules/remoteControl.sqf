/*
 * Author: johnb43
 * Creates a module that allows the Zeus to switch places with the selected AI unit.
 */

["Zeus Additions - AI", "Remote Control (Switch Unit)", {
    (_this select 1) call FUNC(remoteControlContextMenu);
}, ICON_REMOTECONTROL] call zen_custom_modules_fnc_register;
