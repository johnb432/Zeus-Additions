#include "script_component.hpp"

/*
 * Author: johnb43
 * When pressing escape whilst remote controlling an unconscious unit, it will put you back into curator.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_exitUnconsciousUnit;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

if (isNil {GVAR(exitUnconsciousID)} && {GVAR(enableExitUnconsciousUnit)}) exitWith {
    GVAR(exitUnconsciousID) = [missionNamespace, "OnGameInterrupt", {
        if (!isNil {bis_fnc_moduleRemoteControl_unit} && {bis_fnc_moduleRemoteControl_unit getVariable ["ACE_isUnconscious", false]}) then {
            [{
                !isNull (findDisplay 49)
            }, {
                // Close the pause menu
                (findDisplay 49) closeDisplay 0;

                // Stop remote controlling unit
                objNull remoteControl bis_fnc_moduleRemoteControl_unit;
                bis_fnc_moduleRemoteControl_unit = nil;
                openCuratorInterface;
            }] call CBA_fnc_waitUntilAndExecute;
        };
    }] call BIS_fnc_addScriptedEventHandler;
};

if (!isNil {GVAR(exitUnconsciousID)} && {!GVAR(enableExitUnconsciousUnit)}) exitWith {
     [missionNamespace, "OnGameInterrupt", GVAR(exitUnconsciousID)] call BIS_fnc_removeScriptedEventHandler;
     GVAR(exitUnconsciousID) = nil;
};
