#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates a module preventing vehicles from exploding/destruction.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_preventExplodingVehicle;
 *
 * Public: No
 */

["Zeus Additions - Utility", "Prevent Vehicle from Exploding", {
    params ["", "_object"];

    if (!(_object isKindOf "AllVehicles") || {isNull (driver _object)}) exitWith {
        ["Select a vehicle!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Prevent Vehicle from Exploding", [
        ["TOOLBOX:YESNO", ["Prevent Vehicle from Exploding", "Makes the vehicle not blow up when receiving critical damage but still allows for vulnerability."], false, true]
    ],
    {
        params ["_results", "_object"];

        private _string = "Changed vehicle exploding prevention";

        // If prevention is turned on
        if (_results select 0) then {
            if (isNil {_object getVariable QGVAR(explodingID)}) then {
                // "HandleDamage" only fires where the vehicle is local, therefore we need to add it to every client & JIP
                _object setVariable [QGVAR(explodingJIP),
                    [
                        _object,
                        {
                            _this setVariable [QGVAR(explodingID),
                                _this addEventHandler ["HandleDamage", {
                                    params ["", "", "_damage", "", "", "", "", "_hitPoint"];

                                    // Convert to lower case string for string comparison
                                    _hitPoint = toLower _hitPoint;

                                    // Incoming wheel/track damage will not be changed; Allow immobilisation
                                    if ("wheel" in _hitPoint || {"track" in _hitPoint}) exitWith {
                                        _damage;
                                    };

                                    // Above 75% hull damage a vehicle can blow up
                                    ([0.95, 0.75] select (_hitPoint isEqualTo "hithull")) min _damage;
                                }], true
                            ];
                        }
                    ] remoteExecCall ["call", 0, true], true
                ];
            } else {
                _string = "Vehicle already has this feature enabled!";
                playSound "FD_Start_F";
            };
        } else {
            // If prevention is turned off
            private _handleID = _object getVariable QGVAR(explodingID);

            if (isNil "_handleID") exitWith {
                _string = "Vehicle already has this feature disabled!";
                playSound "FD_Start_F";
            };

            [
                _object,
                {
                    // Remove JIP event
                    if (!isNil {_this getVariable QGVAR(explodingJIP)}) then {
                        remoteExecCall ["", _this getVariable QGVAR(explodingJIP)];

                        _this setVariable [QGVAR(explodingJIP), nil, true];
                    };

                    // If prevention is turned off
                    private _handleID = _this getVariable QGVAR(explodingID);

                    if (isNil "_handleID") exitWith {};

                    _this removeEventHandler ["HandleDamage", _handleID];
                    _this setVariable [QGVAR(explodingID), nil, true];
                }
            ] remoteExecCall ["call", 0];
        };

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
