/*
 * Author: johnb43
 * Spawns a module that allows Zeus to unload ACE cargo items from vehicles.
 */

["Zeus Additions - Utility", "Unload ACE Cargo", {
    params ["", "_object"];

    if (!ace_cargo_enable) exitWith {
         ["ACE Cargo isn't enabled!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    if !(alive _object && {_object isKindOf "AllVehicles"}) exitWith {
         ["Select an undestroyed object!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    if !(_object getVariable ["ace_cargo_hasCargo", getNumber (configOf _object >> "ace_cargo_hasCargo") isEqualTo 1]) exitWith {
         ["This vehicle doesn't have ACE Cargo!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    // Save value so it can be applied again later
    private _loadTimeCoeff = ace_cargo_loadTimeCoefficient;
    ace_cargo_loadTimeCoefficient = 0;

    [_object, CARGO_MENU, _loadTimeCoeff] call FUNC(openACEMenu);
}, ICON_CARGO] call zen_custom_modules_fnc_register;
