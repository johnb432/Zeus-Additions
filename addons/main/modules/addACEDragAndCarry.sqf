/*
 * Author: johnb43
 * Spawns a module that allows Zeus to make object draggable and carriable, with ignoring of weight limits possible.
 */

["Zeus Additions - Utility", "Add ACE Drag and Carry Options", {
    params ["", "_object"];

    if (!alive _object) exitWith {
         ["Select an undestroyed object!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    if (_object isKindOf "CAManBase") exitWith {
         ["Select a non-unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    ["Add ACE Drag and Carry Options", [
        ["TOOLBOX:ENABLED", ["Dragging", "Enables the dragging of an object."], true],
        ["TOOLBOX:ENABLED", ["Carrying", "Enables the carrying of an object."], true],
        ["TOOLBOX:ENABLED", ["Overweight dragging", "Ignores the weight limit for dragging if enabled."], true],
        ["TOOLBOX:ENABLED", ["Overweight carrying", "Ignores the weight limit for carrying if enabled."], true]
    ],
    {
        params ["_results", "_object"];

        // Try to calculate offset and angle
        (boundingCenter _object) params ["_xCenter", "_yCenter"];
        (boundingBoxReal _object) params ["_minPos", "_maxPos"];
        _minPos params ["_xMin", "_yMin"];
        _maxPos params ["_xMax", "_yMax"];

        private _dX = _xMax - _xMin;
        private _dY = _yMax - _yMin;

        private _isWiderThanLonger = _dX > _dY;
        private _distance = 0.75 + ([_dY / 2, _dX / 2] select _isWiderThanLonger) + ([_yCenter, _xCenter] select _isWiderThanLonger);

        private _config = configOf _object;

        // Make crate draggable and carryable, with correct offsets to position and direction, along with overweight dragging possibility. Overwrite previous item in JIP queue
        // Remove event immediately so that it's removed from JIP queue in case object gets deleted. https://cbateam.github.io/CBA_A3/docs/files/events/fnc_removeGlobalEventJIP-sqf.html
        [["zen_common_execute", [{
            params ["_object", "_config", "_results", "_offset", "_isWiderThanLonger"];

            // Dragging & Carrying
            [_object, _results select 0, [_config, "ace_dragging_dragPosition", _offset] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_dragDirection", [0, 90] select _isWiderThanLonger] call BIS_fnc_returnConfigEntry, _results select 2] call ace_dragging_fnc_setDraggable;
            [_object, _results select 1, [_config, "ace_dragging_carryPosition", _offset] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_carryDirection", [90, 0] select _isWiderThanLonger] call BIS_fnc_returnConfigEntry, _results select 3] call ace_dragging_fnc_setCarryable;
        }, [_object, _config, _results, [[0, _distance, 0], [_distance, 0, 0]] select _isWiderThanLonger, _isWiderThanLonger]], [_object, QGVAR(dragging_)] call BIS_fnc_objectVar] call CBA_fnc_globalEventJIP, _object] call CBA_fnc_removeGlobalEventJIP;

        ["Changed ACE Drag and Carry abilities"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_OBJECT] call zen_custom_modules_fnc_register;
