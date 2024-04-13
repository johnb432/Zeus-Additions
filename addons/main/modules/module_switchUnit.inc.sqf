/*
 * Author: johnb43
 * Creates a module that allows the Zeus to switch places with the selected AI unit.
 */

[LSTRING(moduleCategoryAI), LSTRING(switchUnitModuleName), {
    (_this select 1) call FUNC(switchUnitStart);
}, ICON_REMOTECONTROL] call zen_custom_modules_fnc_register;
