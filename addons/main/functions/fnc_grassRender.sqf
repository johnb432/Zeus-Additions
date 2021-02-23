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
 * call zeus_additions_main_fnc_grassRender;
 *
 * Public: No
 */

["Zeus Additions", "[WIP] Change grass rendering", {
    params ["", "_unit"];

    ["Grass rendering settings", [
        ["OWNERS", ["Players selected", "Changes selected players/groups/sides grass rendering."], [[], [], [], 0], true],
        ["CHECKBOX", ["Change yourself", "You can use this whilst as a curator to change your grass rendering."], false, true],
        ["LIST", ["Setting", "Choose Low to turn off grass rendering. Choose Standard if you want to render it again."], [[50, 25, 12.5, 6.25, 3.125], ["Low (Off)", "Standard", "High", "Very High", "Ultra"], 0, 5]]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_self", "_setting"];
        _selected params ["_sides", "_groups", "_players"];

        private _string = "Grass rendering changed on selected players";

        if (_self) then {
            setTerrainGrid _setting;
        };

        if  (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            if (!isNull _unit && {isPlayer _unit}) then {
                _setting remoteExec ["setTerrainGrid", _unit];
                _string = "Grass rendering changed on player";
            } else {
                if (_self) then {
                    _string = "Grass rendering changed on yourself";
                } else {
                    _string = "Select a side/group/player or even yourself!";
                    playSound "FD_Start_F";
                };
            };
            [_string] call zen_common_fnc_showMessage;
        };

        _players append _groups;
        _players append _sides;

        {
            _setting remoteExec ["setTerrainGrid", _x];
        } forEach _players;

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
