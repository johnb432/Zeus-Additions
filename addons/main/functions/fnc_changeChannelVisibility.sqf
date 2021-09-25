#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates a module that can change various channel's visibility (including custom ones, which can be added or removed during mission without issues).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_changeChannelVisibility;
 *
 * Public: No
 */

["Zeus Additions - Players", "Change Channel Visibility", {
    params ["", "_unit"];

    // Make array of default dialog choices
    private _dialogChoices = [
        ["OWNERS", ["Players selected", "Select sides/groups/players. Module can also be placed on a player."], [[], [], [], 0], true],
        ["TOOLBOX:YESNO", ["Change yourself", "You can use this whilst as a curator to change your channel visibility."], false, true],
        ["TOOLBOX:WIDE", ["Global channel", "Allows to change the global chat & VON."], [1, 1, 4, ["Disabled", "Chat only", "VON only", "Enabled"]], false],
        ["TOOLBOX:WIDE", ["Side channel", "Allows to change the side chat & VON."], [1, 1, 4, ["Disabled", "Chat only", "VON only", "Enabled"]], false],
        ["TOOLBOX:WIDE", ["Command channel", "Allows to change the command chat & VON."], [1, 1, 4, ["Disabled", "Chat only", "VON only", "Enabled"]], false],
        ["TOOLBOX:WIDE", ["Group channel", "Allows to change the group chat & VON."], [1, 1, 4, ["Disabled", "Chat only", "VON only", "Enabled"]], false],
        ["TOOLBOX:WIDE", ["Vehicle channel", "Allows to change the vehicle chat & VON."], [1, 1, 4, ["Disabled", "Chat only", "VON only", "Enabled"]], false],
        ["TOOLBOX:WIDE", ["Direct channel", "Allows to change the direct chat & VON."], [1, 1, 4, ["Disabled", "Chat only", "VON only", "Enabled"]], false]
    ];

    // Add default channels
    private _channelIDs = [0, 1, 2, 3, 4, 5];

    // Add custom channels if existent
    for "_i" from 1 to 10 step 1 do {
        (radioChannelInfo _i) params ["", "_name", "", "", "", "_exists"];

        if (_exists) then {
            _dialogChoices pushBack (["TOOLBOX:WIDE", [format ["'%1' channel", _name], format ["Allows to change the '%1' chat & VON.", _name]], [1, 1, 4, ["Disabled", "Chat only", "VON only", "Enabled"]], false]);
            _channelIDs pushBack (_i + 5);
        };
    };

    // Add JIP to dialog
    _dialogChoices pushBack (["TOOLBOX:YESNO", ["Account for JIP players", "When players join in progress (JIP), it will automatically apply this setting."], false, false]);

    ["Change Channel Visibility", _dialogChoices,
    {
        params ["_results", "_args"];
        _args params ["_unit", "_channelIDs"];

        // Save results so that they can be deleted; to get all channel settings in one array
        (_results select 0) params ["_sides", "_groups", "_players"];
        private _self = _results select 1;
        private _doJIP = _results select (count _results - 1);

        _results deleteRange [0, 2];
        _results deleteAt (count _results - 1);

        private _enableArray = [];

        // Make array ready to be used with enableChannel
        {
            switch (_x) do {
                case 0: {_enableArray pushBack [(_channelIDs select _forEachIndex), [false, false]]};
                case 1: {_enableArray pushBack [(_channelIDs select _forEachIndex), [true, false]]};
                case 2: {_enableArray pushBack [(_channelIDs select _forEachIndex), [false, true]]};
                default {_enableArray pushBack [(_channelIDs select _forEachIndex), [true, true]]};
            };
        } forEach _results;

        private _string = "Changed channel visibility on selected players";

        // If self is checked
        if (_self) then {
            {
                _x remoteExecCall ["enableChannel", player];
            } forEach _enableArray;
        };

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If unit is player, apply setting
            if (isPlayer _unit) then {
                {
                    _x remoteExecCall ["enableChannel", _unit];
                } forEach _enableArray;

                ["zen_common_hint", ["Zeus has changed channel visibility for you."], _unit] call CBA_fnc_targetEvent;

                _string = "Changed channel visibility on player";
            } else {
                // If unit is AI, null or otherwise invalid, display error if not something done to self
                if (_self) then {
                    _string = "Changed channel visibility on yourself";
                } else {
                    _string = "Select a side/group/player or even yourself (must be a player)!";
                    playSound "FD_Start_F";
                };
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // Handle JIP
        if (_doJIP) then {
            if (GETMVAR(QGVAR(handleServerJIP),false)) then {
                GVAR(channelSettingsJIP) = [_enableArray, _players apply {getPlayerUID _x}, _groups, _sides];
                publicVariableServer QGVAR(channelSettingsJIP);
            } else {
                ["JIP disabled. Turn on in CBA Settings to enable it.", false, 10, 2] call ace_common_fnc_displayText;
            };
        };

        // Add all sides, groups and units into one array, to apply settings more easily
        _players append _groups;
        _players append _sides;

        {
            _x remoteExecCall ["enableChannel", _players];
        } forEach _enableArray;

        "Zeus has changed channel visibility for you." remoteExecCall ["hint", _players];

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_unit, _channelIDs]] call zen_dialog_fnc_create;
}, ICON_CHANNEL] call zen_custom_modules_fnc_register;
