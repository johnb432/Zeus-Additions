#include "script_component.hpp"

/*
 * Author: johnb43
 * Spawns a module that allows Zeus to make object draggable and carriable, with ignoring of weight limits possible.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_addACEDragAndCarry;
 *
 * Public: No
 */

["Zeus Additions - Utility", "[WIP] Add ACE Carry and Drag Options", {
    params ["", "_object"];

    if (isNull _object || {_unit isKindOf "CAManBase"}) exitWith {
         ["Select an object!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    ["[WIP] Add ACE Carry and Drag Options", [
        ["TOOLBOX:YESNO", ["Add dragging", "Adds the ability for an object to be dragged."], true],
        ["TOOLBOX:YESNO", ["Add carrying", "Adds the ability for an object to be carried."], true],
        ["TOOLBOX:YESNO", ["Allow overweight dragging", "Ignores the weight limit for dragging."], true],
        ["TOOLBOX:YESNO", ["Allow overweight carrying", "Ignores the weight limit for carrying."], true]
    ],
    {
        params ["_results", "_object"];

        // Try to calculate offset and angle
        (boundingBoxReal _object) params ["_minPos", "_maxPos", "_boundingSphereDiameter"];
        _minPos params ["_xMin", "_yMin", "_zMin"];
        _maxPos params ["_xMax", "_yMax", "_zMax"];

        (boundingCenter _object) params ["_xCenter", "_yCenter"];

        private _dX = _xMax - _xMin;
        private _dY = _yMax - _yMin;

        private _isWiderThanLonger = _dX > _dY;
        private _distance = 0.75 + ([_dY / 2, _dX / 2] select _isWiderThanLonger) + ([_yCenter, _xCenter] select _isWiderThanLonger);
        private _offset = [[0, _distance, 0], [_distance, 0, 0]] select _isWiderThanLonger;

        // Dragging
        if (_results select 0) then {
            ["zen_common_execute", [
                ace_dragging_fnc_setDraggable, [
                    _object,
                    true,
                    [configOf _object, "ace_dragging_dragPosition", _offset] call BIS_fnc_returnConfigEntry,
                    [configOf _object, "ace_dragging_dragDirection", [0, 90] select _isWiderThanLonger] call BIS_fnc_returnConfigEntry,
                    _results select 2
                ]
            ]] call CBA_fnc_globalEventJIP;
        };

        // Carrying
        if (_results select 1) then {
            ["zen_common_execute", [
                ace_dragging_fnc_setCarryable, [
                    _object,
                    true,
                    [configOf _object, "ace_dragging_carryPosition", _offset] call BIS_fnc_returnConfigEntry,
                    [configOf _object, "ace_dragging_carryDirection", [90, 0] select _isWiderThanLonger] call BIS_fnc_returnConfigEntry,
                    _results select 3
                ]
            ]] call CBA_fnc_globalEventJIP;
        };

        ["Changed carrying and dragging abilities"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_OBJECT] call zen_custom_modules_fnc_register;
