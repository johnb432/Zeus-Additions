/*
 * Author: johnb43
 * Spawns a module that allows Zeus to make dead bodies draggable.
 * Cobbled together out of ACE3 code.
 */

#include "module_dragBodies_init.sqf"

[LSTRING(moduleCategoryUtility), LSTRING(dragBodiesModuleName), {
    params ["", "_object"];

    [LSTRING(dragBodiesModuleName), [
        ["TOOLBOX:ENABLED", [LSTRING_ACE(dragging,drag), LSTRING(enableDragBodiesDesc)], false],
        ["TOOLBOX", ["str_a3_cfgvehicles_modulecuratoraddaddons_f_arguments_mode", LSTRING(changeSelectionDesc)], [0, 1, 2, [LSTRING(objectOnly), LSTRING(allDeadUnits)]]],
        ["TOOLBOX:YESNO", [LSTRING(includePlayerCorpses), LSTRING(includePlayerCorpsesDesc)], !isNil QGVAR(enableDraggingPlayers), true],
        ["TOOLBOX:ENABLED", [LSTRING(applyToFutureUnits), LSTRING(applyToFutureUnitsDesc)], !isNil QGVAR(enableDragging), true]
    ],
    {
        params ["_results", "_object"];
        _results params ["_dragging", "_all", "_includePlayers", "_allFuture"];

        // Select bodies not in vehicles, dead, not null and men
        private _bodies = (if (_all == 1) then {
            allDeadMen
        } else {
            [[], [_object]] select (!isNull _object && {!alive _object})
        }) select {isNull objectParent _x && {_x isKindOf "CAManBase"} && {!(_x isKindOf "VirtualCurator_F")}};

        if (!_includePlayers) then {
            _bodies = _bodies select {!isPlayer _x};
        };

        // Compile action only if it's going to be used
        if (isNil QGVAR(dragBodyActions) && {_dragging || {_allFuture}}) then {
            GVAR(dragBodyActions) = true;
            publicVariable QGVAR(dragBodyActions);

            #include "module_dragBodies_aceAction.sqf"
        };

        private _string = if (_bodies isNotEqualTo []) then {
            if (_dragging) then {
                 // Add action
                _bodies = _bodies select {!(_x getVariable [QGVAR(canDragBody), false])};

                if (_bodies isEqualTo []) exitWith {
                    LSTRING(noDeadBodiesWithoutDragFound)
                };

                {
                    _x setVariable [QGVAR(canDragBody), true, true];
                } forEach _bodies;

                [LSTRING(addedDragToBody), LSTRING(addedDragToBodies)] select (count _bodies != 1)
            } else {
                // Remove action
                _bodies = _bodies select {_x getVariable [QGVAR(canDragBody), false]};

                if (_bodies isEqualTo []) exitWith {
                    LSTRING(noDeadBodiesWithDragFound)
                };

                {
                    _x setVariable [QGVAR(canDragBody), false, true];
                } forEach _bodies;

                [LSTRING(removedDragToBody), LSTRING(removedDragToBodies)] select (count _bodies != 1)
            };
        } else {
            LSTRING(noDeadBodiesFound)
        };

        if (_includePlayers) then {
            if (!isNil QGVAR(enableDraggingPlayers)) exitWith {};

            GVAR(enableDraggingPlayers) = true;
            publicVariable QGVAR(enableDraggingPlayers);

            _string = LSTRING(enabledDragToAllFuturePlayerBodies);
        } else {
            if (isNil QGVAR(enableDraggingPlayers)) exitWith {};

            GVAR(enableDraggingPlayers) = nil;
            publicVariable QGVAR(enableDraggingPlayers);

            _string = LSTRING(disabledDragFromAllFuturePlayerBodies);
        };

        if (_allFuture) then {
            if (!isNil QGVAR(enableDragging)) exitWith {};

            GVAR(enableDragging) = true;
            publicVariable QGVAR(enableDragging);

            _string = LSTRING(enabledDragToAllFutureBodies);
        } else {
            if (isNil QGVAR(enableDragging)) exitWith {};

            GVAR(enableDragging) = nil;
            publicVariable QGVAR(enableDragging);

            _string = LSTRING(disabledDragFromAllFutureBodies);
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_PERSON] call zen_custom_modules_fnc_register;
