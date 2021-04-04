#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module allows you to change if people can kill each other at mission end.
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

["Zeus Additions - Utility", "Set player invincibility at mission end", {
    ["Make Invincible at mission end (use only very close to mission end, as this is performance consuming)", [
        ["CHECKBOX", ["Make Invincible", "Makes players invincible at mission end to prevent friendly firing."], true]
    ],
    {
        params ["_results"];
        _results params ["_invincible"];

        GVAR(endMissionEndCheck) = !_invincible;

        if (_invincible) then {
            [{
                // Wait for mission end screen
                !isNull (uiNamespace getVariable ["RscDisplayDebriefing", displayNull]) || GVAR(endMissionEndCheck)
            }, {
                if (GVAR(endMissionEndCheck)) exitWith {};
                {
                    ["zen_common_allowDamage", [_x, false], _x] call CBA_fnc_targetEvent;

                    // If player is in a vehicle, make that invincible too
                    if (vehicle _x isNotEqualTo _x) then {
                        ["zen_common_allowDamage", [vehicle _x, false], vehicle _x] call CBA_fnc_targetEvent;
                    };
                } forEach allPlayers;
            }] call CBA_fnc_waitUntilAndExecute;
        };

        [(["Mission end invincibility removed", "Mission end invincibility set"] select _invincible)] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions - Utility", "End mission with player invincibility", {
    ["End mission with player invincibility", [
        ["LIST", ["Mission ending", "You can't set a debrief text!"], [[true, false], ["Mission completed", "Mission failed"], 0, 2]],
        ["CHECKBOX", ["Make Invincible", "Makes players invincible at mission end to prevent friendly firing."], true]
    ],
    {
        params ["_results"];
        _results params ["_isVictory", "_invincible"];

        if (_invincible) then {
            {
                ["zen_common_allowDamage", [_x, false], _x] call CBA_fnc_targetEvent;

                // If player is in a vehicle, make that invincible too
                if (vehicle _x isNotEqualTo _x) then {
                    ["zen_common_allowDamage", [vehicle _x, false], vehicle _x] call CBA_fnc_targetEvent;
                };
            } forEach allPlayers;
        };

        ["zen_common_execute", [BIS_fnc_endMission, ["end1", _isVictory]]] call CBA_fnc_globalEventJIP;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
