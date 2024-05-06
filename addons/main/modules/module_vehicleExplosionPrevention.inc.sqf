/*
 * Author: johnb43
 * Creates a module preventing vehicles from exploding/destruction.
 */

[LSTRING(moduleCategoryUtility), LSTRING(vehicleExplosionPreventionModuleName), {
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

    [LSTRING(vehicleExplosionPreventionModuleName), [
        ["TOOLBOX:YESNO", [LSTRING(enableVehicleExplosionPrevention), LSTRING(enableVehicleExplosionPreventionDesc)],
        #ifdef ARMA_216
            !isNil {_object getVariable QGVAR(explodingJIP)},
        #else
            !(_object isNil QGVAR(explodingJIP)),
        #endif
        true]
    ], {
        params ["_results", "_object"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

        // If prevention is turned on
        private _string = if (_results select 0) then {
            if
            #ifdef ARMA_216
                (!isNil {_object getVariable QGVAR(explodingJIP)})
            #else
                !(_object isNil QGVAR(explodingJIP))
            #endif
            exitWith {
                LSTRING(enableVehicleExplosionPreventionAlreadyMessage)
            };

            if (isNil QFUNC(addExplosionPreventionEh)) then {
                DFUNC(addExplosionPreventionEh) = [{
                    // Add handle damage EH to every client and JIP
                    _this setVariable [QGVAR(explodingEhID),
                        _this addEventHandler ["HandleDamage", {
                            params ["_object", "", "_damage", "_killer", "", "", "_instigator", "_hitPoint"];

                            if (!local _object) exitWith {};

                            // Convert to lower case string for string comparison
                            _hitPoint = toLowerANSI _hitPoint;

                            // Incoming wheel/track damage will not be changed; Allow immobilisation
                            if ("wheel" in _hitPoint || {"track" in _hitPoint}) then {
                                _damage
                            } else {
                                // Above 75% hull damage a vehicle can blow up; Must reset hull damage every time because it goes too high otherwise
                                _object setHitPointDamage ["HitHull", (_object getHitPointDamage "HitHull") min 0.75, true, _killer, _instigator];

                                ([0.75, 0.89] select (_hitPoint != "" && {_hitPoint != "HitHull"})) min _damage
                            };
                        }]
                    ];
                }, true] call FUNC(sanitiseFunction);

                SEND_MP(addExplosionPreventionEh);
            };

            // "HandleDamage" only fires where the vehicle is local, therefore we need to add it to every client & JIP
            private _jipID = [QGVAR(executeFunction), [QFUNC(addExplosionPreventionEh), _object], QGVAR(addExplosionPrevention_) + hashValue _object] call FUNC(globalEventJIP);
            [_jipID, _object] call FUNC(removeGlobalEventJIP);

            _object setVariable [QGVAR(explodingJIP), _jipID, true];
            _object setVariable ["ace_cookoff_enable", false, true];
            _object setVariable ["ace_cookoff_enableAmmoCookoff", false, true];

            LSTRING(enableVehicleExplosionPreventionMessage)
        } else {
            // If prevention is turned off
            private _jipID = _object getVariable QGVAR(explodingJIP);

            if (isNil "_jipID") exitWith {
                LSTRING(disableVehicleExplosionPreventionAlreadyMessage)
            };

            // Remove JIP event
            _jipID call FUNC(removeGlobalEventJIP);

            _object setVariable [QGVAR(explodingJIP), nil, true];
            _object setVariable ["ace_cookoff_enable", nil, true];
            _object setVariable ["ace_cookoff_enableAmmoCookoff", nil, true];

            ["zen_common_execute", [{
                _this removeEventHandler ["HandleDamage", _this getVariable [QGVAR(explodingEhID), -1]];
                _this setVariable [QGVAR(explodingEhID), nil];
            } call FUNC(sanitiseFunction), _object]] call CBA_fnc_globalEvent;

            LSTRING(disableVehicleExplosionPreventionMessage)
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
