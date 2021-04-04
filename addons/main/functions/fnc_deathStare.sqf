#include "script_component.hpp"

/*
 * Author: johnb43
 * Spawns a module that units to gain death staring abilities.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_deathStare;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

["Zeus Additions - Utility", "[WIP] Give death stare ability", {
    params ["", "_unit"];

    ["[WIP] Death stare", [
        ["CHECKBOX", ["Give death stare ability", "Adds a ACE self-interaction. To use the ability, look at target and use interaction."], false],
        ["TOOLBOX", ["Incapacitation type", "Type of 'punishment' the target unit will endure if it gets death stared. For no damage, select 'Just Damage' and set damage to 0."], [0, 1, 2, [/*"Cardiac Arrest", */"Unconscious", "Just Damage"]], false],
        ["SLIDER", ["Death timer", "Causes either unconsciousness and/or damage after this amount of time."], [10, 120, 30, 0]],
        ["SLIDER", ["Damage done to target", "Adds vanilla damage to the target in percent. 100% is lethal."], [0, 1, 0.5, 2, true]]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_giveAbility", "_incapType", "_timer", "_damage"];

        // Remove action regardless if new one is added or old one removed only
        if (!isNil {_unit getVariable [QGVAR(hasDeathStare), nil]}) then {
             [_unit, 1, ["ACE_SelfActions", QGVAR(deathstare)]] call ace_interact_menu_fnc_removeActionFromObject;
        };

        if (!_giveAbility) exitWith {
            _unit setVariable [QGVAR(hasDeathStare), nil, true];
            ["Removed death stare ability from unit"] call zen_common_fnc_showMessage;
        };

        [_unit, 1, ["ACE_SelfActions"],
            [
                QGVAR(deathstare),
                "Death Stare",
                "",
                {
                    params ["_target", "_player", "_args"];
                    _args params ["_incapType", "_timer", "_damage"];

                    private _cursorTarget = cursorTarget;

                    if !(alive _cursorTarget && {_cursorTarget isKindOf "CAManBase"}) exitWith {};

                    [{["zen_common_execute", [ace_medical_fnc_adjustPainLevel, [_this, 0.2]], _this] call CBA_fnc_targetEvent}, _cursorTarget, (0.3 *  _timer) - 3] call CBA_fnc_waitAndExecute;
                    // Pain increased to 0.5
                    [{["zen_common_execute", [ace_medical_fnc_adjustPainLevel, [_this, 0.3]], _this] call CBA_fnc_targetEvent}, _cursorTarget, (0.5 *  _timer) - 3] call CBA_fnc_waitAndExecute;
                    // Pain increased to 1
                    [{["zen_common_execute", [ace_medical_fnc_adjustPainLevel, [_this, 0.5]], _this] call CBA_fnc_targetEvent}, _cursorTarget, (0.8 *  _timer) - 3] call CBA_fnc_waitAndExecute;

                    [{(_this select 0) setDamage ((damage (_this select 0)) + (_this select 1))}, [_cursorTarget, _damage], (0.9 * _timer) - 3] call CBA_fnc_waitAndExecute;

                    switch (_incapType) do {
                        //case 0: {[{["zen_common_execute", [ace_medical_status_fnc_setCardiacArrestState, [_this, true]], _this] call CBA_fnc_targetEvent}, _cursorTarget, _timer] call CBA_fnc_waitAndExecute};
                        case 0: {[{["zen_common_execute", [ace_medical_status_fnc_setUnconsciousState, [_this, true]], _this] call CBA_fnc_targetEvent}, _cursorTarget, _timer] call CBA_fnc_waitAndExecute};
                        default {};
                    };
                },
                {true},
                {},
                [_incapType, _timer, _damage]
            ] call ace_interact_menu_fnc_createAction
        ] call ace_interact_menu_fnc_addActionToObject;

        _unit setVariable [QGVAR(hasDeathStare), true, true];

        ["Added death stare ability to unit"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
