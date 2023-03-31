/*
 * Author: johnb43
 * Adds a module that forces a unit to wake up or go unconscious, regardless if they have stable vitals or not (for ACE).
 */

["Zeus Additions - Medical", "Toggle Consciousness (Forced)", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
    };

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if (!alive _unit) exitWith {
        ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
    };

    if !(_unit isKindOf "CAManBase" && {!(_unit isKindOf "VirtualCurator_F")}) exitWith {
        ["STR_ZEN_Modules_OnlyInfantry"] call zen_common_fnc_showMessage;
    };

    // Toggle consciousness
    if (zen_common_aceMedical) then {
        ["zen_common_execute", [{
            params ["_curator", "_unit"];

            if (!isPlayer _unit || {[_unit, ace_medical_STATE_MACHINE] call CBA_statemachine_fnc_getCurrentState != "CardiacArrest"}) then {
                [_unit, !(_unit getVariable ["ACE_isUnconscious", false])] call ace_medical_status_fnc_setUnconsciousState;
            } else {
                // Make this be called on the curator's PC
                ["zen_common_execute", [{
                    _this spawn {
                        // Wait for confirmation for player to be force toggled if they are in cardiac arrest, as it causes numerous issues
                        if ([format ["Are you sure you want to force toggle consciousness on '%1'? He is in Cardiac Arrest.", name _this], "Confirmation", "Yes", "No", findDisplay IDD_RSCDISPLAYCURATOR] call BIS_fnc_guiMessage) then {
                            ["zen_common_execute", [{
                                [_this, !(_this getVariable ["ACE_isUnconscious", false])] call ace_medical_status_fnc_setUnconsciousState;
                            }, _this], _this] call CBA_fnc_targetEvent;
                        };
                    };
                }, _unit], _curator] call CBA_fnc_targetEvent;
            };
        }, [player, _unit]], _unit] call CBA_fnc_targetEvent;
    } else {
        [_unit, lifeState _unit != "INCAPACITATED"] remoteExecCall ["setUnconscious", _unit];
    };
}, [ICON_PERSON, ICON_UNCONSCIOUS] select (!isNil "ace_zeus")] call zen_custom_modules_fnc_register;
