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
 * call zeus_additions_main_fnc_toggleConsciousnessForced;
 *
 * Public: No
 */

["Zeus Additions - Medical", "Toggle Consciousness (forced)", {
    params ["", "_unit"];

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if !(_unit isKindOf "CAManBase") exitWith {
         ["Select a unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    if (!alive _unit) exitWith {
        ["Unit is dead!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    // Toggle consciousness
    ["zen_common_execute", [ace_medical_status_fnc_setUnconsciousState, [_unit, !(_unit getVariable ["ACE_isUnconscious", false])]], _unit] call CBA_fnc_targetEvent;

    // Notify the player if affected unit is a player; for fairness reasons
    if (isPlayer _unit) then {
        ["zen_common_hint", ["Zeus has toggled your consciousness using a module."], _unit] call CBA_fnc_targetEvent;
    };
}, ICON_UNCONSCIOUS] call zen_custom_modules_fnc_register;
