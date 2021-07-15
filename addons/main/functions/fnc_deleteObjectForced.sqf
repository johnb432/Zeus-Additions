#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module that can delete an entity forcefully.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_deleteObjectForced;
 *
 * Public: No
 */

["Zeus Additions - Utility", "Delete Object (forced)", {
    params ["", "_object"];

    if (isPlayer _object) exitWith {
        ["You can't delete players!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    if (!isNil {crew _object}) then {
        {
            _object deleteVehicleCrew _x;
        } forEach (crew _object);
    };

    deleteVehicle (_object);

    ["Deleted %1", getText (configOf _object >> "displayName")] call zen_common_fnc_showMessage;
}, ICON_DELETE] call zen_custom_modules_fnc_register;
