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

private _addLines = {
    if (!_addedLines) then {
        _addedLines = true;

        diag_log text "";
        INFO_ZA("Your curator stats:");
    };
};

private _addedLines = false;
private _objects = createHashMap;
private _type = "";
private _categories = [["CAManBase","Men"], ["Car","Cars"], ["Tank","Tanks"], ["StaticWeapon","Static Weapons"], ["Helicopter","Helicopters"], ["Plane","Planes"], ["All","Misc."]];

{
    _type = _x;

    {
        _x params ["_classname", "_name"];

        _objects = _curatorObjects getOrDefault [format ["%1_%2", _type, _classname], createHashMap];

        if (_objects isNotEqualTo createHashMap) then {
            call _addLines;

            diag_log text format ["%1 %2:", _name, _type];

            // Log an item
            {
                diag_log text format ["    %1x '%2'", _y, _x];
            } forEach _objects;
        };
    } forEach _categories;
} forEach ["placed", "deleted"];

private _groups = _curatorObjects getOrDefault ["groups", 0];

if (_groups != 0) then {
    call _addLines;

    // Log groups placed
    diag_log text format ["%1 group(s) placed", _groups];
};

private _pings = _curatorObjects getOrDefault ["pings", createHashMap];

if (_pings isNotEqualTo createHashMap) then {
    call _addLines;

    private _unit = objNull;

    diag_log text "Pings:";

    {
        _unit = _x call BIS_fnc_getUnitByUID;

        diag_log text format ["    %1 pinged %2 time(s)", ["UID: " + _x, name _unit] select (!isNull _unit), _y];
    } forEach _pings;
};

if (_addedLines) then {
    diag_log text "";
};

if (_notify) then {
    [[LSTRING(missionObjectCounterNothingToPrintMessage), LSTRING(missionObjectCounterSomethingToPrintMessage)] select (_addedLines)] call zen_common_fnc_showMessage;
};
