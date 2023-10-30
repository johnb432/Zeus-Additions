#include "..\script_component.hpp"
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

if (GVAR(enableExitUnconsciousUnit)) then {
    if (!isNil QGVAR(exitUnconsciousEhID)) exitWith {};

    // To exit the unit, the player must get to the pause menu
    GVAR(exitUnconsciousEhID) = [missionNamespace, "OnGameInterrupt", {
        if !(!isNull GETMVAR("bis_fnc_moduleRemoteControl_unit",objNull) && {lifeState bis_fnc_moduleRemoteControl_unit == "INCAPACITATED"}) exitWith {};

        [{
            // Wait until the pause menu has been opened
            !isNull _this
        }, {
            // Close the pause menu
            _this closeDisplay IDC_CANCEL;

            // If Switch Unit module is running, run special code
            if (!isNil QGVAR(switchUnitArgs)) exitWith {
                call FUNC(switchUnitStop);
            };

            // Stop remote controlling unit
            bis_fnc_moduleRemoteControl_unit setVariable ["bis_fnc_moduleRemoteControl_owner", nil, true];

            objNull remoteControl bis_fnc_moduleRemoteControl_unit;
            bis_fnc_moduleRemoteControl_unit = nil;

            // Open curator interface, with a delay
            [{
                openCuratorInterface;
            }, [], 2] call CBA_fnc_execAfterNFrames;
        }, _this select 0] call CBA_fnc_waitUntilAndExecute;
    }] call BIS_fnc_addScriptedEventHandler;
} else {
    if (isNil QGVAR(exitUnconsciousEhID)) exitWith {};

    [missionNamespace, "OnGameInterrupt", GVAR(exitUnconsciousEhID)] call BIS_fnc_removeScriptedEventHandler;
     GVAR(exitUnconsciousEhID) = nil;
};
