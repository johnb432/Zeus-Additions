/*
 * Author: johnb43
 * Creates a module that can create suicide bombers.
 */

["Zeus Additions - Utility", "Make Unit into Suicide Bomber", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
    };

    if (!alive _unit) exitWith {
        ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
    };

    if !(_unit isKindOf "CAManBase" && {!(_unit isKindOf "VirtualCurator_F")}) exitWith {
        ["STR_ZEN_Modules_OnlyInfantry"] call zen_common_fnc_showMessage;
    };

    ["Make Unit into Suicide Bomber", [
        ["TOOLBOX:YESNO", ["Unit is Suicide Bomber", "Make a unit into a suicide bomber. To trigger its explosvies, the Zeus must remote control the unit."], !isNil {_unit getVariable QGVAR(suicideBomberActionJIP)}, true],
        ["TOOLBOX:YESNO", ["Unit has Dead man switch", "If the unit has a dead man switch, the unit will detonate its explosives if the unit goes unconscious or dies."], !isNil {_unit getVariable QGVAR(suicideBomberDeadManSwitchJIP)}, true]
    ], {
        params ["_results", "_unit"];
        _results params ["_makeIntoSuicideBomber", "_deadManSwitchEnabled"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _unit) exitWith {
            ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
        };

        if (!alive _unit) exitWith {
            ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
        };

        // Only send function to all clients if script is enabled
        if (isNil QFUNC(removeSuicideBomberIDs)) then {
            // Define a function on the client
            DFUNC(removeSuicideBomberIDs) = compileScript [format ["\%1\%2\%3\%4\functions\fnc_removeSuicideBomberIDs.sqf", QUOTE(MAINPREFIX), QUOTE(PREFIX), QUOTE(SUBPREFIX), QUOTE(COMPONENT)], true];

            // Broadcast function to everyone, so it can be executed for JIP players
            publicVariable QFUNC(removeSuicideBomberIDs);
        };

        if (_makeIntoSuicideBomber) then {
            if (isNil {_unit getVariable QGVAR(suicideBomberActionJIP)}) then {
                // Create explosives around player
                ["zen_common_execute", [{
                    private _pos = getPosATL _this;

                    // Create demo block belt and attack to unit
                    private _expl1 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
                    _expl1 attachTo [_this, [-0.1, 0.1, 0.15], "Pelvis", true];

                    // Remove from JIP when object is deleted
                    [["zen_common_setVectorDirAndUp", [_expl1, [[0.5, 0.5, 0], [-0.5, 0.5, 0]]]] call CBA_fnc_globalEventJIP, _expl1] call CBA_fnc_removeGlobalEventJIP;

                    private _expl2 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
                    _expl2 attachTo [_this, [0, 0.15, 0.15], "Pelvis", true];
                    [["zen_common_setVectorDirAndUp", [_expl2, [[1, 0, 0], [0, 1, 0]]]] call CBA_fnc_globalEventJIP, _expl2] call CBA_fnc_removeGlobalEventJIP;

                    private _expl3 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
                    _expl3 attachTo [_this, [0.1, 0.1, 0.15], "Pelvis", true];
                    [["zen_common_setVectorDirAndUp", [_expl3, [[0.5, -0.5, 0], [0.5, 0.5, 0]]]] call CBA_fnc_globalEventJIP, _expl3] call CBA_fnc_removeGlobalEventJIP;

                    _this setVariable [QGVAR(suicideBomberExplosives), [_expl1, _expl2, _expl3], true];
                }, _unit], _unit] call CBA_fnc_targetEvent;

                // Add detonate scroll wheel action
                private _jipID = ["zen_common_execute", [{
                    private _actionID = _this addAction [
                        "<t color='#FF0000'>Detonate</t>",
                        {
                            params ["_unit"];

                            // Detonate explosives
                            {
                                _x setDamage 1;
                            } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                            // Remove JIP, action and EHs
                            _unit call FUNC(removeSuicideBomberActions);
                        },
                        [],
                        6,
                        true,
                        true,
                        "",
                        "_this == _originalTarget",
                        1
                    ];

                    _this setVariable [QGVAR(suicideBomberActionID), _actionID];
                }, _unit]] call CBA_fnc_globalEventJIP;

                [_jipID, _unit] call CBA_fnc_removeGlobalEventJIP;

                _unit setVariable [QGVAR(suicideBomberActionJIP), _jipID, true];
            };

            // Dead man switch abilities
            if (_deadManSwitchEnabled) then {
                if (!isNil {_unit getVariable QGVAR(suicideBomberDeadManSwitchJIP)}) exitWith {};

                // ACE Medical
                private _jipID = ["zen_common_execute", [{
                    private _unconEhID = if (zen_common_aceMedical) then {
                        ["ace_unconscious", {
                            params ["_unit", "_unconscious"];

                            if (!local _unit || {!_unconscious}) exitWith {};

                            _thisArgs params ["_target"];

                            if (_unit != _target) exitWith {};

                            [{
                                params ["_unit"];

                                // Detonate explosives
                                {
                                    _x setDamage 1;
                                } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                                // Remove JIP, action and EHs
                                _unit call FUNC(removeSuicideBomberActions);
                            }, _this, random 2] call CBA_fnc_waitAndExecute;
                        }, [_this]] call CBA_fnc_addEventHandlerArgs;
                    } else {
                        _this addEventHandler ["HandleDamage", {
                            params ["_unit"];

                            if (!local _unit || {lifeState _unit != "INCAPACITATED"}) exitWith {};

                            [{
                                params ["_unit"];

                                // Detonate explosives
                                {
                                    _x setDamage 1;
                                } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                                // Remove JIP, action and EHs
                                _unit call FUNC(removeSuicideBomberActions);
                            }, _this, random 2] call CBA_fnc_waitAndExecute;
                        }];
                    };

                    _this setVariable [QGVAR(suicideBomberDeadManSwitchEhIDs), [
                        _unconEhID,
                        _this addEventHandler ["Killed", {
                        [{
                            params ["_unit"];

                            if (!local _unit) exitWith {};

                            // Detonate explosives
                            {
                                _x setDamage 1;
                            } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                            // Remove JIP, action and EHs
                            _unit call FUNC(removeSuicideBomberActions);
                        }, _this, random 2] call CBA_fnc_waitAndExecute;
                    }]]];
                }, _unit]] call CBA_fnc_globalEventJIP;

                [_jipID, _unit] call CBA_fnc_removeGlobalEventJIP;

                _unit setVariable [QGVAR(suicideBomberDeadManSwitchJIP), _jipID, true];
            } else {
                // Remove JIP and EHs, but not action
                [_unit, false] call FUNC(removeSuicideBomberActions);
            };

            ["Made unit into suicide bomber"] call zen_common_fnc_showMessage;
        } else {
            // Remove explosives
            {
                deleteVehicle _x;
            } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

            // Remove JIP, action and EHs
            _unit call FUNC(removeSuicideBomberActions);

            ["Reverted unit's suicide bomber status"] call zen_common_fnc_showMessage;
        };
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_EXPLOSION] call zen_custom_modules_fnc_register;
