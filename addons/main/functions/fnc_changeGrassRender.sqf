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
 * call zeus_additions_main_fnc_changeGrassRender;
 *
 * Public: No
 */

["Zeus Additions - Players", "Change Grass Rendering", {
    params ["", "_unit"];

    ["Change Grass Rendering Settings", [
        ["OWNERS", ["Players selected", "Select sides/groups/units. Module can also be placed on a player."], [[], [], [], 0], true],
        ["TOOLBOX:YESNO", ["Change yourself", "You can use this whilst as a curator to change your grass rendering."], false, true],
        ["LIST", ["Setting", "Choose Low to turn off grass rendering. Choose Standard if you want to render it again."], [[50, 25, 12.5, 6.25, 3.125], ["Low (Off)", "Standard (Normal)", "High", "Very High", "Ultra"], 0, 5]],
        ["TOOLBOX:YESNO", ["Account for JIP players", "When players join in progress (JIP), it will automatically apply this setting."], false, false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_self", "_setting", "_doJIP"];
        _selected params ["_sides", "_groups", "_players"];

        private _string = "Grass rendering changed on selected players";

        // If self is checked
        if (_self) then {
            setTerrainGrid _setting;
        };

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If unit is player, apply setting
            if (isPlayer _unit) then {
                _setting remoteExecCall ["setTerrainGrid", _unit];

                _string = "Grass rendering changed on player";
            } else {
                // If unit is AI, null or otherwise invalid, display error if not something done to self
                if (_self) then {
                    _string = "Grass rendering changed on yourself";
                } else {
                    _string = "Select a side/group/player or even yourself (must be a player)!";
                    playSound "FD_Start_F";
                };
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // Handle JIP
        if (_doJIP) then {
            if (missionNamespace getVariable [QGVAR(handleServerJIP), false]) then {
                GVAR(grassSettingsJIP) = [_setting, _players apply {getPlayerUID _x}, _groups, _sides];
                publicVariableServer QGVAR(grassSettingsJIP);
            } else {
                ["JIP disabled. Turn on in CBA Settings to enable it.", false, 10, 2] call ace_common_fnc_displayText;
            };
        };

        // Add all sides, groups and units into one array, to apply settings more easily
        _players append _groups;
        _players append _sides;

        _setting remoteExecCall ["setTerrainGrid", _players];

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
