/*
 * Author: johnb43
 * Creates a module preventing vehicles from exploding/destruction.
 */

["Zeus Additions - Utility", "Prevent Vehicle from Exploding", {
    params ["", "_object"];

    if ((fullCrew [_object, "driver", true]) isEqualTo []) exitWith {
        ["Select a vehicle!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Prevent Vehicle from Exploding", [
        ["TOOLBOX:YESNO", ["Prevent Vehicle from Exploding", "Makes the vehicle not blow up when receiving critical damage but still allows for vulnerability."], false]
    ],
    {
        params ["_results", "_object"];

        // If prevention is turned on
        private _string = if (_results select 0) then {
            if (!isNil {_object getVariable QGVAR(explodingJIP)}) exitWith {
                playSound "FD_Start_F";
                "Vehicle already has this feature enabled!";
            };

            // "HandleDamage" only fires where the vehicle is local, therefore we need to add it to every client & JIP
            private _jipID = ["zen_common_execute", [{
                // Local EH
                _this setVariable [QGVAR(localID),
                    _this addEventHandler ["Local", {
                        params ["_object", "_isLocal"];

                        // If object becomes local, add damage handler there
                        if (_isLocal) then {
                            _object setVariable [QGVAR(explodingID),
                                _object addEventHandler ["HandleDamage", {
                                    params ["_object", "", "_damage", "", "", "", "", "_hitPoint"];

                                    // Convert to lower case string for string comparison
                                    _hitPoint = toLowerANSI _hitPoint;

                                    // Incoming wheel/track damage will not be changed; Allow immobilisation
                                    if ("wheel" in _hitPoint || {"track" in _hitPoint}) then {
                                        _damage;
                                    } else {
                                        // Above 75% hull damage a vehicle can blow up; Must reset hull damage every time because it goes too high otherwise
                                        _object setHitPointDamage ["hithull", (_object getHitPointDamage "hithull") min 0.75];
                                        ([0.75, 0.95] select (_hitPoint isNotEqualTo "" && {_hitPoint isNotEqualTo "hithull"})) min _damage;
                                    };
                                }]
                            ];
                        } else {
                            // When not local anymore, remove handle damage EH
                            private _handleID = _object getVariable QGVAR(explodingID);

                            if (isNil "_handleID") exitWith {};

                            _object removeEventHandler ["HandleDamage", _handleID];
                            _object setVariable [QGVAR(explodingID), nil];
                        };
                    }]
                ];

                if (!local _this) exitWith {};

                // If local, add handle damage EH now
                _this setVariable [QGVAR(explodingID),
                    _this addEventHandler ["HandleDamage", {
                        params ["_object", "", "_damage", "", "", "", "", "_hitPoint"];

                        // Convert to lower case string for string comparison
                        _hitPoint = toLowerANSI _hitPoint;

                        // Incoming wheel/track damage will not be changed; Allow immobilisation
                        if ("wheel" in _hitPoint || {"track" in _hitPoint}) then {
                            _damage;
                        } else {
                            // Above 75% hull damage a vehicle can blow up; Must reset hull damage every time because it goes too high otherwise
                            _object setHitPointDamage ["hithull", (_object getHitPointDamage "hithull") min 0.75];
                            ([0.75, 0.95] select (_hitPoint isNotEqualTo "" && {_hitPoint isNotEqualTo "hithull"})) min _damage;
                        };
                    }]
                ];
            }, _object]] call CBA_fnc_globalEventJIP;

            _object setVariable [QGVAR(explodingJIP), _jipID, true];
            _object setVariable ["ace_cookoff_enable", 0, true];

            // In case object is deleted
            [_jipID, _object] call CBA_fnc_removeGlobalEventJIP;

            "Vehicle exploding prevention has been enabled";
        } else {
            // If prevention is turned off
            private _jipID = _object getVariable QGVAR(explodingJIP);

            if (isNil "_jipID") exitWith {
                playSound "FD_Start_F";
                "Vehicle already has this feature disabled!";
            };

            // Remove JIP event
            _jipID call CBA_fnc_removeGlobalEventJIP;

            _object setVariable [QGVAR(explodingJIP), nil, true];
            _object setVariable ["ace_cookoff_enable", nil, true];

            ["zen_common_execute", [{
                // Remove handle damage EH for object
                private _handleID = _this getVariable QGVAR(explodingID);

                if (!isNil "_handleID") then {
                    _this removeEventHandler ["HandleDamage", _handleID];
                    _this setVariable [QGVAR(explodingID), nil];
                };

                // Remove local EH for object
                private _localID = _this getVariable QGVAR(localID);

                if (isNil "_localID") exitWith {};

                _this removeEventHandler ["Local", _localID];
                _this setVariable [QGVAR(localID), nil];
            }, _object]] call CBA_fnc_globalEvent;

            "Vehicle exploding prevention has been disabled";
        };

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
