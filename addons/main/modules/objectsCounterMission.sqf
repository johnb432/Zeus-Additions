/*
 * Author: johnb43
 * Spawns a module that keeps track of what stuff has been spawned by you as a curator.
 */

["Zeus Additions - Utility", "Show Mission Object Counter", {
    if (!GVAR(enableMissionCounter)) exitWith {
        ["Module is turned off in CBA settings!"] call zen_common_fnc_showMessage;
    };

    if (isNil FORMAT_1(QGVAR(curatorObjects_%1),str (getAssignedCuratorLogic player))) exitWith {
        ["Nothing to print to log!"] call zen_common_fnc_showMessage;
    };

    private _index = 0;
    private _types = ["Men", "Cars", "Tanks", "Static Weapons", "Helicopters", "Planes", "Misc.", "Pings", "Deletions", "Groups"];

    diag_log text "[Zeus Additions]: Your curator stats:";

    // List all objects in hashmaps
    {
        _index = _forEachIndex;

        diag_log text format ["    %1:", _types select _index];

        {
            switch (_index) do {
                case 7: {diag_log text format ["        %1x pinged %2 time(s)", ["UID: " + str _x, name (_x call BIS_fnc_getUnitByUID)] select (!isNull (_x call BIS_fnc_getUnitByUID)), _y]};
                case 8: {diag_log text format ["        %1 entities deleted", _y]};
                case 9: {diag_log text format ["        %1 groups placed", _y]};
                default {diag_log text format ["        %1x '%2' placed", _y, _x]};
            };
        } forEach _x;
    } forEach GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),str (getAssignedCuratorLogic player)),nil);

    ["Added curator stats to RPT log"] call zen_common_fnc_showMessage;
}, ICON_OBJECT] call zen_custom_modules_fnc_register;

// When mission ends, add stuff to RPT
addMissionEventHandler ["Ended", {
    if (!GVAR(enableMissionCounter) || {isNil FORMAT_1(QGVAR(curatorObjects_%1),str (getAssignedCuratorLogic player))}) exitWith {};

    private _index = 0;
    private _types = ["Men", "Cars", "Tanks", "Static Weapons", "Helicopters", "Planes", "Misc.", "Pings", "Deletions", "Groups"];

    diag_log text "[Zeus Additions]: Your curator stats at mission end:";

    // List all objects in hashmaps
    {
        _index = _forEachIndex;

        diag_log text format ["    %1:", _types select _index];

        {
            switch (_index) do {
                case 7: {diag_log text format ["        %1x pinged %2 time(s)", ["UID: " + str _x, name (_x call BIS_fnc_getUnitByUID)] select (!isNull (_x call BIS_fnc_getUnitByUID)), _y]};
                case 8: {diag_log text format ["        %1 entities deleted", _y]};
                case 9: {diag_log text format ["        %1 groups placed", _y]};
                default {diag_log text format ["        %1x '%2' placed", _y, _x]};
            };
        } forEach _x;
    } forEach GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),str (getAssignedCuratorLogic player)),nil);
}];
