/*
 * Author: johnb43
 * Adds a module that forces a unit to wake up or go unconscious, regardless if they have stable vitals or not (for ACE).
 */

[LSTRING(moduleCategoryMedical), LSTRING(toggleConsciousnessModuleName), {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if (!alive _unit) exitWith {
        [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
    };

    if !(_unit isKindOf "CAManBase" && {getNumber ((configOf _unit) >> "isPlayableLogic") == 0}) exitWith {
        [LSTRING_ZEN(modules,onlyInfantry)] call zen_common_fnc_showMessage;
    };

    // Toggle consciousness
    if (!isNil "ace_medical_statemachine") then {
        ["zen_common_execute", [{
            params ["_owner", "_unit"];

            if (!isPlayer _unit || {[_unit, ace_medical_STATE_MACHINE] call CBA_statemachine_fnc_getCurrentState != "CardiacArrest"}) then {
                [_unit, lifeState _unit != "INCAPACITATED"] call ace_medical_status_fnc_setUnconsciousState;
            } else {
                // Make this be called on the curator's PC
                ["zen_common_execute", [{
                    _this spawn {
                        // Wait for confirmation for player to be force toggled if they are in cardiac arrest, as it causes numerous issues
                        if ([format [LLSTRING(toggleConsciousnessConfirmation), name _this], localize "str_a3_a_hub_misc_mission_selection_box_title", LLSTRING_ZEN(common,yes), LLSTRING_ZEN(common,no), findDisplay IDD_RSCDISPLAYCURATOR] call BIS_fnc_guiMessage) then {
                            ["zen_common_execute", [{
                                [_this, lifeState _this != "INCAPACITATED"] call ace_medical_status_fnc_setUnconsciousState;
                            }, _this], _this] call CBA_fnc_targetEvent;
                        };
                    };
                }, _unit], _owner] call CBA_fnc_ownerEvent;
            };
        } call FUNC(sanitiseFunction), [clientOwner, _unit]], _unit] call CBA_fnc_targetEvent;
    } else {
        ["zen_common_execute", [{
            _this setUnconscious (lifeState _this != "INCAPACITATED");
        }, _unit], _unit] call CBA_fnc_targetEvent;
    };
}, [ICON_PERSON, "\z\ace\addons\zeus\ui\Icon_Module_Zeus_Unconscious_ca.paa"] select (!isNil "ace_zeus")] call zen_custom_modules_fnc_register;
