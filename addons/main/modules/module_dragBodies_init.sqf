/*
 * Author: johnb43
 * Init for drag bodies module.
 */

INFO_ZA(FORMAT_1("Running %1",__FILE__));

// Can't use exitWith, as it would stop the module from being created
if (isNil QGVAR(draggingEH)) then {
    ["zen_common_execute", [{
        if (!isNil QGVAR(draggingEH)) exitWith {};

        GVAR(draggingEH) = true;
        publicVariable QGVAR(draggingEH);

        // When a unit is killed, enable interaction
        addMissionEventHandler ["EntityKilled", {
            params ["_unit"];

            if (isNil QGVAR(enableDragging) || {!(_unit isKindOf "CAManBase")} || {_unit isKindOf "VirtualCurator_F"}) exitWith {};
            if (isNil QGVAR(enableDraggingPlayers) && {isPlayer _unit}) exitWith {};

            _unit setVariable [QGVAR(canDragBody), true, true];
        }];
    } call FUNC(sanitiseFunction), []]] call CBA_fnc_serverEvent;

    ["zen_common_execute", [{
        if (!isNil QGVAR(bodyBagEhID)) exitWith {};

        // When unit has finished dragging, this event is triggered
        GVAR(bodyBagEhID) = ["ace_common_fixCollision", {
            params ["_clone"];

            (_clone getVariable [QGVAR(corpse), []]) params ["_target", ["_isInRemainsCollector", true], ["_isObjectHidden", false]];

            // If not a clone, exit
            if (isNil "_target") exitWith {};

            // Check if unit was deleted
            if (isNull _target) exitWith {
                deleteVehicle _clone;
            };

            private _posASL = getPosASL _clone;

            if (round insideBuilding _clone == 1) then {
                _posASL = _posASL vectorAdd [0, 0, 0.05];
            };

            if (_isInRemainsCollector) then {
                addToRemainsCollector [_target];
            };

            ["zen_common_execute", [{
                params ["_target"];

                // Turn on PhysX so that unit does not desync when moving
                [_target, true] remoteExecCall ["awake", 0];

                [{
                    params ["_target", "", "_isObjectHidden", "_posASL", "_direction"];

                    if (!_isObjectHidden) then {
                        _target hideObjectGlobal false;
                    };

                    // Make sure PhysX is on
                    [_target, true] remoteExecCall ["awake", 0];

                    // Set the unit's direction and bring unit back to clone's position
                    _target setDir _direction;
                    _target setPosASL _posASL;

                    [{
                        params ["_target", "_clone", "_isObjectHidden"];

                        // Release claim
                        [objNull, _target] call ace_common_fnc_claim;

                        // Add target back to curator interfaces
                        _target call zen_common_fnc_updateEditableObjects;

                        deleteVehicle _clone;
                    }, _this, 0.25] call CBA_fnc_waitAndExecute;
                }, _this, 0.25] call CBA_fnc_waitAndExecute;
            }, [_target, _clone, _isObjectHidden, _posASL, getDir ACE_player + 180]]] call CBA_fnc_serverEvent;
        }] call CBA_fnc_addEventHandler;
    } call FUNC(sanitiseFunction), []], QGVAR(bodyBagJIP)] call CBA_fnc_globalEventJIP;
};
