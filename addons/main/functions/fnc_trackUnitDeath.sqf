#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module that can inform the Zeus when a unit dies.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_trackUnitDeath;
 *
 * Public: No
 */

GVAR(trackUnits) = [];

addMissionEventHandler ["EntityKilled", {
    params ["_unit", "_killer"];

    if (GVAR(trackUnits) isEqualTo [] || {!(_unit in GVAR(trackUnits))}) exitWith {};

    private _nameUnit = name _unit;
    _killer = name _killer;

    if (_unit getVariable [QGVAR(displayHint), false]) then {
        hint format ["[Zeus Additions]: %1 was killed by %2", _nameUnit, _killer];
    };

    if (_unit getVariable [QGVAR(displaySystemChat), false]) then {
        systemChat format ["[Zeus Additions]: %1 was killed by %2", _nameUnit, _killer];
    };

    if (_unit getVariable [QGVAR(displayZeusBanner), false]) then {
        ["[Zeus Additions]: %1 was killed by %2", _nameUnit, _killer] call zen_common_fnc_showMessage;
    };

    if (_unit getVariable [QGVAR(displayLog), false]) then {
        diag_log text format ["[Zeus Additions]: %1 was killed by %2", _nameUnit, _killer];
    };

    GVAR(trackUnit) = GVAR(trackUnit) - [_unit];
}];

["Zeus Additions - Utility", "Track Unit Death", {
    params ["", "_unit"];

    ["Track Unit Death", [
        ["OWNERS", ["Player selected", "Select unit. Module can also be placed on a unit."], [[], [], [], 0], true],
        ["TOOLBOX:ENABLED", ["Tracking", "Adds/removes tracking from the selected unit."], false],
        ["TOOLBOX:YESNO", ["Display in a Hint", "Displays notification as hint."], true],
        ["TOOLBOX:YESNO", ["Display in System Chat", "Displays notification in system chat."], false],
        ["TOOLBOX:YESNO", ["Display in Zeus Banner", "Displays notification in zeus interface."], false],
        ["TOOLBOX:YESNO", ["Log", "Write notification in Log (RPT)."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_remove", "_hint", "_systemChat", "_zeusBanner", "_log"];
        _selected params ["", "", "_players"];

        // If no unit was selected in the dialog, check if module was placed on a unit
        if (_players isNotEqualTo []) then {
            _unit = _players select 0;
        };

        // If object is not unit, exit
        if !(_unit isKindOf "CAManBase") exitWith {
            ["Select a unit!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        // If remove EH
        if (_remove) exitWith {
            GVAR(trackUnit) = GVAR(trackUnit) - [_unit];
        };

        // If no method of notification was selected, exit
        if (!_hint && {!_systemChat} && {!_zeusBanner} && {!_log}) exitWith {
            ["Select a way of notification!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        // Add unit to tracking
        GVAR(trackUnits) pushBackUnique _unit;

        _unit setVariable [QGVAR(displayHint), _hint];
        _unit setVariable [QGVAR(displaySystemChat), _systemChat];
        _unit setVariable [QGVAR(displayZeusBanner), _zeusBanner];
        _unit setVariable [QGVAR(displayLog), _log];

        ["Unit is being tracked"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_RADIO] call zen_custom_modules_fnc_register;
