#include "script_component.hpp"

/*
 * Author: johnb43
 * Remove JIP IDs, actions and EH IDs from a suicide bomber.
 *
 * Arguments:
 * 0: Unit <OBJECT>
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
    _jipID call CBA_fnc_removeGlobalEventJIP;
    _unit setVariable [QGVAR(suicideBomberDeadManSwitchJIP), nil, true];
};

if (_removeAction) then {
    _jipID = _unit getVariable QGVAR(suicideBomberActionJIP);

    if (!isNil "_jipID") then {
        _jipID call CBA_fnc_removeGlobalEventJIP;
        _unit setVariable [QGVAR(suicideBomberActionJIP), nil, true];
    };

    // Reset explosives
    _unit setVariable [QGVAR(suicideBomberExplosives), nil, true];
};

// Remove actions and EHs
["zen_common_execute", [{
    params ["_unit", "_removeAction"];

    // Remove scroll wheel action
    if (_removeAction) then {
        private _actionID = _unit getVariable QGVAR(suicideBomberActionID);

        if (!isNil "_actionID") then {
            _unit removeAction _actionID;
            _unit setVariable [QGVAR(suicideBomberActionID), nil];
        };
    };

    // Remove dead man switch
    (_unit getVariable [QGVAR(suicideBomberDeadManSwitchEhIDs), []]) params ["_damageEhID", "_killedEhID"];

    if (isNil "_damageEhID") exitWith {};

    if (zen_common_aceMedical) then {
        ["ace_unconscious", _damageEhID] call CBA_fnc_removeEventHandler;
    } else {
        _unit removeEventHandler ["HandleDamage", _damageEhID];
    };

    _unit removeEventHandler ["Killed", _killedEhID];

    _unit setVariable [QGVAR(suicideBomberDeadManSwitchEhIDs), nil];
}, [_unit, _removeAction]]] call CBA_fnc_globalEvent;
