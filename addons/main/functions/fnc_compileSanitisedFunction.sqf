#include "..\script_component.hpp"
/*
 * Author: commy2 (from CBA), johnb43
 * Compiles a function into mission namespace and into ui namespace for caching purposes.
 * Recompiling can be enabled by inserting the CBA_cache_disable.pbo from the optionals folder.
 * Slightly modified CBA_fnc_compileFunction.
 *
 * Arguments:
 * 0: Path to function sqf file <STRING> (default: "")
 * 1: Final function name <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * ["x\zeus_additions\addons\main\functions\fnc_compileSanitisedFunction.sqf", "zeus_additions_main_fnc_compileSanitisedFunction"] call zeus_additions_main_fnc_compileSanitisedFunction
 *
 * Public: No
 */

params [["_funcFile", "", [""]], ["_funcName", "", [""]]];

private _cachedFunc = uiNamespace getVariable _funcName;

if (isNil "_cachedFunc") then {
    uiNamespace setVariable [_funcName, [preprocessFileLineNumbers _funcFile, true, true] call FUNC(sanitiseFunction)];
    missionNamespace setVariable [_funcName, uiNamespace getVariable _funcName];
} else {
    if (["compile"] call CBA_fnc_isRecompileEnabled) then {
        missionNamespace setVariable [_funcName, [preprocessFileLineNumbers _funcFile, true, true] call FUNC(sanitiseFunction)];
    } else {
        missionNamespace setVariable [_funcName, _cachedFunc];
    };
};
