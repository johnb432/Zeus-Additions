#include "..\script_component.hpp"
/*
 * Author: commy2, johnb43
 * CBA_fnc_globalEventJIP, but adjusted for Zeus Additions.
 *
 * Arguments:
 * 0: Event name <STRING>
 * 1: Paramters <ANYTHING>
 * 2: Unique event ID. Can be used to remove or overwrite the event later <STRING> (default: create unique id)
 *
 * Return Value:
 * Unique event ID <STRING>
 *
 * Example:
 * [player, (getPosATL player) vectorAdd [0, 0, 1000]] call zeus_additions_main_fnc_addParachute;
 *
 * Public: No
 */

params [["_eventName", "", [""]], ["_params", []], ["_jipID", "", [""]]];

// Generate string
if (_jipID isEqualTo "") then {
    if (isNil QGVAR(lastJIPID)) then {
        GVAR(lastJIPID) = -1;
    };

    GVAR(lastJIPID) = GVAR(lastJIPID) + 1;

    _jipID = [QUOTE(ADDON), clientOwner, GVAR(lastJIPID)] joinString ":";
};

// Put on JIP stack
[QGVAR(addEventJIP), [_eventName, _params, _jipID]] call CBA_fnc_serverEvent;

// Execute on every machine
[_eventName, _params] call CBA_fnc_globalEvent;

_jipID
