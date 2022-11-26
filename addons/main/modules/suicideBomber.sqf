/*
 * Author: johnb43
 * Creates a module that can create suicide bombers.
 */

["Zeus Additions - Utility", "[WIP] Make Unit into Suicide Bomber", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
    };

    if (!alive _unit) exitWith {
        ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
    };

    if !(_unit isKindOf "CAManBase") exitWith {
        ["STR_ZEN_Modules_OnlyInfantry"] call zen_common_fnc_showMessage;
    };

    ["Make Unit into Suicide Bomber", [
        ["TOOLBOX:YESNO", ["Make unit into Suicide bomber", ""], isNil {_unit getVariable QGVAR(suicideBomberActionJIPID)}],
        ["TOOLBOX:YESNO", ["Dead man switch", ""], isNil {_unit getVariable QGVAR(suicideBomberEHJIPID)}]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_makeIntoSuicideBomber", "_deadManSwitchEnabled"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _unit) exitWith {
            ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
        };

        if (!alive _unit) exitWith {
            ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
        };

        if (_makeIntoSuicideBomber) then {
            if (isNil {_unit getVariable QGVAR(suicideBomberActionJIPID)}) then {
                // Create explosives around player
                ["zen_common_execute", [{
                    private _pos = getPosATL _this;

                    // Create demo block belt and attack to unit
                    private _expl1 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
                    _expl1 attachTo [_this, [-0.1, 0.1, 0.15], "Pelvis", true];
                    _expl1 setVectorDirAndUp [[0.5, 0.5, 0], [-0.5, 0.5, 0]];

                    private _expl2 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
                    _expl2 attachTo [_this, [0, 0.15, 0.15], "Pelvis", true];
                    _expl2 setVectorDirAndUp [[1, 0, 0], [0, 1, 0]];

                    private _expl3 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
                    _expl3 attachTo [_this, [0.1, 0.1, 0.15], "Pelvis", true];
                    _expl3 setVectorDirAndUp [[0.5, -0.5, 0], [0.5, 0.5, 0]];

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

                            _unit setVariable [QGVAR(suicideBomberExplosives), nil, true];

                            // Remove JIP
                            private _jipID = _unit getVariable QGVAR(suicideBomberEHJIPID);

                            if (!isNil "_jipID") then {
                                _jipID call CBA_fnc_removeGlobalEventJIP;
                                _unit setVariable [QGVAR(suicideBomberEHJIPID), nil, true];
                            };

                            _jipID = _unit getVariable QGVAR(suicideBomberActionJIPID);

                            if (!isNil "_jipID") then {
                                _jipID call CBA_fnc_removeGlobalEventJIP;
                                _unit setVariable [QGVAR(suicideBomberActionJIPID), nil, true];
                            };

                            // Remove actions and EHs
                            ["zen_common_execute", [{
                                private _actionID = _this getVariable QGVAR(suicideBomberActionID);

                                if (!isNil "_actionID") then {
                                    _this removeAction _actionID;
                                    _this setVariable [QGVAR(suicideBomberActionID), nil];
                                };

                                private _ehIDs = _this getVariable QGVAR(suicideBomberEHIDs);

                                if (isNil "_ehIDs") exitWith {};

                                if (zen_common_aceMedical) then {
                                    ["ace_unconscious", _ehIDs select 0] call CBA_fnc_removeEventHandler;
                                } else {
                                    _this removeEventHandler ["HandleDamage", _ehIDs select 0];
                                };

                                _this removeEventHandler ["Killed", _ehIDs select 1];

                                _this setVariable [QGVAR(suicideBomberEHIDs), nil];
                            }, _unit]] call CBA_fnc_globalEvent;
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

                _unit setVariable [QGVAR(suicideBomberActionJIPID), _jipID, true];
            };

            // Dead man switch abilities
            if (_deadManSwitchEnabled) then {
                if (!isNil {_unit getVariable QGVAR(suicideBomberEHJIPID)}) exitWith {};

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

                                _unit setVariable [QGVAR(suicideBomberExplosives), nil, true];

                                // Remove JIP
                                private _jipID = _unit getVariable QGVAR(suicideBomberEHJIPID);

                                if (!isNil "_jipID") then {
                                    _jipID call CBA_fnc_removeGlobalEventJIP;
                                    _unit setVariable [QGVAR(suicideBomberEHJIPID), nil, true];
                                };

                                _jipID = _unit getVariable QGVAR(suicideBomberActionJIPID);

                                if (!isNil "_jipID") then {
                                    _jipID call CBA_fnc_removeGlobalEventJIP;
                                    _unit setVariable [QGVAR(suicideBomberActionJIPID), nil, true];
                                };

                                // Remove actions and EHs
                                ["zen_common_execute", [{
                                    private _actionID = _this getVariable QGVAR(suicideBomberActionID);

                                    if (!isNil "_actionID") then {
                                        _this removeAction _actionID;
                                        _this setVariable [QGVAR(suicideBomberActionID), nil];
                                    };

                                    private _ehIDs = _this getVariable QGVAR(suicideBomberEHIDs);

                                    if (isNil "_ehIDs") exitWith {};

                                    if (zen_common_aceMedical) then {
                                        ["ace_unconscious", _ehIDs select 0] call CBA_fnc_removeEventHandler;
                                    } else {
                                        _this removeEventHandler ["HandleDamage", _ehIDs select 0];
                                    };

                                    _this removeEventHandler ["Killed", _ehIDs select 1];

                                    _this setVariable [QGVAR(suicideBomberEHIDs), nil];
                                }, _unit]] call CBA_fnc_globalEvent;
                            }, _this, random 2] call CBA_fnc_waitAndExecute;
                        }, [_this]] call CBA_fnc_addEventHandlerArgs;
                    } else {
                        _this addEventHandler ["HandleDamage", {
                            params ["_unit"];

                            if (lifeState _unit != "INCAPACITATED") exitWith {};

                            [{
                                params ["_unit"];

                                // Detonate explosives
                                {
                                    _x setDamage 1;
                                } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                                _unit setVariable [QGVAR(suicideBomberExplosives), nil, true];

                                // Remove JIP
                                private _jipID = _unit getVariable QGVAR(suicideBomberEHJIPID);

                                if (!isNil "_jipID") then {
                                    _jipID call CBA_fnc_removeGlobalEventJIP;
                                    _unit setVariable [QGVAR(suicideBomberEHJIPID), nil, true];
                                };

                                _jipID = _unit getVariable QGVAR(suicideBomberActionJIPID);

                                if (!isNil "_jipID") then {
                                    _jipID call CBA_fnc_removeGlobalEventJIP;
                                    _unit setVariable [QGVAR(suicideBomberActionJIPID), nil, true];
                                };

                                // Remove actions and EHs
                                ["zen_common_execute", [{
                                    private _actionID = _this getVariable QGVAR(suicideBomberActionID);

                                    if (!isNil "_actionID") then {
                                        _this removeAction _actionID;
                                        _this setVariable [QGVAR(suicideBomberActionID), nil];
                                    };

                                    private _ehIDs = _this getVariable QGVAR(suicideBomberEHIDs);

                                    if (isNil "_ehIDs") exitWith {};

                                    if (zen_common_aceMedical) then {
                                        ["ace_unconscious", _ehIDs select 0] call CBA_fnc_removeEventHandler;
                                    } else {
                                        _this removeEventHandler ["HandleDamage", _ehIDs select 0];
                                    };

                                    _this removeEventHandler ["Killed", _ehIDs select 1];

                                    _this setVariable [QGVAR(suicideBomberEHIDs), nil];
                                }, _unit]] call CBA_fnc_globalEvent;
                            }, _this, random 2] call CBA_fnc_waitAndExecute;
                        }];
                    };

                    private _killedEhID = _this addEventHandler ["Killed", {
                        [{
                            params ["_unit"];

                            // Detonate explosives
                            {
                                _x setDamage 1;
                            } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                            _unit setVariable [QGVAR(suicideBomberExplosives), nil, true];

                            // Remove JIP
                            private _jipID = _unit getVariable QGVAR(suicideBomberEHJIPID);

                            if (!isNil "_jipID") then {
                                _jipID call CBA_fnc_removeGlobalEventJIP;
                                _unit setVariable [QGVAR(suicideBomberEHJIPID), nil, true];
                            };

                            _jipID = _unit getVariable QGVAR(suicideBomberActionJIPID);

                            if (!isNil "_jipID") then {
                                _jipID call CBA_fnc_removeGlobalEventJIP;
                                _unit setVariable [QGVAR(suicideBomberActionJIPID), nil, true];
                            };

                            // Remove actions and EHs
                            ["zen_common_execute", [{
                                private _actionID = _this getVariable QGVAR(suicideBomberActionID);

                                if (!isNil "_actionID") then {
                                    _this removeAction _actionID;
                                    _this setVariable [QGVAR(suicideBomberActionID), nil];
                                };

                                private _ehIDs = _this getVariable QGVAR(suicideBomberEHIDs);

                                if (isNil "_ehIDs") exitWith {};

                                if (zen_common_aceMedical) then {
                                    ["ace_unconscious", _ehIDs select 0] call CBA_fnc_removeEventHandler;
                                } else {
                                    _this removeEventHandler ["HandleDamage", _ehIDs select 0];
                                };

                                _this removeEventHandler ["Killed", _ehIDs select 1];

                                _this setVariable [QGVAR(suicideBomberEHIDs), nil];
                            }, _unit]] call CBA_fnc_globalEvent;
                        }, _this, random 2] call CBA_fnc_waitAndExecute;
                    }];

                    _this setVariable [QGVAR(suicideBomberEHIDs), [_unconEhID, _killedEhID]];
                }, _unit]] call CBA_fnc_globalEventJIP;

                [_jipID, _unit] call CBA_fnc_removeGlobalEventJIP;

                _unit setVariable [QGVAR(suicideBomberEHJIPID), _jipID, true];
            } else {
                // Remove JIP
                private _jipID = _unit getVariable QGVAR(suicideBomberEHJIPID);

                if (!isNil "_jipID") then {
                    _jipID call CBA_fnc_removeGlobalEventJIP;

                    _unit setVariable [QGVAR(suicideBomberEHJIPID), nil, true];
                };

                // Remove EHs
                ["zen_common_execute", [{
                    private _ehIDs = _this getVariable QGVAR(suicideBomberEHIDs);

                    if (isNil "_ehIDs") exitWith {};

                    if (zen_common_aceMedical) then {
                        ["ace_unconscious", _ehIDs select 0] call CBA_fnc_removeEventHandler;
                    } else {
                        _this removeEventHandler ["HandleDamage", _ehIDs select 0];
                    };

                    _this removeEventHandler ["Killed", _ehIDs select 1];

                    _this setVariable [QGVAR(suicideBomberEHIDs), nil];
                }, _unit]] call CBA_fnc_globalEvent;
            };

            ["Made unit into suicide bomber"] call zen_common_fnc_showMessage;
        } else {
            // Remove explosives
            {
                deleteVehicle _x;
            } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

            _unit setVariable [QGVAR(suicideBomberExplosives), nil, true];

            // Remove JIP
            private _jipID = _unit getVariable QGVAR(suicideBomberEHJIPID);

            if (!isNil "_jipID") then {
                _jipID call CBA_fnc_removeGlobalEventJIP;
                _unit setVariable [QGVAR(suicideBomberEHJIPID), nil, true];
            };

            _jipID = _unit getVariable QGVAR(suicideBomberActionJIPID);

            if (!isNil "_jipID") then {
                _jipID call CBA_fnc_removeGlobalEventJIP;
                _unit setVariable [QGVAR(suicideBomberActionJIPID), nil, true];
            };

            // Remove actions and EHs
            ["zen_common_execute", [{
                private _actionID = _this getVariable QGVAR(suicideBomberActionID);

                if (!isNil "_actionID") then {
                    _this removeAction _actionID;
                    _this setVariable [QGVAR(suicideBomberActionID), nil];
                };

                private _ehIDs = _this getVariable QGVAR(suicideBomberEHIDs);

                if (isNil "_ehIDs") exitWith {};

                if (zen_common_aceMedical) then {
                    ["ace_unconscious", _ehIDs select 0] call CBA_fnc_removeEventHandler;
                } else {
                    _this removeEventHandler ["HandleDamage", _ehIDs select 0];
                };

                _this removeEventHandler ["Killed", _ehIDs select 1];

                _this setVariable [QGVAR(suicideBomberEHIDs), nil];
            }, _unit]] call CBA_fnc_globalEvent;

            ["Reverted unit's suicide bomber status"] call zen_common_fnc_showMessage;
        };
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_EXPLOSION] call zen_custom_modules_fnc_register;
