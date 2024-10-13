/*
 * Author: johnb43
 * Adds the ability to drag corpses whilst in Zeus and using the map.
 */

// Whenever player opens zeus interface, check if curator has changed; If change, reassign eventhandler
["zen_curatorDisplayLoaded", {
    private _curator = getAssignedCuratorLogic player;

    if !(_curator isNil QGVAR(curatorEhID)) exitWith {};

    _curator setVariable [QGVAR(curatorEhID),
        _curator addEventHandler ["CuratorObjectEdited", {
            params ["", "_entity"];

            if (alive _entity || {!(_entity isKindOf "CAManBase")}) exitWith {};

            // Sync the corpse
            if (getNumber (_cfgPatches >> "ace_main" >> "version") >= 3.18) then {
                ["ace_dragging_moveCorpse", [_entity, getDir _entity, getPosATL _entity]] call CBA_fnc_globalEvent;
            } else {
                [QGVAR(awake), [_entity, true]] call CBA_fnc_globalEvent;
                [QGVAR(awake), [_entity, false]] call CBA_fnc_globalEvent;
                [QGVAR(awake), [_entity, true]] call CBA_fnc_globalEvent;
            };
        }]
    ];
}] call CBA_fnc_addEventHandler;
