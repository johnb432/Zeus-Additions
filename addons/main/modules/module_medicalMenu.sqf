/*
 * Author: johnb43
 * Adds a module that allows you to open the medical menu of a unit.
 */

[LSTRING(moduleCategoryMedical), LSTRING_ACE(medical_GUI,openMedicalMenu), {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
    if (alive _unit) then {
        _unit = effectiveCommander _unit;
    };

    // Can be applied to dead units too!
    if !(_unit isKindOf "CAManBase" && {!(_unit isKindOf "VirtualCurator_F")}) exitWith {
        [LSTRING_ZEN(modules,onlyInfantry)] call zen_common_fnc_showMessage;
    };

    [_unit, MEDICAL_MENU] call FUNC(openACEMenu);
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
