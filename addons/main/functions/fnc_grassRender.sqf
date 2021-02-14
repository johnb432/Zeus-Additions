#include "script_component.hpp"
/*
 * Author: johnb43
 * Adds a module that can change grass rendering density.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_grassRender;
 *
 * Public: No
 */

["Zeus Additions", "Change grass rendering", {
    params ["", "_unit"];

    ["Grass rendering settings", [
        ["OWNERS", ["Player selected", "Changes selected players/groups/sides grass rendering."], [[], [], [], 0], true],
        ["LIST", ["Setting", "Choose Low to turn off grass rendering. Choose Standard if you want to render it again."], [[50, 25, 12.5, 6.25, 3.125], ["Low (Off)", "Standard", "High", "Very High", "Ultra"], 0, 5]]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_setting"];
        _selected params ["_sides", "_groups", "_players"];

        if  (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []} && {isNull _unit}) exitWith {
            ["Select a side/group/unit!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            _setting remoteExec ["setTerrainGrid", _unit];
            ["Grass rendering changed on unit"] call zen_common_fnc_showMessage;
        };

        private _side = "";
        {
            _side = _x;
            {
                if (side _x isEqualTo _side) then {
                    _setting remoteExec ["setTerrainGrid", _x]; // optimize? https://community.bistudio.com/wiki/remoteExec
                };
            } forEach allPlayers;
        } forEach _sides;

        private _group = "";
        {
            _group = _x;
            {
                if (group _x isEqualTo _group) then {
                    _setting remoteExec ["setTerrainGrid", _x]; // optimize? https://community.bistudio.com/wiki/remoteExec
                };
            } forEach allPlayers;
        } forEach _groups;

        {
            _setting remoteExec ["setTerrainGrid", _x];
        } forEach _players;

        ["Grass rendering changed"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
