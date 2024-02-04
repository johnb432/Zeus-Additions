/*
 * Author: johnb43
 * Spawns a module that allows Zeus to make object draggable and carriable, with ignoring of weight limits possible.
 */

[LSTRING(moduleCategoryUtility), LSTRING(dragAndCarryModuleName), {
    params ["", "_object"];

    if (isNull _object) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    if (!alive _object) exitWith {
        [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
    };

    if (_object isKindOf "CAManBase") exitWith {
        [LSTRING_ZEN(modules,onlyNonInfantry)] call zen_common_fnc_showMessage;
    };

    [LSTRING(dragAndCarryModuleName), [
        ["TOOLBOX:ENABLED", [LSTRING_ACE(dragging,drag), LSTRING(enableDragDesc)], true],
        ["TOOLBOX:ENABLED", [LSTRING_ACE(dragging,carry), LSTRING(enableCarryDesc)], true],
        ["TOOLBOX:ENABLED", [LSTRING(enableDragOverweight), LSTRING(enableDragOverweightDesc)], true],
        ["TOOLBOX:ENABLED", [LSTRING(enableCarryOverweight), LSTRING(enableCarryOverweightDesc)], true]
    ], {
        params ["_results", "_object"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

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

        if (isNil QFUNC(setDraggableAndCarryable)) then {
            DFUNC(setDraggableAndCarryable) = [{
                params ["_object", "_config", "_results", "_offset", "_isWiderThanLonger"];

                // Dragging & Carrying
                [_object, _results select 0, [_config, "ace_dragging_dragPosition", _offset] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_dragDirection", [0, 90] select _isWiderThanLonger] call BIS_fnc_returnConfigEntry, _results select 2] call ace_dragging_fnc_setDraggable;
                [_object, _results select 1, [_config, "ace_dragging_carryPosition", _offset] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_carryDirection", [90, 0] select _isWiderThanLonger] call BIS_fnc_returnConfigEntry, _results select 3] call ace_dragging_fnc_setCarryable;
            }, true, true] call FUNC(sanitiseFunction);

            SEND_MP(setDraggableAndCarryable);
        };

        // Make crate draggable and carryable, with correct offsets to position and direction, along with overweight dragging possibility; Overwrite previous entry in JIP queue
        [[QGVAR(executeFunction), [QFUNC(setDraggableAndCarryable), [_object, _config, _results, [[0, _distance, 0], [_distance, 0, 0]] select _isWiderThanLonger, _isWiderThanLonger]], QGVAR(dragging_) + hashValue _object] call FUNC(globalEventJIP), _object] call FUNC(removeGlobalEventJIP);

        [LSTRING(changedDragAndCarryMessage)] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_OBJECT] call zen_custom_modules_fnc_register;
