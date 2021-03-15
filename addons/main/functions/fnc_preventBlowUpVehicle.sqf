#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates a module preventing vehicles from blowing up.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_preventBlowUpVehicle;
 *
 * Public: No
 */

["Zeus Additions - Utility", "[WIP] Prevent vehicle from blowing up", {
    params ["", "_object"];

				if (isNull _object) exitWith {
        ["Select a vehicle!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Prevent vehicles from blowing up", [
        ["CHECKBOX", ["Prevent vehicle from blowing up", "Makes the vehicle not blow up when receiving critical damage but still allows for vulnerability."], false, true]
    ],
    {
        params ["_results", "_object"];
								_results params ["_preventBlowup"];

        private _EHIndex;
        private _string = "Changed vehicle explosion prevention";

								if (_preventBlowup) then {
            if (isNil {_object getVariable [QGVAR(blowUpID), nil]}) then {
                _EHIndex = _object addEventHandler ["HandleDamage", {
                    params ["_object", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

                    if !("wheel" in _hitPoint || "track" in _hitPoint) then {
                        _damage = 0.95 min _damage;
                        if (_hitPoint == "hitHull") then {
                            _damage = 0.75;
                        };
                    };
                    _damage;
                }];
                _object setVariable [QGVAR(blowUpID), _EHIndex, true];
            } else {
                _string = "Vehicle already has this feature enabled!";
                playSound "FD_Start_F";
            };
								} else {
												_EHIndex = _object getVariable [QGVAR(blowUpID), nil];
												if (isNil "_EHIndex") exitWith {};
												_object removeEventHandler ["HandleDamage", _EHIndex];
												_object setVariable [QGVAR(blowUpID), nil, true];
								};

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
