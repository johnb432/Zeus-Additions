#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Returns if there is an object in the array of objects that can have its pathing disabled or enabled.
 *
 * Arguments:
 * 0: Objects <ARRAY> (default: [])
 * 1: Type <STRING> (default: "")
 *
 * Return Value:
 * If there is an object that can have its pathing enabled/disabled <BOOL>
 *
 * Example:
 * [[cursorObject], "disableAI"] call zeus_additions_main_fnc_pathingCondition;
 *
 * Public: No
 */

params [["_objects", []], ["_type", "", [""]]];

private _condition = if (_type == "enableAI") then {
    {!(_x checkAIFeature "PATH")}
} else {
    {_x checkAIFeature "PATH"}
};

_objects findIf {
    ((_x isKindOf "CAManBase" && {getNumber ((configOf _x) >> "isPlayableLogic") == 0}) || {
        if (fullCrew [_x, "driver", true] isNotEqualTo []) then {
            _x = driver _x;
            true
        } else {
            false
        }
    }) &&
    {alive _x} &&
    {!isPlayer _x} &&
    _condition
} != -1
