#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Handles building destruction by making all items within a building fall to the ground.
 *
 * Arguments:
 * 0: Add or remove <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * true call zeus_additions_main_fnc_handleBuildingDestruction;
 *
 * Public: No
 */

params ["_add"];

// Have server call it on every client (make it JIP compatible)
if (isServer) then {
    [QGVAR(executeFunction), [QFUNC(handleBuildingDestruction), _add]] call CBA_fnc_remoteEvent;

    // FUNC(globalEventJIP) not guaranteed to exist on server
    [QGVAR(addEventJIP), [QGVAR(executeFunction), [QFUNC(handleBuildingDestruction), _add], QGVAR(handleBuildingDestructionJipID)]] call CBA_fnc_localEvent;
};

if (_add) then {
    if (!isNil QGVAR(handleBuildingDestructionEhID)) exitWith {};

    // When building model changes into ruined, turn on gravity on objects on/in building
    GVAR(handleBuildingDestructionEhID) = addMissionEventHandler ["BuildingChanged", {
        [QGVAR(executeFunction), [QFUNC(onBuildingDestroyed), _this]] call CBA_fnc_serverEvent;
    }];

    if (!isServer || {!isNil QGVAR(simulationHashmap)}) exitWith {};

    GVAR(simulationHashmap) = createHashMap;
    GVAR(destroyedBuildingCache) = createHashMap;

    // Code to run on server when building is destroyed
    DFUNC(onBuildingDestroyed) = compileFinal {
        params ["_from", "_to", "_isRuin"];

        if (!_isRuin || {_from == _to}) exitWith {};

        private _key = hashValue _from;

        // If the value has already been added to the cache, skip
        if (_key in GVAR(destroyedBuildingCache)) exitWith {};

        GVAR(destroyedBuildingCache) set [_key, nil];

        {
            // Buildings or dead non-PhysX objects are not subject to gravity
            if (_x isKindOf "Building" || {!alive _x && {!(_x isKindOf "AllVehicles")}}) then {
                _x call FUNC(simulateGravity);
            } else {
                // Update floating objects so that they fall
                _x enableSimulationGlobal true;

                [QGVAR(awake), [_x, true]] call CBA_fnc_globalEvent;
            };
        } forEach (((_from nearObjects ((boundingBoxReal _from) select 2)) - [_from, _to]) select {!(alive _x && {_x isKindOf "CAManBase"})});

        // Remove from cache after a delay
        [{
            GVAR(destroyedBuildingCache) deleteAt _this;
        }, _key, 5] call CBA_fnc_waitAndExecute;
    };

    // Simulate gravity at 30 FPS
    DFUNC(simulateGravity) = compileFinal {
        params ["_object"];

        GVAR(simulationHashmap) set [hashValue _object, [_object, getPosATL _object, time], true];

        if (!isNil QGVAR(simulationPfHID)) exitWith {};

        GVAR(simulationPfHID) = [{
            if (GVAR(simulationHashmap) isEqualTo createHashMap) exitWith {
                (_this select 1) call CBA_fnc_removePerFrameHandler;

                GVAR(simulationPfHID) = nil;
            };

            private _newPos = [];

            {
                _y params ["_object", "_beginPos", "_startTime"];

                _newPos = _beginPos vectorAdd [0, 0, -GRAVITY / 2 * (time - _startTime)^2];

                // Prevent objects from going under the map
                if (_newPos select 2 <= 0) then {
                    GVAR(simulationHashmap) deleteAt _x;

                    _newPos set [2, 0];

                    _object setVehiclePosition [_newPos, [], 0, "CAN_COLLIDE"];
                } else {
                    _object setPosATL _newPos;
                };

                if ((_newPos select 2) < 0.1) then {
                    ["zen_common_setVectorUp", [_object, surfaceNormal _newPos], _object] call CBA_fnc_targetEvent;
                };
            } forEach GVAR(simulationHashmap);
        }, 1/30] call CBA_fnc_addPerFrameHandler;
    };
} else {
    if (isNil QGVAR(handleBuildingDestructionEhID)) exitWith {};

    removeMissionEventHandler ["BuildingChanged", GVAR(handleBuildingDestructionEhID)];

    GVAR(handleBuildingDestructionEhID) = nil;
};
