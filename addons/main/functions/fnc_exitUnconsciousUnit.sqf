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

if (isNil QGVAR(exitUnconsciousID) && {GVAR(enableExitUnconsciousUnit)}) exitWith {
    // To exit the unit, the player must get to the pause menu
    GVAR(exitUnconsciousID) = [missionNamespace, "OnGameInterrupt", {
        // If Select Unit module is running, do special code
        if (!isNil QGVAR(remoteControlArgs)) exitWith {
            [{
                // Wait until the pause menu has been opened
                !isNull _this
            }, {
                // Close the pause menu
                _this closeDisplay IDC_CANCEL;

                call FUNC(remoteControlStop);
            }, _this select 0] call CBA_fnc_waitUntilAndExecute;
        };

        if !(!isNull GETMVAR("bis_fnc_moduleRemoteControl_unit",objNull) && {(lifeState bis_fnc_moduleRemoteControl_unit) == "INCAPACITATED" || {bis_fnc_moduleRemoteControl_unit getVariable ["ACE_isUnconscious", false]}}) exitWith {};

        [{
            // Wait until the pause menu has been opened
            !isNull _this
        }, {
            // Close the pause menu
            _this closeDisplay IDC_CANCEL;

            // Stop remote controlling unit
            bis_fnc_moduleRemoteControl_unit setVariable ["bis_fnc_moduleRemoteControl_owner", nil, true];

            objNull remoteControl bis_fnc_moduleRemoteControl_unit;
            bis_fnc_moduleRemoteControl_unit = nil;

            // Open curator interface, with a delay
            {
                {
                    openCuratorInterface;
                } call CBA_fnc_execNextFrame;
            } call CBA_fnc_execNextFrame;
        }, _this select 0] call CBA_fnc_waitUntilAndExecute;
    }] call BIS_fnc_addScriptedEventHandler;
};

if (!isNil QGVAR(exitUnconsciousID) && {!GVAR(enableExitUnconsciousUnit)}) exitWith {
    [missionNamespace, "OnGameInterrupt", GVAR(exitUnconsciousID)] call BIS_fnc_removeScriptedEventHandler;
     GVAR(exitUnconsciousID) = nil;
};
