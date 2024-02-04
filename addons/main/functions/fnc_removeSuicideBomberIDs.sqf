#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Remove JIP, action and EHs from a suicide bomber.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Remove actions <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * player call zeus_additions_main_fnc_removeSuicideBomberIDs;
 *
 * Public: No
 */

params ["_unit", ["_removeAction", true]];

if (isNull _unit) exitWith {};

// Remove JIP
private _jipID = _unit getVariable QGVAR(suicideBomberDeadManSwitchJIP);

if (!isNil "_jipID") then {
    // FUNC(removeGlobalEventJIP) not guaranteed to exist on clients
    [QGVAR(removeEventJIP), [_jipID, objNull]] call CBA_fnc_serverEvent;

    _unit setVariable [QGVAR(suicideBomberDeadManSwitchJIP), nil, true];
};

if (_removeAction) then {
    _jipID = _unit getVariable QGVAR(suicideBomberActionJIP);

    if (!isNil "_jipID") then {
        [QGVAR(removeEventJIP), [_jipID, objNull]] call CBA_fnc_serverEvent;

        _unit setVariable [QGVAR(suicideBomberActionJIP), nil, true];
    };

    // Reset explosives
    _unit setVariable [QGVAR(suicideBomberExplosives), nil, true];
};

// Remove actions and EHs
[QGVAR(executeFunction), [QFUNC(removeSuicideBomberEh), [_unit, _removeAction]]] call CBA_fnc_globalEvent;
