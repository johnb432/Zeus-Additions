/*
 * Author: johnb43
 * Creates a module that can create car bombs.
 */

["Zeus Additions - Utility", "Make Vehicle into VBIED", {
    params ["", "_object"];

    if (isNull _object) exitWith {
        ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
    };

    if (!alive _object) exitWith {
        ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
    };

    if ((fullCrew [_object, "driver", true]) isEqualTo []) exitWith {
        ["STR_ZEN_Modules_OnlyVehicles"] call zen_common_fnc_showMessage;
    };

    ["Make Vehicle into VBIED", [
        ["TOOLBOX:YESNO", ["Vehicle is VBIED", "Make a vehicle into a VBIED. Starting the engine will trigger the VBIED."], !isNil {_object getVariable QGVAR(detonateJIP)}, true],
        ["TOOLBOX", ["IED Size", "Changes the size of the explosion."], [0, 1, 2, ["Small", "Large"]]]
    ], {
        params ["_results", "_object"];
        _results params ["_makeIntoVBIED", "_IEDSize"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
        };

        if (_makeIntoVBIED) then {
            _object setVariable [QGVAR(IEDSize), _IEDSize, true];

            if (!isNil {_object getVariable QGVAR(detonateJIP)}) exitWith {};

            private _jipID = ["zen_common_execute", [{
                params ["_object", "_IEDSize"];

                private _ehID = _object addEventHandler ["Engine", {
                    params ["_object", "_engineState"];

                    if (!local _object || {!_engineState}) exitWith {};

                    // Create IED and trigger it
                    (createVehicle [["IEDLandSmall_Remote_Ammo", "IEDLandBig_Remote_Ammo"] select (_object getVariable [QGVAR(IEDSize), 1]), ASLToATL (getPosWorld _object)]) setDamage 1;

                    // Make sure vehicle is destroyed
                    _object setDamage 1;

                    // Apply damage to crew; If they don't die, make sure they do
                    {
                        ["zen_common_execute", [{
                            if (zen_common_aceMedical) then {
                                private _damages = [];

                                {
                                    // 95% chance of getting a wound
                                    if (random 1 > 0.05) then {
                                        _damages pushBack [(random [0.5, 0.75, 1]) * 10, _x, 0];
                                    };
                                } forEach ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"];

                                ["ace_medical_woundReceived", [_this, _damages, _this, "explosive"], _this] call CBA_fnc_localEvent;

                                // If unit still alive, kill
                                if (alive _this) then {
                                    _this call ace_medical_status_fnc_setDead;
                                };
                            } else {
                                {
                                    // 95% chance of getting a wound
                                    if (random 1 > 0.05) then {
                                        _this setHitPointDamage [_x, (_this getHitPointDamage _x) + random [0.5, 0.75, 1], true];
                                    };
                                } forEach ["hitface", "hitneck", "hithead", "hitpelvis", "hitabdomen", "hitdiaphragm", "hitchest", "hitbody", "hitarms", "hithands", "hitlegs"];

                                // If unit still alive, kill
                                if (alive _this) then {
                                    _this setHitPointDamage ["hithead", 1, true];
                                };
                            };
                        }, _x], _x] call CBA_fnc_targetEvent;
                    } forEach ((crew _object) select {alive _x && {isDamageAllowed _x} && {_x getVariable ["ace_medical_allowDamage", true]}});

                    _object setVariable [QGVAR(IEDSize), nil, true];
                }];

                _object setVariable [QGVAR(detonateEhID), _ehID];
            }, [_object, _IEDSize]]] call CBA_fnc_globalEventJIP;

            _object setVariable [QGVAR(detonateJIP), _jipID, true];

            [_jipID, _object] call CBA_fnc_removeGlobalEventJIP;

            ["Made vehicle into a VBIED"] call zen_common_fnc_showMessage;
        } else {
            private _jipID = _object getVariable QGVAR(detonateJIP);

            if (isNil "_jipID") exitWith {};

            _jipID call CBA_fnc_removeGlobalEventJIP;

            ["zen_common_execute", [{
                private _ehID = _this getVariable QGVAR(detonateEhID);

                if (isNil "_ehID") exitWith {};

                _this removeEventHandler ["Engine", _ehID];
                _this setVariable [QGVAR(detonateEhID), nil];
            }, _object]] call CBA_fnc_globalEvent;

            _object setVariable [QGVAR(detonateJIP), nil, true];
            _object setVariable [QGVAR(IEDSize), nil, true];

            ["Reverted vehicle's VBIED status"] call zen_common_fnc_showMessage;
        };
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_EXPLOSION] call zen_custom_modules_fnc_register;
