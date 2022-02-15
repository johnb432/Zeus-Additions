/*
 * Author: johnb43
 * Spawns a module that allows Zeus to enable and disable RHS vehicles' active protection system (APS).
 */

["Zeus Additions - Utility", "Change RHS APS", {
    params ["", "_object"];

    ["Change RHS APS", [
        ["TOOLBOX:ENABLED", ["APS", "Allows you to change the APS (Active Protection System) on a vehicle with RHS APS."], true],
        ["TOOLBOX", ["Selection", "Changes APS on selected object only or all vehicles with RHS APS."], [0, 1, 2, ["Object only", "All Vehicles"]]]
    ],
    {
        params ["_result", "_object"];
        _result params ["_enabled", "_all"];

        private _apsVehicles = (GETMVAR("rhs_aps_vehicles",[])) select {alive _x};

        // All vehicles
        if (_all isEqualTo 1) exitWith {
            private _string = if (_enabled) then {
                private _vehicles = entities [["rhs_t14_base", "rhs_t15_base"], [], false, true];

                if (_vehicles isEqualTo []) exitWith {
                    playSound "FD_Start_F";
                    "No valid vehicles were found!";
                };

                private _count = count _apsVehicles;

                _apsVehicles append _vehicles;
                _apsVehicles = _apsVehicles arrayIntersect _apsVehicles;

                // See if any vehicles were added
                if ((count _apsVehicles) isEqualTo _count) then {
                    playSound "FD_Start_F";
                    "All Vehicles already had RHS APS enabled!";
                } else {
                    SETMVAR("rhs_aps_vehicles",_apsVehicles,true);
                    "RHS APS enabled on all vehicles";
                };
            } else {
                if (_apsVehicles isEqualTo []) exitWith {
                    "All Vehicles already had RHS APS disabled!";
                };

                SETMVAR("rhs_aps_vehicles",[],true);
                "Disabled RHS APS on all vehicles";
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // If not valid vehicle
        if !(alive _object && {(_object isKindOf "rhs_t14_base" || {_object isKindOf "rhs_t15_base"})}) exitWith {
             ["Place on an undestroyed vehicle with RHS APS!"] call zen_common_fnc_showMessage;
             playSound "FD_Start_F";
        };

        private _string = if (_enabled) then {
            // Add if necessary
            if ((_apsVehicles pushBackUnique _object) isEqualTo -1) exitWith {
                "Vehicle aleady had RHS APS enabled!";
            };

            SETMVAR("rhs_aps_vehicles",_apsVehicles,true);

            "Enabled RHS APS on vehicle";
        } else {
            // Remove if necessary
            private _index = _apsVehicles find _object;

            if (_index isEqualTo -1) exitWith {
                "Vehicle aleady had RHS APS disabled!";
            };

            _apsVehicles deleteAt _index;

            SETMVAR("rhs_aps_vehicles",_apsVehicles,true);

            "Disabled RHS APS on vehicle";
        };

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
