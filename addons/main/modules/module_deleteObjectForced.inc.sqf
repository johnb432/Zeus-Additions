/*
 * Author: johnb43
 * Adds a module that can delete an entity forcefully.
 */

[LSTRING(moduleCategoryUtility), LSTRING(deleteObjectModuleName), {
    params ["", "_object"];

    if (isNull _object) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    if (isPlayer _object) exitWith {
        ["str_a3_bis_fnc_showcuratorfeedbackmessage_407"] call zen_common_fnc_showMessage;
    };

    // Delete crew & object
    ["zen_common_execute", [{
        deleteVehicleCrew _this;
        deleteVehicle _this;
    } call FUNC(sanitiseFunction), _object], _object] call CBA_fnc_targetEvent;

    [LSTRING(deleteObjectMessage), getText (configOf _object >> "displayName")] call zen_common_fnc_showMessage;
}, "\A3\ui_f\data\igui\cfg\commandbar\unitcombatmode_ca.paa"] call zen_custom_modules_fnc_register;
