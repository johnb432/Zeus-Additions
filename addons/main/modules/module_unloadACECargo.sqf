/*
 * Author: johnb43
 * Spawns a module that allows Zeus to unload ACE cargo items from vehicles.
 */

[LSTRING(moduleCategoryUtility), LSTRING(unloadACECargoModuleName), {
    if (!isNil "ace_cargo_enable" && {!ace_cargo_enable}) exitWith {
        [LSTRING(aceCargoDisabled)] call zen_common_fnc_showMessage;
    };

    params ["", "_object"];

    if (isNull _object) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    if !(alive _object) exitWith {
        [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
    };

    if ((fullCrew [_object, "driver", true]) isEqualTo []) exitWith {
        [LSTRING_ZEN(modules,onlyVehicles)] call zen_common_fnc_showMessage;
    };

    if (_object getVariable ["ace_cargo_loaded", []] isEqualTo []) exitWith {
        [LSTRING(unloadACECargoNoCargo)] call zen_common_fnc_showMessage;
    };

    // Save value so it can be applied again later
    private _loadTimeCoeff = ace_cargo_loadTimeCoefficient;
    ace_cargo_loadTimeCoefficient = 0;

    [_object, CARGO_MENU, _loadTimeCoeff] call FUNC(openACEMenu);
}, "a3\ui_f\data\IGUI\Cfg\Actions\loadVehicle_ca.paa"] call zen_custom_modules_fnc_register;
