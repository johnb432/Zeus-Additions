/*
 * Author: johnb43
 * Adds the ability to drag corpses whilst in Zeus and using the map.
 */

// Whenever player opens zeus interface, check if curator has changed; If change, reassign eventhandler
["zen_curatorDisplayLoaded", {
    private _curator = getAssignedCuratorLogic player;

    #ifdef ARMA_216
        if (!isNil {_curator getVariable QGVAR(curatorEhID)}) exitWith {};
    #else
        if !(_curator isNil QGVAR(curatorEhID)) exitWith {};
    #endif

    _curator setVariable [QGVAR(curatorEhID),
        _curator addEventHandler ["CuratorObjectEdited", {
            params ["", "_entity"];

            if (alive _entity || {!(_entity isKindOf "CAManBase")}) exitWith {};

            // Sync the corpse
            [QGVAR(awake), [_entity, true]] call CBA_fnc_globalEvent;
            [QGVAR(awake), [_entity, false]] call CBA_fnc_globalEvent;
            [QGVAR(awake), [_entity, true]] call CBA_fnc_globalEvent;
        }]
    ];
}] call CBA_fnc_addEventHandler;
