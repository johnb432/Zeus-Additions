/*
 * Author: johnb43
 * Spawns a module that allows Zeus to enable and disable RHS vehicles' active protection system (APS).
 */

[LSTRING(moduleCategoryUtility), LSTRING(rhsApsModuleName), {
    params ["", "_object"];

    [LSTRING(rhsApsModuleName), [
        ["TOOLBOX:ENABLED", [LSTRING(rhsAps), LSTRING(rhsApsDesc)], true],
        ["TOOLBOX", [LSTRING_ZEN(context_Actions,selected), LSTRING(rhsApsSelectionDesc)], [0, 1, 2, ["STR_3DEN_Object_textSingular", "str_a3_ta_vanguard_allvehicles"]]],
        ["TOOLBOX:ENABLED", [LSTRING(rhsApsFutureVehicles), LSTRING(rhsApsFutureVehiclesDesc)], isNil QGVAR(disableAPS), true]
    ], {
        params ["_result", "_object"];
        _result params ["_enabled", "_all", "_allFuture"];

        private _apsVehicles = (GETMVAR("rhs_aps_vehicles",[])) select {alive _x};

        // All vehicles
        if (_all == 1) exitWith {
            private _string = if (_enabled) then {
                private _vehicles = entities [["rhs_t14_base", "rhs_t15_base"], [], false, true];

                if (_vehicles isEqualTo []) exitWith {
                    LSTRING(rhsApsNoVehiclesFoundMessage)
                };

                private _count = count _apsVehicles;

                _apsVehicles insert [-1, _vehicles, true];

                // See if any vehicles were added
                if ((count _apsVehicles) == _count) then {
                    LSTRING(rhsApsAllVehiclesAlreadyEnabledMessage)
                } else {
                    SETMVAR("rhs_aps_vehicles",_apsVehicles,true);

                    LSTRING(rhsApsAllVehiclesEnabledMessage)
                };
            } else {
                if (_apsVehicles isEqualTo []) then {
                    LSTRING(rhsApsAllVehiclesAlreadyDisabledMessage)
                } else {
                    SETMVAR("rhs_aps_vehicles",[],true);

                    LSTRING(rhsApsAllVehiclesDisabledMessage)
                };
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // If valid vehicle
        private _string = if (alive _object) then {
            if (_object isKindOf "rhs_t14_base" || {_object isKindOf "rhs_t15_base"}) then {
                if (_enabled) then {
                    // Add if necessary
                    if ((_apsVehicles pushBackUnique _object) == -1) exitWith {
                        LSTRING(rhsApsVehicleAlreadyEnabledMessage)
                    };

                    SETMVAR("rhs_aps_vehicles",_apsVehicles,true);

                    LSTRING(rhsApsVehicleEnabledMessage)
                } else {
                    // Remove if necessary
                    private _index = _apsVehicles find _object;

                    if (_index == -1) exitWith {
                        LSTRING(rhsApsVehicleAlreadyDisabledMessage)
                    };

                    _apsVehicles deleteAt _index;

                    SETMVAR("rhs_aps_vehicles",_apsVehicles,true);

                    LSTRING(rhsApsVehicleDisabledMessage)
                };
            } else {
                LSTRING(rhsApsNoVehicleFoundMessage)
            };
        } else {
            LSTRING_ZEN(modules,onlyAlive)
        };

        if (_allFuture) then {
            if (isNil QGVAR(disableAPS)) exitWith {};

            ["zen_common_execute", [{
                if (isNil QGVAR(disableAPS)) exitWith {};

                removeMissionEventHandler ["EntityCreated", GVAR(disableAPS)];

                GVAR(disableAPS) = nil;
                publicVariable QGVAR(disableAPS);
            } call FUNC(sanitiseFunction), []]] call CBA_fnc_serverEvent;

            _string = LSTRING(rhsApsAllFutureVehiclesEnabledMessage);
        } else {
            if (!isNil QGVAR(disableAPS)) exitWith {};

            ["zen_common_execute", [{
                if (!isNil QGVAR(disableAPS)) exitWith {};

                GVAR(disableAPS) = addMissionEventHandler ["EntityCreated", {
                    params ["_object"];

                    if !(_object isKindOf "rhs_t14_base" || {_object isKindOf "rhs_t15_base"}) exitWith {};

                    // Wait for rhs_aps_vehicles to be updated
                    [{
                        private _apsVehicles = (GETMVAR("rhs_aps_vehicles",[])) select {alive _x};
                        private _index = _apsVehicles find _this;

                        if (_index == -1) exitWith {};

                        _apsVehicles deleteAt _index;

                        SETMVAR("rhs_aps_vehicles",_apsVehicles,true);
                    }, _object, 1] call CBA_fnc_waitAndExecute;
                }];

                publicVariable QGVAR(disableAPS);
            } call FUNC(sanitiseFunction), []]] call CBA_fnc_serverEvent;

            _string = LSTRING(rhsApsAllFutureVehiclesDisabledMessage);
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
