#include "..\script_component.hpp"
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

private _vehicles = [];
private _misc = [];

// If selection is either vehicles or all, include all vehicles
if (_filterMode in [PARADROP_VEHICLES, PARADROP_ALL]) then {
    _vehicles = _objects select {_x isKindOf "LandVehicle" || {_x isKindOf "Ship"}};
    GVAR(selectedParadropVehicles) = _vehicles;
};

if (_filterMode in [PARADROP_MISC, PARADROP_ALL]) then {
    _misc = _objects select {_x isKindOf "Thing"};
    GVAR(selectedParadropMisc) = _misc;
};

// If vehicles only, exit
if (_filterMode == PARADROP_VEHICLES) exitWith {
    [LSTRING(selectedParadropVehiclesContextMenu), count _vehicles] call zen_common_fnc_showMessage;
};

// If misc only, exit
if (_filterMode == PARADROP_MISC) exitWith {
    [LSTRING(selectedParadropObjectsContextMenu), count _misc] call zen_common_fnc_showMessage;
};

private _units = _objects select {_x isKindOf "CAManBase" && {!(_x isKindOf "VirtualCurator_F")}};

[LSTRING(paradropContextMenu), [
    ["TOOLBOX:YESNO", [LSTRING(paradropContextMenuIncludeGroup), LSTRING(paradropContextMenuIncludeGroupDesc)], false, true],
    ["TOOLBOX:YESNO", [LSTRING(paradropContextMenuIncludeVehicles), LSTRING(paradropContextMenuIncludeVehiclesDesc)], false, true]
], {
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
            _units insert [-1, (units _x) select {isNull objectParent _x || {_includeInside}}, true];
        } forEach _groups;
    } else {
        if (!_includeInside) exitWith {};

        // Add vehicle crews to the selected units
        {
            _units insert [-1, crew _x, true];
        } forEach _vehicles;
    };

    // Remove non-man entities
    _units = _units select {alive _x && {_x isKindOf "CAManBase"} && {!(_x isKindOf "VirtualCurator_F")}};

    GVAR(selectedParadropUnits) = _units;

    [LSTRING(paradropContextMenuMessage), count _units, count _vehicles, count _misc] call zen_common_fnc_showMessage;
}, {}, [_units, _vehicles, _misc]] call zen_dialog_fnc_create;
