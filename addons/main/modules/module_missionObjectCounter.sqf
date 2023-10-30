/*
 * Author: johnb43
 * Spawns a module that keeps track of what stuff has been spawned by you as a curator.
 */

[LSTRING(moduleCategoryUtility), LSTRING(missionObjectCounterModuleName), {
    true call FUNC(logCuratorObjects);
}, ICON_OBJECT] call zen_custom_modules_fnc_register;

// When mission ends, add data to RPT
addMissionEventHandler ["Ended", {
    false call FUNC(logCuratorObjects);
}];
