#include "script_component.hpp"

/*
 * Author: johnb43
 * When pressing ESCAPE whilst remote controlling an unconscious unit, it will put you back into curator.
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

if (isNil {GVAR(exitUnconsciousID)} && {GVAR(enableExitUnconsciousUnit)}) exitWith {
    // To exit the unit, the player must get to the pause menu
    GVAR(exitUnconsciousID) = [missionNamespace, "OnGameInterrupt", {
        if (isNil "bis_fnc_moduleRemoteControl_unit" || {!(bis_fnc_moduleRemoteControl_unit getVariable ["ACE_isUnconscious", false])}) exitWith {};

        [{
            // Wait until the pause menus has been opened
            !isNull (findDisplay IDD_INTERRUPT);
        }, {
            // Close the pause menu
            (findDisplay IDD_INTERRUPT) closeDisplay IDC_CANCEL;

            // Stop remote controlling unit
            objNull remoteControl bis_fnc_moduleRemoteControl_unit;
            bis_fnc_moduleRemoteControl_unit = nil;

            // Open curator interface
            {
                openCuratorInterface;
            } call CBA_fnc_execNextFrame;
        }] call CBA_fnc_waitUntilAndExecute;
    }] call BIS_fnc_addScriptedEventHandler;
};

if (!isNil {GVAR(exitUnconsciousID)} && {!GVAR(enableExitUnconsciousUnit)}) exitWith {
     [missionNamespace, "OnGameInterrupt", GVAR(exitUnconsciousID)] call BIS_fnc_removeScriptedEventHandler;
     GVAR(exitUnconsciousID) = nil;
};
