#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Initialises Zeus Additions on PCs.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_init;
 *
 * Public: No
 */

// Don't run function more than once on a PC
if (!isNil QGVAR(init)) exitWith {};

GVAR(init) = true;

// Macros don't like commas in strings
INFO_ZA(FORMAT_5(QUOTE(Init: Net mode: ARR_2(%1,%2) loaded: ARR_2(%3,remoteExecutedOwner): ARR_2(%4,clientOwner): %5),call BIS_fnc_getNetMode,toUpperANSI QUOTE(PREFIX),!isNil QUOTE(ADDON),remoteExecutedOwner,clientOwner));

// By wrapping the FUNC with 'call' we can send the FUNC only when we need them
[QGVAR(addBehaviourEh), LINKFUNC(addBehaviourEh)] call CBA_fnc_addEventHandler;
[QGVAR(addCarBombEh), LINKFUNC(addCarBombEh)] call CBA_fnc_addEventHandler;
[QGVAR(addDetonateAction), LINKFUNC(addDetonateAction)] call CBA_fnc_addEventHandler;
[QGVAR(addExplosionPreventionEh), LINKFUNC(addExplosionPreventionEh)] call CBA_fnc_addEventHandler;
[QGVAR(addSuicideEh), LINKFUNC(addSuicideEh)] call CBA_fnc_addEventHandler;
[QGVAR(addParachuteAction), LINKFUNC(addParachuteAction)] call CBA_fnc_addEventHandler;
[QGVAR(breachingAddAction), LINKFUNC(breachingAddAction)] call CBA_fnc_addEventHandler;
[QGVAR(setDraggableAndCarryable), LINKFUNC(setDraggableAndCarryable)] call CBA_fnc_addEventHandler;
[QGVAR(setResupplyDraggable), LINKFUNC(setResupplyDraggable)] call CBA_fnc_addEventHandler;

[QGVAR(setUnloadInCombat), {
    params ["_object", "_dismountPassengers", "_dismountCrew"];

    _object setUnloadInCombat [_dismountPassengers, _dismountCrew];
}] call CBA_fnc_addEventHandler;

// If single player, finish here
if (!isMultiplayer) exitWith {
    GVAR(functionsSent) = true;
};

// Whenever a player disconnects, reset his reasons
if (isServer) then {
    if (!isNil QGVAR(playerDisconnectedEh)) exitWith {};

    GVAR(playerDisconnectedEh) = true;
    publicVariable QGVAR(playerDisconnectedEh);

    addMissionEventHandler ["PlayerDisconnected", {
        params ["", "_uid"];

        [QGVAR(JIP), _uid, false, QFUNC(handleJIP)] call FUNC(changeReason);
        [QGVAR(buildingDestruction), _uid, false, QFUNC(handleBuildingDestruction)] call FUNC(changeReason);
    }];
};

// Send functions to server once (if necessary)
if (!isNil QUOTE(ADDON) && {isNil QGVAR(functionsSent)}) then {
    if (!isServer) then {
        SEND_SERVER(changeReason);
        SEND_MP(handleBuildingDestruction);
        SEND_SERVER(handleJIP);
    };

    GVAR(functionsSent) = true;
    publicVariable QGVAR(functionsSent);
};
