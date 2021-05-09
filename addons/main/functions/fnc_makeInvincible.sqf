#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module that allows you to change if people can kill each other at mission end.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_makeInvincible;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

["Zeus Additions - Utility", "[WIP] Set player modifier at mission end", {
    ["[WIP] Set player modifier at mission end", [
        ["TOOLBOX:WIDE", ["Mission end modifier", "Sets what type of action is applied to players at mission end."], [0, 1, 5, ["None", "Invincibility", "Weapon removal", "Disable User Input", "Death"]], false]
    ],
    {
        params ["_results"];
        _results params ["_setting"];

        GVAR(endMissionEndCheck) = _setting;

        if (_setting isNotEqualTo 0) then {
            [{
                // Wait for mission end screen
                !isNull (uiNamespace getVariable ["RscDisplayDebriefing", displayNull]) || {GVAR(endMissionEndCheck) isEqualTo 0}
            }, {
                private _setting = GVAR(endMissionEndCheck);
                if (_setting isEqualTo 0) exitWith {};

                switch (_setting) do {
                    case 1: {
                        {
                            ["zen_common_allowDamage", [_x, false], _x] call CBA_fnc_targetEvent;

                            // If player is in a vehicle, make that invincible too
                            if (!isNull objectParent _x) then {
                                ["zen_common_allowDamage", [objectParent _x, false], objectParent _x] call CBA_fnc_targetEvent;
                            };
                        } forEach allPlayers;
                    };
                    case 2: {
                        {
                             _x remoteExecCall ["removeAllWeapons", _x];
                        } forEach allPlayers;
                    };
                    case 3: {
                        true remoteExecCall ["disableUserInput", allPlayers, true];
                    };
                    case 4: {
                        {
                            _x setDamage 1;
                        } forEach allPlayers;
                    };
                    default {};
                };
            }] call CBA_fnc_waitUntilAndExecute;
        };

        ["Mission end player" + (["modifier removed", "invincibility set", "weapon removal set", "input disabled", "death set"] select _setting)] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions - Utility", "[WIP] End mission with player modifier", {
    ["[WIP] End mission with player modifier", [
        ["LIST", ["Mission ending", "You can't set a debrief text!"], [[true, false], ["Mission completed", "Mission failed"], 0, 2]],
        ["TOOLBOX:WIDE", ["Mission end modifier", "Sets what type of action is applied to players at mission end."], [0, 1, 5, ["None", "Invincibility", "Weapon removal", "Disable User Input", "Death"]], false]
    ],
    {
        params ["_results"];
        _results params ["_isVictory", "_setting"];

        switch (_setting) do {
            case 1: {
                {
                    ["zen_common_allowDamage", [_x, false], _x] call CBA_fnc_targetEvent;

                    // If player is in a vehicle, make that invincible too
                    if (!isNull objectParent _x) then {
                        ["zen_common_allowDamage", [objectParent _x, false], objectParent _x] call CBA_fnc_targetEvent;
                    };
                } forEach allPlayers;
            };
            case 2: {
                {
                     _x remoteExecCall ["removeAllWeapons", _x];
                } forEach allPlayers;
            };
            case 3: {
                true remoteExecCall ["disableUserInput", allPlayers, true];
            };
            case 4: {
                {
                    _x setDamage 1;
                } forEach allPlayers;
            };
            default {};
        };

        ["zen_common_execute", [BIS_fnc_endMission, ["end1", _isVictory]]] call CBA_fnc_globalEventJIP;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
