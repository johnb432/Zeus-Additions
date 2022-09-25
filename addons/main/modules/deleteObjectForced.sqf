/*
 * Author: johnb43
 * Adds a module that can delete an entity forcefully.
 */

["Zeus Additions - Utility", "Delete Object (Forced)", {
    params ["", "_object"];

    if (isNull _object) exitWith {
        ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
    };

    if (isPlayer _object) exitWith {
        ["You can't delete players!"] call zen_common_fnc_showMessage;
    };

    // Delete crew & object
    ["zen_common_execute", [{
        deleteVehicleCrew _this;
        deleteVehicle _this;
    }, _object], _object] call CBA_fnc_targetEvent;

    ["Deleted %1", getText (configOf _object >> "displayName")] call zen_common_fnc_showMessage;
}, ICON_DELETE] call zen_custom_modules_fnc_register;
