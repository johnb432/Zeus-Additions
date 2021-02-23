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

["Zeus Additions", "[WIP] Make people invincible at mission end", {
    ["Make Invincible at mission end (use only very close to mission end, as this is performance consuming)", [
        ["CHECKBOX", ["Make Invincible", "Makes players invincible at mission end to prevent friendly firing."], true]
    ],
    {
        params ["_results"];
        _results params ["_invincible"];

        private _string = "Mission end invincibility set";

        if (_invincible) then {
            if (isNil QGVAR(missionEndID)) then {
                GVAR(missionEndID) = [{
                    if (!isNull (uiNamespace getVariable ["RscDisplayDebriefing",displayNull])) exitWith {
                        [GVAR(missionEndID)] call CBA_fnc_removePerFrameHandler;

                        {
                            ["zen_common_allowDamage", [_x, false], _x] call CBA_fnc_targetEvent;

                            // If player is in a vehicle, make that invincible too
                            if !(vehicle _x isEqualTo _x) then {
                                ["zen_common_allowDamage", [vehicle _x, false], vehicle _x] call CBA_fnc_targetEvent;
                            };
                        } forEach allPlayers;
                    };
                }, 0.1] call CBA_fnc_addPerFrameHandler;
            } else {
                _string = "Mission end invincibility already set!";
            };
        } else {
            if (!isNil QGVAR(missionEndID)) then {
                [GVAR(missionEndID)] call CBA_fnc_removePerFrameHandler;
                GVAR(missionEndID) = nil;
                _string = "Mission end invincibility removed";
            } else {
                _string = "Mission end invincibility already removed!";
            };
        };

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions", "[WIP] End mission with player invincibility", {
    ["End mission with player invincibility", [
        ["LIST", ["Mission ending", "You can't set a debrief text!"], [[true, false], ["Mission completed", "Mission failed"], 0, 1]],
        ["CHECKBOX", ["Make Invincible", "Makes players invincible at mission end to prevent friendly firing."], true]
    ],
    {
        params ["_results"];
        _results params ["_isVictory", "_invincible"];

        private _allowDamage = !_invincible;

        {
            ["zen_common_allowDamage", [_x, _allowDamage], _x] call CBA_fnc_targetEvent;

            // If player is in a vehicle, make that invincible too
            if !(vehicle _x isEqualTo _x) then {
                ["zen_common_allowDamage", [vehicle _x, _allowDamage], vehicle _x] call CBA_fnc_targetEvent;
            };
        } forEach allPlayers;

        ["end1", _isVictory] remoteExecCall ["BIS_fnc_endMission", 0];
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
