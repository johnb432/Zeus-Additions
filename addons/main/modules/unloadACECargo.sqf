/*
 * Author: johnb43
 * Spawns a module that allows Zeus to unload ACE cargo items from vehicles.
 */

["Zeus Additions - Utility", "Unload ACE Cargo", {
    if (!isNil "ace_cargo_enable" && {!ace_cargo_enable}) exitWith {
        ["ACE Cargo isn't enabled!"] call zen_common_fnc_showMessage;
    };

    params ["", "_object"];

    if (isNull _object) exitWith {
        ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
    };

    if !(alive _object) exitWith {
        ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
    };

    if ((fullCrew [_object, "driver", true]) isEqualTo []) exitWith {
        ["STR_ZEN_Modules_OnlyVehicles"] call zen_common_fnc_showMessage;
    };

    if !(_object getVariable ["ace_cargo_hasCargo", getNumber (configOf _object >> "ace_cargo_hasCargo") == 1]) exitWith {
        ["This vehicle doesn't have ACE Cargo!"] call zen_common_fnc_showMessage;
    };

    // Save value so it can be applied again later
    private _loadTimeCoeff = ace_cargo_loadTimeCoefficient;
    ace_cargo_loadTimeCoefficient = 0;

    [_object, CARGO_MENU, _loadTimeCoeff] call FUNC(openACEMenu);
}, ICON_CARGO] call zen_custom_modules_fnc_register;
