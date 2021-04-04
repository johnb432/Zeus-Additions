#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds context menu for paradrop selection
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_unitParadropContextMenu;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Add context menu & submenus
[[QGVAR(selectParadropMenu), "Select units/objects for paradrop", "", {}, {
    count (curatorSelected select 0) > 0 || count (curatorSelected select 1) > 0
}, [], {}] call zen_context_menu_fnc_createAction, [], 0] call zen_context_menu_fnc_addAction;

[[QGVAR(selectParadropUnitsMenu), "Select units only", "", {
    curatorSelected params ["_objects"];

    private _units = _objects select {_x isKindOf "CAManBase"};
    private _vehicles = _objects select {_x isKindOf "LandVehicle"};

    ["[WIP] Paradrop Context Menu Selection", [
        ["CHECKBOX", ["Include entire group", "If enabled and a unit is selected, his entire group is also selected."], false, true],
        ["CHECKBOX", ["Include units in vehicles", "If enabled and the units selected are in vehicles, it will dismount them and paradrop them without their vehicles."], false, true]
    ],
    {
        params ["_results", "_args"];
        _results params ["_includeGroup", "_includeInside"];
        _args params ["_units", "_vehicles"];

        if (_includeGroup) then {
            private _groups = [];
            {
                _groups pushBackUnique (group _x);
            } forEach (_units + ([[], _vehicles] select _includeInside));

            {
                _units append ((units _x) select {isNull objectParent _x || _includeInside});
            } forEach _groups;
        } else {
            if (!_includeInside) exitWith {};

            {
                _units append (crew _x);
            } forEach _vehicles;
        };

        _units = _units arrayIntersect _units;
        _units = _units select {_x isKindOf "CAManBase"};

        GVAR(selectedParadropUnits) = _units;
        ["Selected %1 units", count _units] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_units, _vehicles]] call zen_dialog_fnc_create;
}] call zen_context_menu_fnc_createAction, [QGVAR(selectParadropMenu)], 0] call zen_context_menu_fnc_addAction;

[[QGVAR(selectParadropVehiclesMenu), "Select vehicles only", "", {
    curatorSelected params ["_objects"];

    private _vehicles = _objects select {_x isKindOf "LandVehicle"};
    GVAR(selectedParadropVehicles) = _vehicles;
    ["Selected %1 vehicles", count _vehicles] call zen_common_fnc_showMessage;
}] call zen_context_menu_fnc_createAction, [QGVAR(selectParadropMenu)], 0] call zen_context_menu_fnc_addAction;

[[QGVAR(selectParadropAllMenu), "Select all", "", {
    curatorSelected params ["_objects"];

    private _units = _objects select {_x isKindOf "CAManBase"};
    private _vehicles = _objects select {_x isKindOf "LandVehicle"};
    GVAR(selectedParadropVehicles) = _vehicles;

    ["[WIP] Paradrop Context Menu Selection", [
        ["CHECKBOX", ["Include entire group", "If enabled and a unit is selected, his entire group is also selected."], false, true],
        ["CHECKBOX", ["Include units in vehicles", "If enabled and the units selected are in vehicles, it will dismount them and paradrop them without their vehicles."], false, true]
    ],
    {
        params ["_results", "_args"];
        _results params ["_includeGroup", "_includeInside"];
        _args params ["_units", "_vehicles"];

        if (_includeGroup) then {
            private _groups = [];
            {
                _groups pushBackUnique (group _x);
            } forEach (_units + ([[], _vehicles] select _includeInside));

            {
                _units append ((units _x) select {isNull objectParent _x || _includeInside});
            } forEach _groups;
        } else {
            if (!_includeInside) exitWith {};

            {
                _units append (crew _x);
            } forEach _vehicles;
        };

        _units = _units arrayIntersect _units;
        _units = _units select {_x isKindOf "CAManBase"};

        GVAR(selectedParadropUnits) = _units;
        ["Selected %1 units & %2 vehicles", count _units, count _vehicles] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_units, _vehicles]] call zen_dialog_fnc_create;
}] call zen_context_menu_fnc_createAction, [QGVAR(selectParadropMenu)], 0] call zen_context_menu_fnc_addAction;
