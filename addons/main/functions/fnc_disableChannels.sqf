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

if (hasInterface) then {
    GVAR(disableChannelsJIP) = [];

    ["Zeus Additions - Players", "[WIP] Disable Channels", {
        params ["", "_unit"];

        ["[WIP] Disable Channels", [
            ["OWNERS", ["Players selected", "Select a side/group/unit."], [[], [], [], 2], true],
            ["TOOLBOX:WIDE", ["Global channel", "Allows to change the global chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
            ["TOOLBOX:WIDE", ["Side channel", "Allows to change the side chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
            ["TOOLBOX:WIDE", ["Command channel", "Allows to change the command chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
            ["TOOLBOX:WIDE", ["Group channel", "Allows to change the group chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
            ["TOOLBOX:WIDE", ["Vehicle channel", "Allows to change the vehicle chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
            ["TOOLBOX:WIDE", ["Direct channel", "Allows to change the direct chat & VON."], [1, 1, 4, ["Disabled","Chat only","VON only","Enabled"]], false],
            ["TOOLBOX:YESNO", ["Account for JIP players", "This option only works if the mod is on the server aswell."], false, false]
        ],
        {
            params ["_results", "_unit"];
            _results params ["_selected", "_globalEnabled", "_sideEnabled", "_commandEnabled", "_groupEnabled", "_vehicleEnabled", "_directEnabled", "_doJIP"];
            _selected params ["_sides", "_groups", "_players"];

            private _enableArray = [];

            {
                switch (_x) do {
                    case 0: {_enableArray pushBack [_forEachIndex, [false, false]]};
                    case 1: {_enableArray pushBack [_forEachIndex, [true, false]]};
                    case 2: {_enableArray pushBack [_forEachIndex, [false, true]]};
                    case 3: {_enableArray pushBack [_forEachIndex, [true, true]]};
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
                    } forEach _enableArray;

                    ["zen_common_hint", ["Zeus has changed channel visibility."], _unit] call CBA_fnc_targetEvent;
                    ["Changed channel visibility on unit"] call zen_common_fnc_showMessage;
                };
            };

            if (_doJIP) then {
                GVAR(disableChannelsJIP) = _enableArray;
                publicVariable QGVAR(disableChannelsJIP);

                GVAR(disableChannelsPlayersJIP) = _players apply {getPlayerUID _x};
                publicVariable QGVAR(disableChannelsPlayersJIP);

                GVAR(disableChannelsGroupsJIP) = _groups;
                publicVariable QGVAR(disableChannelsGroupsJIP);

                GVAR(disableChannelsSidesJIP) = _sides;
                publicVariable QGVAR(disableChannelsSidesJIP);
            };

            _players append _groups;

            // remoteExecCall can do units, groups and sides, whereas targetEvents can only do units and groups
            // Add all players from a selected side
            _players append (allPlayers select {side _x in _sides});

            {
                _x remoteExecCall ["enableChannel", _players];
            } forEach _enableArray;

            ["zen_common_hint", ["Zeus has changed channel visibility."], _players] call CBA_fnc_targetEvent;

            ["Changed channel visibility for selected units"] call zen_common_fnc_showMessage;
        }, {
            ["Aborted"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        }, _unit] call zen_dialog_fnc_create;
    }] call zen_custom_modules_fnc_register;
};

if (isServer) then {
    addMissionEventHandler ["PlayerConnected", {
        params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

        if (!_jip || isNil QGVAR(disableChannelsJIP)) exitWith {};

        [{
            !isNull (_this call BIS_fnc_getUnitByUID)
        }, {
            private _player = _this call BIS_fnc_getUnitByUID;

            if !(!isNil QGVAR(disableChannelsPlayersJIP) && {_this in GVAR(disableChannelsPlayersJIP)}) exitWith {};
            if !(!isNil QGVAR(disableChannelsGroupsJIP) && {(group _player) in GVAR(disableChannelsGroupsJIP)}) exitWith {};
            if !(!isNil QGVAR(disableChannelsSidesJIP) && {(side _player) in GVAR(disableChannelsSidesJIP)}) exitWith {};

            GVAR(disableChannelsJIP) remoteExecCall ["enableChannel", _player];
        }, _uid, 60, {
            ["Could not apply 'disable channels' module on JIP player '%1'", _this call BIS_fnc_getUnitByUID] call zen_common_fnc_showMessage;
        }] call CBA_fnc_waitUntilAndExecute;
    }];
};
