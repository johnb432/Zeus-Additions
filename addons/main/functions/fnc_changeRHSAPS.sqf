#include "script_component.hpp"

/*
 * Author: johnb43
 * Spawns a module that allows Zeus to enable and disable RHS vehicles' active protection system (APS).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_changeRHSAPS;
 *
 * Public: No
 */

 // Check if RHS AFRF is loaded
if (!isClass (configFile >> "CfgPatches" >> "rhs_main_loadorder")) exitWith {};

["Zeus Additions - Utility", "Change RHS APS", {
    params ["", "_object"];

    // If not valid vehicle
    if !(_object isKindOf "rhs_t14_base" || {_object isKindOf "rhs_t15_base"}) exitWith {
         ["Place on an RHS vehicle with APS!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    ["Change RHS APS", [
        ["TOOLBOX:ENABLED", ["APS", "Allows you to change the APS (Active Protection System) on an RHS vehicle."], true]
    ],
    {
        params ["_results", "_object"];

        private _apsVehicles = GETMVAR("rhs_aps_vehicles",[]);

        if (_results select 0) then {
            // Add if necessary
            _apsVehicles pushBackUnique _object;

            SETMVAR("rhs_aps_vehicles",_apsVehicles,true);
        } else {
            // Remove if necessary
            private _index = _apsVehicles find _object;

            if (_index isEqualTo -1) exitWith {};

            _apsVehicles deleteAt _index;

            SETMVAR("rhs_aps_vehicles",_apsVehicles,true);
        };

        ["Changed RHS APS capabilities"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
