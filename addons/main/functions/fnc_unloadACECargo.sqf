#include "script_component.hpp"

/*
 * Author: johnb43
 * Spawns a module that allows Zeus to unload ACE cargo items from vehicles.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_addACEDragAndCarry;
 *
 * Public: No
 */

["Zeus Additions - Utility", "[WIP] Unload ACE Cargo", {
    params ["", "_object"];

    if (!(_object isKindOf "AllVehicles")) exitWith {
         ["Select an object!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    if (!ace_cargo_enable) exitWith {
         ["ACE Cargo isn't enabled!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    if (!(_object getVariable ["ace_cargo_hasCargo", getNumber (configFile >> "CfgVehicles" >> (typeOf _object) >> "ace_cargo_hasCargo") == 1])) exitWith {
         ["This vehicle doesn't have ACE Cargo!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    private _loadTimeCoeff = +ace_cargo_loadTimeCoefficient;
    ace_cargo_loadTimeCoefficient = 0;

    [_object, CARGO_MENU, _loadTimeCoeff] call FUNC(openACEMenu);
}, ICON_CARGO] call zen_custom_modules_fnc_register;
