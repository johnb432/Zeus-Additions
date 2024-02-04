#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Disables or enables pathing on units/drivers in array.
 *
 * Arguments:
 * 0: Objects <ARRAY> (default: [])
 * 1: Type <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * [[cursorObject], "disableAI"] call zeus_additions_main_fnc_pathingStatement;
 *
 * Public: No
 */

params [["_objects", []], ["_type", "", [""]]];

private _condition = if (_type == "enableAI") then {
    {!(_x checkAIFeature "PATH")}
} else {
    {_x checkAIFeature "PATH"}
};

{
    if !(_x isKindOf "CAManBase") then {
        _x = driver _x;
    };

    [["zen_common_" + _type, [_x, "PATH"], QGVAR(path_) + hashValue _x] call CBA_fnc_globalEventJIP, _x] call CBA_fnc_removeGlobalEventJIP;
} forEach (_objects select {
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
});
