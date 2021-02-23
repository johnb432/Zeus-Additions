#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module that forces a unit to wake up or go unconscious, regardless if they have stable vitals or not.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_forceWakeUp;
 *
 * Public: No
 */

["Zeus Additions", "Force consciousness change", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["Select a unit!"] call zen_common_fnc_showMessage;
    };

    if (!alive _unit) exitWith {
        ["Unit is dead!"] call zen_common_fnc_showMessage;
    };

    if (local _unit) then {
        [_unit, !(_unit getVariable ["ACE_isUnconscious", false])] call ace_medical_status_fnc_setUnconsciousState;
    } else {
        [_unit, !(_unit getVariable ["ACE_isUnconscious", false])] remoteExec ["ace_medical_status_fnc_setUnconsciousState", _unit];
    };

    if (isPlayer _unit) then {
        ["Zeus has toggled your consciousness using a module.", false, 10, 2] remoteExec ["ace_common_fnc_displayText", _unit];
    };
}] call zen_custom_modules_fnc_register;
