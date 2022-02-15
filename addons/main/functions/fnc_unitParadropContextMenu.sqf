#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds context menu for paradrop selection.
 *
 * Arguments:
 * 0: Objects <ARRAY>
 * 1: Type of filtering <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects, 2] call zeus_additions_main_fnc_unitParadropContextMenu;
 *
 * Public: No
 */

params ["_objects", "_filterMode"];

_objects = _objects select {alive _x};

private _units = _objects select {_x isKindOf "CAManBase"};
private _vehicles = _objects select {_x isKindOf "LandVehicle" || {_x isKindOf "Ship"}};
private _misc = _objects select {_x isKindOf "Thing"};

// If selection is either vehicles or all, include all vehicles
if (_filterMode in [PARADROP_VEHICLES, PARADROP_ALL]) then {
    GVAR(selectedParadropVehicles) = _vehicles;
};

if (_filterMode in [PARADROP_MISC, PARADROP_ALL]) then {
    GVAR(selectedParadropMisc) = _misc;
};

// If vehicles only, exit
if (_filterMode isEqualTo PARADROP_VEHICLES) exitWith {
    ["Selected %1 vehicles", count _vehicles] call zen_common_fnc_showMessage;
};

// If misc only, exit
if (_filterMode isEqualTo PARADROP_MISC) exitWith {
    ["Selected %1 misc objects", count _misc] call zen_common_fnc_showMessage;
};

["Paradrop Context Menu Selection", [
    ["TOOLBOX:YESNO", ["Include entire group", "If enabled and a unit is selected, his entire group is also selected."], false, true],
    ["TOOLBOX:YESNO", ["Include units in vehicles", "If enabled and the units selected are in vehicles, it will dismount them and paradrop them without their vehicles."], false, true]
],
{
    params ["_results", "_args"];
    _results params ["_includeGroup", "_includeInside"];
    _args params ["_units", "_vehicles", "_misc"];

    if (_includeGroup) then {
        private _groups = [];

        // Search for all groups, including vehicles if wanted
        {
            _groups pushBackUnique (group _x);
        } forEach (_units + ([[], _vehicles] select _includeInside));

        {
            _units append ((units _x) select {isNull objectParent _x || _includeInside});
        } forEach _groups;
    } else {
        if (!_includeInside) exitWith {};

        // Add vehicle crews to the selected units
        {
            _units append (crew _x);
        } forEach _vehicles;
    };

    // Remove non-man entities and duplicates
    _units = (_units arrayIntersect _units) select {alive _x && {_x isKindOf "CAManBase"}};

    GVAR(selectedParadropUnits) = _units;

    ["Selected %1 units, %2 vehicles & %3 objects", count _units, count _vehicles, count _misc] call zen_common_fnc_showMessage;
}, {
    ["Aborted"] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
}, [_units, _vehicles, _misc]] call zen_dialog_fnc_create;
