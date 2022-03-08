/*
 * Author: johnb43
 * Spawns a module that units to gain death staring abilities.
 */

["Zeus Additions - Utility", "Give Death Stare Ability", {
    params ["", "_unit"];

    if !(alive _unit && {_unit isKindOf "CAManBase"}) exitWith {
         ["Select a unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    ["Death Stare Ability", [
        ["TOOLBOX", ["Give death stare ability", "Adds a ACE self-interaction. To use the ability, look at target (must be a living unit) and use interaction."], [0, 1, 2, ["Add", "Remove"]]],
        ["TOOLBOX", ["Incapacitation type", "Type of 'punishment' the target unit will endure if it gets death stared. For no damage, select 'Just Damage' and set damage to 0."], [0, 1, 3, ["Lightning Bolt", "Unconscious", "Just Damage"]]],
        ["SLIDER", ["Death timer", "Causes either unconsciousness and/or damage after this amount of time."], [10, 120, 30, 0]],
        ["SLIDER:PERCENT", ["Damage done to target", "Adds vanilla damage to the target in percent. 100% is lethal."], [0, 1, 0.5]]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_giveAbility", "_incapType", "_timer", "_damage"];

        // Remove action regardless if new one is added or old one removed only
        if (!isNil {_unit getVariable QGVAR(hasDeathStare)}) then {
             [_unit, 1, ["ACE_SelfActions", QGVAR(deathstare)]] remoteExecCall ["ace_interact_menu_fnc_removeActionFromObject", _unit];
        };

        // If remove
        if (_giveAbility isEqualTo 1) exitWith {
            _unit setVariable [QGVAR(hasDeathStare), nil, true];
            ["Removed death stare ability from unit"] call zen_common_fnc_showMessage;
        };

        // Add action
        [
            _unit,
            1,
            ["ACE_SelfActions"],
            [
                QGVAR(deathstare),
                "Death Stare",
                ICON_DEATH_STARE,
                {
                    params ["_target", "_player", "_args"];
                    _args params ["_incapType", "_timer", "_damage"];

                    private _cursorTarget = cursorTarget;

                    // Target must be alive and a man
                    if !(alive _cursorTarget && {_cursorTarget isKindOf "CAManBase"}) exitWith {};

                    // If "lightning" type
                    if (_incapType isEqualTo 0) exitWith {
                        (getPosATL _cursorTarget) params ["_posX", "_posY"];
                        private _lightning = createVehicle [selectRandom ["Lightning1_F", "Lightning2_F"], [_posX, _posY, 0], [], 0, "CAN_COLLIDE"];

                        // Make the bolt go off and add damage to unit
                        [{
                            deleteVehicle (_this select 0);
                            (_this select 1) setDamage ((damage (_this select 1)) + (_this select 2));
                        }, [_lightning, _cursorTarget, _damage], 1] call CBA_fnc_waitAndExecute;

                        (createvehicle ["LightningBolt", [_posX, _posY, 0], [], 0, "CAN_COLLIDE"]) setDamage 1;
                    };

                    [{[_this, 0.2] remoteExecCall ["ace_medical_fnc_adjustPainLevel", _this]}, _cursorTarget, (0.3 *  _timer) - 3] call CBA_fnc_waitAndExecute;
                    // Pain increase to 0.5
                    [{[_this, 0.3] remoteExecCall ["ace_medical_fnc_adjustPainLevel", _this]}, _cursorTarget, (0.5 *  _timer) - 3] call CBA_fnc_waitAndExecute;
                    // Pain increase to 1
                    [{[_this, 0.5] remoteExecCall ["ace_medical_fnc_adjustPainLevel", _this]}, _cursorTarget, (0.8 *  _timer) - 3] call CBA_fnc_waitAndExecute;

                    [{(_this select 0) setDamage ((damage (_this select 0)) + (_this select 1))}, [_cursorTarget, _damage], (0.9 * _timer) - 3] call CBA_fnc_waitAndExecute;

                    switch (_incapType) do {
                        case 1: {
                            [{
                                if (!alive _this) exitWith {};

                                [_this, true] remoteExecCall ["ace_medical_status_fnc_setUnconsciousState", _this]
                            }, _cursorTarget, _timer] call CBA_fnc_waitAndExecute;
                        };
                        default {};
                    };
                },
                {true},
                {},
                [_incapType, _timer, _damage]
            ] call ace_interact_menu_fnc_createAction
        ] remoteExecCall ["ace_interact_menu_fnc_addActionToObject", _unit];

        _unit setVariable [QGVAR(hasDeathStare), true, true];

        ["Added death stare ability to unit"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_DEATH_STARE] call zen_custom_modules_fnc_register;
