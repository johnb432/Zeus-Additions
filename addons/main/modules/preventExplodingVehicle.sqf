/*
 * Author: johnb43
 * Creates a module preventing vehicles from exploding/destruction.
 */

["Zeus Additions - Utility", "Prevent Vehicle from Exploding", {
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

    ["Prevent Vehicle from Exploding", [
        ["TOOLBOX:YESNO", ["Vehicle has prevention on", "Makes the vehicle not blow up when receiving critical damage but still allows for vulnerability."], !isNil {_object getVariable QGVAR(explodingJIP)}, true]
    ], {
        params ["_results", "_object"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
        };

        // If prevention is turned on
        private _string = if (_results select 0) then {
            if (!isNil {_object getVariable QGVAR(explodingJIP)}) exitWith {
                "Vehicle already has this feature enabled"
            };

            // "HandleDamage" only fires where the vehicle is local, therefore we need to add it to every client & JIP
            private _jipID = ["zen_common_execute", [{
                // Add handle damage EH to every client and JIP
                _this setVariable [QGVAR(explodingEhID),
                    _this addEventHandler ["HandleDamage", {
                        params ["_object", "", "_damage", "", "", "", "", "_hitPoint"];

                        if (!local _object) exitWith {};

                        // Convert to lower case string for string comparison
                        _hitPoint = toLowerANSI _hitPoint;

                        // Incoming wheel/track damage will not be changed; Allow immobilisation
                        if ("wheel" in _hitPoint || {"track" in _hitPoint}) then {
                            _damage
                        } else {
                            // Above 75% hull damage a vehicle can blow up; Must reset hull damage every time because it goes too high otherwise
                            _object setHitPointDamage ["HitHull", (_object getHitPointDamage "HitHull") min 0.75];
                            ([0.75, 0.95] select (_hitPoint != "" && {_hitPoint != "HitHull"})) min _damage
                        };
                    }]
                ];
            }, _object]] call CBA_fnc_globalEventJIP;

            _object setVariable [QGVAR(explodingJIP), _jipID, true];
            _object setVariable ["ace_cookoff_enable", 0, true];

            // In case object is deleted
            [_jipID, _object] call CBA_fnc_removeGlobalEventJIP;

            "Vehicle exploding prevention has been enabled"
        } else {
            // If prevention is turned off
            private _jipID = _object getVariable QGVAR(explodingJIP);

            if (isNil "_jipID") exitWith {
                "Vehicle already has this feature disabled"
            };

            // Remove JIP event
            _jipID call CBA_fnc_removeGlobalEventJIP;

            _object setVariable [QGVAR(explodingJIP), nil, true];
            _object setVariable ["ace_cookoff_enable", nil, true];

            ["zen_common_execute", [{
                // Remove handle damage EH for object
                private _ehID = _this getVariable QGVAR(explodingEhID);

                if (isNil "_ehID") exitWith {};

                _this removeEventHandler ["HandleDamage", _ehID];
                _this setVariable [QGVAR(explodingEhID), nil];
            }, _object]] call CBA_fnc_globalEvent;

            "Vehicle exploding prevention has been disabled"
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
