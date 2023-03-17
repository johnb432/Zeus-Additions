/*
 * Author: johnb43
 * Adds a module that can inform the Zeus when a unit dies.
 */

GVAR(trackUnits) = [];

["Zeus Additions - Utility", "Track Unit Death", {
    params ["", "_unit"];

    ["Track Unit Death", [
        ["OWNERS", ["Player selected", "Select unit. Module can also be placed on a unit."], [[], [], [], 2], true],
        ["TOOLBOX:ENABLED", ["Tracking", "Adds/removes tracking from the selected unit."], false],
        ["TOOLBOX:YESNO", ["Display in a Hint", "Displays notification as hint."], true],
        ["TOOLBOX:YESNO", ["Display in System Chat", "Displays notification in system chat."], false],
        ["TOOLBOX:YESNO", ["Display in Zeus Banner", "Displays notification in zeus interface."], false],
        ["TOOLBOX:YESNO", ["Log", "Write notification in Log (RPT)."], false]
    ], {
        params ["_results", "_unit"];
        _results params ["_selected", "_add", "_hint", "_systemChat", "_zeusBanner", "_log"];
        _selected params ["", "", "_players"];

        // If no unit was selected in the dialog, check if module was placed on a unit
        _unit = _players param [0, _unit];

        if (!alive _unit) exitWith {
            ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
        };

        if !(_unit isKindOf "CAManBase") exitWith {
            ["STR_ZEN_Modules_OnlyInfantry"] call zen_common_fnc_showMessage;
        };

        // If remove EH
        if (!_add) exitWith {
            GVAR(trackUnits) deleteAt (GVAR(trackUnits) find _unit);

            // Remove EH if unit tracking is empty
            if (GVAR(trackUnits) isEqualTo []) then {
                removeMissionEventHandler ["EntityKilled", GVAR(trackUnitDeathEH)];
                GVAR(trackUnitDeathEH) = nil;
            };

            ["Unit is no longer being tracked"] call zen_common_fnc_showMessage;
        };

        // If no method of notification was selected, exit
        if (!_hint && {!_systemChat} && {!_zeusBanner} && {!_log}) exitWith {
            ["Select a way of notification"] call zen_common_fnc_showMessage;
        };

        _unit setVariable [QGVAR(displayDeath), [_hint, _systemChat, _zeusBanner, _log]];

        if (isNil QGVAR(trackUnitDeathEH)) then {
            GVAR(trackUnitDeathEH) = addMissionEventHandler ["EntityKilled", {
                params ["_unit", "_killer", "_instigator"];

                if !(_unit in GVAR(trackUnits)) exitWith {};

                private _nameUnit = name _unit;

                if (!isNull _instigator) then {
                    _killer = _instigator;
                };

                _killer = name _killer;

                private _notification = _unit getVariable [QGVAR(displayDeath), [false, false, false, false]];

                if (_notification select 0) then {
                    hint format ["[Zeus Additions]: %1 was killed by %2", _nameUnit, _killer];
                };

                if (_notification select 1) then {
                    systemChat format ["[Zeus Additions]: %1 was killed by %2", _nameUnit, _killer];
                };

                if (_notification select 2) then {
                    ["[Zeus Additions]: %1 was killed by %2", _nameUnit, _killer] call zen_common_fnc_showMessage;
                };

                if (_notification select 3) then {
                    diag_log text format ["[Zeus Additions]: %1 was killed by %2", _nameUnit, _killer];
                };

                GVAR(trackUnits) deleteAt (GVAR(trackUnits) find _unit);

                // Remove EH if unit tracking is empty
                if (GVAR(trackUnits) isNotEqualTo []) exitWith {};

                removeMissionEventHandler [_thisEvent, _thisEventHandler];
                GVAR(trackUnitDeathEH) = nil;
            }];
        };

        // Add unit to tracking
        [["Unit is being tracked", "Unit is already being tracked"] select ((GVAR(trackUnits) pushBackUnique _unit) == -1)] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_RADIO] call zen_custom_modules_fnc_register;
