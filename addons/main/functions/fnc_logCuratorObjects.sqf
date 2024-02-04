#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Puts items that curator interacted with in log.
 *
 * Arguments:
 * 0: Display notification in zeus banner <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * true call zeus_additions_main_fnc_logCuratorObjects;
 *
 * Public: No
 */

params ["_notify"];

if (!GVAR(enableMissionCounter)) exitWith {
    if (_notify) then {
        [LSTRING(missionObjectCounterTurnedOffMessage)] call zen_common_fnc_showMessage;
    };
};

private _curatorObjects = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),getPlayerUID player),createHashMap);

if (_curatorObjects isEqualTo createHashMap) exitWith {
    if (_notify) then {
        [LSTRING(missionObjectCounterNothingToPrintMessage)] call zen_common_fnc_showMessage;
    };
};

private _logEntries = [];

private _objects = createHashMap;
private _type = "";
private _categories = [["CAManBase","Men"], ["Car","Cars"], ["Tank","Tanks"], ["StaticWeapon","Static Weapons"], ["Helicopter","Helicopters"], ["Plane","Planes"], ["All","Misc."]];

{
    _type = _x;

    {
        _x params ["_classname", "_name"];

        _objects = _curatorObjects getOrDefault [format ["%1_%2", _type, _classname], createHashMap];

        if (_objects isNotEqualTo createHashMap) then {
            _logEntries pushBack format ["%1 %2:", _name, _type];

            // Log an item
            {
                _logEntries pushBack format ["    %1x '%2'", _y, _x];
            } forEach _objects;
        };
    } forEach _categories;
} forEach ["placed", "deleted"];

private _groups = _curatorObjects getOrDefault ["groups", 0];

// Log groups placed
if (_groups != 0) then {
    _logEntries pushBack format ["%1 group(s) placed", _groups];
};

private _pings = _curatorObjects getOrDefault ["pings", createHashMap];

// Log pings
if (_pings isNotEqualTo createHashMap) then {
    call _addLines;

    private _unit = objNull;

    _logEntries pushBack "Pings:";

    {
        _unit = _x call BIS_fnc_getUnitByUID;

        _logEntries pushBack format ["    %1 pinged %2 time(s)", ["UID: " + _x, name _unit] select (!isNull _unit), _y];
    } forEach _pings;
};

private _addedLines = _logEntries isNotEqualTo [];

// Print to RPT
if (_addedLines) then {
    // Add header
    _logEntries insert [0, ["Your curator stats:"]];

    INFO(_logEntries joinString endl);
};

// Put in Zeus banner if wanted
if (_notify) then {
    [[LSTRING(missionObjectCounterNothingToPrintMessage), LSTRING(missionObjectCounterSomethingToPrintMessage)] select _addedLines] call zen_common_fnc_showMessage;
};
