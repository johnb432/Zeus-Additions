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

GVAR(grassRenderJIP) = nil;

if (hasInterface) then {
    ["Zeus Additions - Players", "Change grass rendering", {
        params ["", "_unit"];

        ["Grass rendering settings", [
            ["OWNERS", ["Players selected", "Changes selected players/groups/sides grass rendering."], [[], [], [], 0], true],
            ["TOOLBOX:YESNO", ["Change yourself", "You can use this whilst as a curator to change your grass rendering."], false, true],
            ["LIST", ["Setting", "Choose Low to turn off grass rendering. Choose Standard if you want to render it again."], [[50, 25, 12.5, 6.25, 3.125], ["Low (Off)", "Standard (Normal)", "High", "Very High", "Ultra"], 0, 5]],
            ["TOOLBOX:YESNO", ["Account for JIP players", "Only works if the mod is on the server aswell."], false, false]
        ],
        {
            params ["_results", "_unit"];
            _results params ["_selected", "_self", "_setting", "_doJIP"];
            _selected params ["_sides", "_groups", "_players"];

            private _string = "Grass rendering changed on selected players";

            if (_self) then {
                setTerrainGrid _setting;
            };

            if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
                if (!isNull _unit && {isPlayer _unit}) then {
                    _setting remoteExecCall ["setTerrainGrid", _unit];
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

            if (_doJIP) then {
                GVAR(grassRenderJIP) = _setting;
                publicVariable QGVAR(grassRenderJIP);

                GVAR(grassRenderPlayersJIP) = _players apply {getPlayerUID _x};
                publicVariable QGVAR(grassRenderPlayersJIP);

                GVAR(grassRenderGroupsJIP) = _groups;
                publicVariable QGVAR(grassRenderGroupsJIP);

                GVAR(grassRenderSidesJIP) = _sides;
                publicVariable QGVAR(grassRenderSidesJIP);
            };

            _players append _groups;
            _players append _sides;

            {
                _setting remoteExecCall ["setTerrainGrid", _x];
            } forEach _players;

            [_string] call zen_common_fnc_showMessage;
        }, {
            ["Aborted"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        }, _unit] call zen_dialog_fnc_create;
    }] call zen_custom_modules_fnc_register;
};

if (isServer) then {
    addMissionEventHandler ["PlayerConnected", {
    	   params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

        if (!_jip || isNil QGVAR(grassRenderJIP)) exitWith {};

        [{
            !isNull (_this call BIS_fnc_getUnitByUID)
        }, {
            private _player = _this call BIS_fnc_getUnitByUID;

            if !(!isNil QGVAR(grassRenderPlayersJIP) && {_this in GVAR(grassRenderPlayersJIP)}) exitWith {};
            if !(!isNil QGVAR(grassRenderGroupsJIP) && {(group _player) in GVAR(grassRenderGroupsJIP)}) exitWith {};
            if !(!isNil QGVAR(grassRenderSidesJIP) && {(side _player) in GVAR(grassRenderSidesJIP)}) exitWith {};

            GVAR(grassRenderJIP) remoteExecCall ["setTerrainGrid", _player];
        }, _uid, 60, {
            ["Could not apply 'disable channels' module on JIP player '%1'", _this call BIS_fnc_getUnitByUID] call zen_common_fnc_showMessage;
        }] call CBA_fnc_waitUntilAndExecute;
    }];
};
