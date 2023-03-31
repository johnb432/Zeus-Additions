/*
 * Author: johnb43
 * Adds a module that allows you to open the medical menu of a unit.
 */

["Zeus Additions - Medical", "Open ACE Medical Menu", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
    };

    // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
    if (alive _unit) then {
        _unit = effectiveCommander _unit;
    };

    // Can be applied to dead units too!
    if !(_unit isKindOf "CAManBase" && {!(_unit isKindOf "VirtualCurator_F")}) exitWith {
        ["STR_ZEN_Modules_OnlyInfantry"] call zen_common_fnc_showMessage;
    };

    [_unit, MEDICAL_MENU] call FUNC(openACEMenu);
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
