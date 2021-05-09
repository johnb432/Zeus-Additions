#include "script_component.hpp"

/*
 * Author: JW, AZCoder, modified by johnb43
 * Spawns a module that adds a snowscript.
 * https://forums.bohemia.net/forums/topic/215391-light-snowfall-script/?tab=comments#comment-3276526
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_snowScript;
 *
 * Public: No
 */

if (!isClass (configFile >> "CfgPatches" >> "CUP_Worlds")) exitWith {
    if (hasInterface && {GVAR(enableSnowScriptHint)}) then {
        hint "The snow script isn't available because CUP Core isn't loaded."
    };
};

if (hasInterface) then {
    GVAR(initialWindSpeed) = nil;
    GVAR(initialWindDir) = nil;
    GVAR(intensitySnowJIP) = nil;

    ["Zeus Additions - Players", "[WIP] Toggle Snow Script", {
        params ["", "_unit"];

        ["Snow script", [
            ["OWNERS", ["Players selected", "Select sides, groups, players."], [[], [], [], 0], true],
            ["TOOLBOX:ENABLED", ["Toggle script", "Turns the script on or off."], false, false],
            ["SLIDER", ["Intensity", "Determines how many particles are spawned."], [0, 1, 0.25, 2, true]],
            ["SLIDER", ["Wind strength (m/s)", "Sets wind speed."], [0, 20, 5, 0]],
            ["SLIDER", ["Wind direction (from bearing)", "0 = N, 90 = E, 180 = S, 270 = W"], [0, 360, 180, 0]],
            ["TOOLBOX:ENABLED", ["Account for JIP players", "Only works if the mod is on the server aswell."], false, false]
        ],
        {
            params ["_results", "_unit"];
            _results params ["_selected", "_enableScript", "_intensity", "_windStrength", "_windDirection", "_doJIP"];
            _selected params ["_sides", "_groups", "_players"];

            if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
                if (isNull _unit) then {
                    ["Select a side/group/unit!"] call zen_common_fnc_showMessage;
                    playSound "FD_Start_F";
                } else {
                    _unit setVariable [QGVAR(enableSnowScript), true, true];
                    _unit setVariable [QGVAR(intensitySnow), _intensity, true];

                    _unit call FUNC(snowScriptEvent);
                    ["Turned snow script on for unit"] call zen_common_fnc_showMessage;
                };
            };

            private _playerList = allPlayers select {side _x in _sides || {group _x in _groups} || {_x in _players}};

            if (!_enableScript) exitWith {
                {
                    _x setVariable [QGVAR(enableSnowScript), false, true];
                } forEach _playerList;

                // Reset wind & player list
                if (isNil QGVAR(initialWindSpeed) || isNil QGVAR(initialWindDir)) exitWith {};
                [GVAR(initialWindSpeed)] remoteExecCall ["setWind", 2];
                [0, GVAR(initialWindDir)] remoteExecCall ["setWindDir", 2];
                GVAR(initialWindSpeed) = nil;
                GVAR(initialWindDir) = nil;

                ["Turned snow script off"] call zen_common_fnc_showMessage;
            };

            if (isNil QGVAR(initialWindSpeed)) then {
                wind params ["_x", "_y"];
                GVAR(initialWindSpeed) = [_x, _y, false];
            };

            if (isNil QGVAR(initialWindDir)) then {
                GVAR(initialWindDir) = windDir;
            };

            _intensity = _intensity * 100;

            if (_doJIP) then {
                GVAR(intensitySnowJIP) = _intensity;
                publicVariable QGVAR(intensitySnowJIP);

                GVAR(turnOnSnowPlayersJIP) = _players apply {getPlayerUID _x};
                publicVariable QGVAR(turnOnSnowPlayersJIP);

                GVAR(turnOnSnowGroupsJIP) = _groups;
                publicVariable QGVAR(turnOnSnowGroupsJIP);

                GVAR(turnOnSnowSidesJIP) = _sides;
                publicVariable QGVAR(turnOnSnowSidesJIP);
            };

            _playerList = _playerList select {!(_x getVariable [QGVAR(enableSnowScript), false])};

            if (_playerList isEqualTo []) exitWith {
                ["All players have the snow script already applied!"] call zen_common_fnc_showMessage;
            };

            {
                _x setVariable [QGVAR(enableSnowScript), true, true];
                _x setVariable [QGVAR(intensitySnow), _intensity, true];
            } forEach _playerList;

            // Change wind on server and remove rain
            [[0, -_windStrength, true]] remoteExecCall ["setWind", 2];
            [0, _windDirection] remoteExecCall ["setWindDir", 2];
            [0, 0] remoteExecCall ["setRain", 2];

            _playerList call FUNC(snowScriptEvent);

            ["Turned snow script on"] call zen_common_fnc_showMessage;
        }, {
            ["Aborted"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        }, _unit] call zen_dialog_fnc_create;
    }] call zen_custom_modules_fnc_register;
};

if (isServer) then {
    addMissionEventHandler ["PlayerConnected", {
    	   params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

        if (!_jip || isNil QGVAR(intensitySnowJIP)) exitWith {};

        [{
            !isNull (_this call BIS_fnc_getUnitByUID)
        }, {
            private _player = _this call BIS_fnc_getUnitByUID;

            if !(!isNil QGVAR(turnOnSnowPlayersJIP) && {_this in GVAR(turnOnSnowPlayersJIP)}) exitWith {};
            if !(!isNil QGVAR(turnOnSnowGroupsJIP) && {(group _player) in GVAR(turnOnSnowGroupsJIP)}) exitWith {};
            if !(!isNil QGVAR(turnOnSnowSidesJIP) && {(side _player) in GVAR(turnOnSnowSidesJIP)}) exitWith {};

            _player setVariable [QGVAR(enableSnowScript), true, true];
            _player setVariable [QGVAR(intensitySnow), GVAR(intensitySnowJIP), true];

            _player call FUNC(snowScriptEvent);
        }, _uid, 60, {
            ["Could not apply snow script on JIP player '%1'", _this call BIS_fnc_getUnitByUID] call zen_common_fnc_showMessage;
        }] call CBA_fnc_waitUntilAndExecute;
    }];
};
