#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds context menu for paradrop selection.
 *
 * Arguments:
 * 0: Objects <ARRAY>
 * 1: Type of filtering <INTEGER>
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

private _units = _objects select {_x isKindOf "CAManBase"};
private _vehicles = _objects select {_x isKindOf "LandVehicle" || {_x isKindOf "Ship"}};

// If selection is either vehicles or all, include all vehicles
if (_filterMode isNotEqualTo 0) then {
    GVAR(selectedParadropVehicles) = _vehicles;
};

// If only vehicles, exit
if (_filterMode isEqualTo 1) exitWith {
    ["Selected %1 vehicles", count _vehicles] call zen_common_fnc_showMessage;
};

["Paradrop Context Menu Selection", [
    ["TOOLBOX:YESNO", ["Include entire group", "If enabled and a unit is selected, his entire group is also selected."], false, true],
    ["TOOLBOX:YESNO", ["Include units in vehicles", "If enabled and the units selected are in vehicles, it will dismount them and paradrop them without their vehicles."], false, true]
],
{
    params ["_results", "_args"];
    _results params ["_includeGroup", "_includeInside"];
    _args params ["_units", "_vehicles"];

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
    _units = (_units arrayIntersect _units) select {_x isKindOf "CAManBase"};

    GVAR(selectedParadropUnits) = _units;
    ["Selected %1 units & %2 vehicles", count _units, count _vehicles] call zen_common_fnc_showMessage;
}, {
    ["Aborted"] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
}, [_units, _vehicles]] call zen_dialog_fnc_create;
