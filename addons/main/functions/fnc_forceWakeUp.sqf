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

if (!hasInterface) exitWith {};

["Zeus Additions - Medical", "Force consciousness change", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["Select a unit!"] call zen_common_fnc_showMessage;
    };

    if (!alive _unit) exitWith {
        ["Unit is dead!"] call zen_common_fnc_showMessage;
    };

    ["zen_common_execute", [ace_medical_status_fnc_setUnconsciousState, [_unit, !(_unit getVariable ["ACE_isUnconscious", false])]], _unit] call CBA_fnc_targetEvent;

    if (isPlayer _unit) then {
        ["zen_common_hint", ["Zeus has toggled your consciousness using a module."], _unit] call CBA_fnc_targetEvent;
    };
}] call zen_custom_modules_fnc_register;
