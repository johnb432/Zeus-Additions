/*
 * Author: johnb43
 * Adds a module that forces a unit to wake up or go unconscious, regardless if they have stable vitals or not (for ACE).
 */

["Zeus Additions - Medical", "Toggle Consciousness (Forced)", {
    params ["", "_unit"];

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if !(alive _unit && {_unit isKindOf "CAManBase"}) exitWith {
        ["Select a living unit!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    // Toggle consciousness
    if (zen_common_aceMedical) then {
        // Do not allow player to be force toggled if they are in cardiac arrest, as it causes numerous issues
        ["zen_common_execute", [{
            if ([_this, ace_medical_STATE_MACHINE] call CBA_statemachine_fnc_getCurrentState != "CardiacArrest" || {!isPlayer _this}) then {
                [_this, !(_this getVariable ["ACE_isUnconscious", false])] call ace_medical_status_fnc_setUnconsciousState
            };
        }, _unit], _unit] call CBA_fnc_targetEvent;
    } else {
        [_unit, lifeState _unit != "INCAPACITATED"] remoteExecCall ["setUnconscious", _unit];
    };

    // Notify the player if affected unit is a player; for fairness reasons
    if (isPlayer _unit) then {
        "Zeus has toggled your consciousness." remoteExecCall ["hint", _unit];
    };
}, [ICON_PERSON, ICON_UNCONSCIOUS] select (isClass (configFile >> "CfgPatches" >> "ace_zeus"))] call zen_custom_modules_fnc_register;
