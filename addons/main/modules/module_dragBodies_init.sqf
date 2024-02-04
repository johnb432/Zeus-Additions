/*
 * Author: johnb43
 * Init for drag bodies module.
 */

INFO_1("Running %1",__FILE__);

// Can't use exitWith, as it would stop the module from being created
if (isNil QGVAR(draggingEH)) then {
    ["zen_common_execute", [{
        if (!isNil QGVAR(draggingEH)) exitWith {};

        GVAR(draggingEH) = true;
        publicVariable QGVAR(draggingEH);

        // When a unit is killed, enable interaction
        addMissionEventHandler ["EntityKilled", {
            params ["_unit"];

            if (isNil QGVAR(enableDragging) || {!(_unit isKindOf "CAManBase")} || {getNumber ((configOf _unit) >> "isPlayableLogic") == 1}) exitWith {};
            if (isNil QGVAR(enableDraggingPlayers) && {isPlayer _unit}) exitWith {};

            _unit setVariable [QGVAR(canDragBody), true, true];
        }];
    } call FUNC(sanitiseFunction), []]] call CBA_fnc_serverEvent;

    ["zen_common_execute", [{
        if (!isNil QGVAR(bodyBagEhID)) exitWith {};

        GVAR(bodyBagEhID) = true;

        // Extended EH doesn't fire for dead units, so add interactions manually
        {
            private _type = typeOf _x;

            if (ace_interact_menu_inheritedClassesMan pushBackUnique _type == -1) then {
                continue;
            };

            {
                _x params ["_typeNum", "_parentPath", "_action"];
                [_type, _typeNum, _parentPath, _action] call ace_interact_menu_fnc_addActionToClass;
            } forEach ace_interact_menu_inheritedActionsMan;
        } forEach allDeadMen;

        DFUNC(moveCorpse) = compileFinal {
            params ["_corpse", "_dir", "_pos"];

            // Set direction before position
            _corpse setDir _dir;

            // Bring corpse back to clone's position
            _corpse setPosATL _pos;

            // Sync the corpse
            [QGVAR(awake), [_corpse, true]] call CBA_fnc_globalEvent;
            [QGVAR(awake), [_corpse, false]] call CBA_fnc_globalEvent;
            [QGVAR(awake), [_corpse, true]] call CBA_fnc_globalEvent;
        };

        // When unit has finished dragging, this event is triggered
        ["ace_common_fixCollision", {
            params ["_clone"];

            (_clone getVariable [QGVAR(corpse), []]) params ["_target", "_garbageCollectors", ["_isObjectHidden", false], ["_simulationEnabled", true]];

            // If not a clone, exit
            if (isNil "_target") exitWith {};

            // Check if unit was deleted
            if (isNull _target) exitWith {
                // Detach first to prevent objNull in attachedObjects
                detach _clone;
                deleteVehicle _clone;
            };

            private _pos = getPosATL _clone;

            // Make sure position is not underground
            if (_pos select 2 < 0.05) then {
                _pos set [2, 0.05];
            };

            // Move the unit where it is local
            [QGVAR(executeFunction), [QFUNC(moveCorpse), [_target, getDir ACE_player + 180, _pos]], _target] call CBA_fnc_targetEvent;

            // Unhide unit
            if (!_isObjectHidden) then {
                ["zen_common_hideObjectGlobal", [_target, false]] call CBA_fnc_serverEvent;
            };

            // Enable simulation again
            if (_simulationEnabled) then {
                ["zen_common_enableSimulationGlobal", [_target, true]] call CBA_fnc_serverEvent;
            };

            // Detach first to prevent objNull in attachedObjects
            detach _clone;
            deleteVehicle _clone;

            // Get which curators had this object as editable
            private _objectCurators = _target getVariable [QGVAR(objectCurators), []];

            if (_objectCurators isNotEqualTo []) then {
                [[_target], true, _objectCurators] call zen_common_fnc_updateEditableObjects;
            };

            _garbageCollectors params [["_isInRemainsCollector", true], ["_isInClibCollector", true]];

            if (_isInRemainsCollector) then {
                addToRemainsCollector [_target];
            };

            if (_isInClibCollector) then {
                _target setVariable ["CLib_noClean", false, true];
            };
        }] call CBA_fnc_addEventHandler;
    } call FUNC(sanitiseFunction), []], QGVAR(bodyBagJIP)] call CBA_fnc_globalEventJIP;
};
