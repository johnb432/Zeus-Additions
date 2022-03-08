/*
 * Author: johnb43
 * Adds a module that can delete an entity forcefully.
 */

["Zeus Additions - Utility", "Delete Object (Forced)", {
    params ["", "_object"];

    if (isNull _object) exitWith {
         ["Select an object!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    if (isPlayer _object) exitWith {
        ["You can't delete players!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    // Check if there is crew
    if ((crew _object) isNotEqualTo []) then {
        // Delete units where vehicle is local
        _object remoteExecCall ["deleteVehicleCrew", _object];

        [{
            (crew _this) isEqualTo [];
        }, {
            deleteVehicle _this;
        }, _object] call CBA_fnc_waitUntilAndExecute;
    } else {
        // No crew
        deleteVehicle _object;
    };

    ["Deleted %1", getText (configOf _object >> "displayName")] call zen_common_fnc_showMessage;
}, ICON_DELETE] call zen_custom_modules_fnc_register;
