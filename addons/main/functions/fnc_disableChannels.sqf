#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates a module that can disable various chats (excluding custom ones).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_disableChannels;
 *
 * Public: No
 */

["Zeus Additions - Utility", "[WIP] Disable Channels", {
    params ["", "_unit"];

    ["[WIP] Disable Channels", [
        ["OWNERS", ["Players selected", "Select a side/group/unit."], [[], [], [], 2], true],
        ["TOOLBOX:WIDE", ["Global channel", "Allows to change the global chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
        ["TOOLBOX:WIDE", ["Side channel", "Allows to change the side chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
        ["TOOLBOX:WIDE", ["Command channel", "Allows to change the command chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
        ["TOOLBOX:WIDE", ["Group channel", "Allows to change the group chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
        ["TOOLBOX:WIDE", ["Vehicle channel", "Allows to change the vehicle chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
        ["TOOLBOX:WIDE", ["Direct channel", "Allows to change the direct chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_globalEnabled", "_sideEnabled", "_commandEnabled", "_groupEnabled", "_vehicleEnabled", "_directEnabled"];
        _selected params ["_sides", "_groups", "_players"];

        {
            switch (_x) do {
                case 0: {_x = [_forEachIndex, [false, false]]};
                case 1: {_x = [_forEachIndex, [true, false]]};
                case 2: {_x = [_forEachIndex, [false, true]]};
                case 3: {_x = [_forEachIndex, [true, true]]};
                default {};
            };
        } forEach [_globalEnabled, _sideEnabled, _commandEnabled, _groupEnabled, _vehicleEnabled, _directEnabled];

        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            if (isNull _unit) then {
                ["Select a side/group/unit!"] call zen_common_fnc_showMessage;
                playSound "FD_Start_F";
            } else {
                {
                    _x remoteExecCall ["enableChannel", _unit];
                } forEach [_globalEnabled, _sideEnabled, _commandEnabled, _groupEnabled, _vehicleEnabled, _directEnabled];

                ["Zeus has changed channel visibility.", false, 5, 10] remoteExecCall ["ace_common_fnc_displayText", _unit];
                ["Changed channel visibility on unit"] call zen_common_fnc_showMessage;
            };
        };

        _players append _groups;
        _players append _sides;

        {
            _unit = _x;
            ["Zeus has changed channel visibility.", false, 5, 10] remoteExecCall ["ace_common_fnc_displayText", _unit];

            {
                _x remoteExecCall ["enableChannel", _unit];
            } forEach [_globalEnabled, _sideEnabled, _commandEnabled, _groupEnabled, _vehicleEnabled, _directEnabled];
        } forEach _players;

        ["Changed channel visibility for selected units"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
