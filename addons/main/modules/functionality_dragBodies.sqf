/*
 * Author: johnb43
 * Adds the ability to drag corpses whilst in Zeus and using the map.
 */

// Whenever player opens zeus interface, check if curator has changed; If change, reassign eventhandler
["zen_curatorDisplayLoaded", {
    private _curator = getAssignedCuratorLogic player;

    if (isNull _curator || {!isNil {_curator getVariable QGVAR(curatorEhID)}}) exitWith {};

    _curator setVariable [QGVAR(curatorEhID),
        _curator addEventHandler ["CuratorObjectEdited", {
            params ["", "_entity"];

            if (alive _entity || {!(_entity isKindOf "CAManBase")}) exitWith {};

            // Turn on PhysX so that unit is not desynced when moving
            [_entity, true] remoteExecCall ["awake", 0];

            private _posASL = getPosASL _entity;

            if (round insideBuilding _entity == 1) then {
                _posASL = _posASL vectorAdd [0, 0, 0.05];
            };

            [{
                // Turn on PhysX so that unit does not desync when moving
                [_this select 0, true] remoteExecCall ["awake", 0];

                // Bring unit back to clone's position
                (_this select 0) setPosASL (_this select 1);
            }, [_target, _posASL], 0.25] call CBA_fnc_waitAndExecute;
        }]
    ];
}] call CBA_fnc_addEventHandler;
