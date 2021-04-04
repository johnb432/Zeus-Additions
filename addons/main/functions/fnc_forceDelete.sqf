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
 * call zeus_additions_main_fnc_forceDelete;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

["Zeus Additions - Utility", "[WIP] Force delete object", {
    params ["", "_object"];

    if (isPlayer _object) exitWith {
        ["You can't delete players!"] call zen_common_fnc_showMessage;
    };

    if (!isNil {crew _object}) then {
        {
            deleteVehicle _x;
        } forEach (crew _object);
    };

    deleteVehicle (_object);

    ["Deleted %1", name _object] call zen_common_fnc_showMessage;
}] call zen_custom_modules_fnc_register;
