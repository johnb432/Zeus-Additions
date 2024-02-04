#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Allows to store multiple sources for a single reason. Each source can set or reset its value.
 * From a boolean point of view, this is an elaborate OR gate.
 *
 * Arguments:
 * 0: Subject <STRING> (default: "")
 * 1: Source <STRING> (default: "")
 * 2: Set (true) or reset (false) <BOOL> (default: true)
 * 3: Function to be run, if there was a change <STRING> <CODE> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * ["zeus_additions_main_buildingDestruction", getPlayerUID player, true, "zeus_additions_main_fnc_handleBuildingDestruction"] call zeus_additions_main_fnc_changeReason;
 *
 * Public: No
 */

params [["_subject", "", [""]], ["_source", "", [""]], ["_set", true, [true]], ["_function", {}, ["", {}]]];

if ("" in [_subject, _source]) exitWith {};

// If single player, it will never go into this
if (!isServer) exitWith {
    if (!isNil QGVAR(functionsSent)) exitWith {
        [QGVAR(executeFunction), [QFUNC(changeReason), _this]] call CBA_fnc_serverEvent;
    };

    // If function isn't available on server yet
    if (isNil QGVAR(subjectReasonsDelayed)) then {
        GVAR(subjectReasonsDelayed) = [];

        // When functions have been sent, execute delayed
        QGVAR(functionsSent) addPublicVariableEventHandler {
            params ["", "_value"];

            // If already executed, don't execute again
            if (isNil QGVAR(subjectReasonsDelayed)) exitWith {};

            if !(!isNil "_value" && {_value isEqualType true} && {_value}) exitWith {};

            {
                [QGVAR(executeFunction), [QFUNC(changeReason), _x]] call CBA_fnc_serverEvent;
            } forEach GVAR(subjectReasonsDelayed);

            GVAR(subjectReasonsDelayed) = nil;
        };
    };

    GVAR(subjectReasonsDelayed) pushBack _this;
};

if (isNil QGVAR(subjectReasons)) then {
    GVAR(subjectReasons) = createHashMap;
    GVAR(results) = createHashMap;
};

private _reasons = GVAR(subjectReasons) getOrDefault [_subject, [], true];

if (_set) then {
    _reasons pushBackUnique _source;
} else {
    _reasons deleteAt (_reasons find _source);
};

// Check if there are any reasons stored
private _result = _reasons isNotEqualTo [];

// If the current result is the same as the previous, skip calling function
if ((GVAR(results) getOrDefault [_subject, !_result]) == _result) exitWith {};

GVAR(results) set [_subject, _result];

// Get function
if (_function isEqualType "") then {
    _function = GETMVAR(_function,GETUVAR(_function,{}));
};

if (!isNil "_function" && {_function isEqualType {}}) then {
    _result call _function;
};

nil
