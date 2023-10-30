/*
 * Author: johnb43
 * Creates a module that can create car bombs.
 */

[LSTRING(moduleCategoryUtility), "str_a3_systems_commondescription.inccfgomphonecontacts_detonation0", {
    params ["", "_object"];

    if (isNull _object) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    if (!alive _object) exitWith {
        [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
    };

    if ((fullCrew [_object, "driver", true]) isEqualTo []) exitWith {
        [LSTRING_ZEN(modules,onlyVehicles)] call zen_common_fnc_showMessage;
    };

    if (_object getVariable ["zen_modules_isIED", false]) exitWith {
        [LSTRING_ZEN(modules,alreadyAnIED)] call zen_common_fnc_showMessage;
    };

    ["str_a3_systems_commondescription.inccfgomphonecontacts_detonation0", [
        ["TOOLBOX:YESNO", [LSTRING(enableCarBomb), LSTRING(enableCarBombDesc)], !isNil {_object getVariable QGVAR(detonateJIP)}, true],
        ["TOOLBOX", [LSTRING_ZEN(modules,explosionSize), LSTRING(explosionSizeDesc)], [0, 1, 2, ["str_small", "str_large"]]]
    ], {
        params ["_results", "_object"];
        _results params ["_makeIntoCarBomb", "_IEDSize"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

        if (_object getVariable ["zen_modules_isIED", false]) exitWith {
            [LSTRING_ZEN(modules,alreadyAnIED)] call zen_common_fnc_showMessage;
        };

        if (_makeIntoCarBomb) then {
            _object setVariable [QGVAR(IEDSize), _IEDSize, true];
            _object setVariable ["zen_modules_isIED", true, true];

            if (!isNil {_object getVariable QGVAR(detonateJIP)}) exitWith {};

            // Turn off engine
            if (isEngineOn _object) then {
                [_object, false] remoteExecCall ["engineOn", _object];
            };

            // Only send function to all clients if script is enabled
            if (isNil QFUNC(addCarBombEh)) then {
                DFUNC(addCarBombEh) = [{
                    _this setVariable [QGVAR(detonateEhID),
                        _this addEventHandler ["Engine", {
                            params ["_object", "_engineState"];

                            if (!local _object || {!_engineState}) exitWith {};

                            [{
                                // Create IED and trigger it
                                (createVehicle [["IEDLandSmall_Remote_Ammo", "IEDLandBig_Remote_Ammo"] select (_this getVariable [QGVAR(IEDSize), 1]), ASLToATL (getPosWorld _this)]) setDamage 1;

                                // Make sure vehicle is destroyed
                                _this setDamage 1;

                                // Apply damage to crew; If they don't die, make sure they do
                                {
                                    _x remoteExecCall [QFUNC(killUnit), _x];
                                } forEach (crew _this);

                                _this setVariable [QGVAR(IEDSize), nil, true];
                                _this setVariable ["zen_modules_isIED", nil, true];
                            }, _object, random 2] call CBA_fnc_waitAndExecute;
                        }]
                    ];
                }, true, true] call FUNC(sanitiseFunction);

                DFUNC(killUnit) = [{
                    // 'isDamageAllowed' needs to be checked locally
                    if !(isDamageAllowed _this && {_this getVariable ["ace_medical_allowDamage", true]}) exitWith {};

                    if (zen_common_aceMedical) then {
                        ["ace_medical_woundReceived", [_this, ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"] apply {[(random [0.5, 0.75, 1]) * 10, _x, 0]}, objNull, "explosive"]] call CBA_fnc_localEvent;

                        // If unit still alive, kill
                        if (alive _this) then {
                            _this call ace_medical_status_fnc_setDead;
                        };
                    } else {
                        {
                            _this setHitPointDamage [_x, (_this getHitPointDamage _x) + random [0.5, 0.75, 1], true];
                        } forEach ["HitFace", "HitNeck", "HitHead", "HitPelvis", "HitAbdomen", "HitDiaphragm", "HitChest", "HitBody", "HitArms", "HitHands", "HitLegs"];

                        // If unit still alive, kill
                        if (alive _this) then {
                            _this setHitPointDamage ["HitHead", 1, true];
                        };
                    };
                }, true, true] call FUNC(sanitiseFunction);

                SEND_MP(addCarBombEh);
                SEND_MP(killUnit);
            };

            private _jipID = [QGVAR(addCarBombEh), _object, QGVAR(addCarBomb_) + netId _object] call CBA_fnc_globalEventJIP;
            [_jipID, _object] call CBA_fnc_removeGlobalEventJIP;

            _object setVariable [QGVAR(detonateJIP), _jipID, true];

            [LSTRING(enableCarBombMessage)] call zen_common_fnc_showMessage;
        } else {
            private _jipID = _object getVariable QGVAR(detonateJIP);

            if (isNil "_jipID") exitWith {};

            _jipID call CBA_fnc_removeGlobalEventJIP;

            _object setVariable [QGVAR(detonateJIP), nil, true];
            _object setVariable [QGVAR(IEDSize), nil, true];
            _object setVariable ["zen_modules_isIED", nil, true];

            ["zen_common_execute", [{
                private _ehID = _this getVariable QGVAR(detonateEhID);

                if (isNil "_ehID") exitWith {};

                _this removeEventHandler ["Engine", _ehID];
                _this setVariable [QGVAR(detonateEhID), nil];
            } call FUNC(sanitiseFunction), _object]] call CBA_fnc_globalEvent;

            [LSTRING(disableCarBombMessage)] call zen_common_fnc_showMessage;
        };
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_EXPLOSION] call zen_custom_modules_fnc_register;
