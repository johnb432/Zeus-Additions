#include "script_component.hpp"

/*
 * Author: JW, AZCoder, modified by johnb43
 * Spawns a module that adds a snowscript. Can only be applied to everyone or no one.
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
            ["CHECKBOX", ["Toggle script", "Turns the script on or off."], false, false],
            ["SLIDER", ["Intensity", "Determines how many particles are spawned."], [0, 1, 0.25, 2, true]],
            ["SLIDER", ["Wind strength (m/s)", "Sets wind speed."], [0, 20, 5, 0]],
            ["SLIDER", ["Wind direction (from bearing)", "0 = N, 90 = E, 180 = S, 270 = W"], [0, 360, 180, 0]],
            ["CHECKBOX", ["Account for JIP players", "Only works if the mod is on the server aswell."], false, false]
        ],
        {
            params ["_results", "_unit"];
            _results params ["_selected", "_enableScript", "_intensity", "_windStrength", "_windDirection", "_doJIP"];
            _selected params ["_sides", "_groups", "_players"];

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

            ["zen_common_execute", [CBA_fnc_addPerFrameHandler,
                [{
                    params ["_args", "_handleid"];
                    _args params ["_playerPos", "_line", "_pos", "_d", "_a"];

                    private _intensity = player getVariable [QGVAR(intensitySnow), nil];

                    if (!player getVariable [QGVAR(enableSnowScript), false] || isNil "_intensity") exitWith {
                        [_handleid] call CBA_fnc_removePerFrameHandler;
                    };

                    while {_a < _intensity} do {
                        // See if there is a roof over the player's head
                        _playerPos = getPosWorld player;
                        _line = lineIntersectsSurfaces [_playerPos, _playerPos vectorAdd [0, 0, 50], player, objNull, true, 1, "GEOM", "NONE"];

                        // If not inside
                        if !(count _line > 0 && {(_line select 0 select 3) isKindOf "House"}) then {
                            _pos = getPosATL (objectParent player);

                            if (isNil "_fog") then {
                                if (_intensity > 4000) then {
                                    _fog = "#particlesource" createVehicleLocal _pos;
                                    _fog setParticleParams [
                                        ["\Ca\Data\ParticleEffects\Universal\universal.p3d" , 16, 12, 13, 0], "", "Billboard", 1, 10,
                                        [0, 0, -6], [0, 0, 0], 1, 1.275, 1, 0,
                                        [7,6], [[1, 1, 1, 0], [1, 1, 1, 0.04], [1, 1, 1, 0]], [1000], 1, 0, "", "", player
                                    ];
                                    _fog setParticleRandom [3, [55, 55, 0.2], [0, 0, -0.1], 2, 0.45, [0, 0, 0, 0.1], 0, 0];
                                    _fog setParticleCircle [0.001, [0, 0, -0.12]];
                                    _fog setDropInterval 0.001;
                                };
                            } else {
                                _fog setPos _pos;
                            };

                            for "_i" from 2 to 12 step 2 do {
                                _dpos = [((_pos select 0) + (_d - (random (2*_d))) + ((velocity objectParent player select 0)*1)),((_pos select 1) + (_d - (random (2*_d))) + ((velocity objectParent player select 0)*1)),((_pos select 2) + _i)];
                                drop ["\ca\data\cl_water", "", "Billboard", 1, 7, _dpos, [0,0,-1], 1, 0.0000001, 0.000, 0.7, [0.07], [[1,1,1,0], [1,1,1,1], [1,1,1,1], [1,1,1,1]], [0,0], 0.2, 1.2, "", "", ""];
                                _a = _a + 1;
                            };
                        };
                    };
                }, 0.1, [nil, nil, position (objectParent player), 15, 0]]
            ], _playerList] call CBA_fnc_targetEvent;

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

            ["zen_common_execute", [CBA_fnc_addPerFrameHandler,
                [{
                    params ["_args", "_handleid"];
                    _args params ["_playerPos", "_line", "_pos", "_d", "_a"];

                    private _intensity = player getVariable [QGVAR(intensitySnow), nil];

                    if (!player getVariable [QGVAR(enableSnowScript), false] || isNil "_intensity") exitWith {
                        [_handleid] call CBA_fnc_removePerFrameHandler;
                    };

                    while {_a < _intensity} do {
                        // See if there is a roof over the player's head
                        _playerPos = getPosWorld player;
                        _line = lineIntersectsSurfaces [_playerPos, _playerPos vectorAdd [0, 0, 50], player, objNull, true, 1, "GEOM", "NONE"];

                        // If not inside
                        if !(count _line > 0 && {(_line select 0 select 3) isKindOf "House"}) then {
                            _pos = getPosATL (objectParent player);

                            if (isNil "_fog") then {
                                if (_intensity > 4000) then {
                                    _fog = "#particlesource" createVehicleLocal _pos;
                                    _fog setParticleParams [
                                        ["\Ca\Data\ParticleEffects\Universal\universal.p3d" , 16, 12, 13, 0], "", "Billboard", 1, 10,
                                        [0, 0, -6], [0, 0, 0], 1, 1.275, 1, 0,
                                        [7,6], [[1, 1, 1, 0], [1, 1, 1, 0.04], [1, 1, 1, 0]], [1000], 1, 0, "", "", player
                                    ];
                                    _fog setParticleRandom [3, [55, 55, 0.2], [0, 0, -0.1], 2, 0.45, [0, 0, 0, 0.1], 0, 0];
                                    _fog setParticleCircle [0.001, [0, 0, -0.12]];
                                    _fog setDropInterval 0.001;
                                };
                            } else {
                                _fog setPos _pos;
                            };

                            for "_i" from 2 to 12 step 2 do {
                                _dpos = [((_pos select 0) + (_d - (random (2*_d))) + ((velocity objectParent player select 0)*1)),((_pos select 1) + (_d - (random (2*_d))) + ((velocity objectParent player select 0)*1)),((_pos select 2) + _i)];
                                drop ["\ca\data\cl_water", "", "Billboard", 1, 7, _dpos, [0,0,-1], 1, 0.0000001, 0.000, 0.7, [0.07], [[1,1,1,0], [1,1,1,1], [1,1,1,1], [1,1,1,1]], [0,0], 0.2, 1.2, "", "", ""];
                                _a = _a + 1;
                            };
                        };
                    };
                }, 0.1, [nil, nil, position (objectParent player), 15, 0]]
            ], _player] call CBA_fnc_targetEvent;
        }, _uid, 60, {
            ["Could not apply snow script on JIP player '%1'", _this call BIS_fnc_getUnitByUID] call zen_common_fnc_showMessage;
        }] call CBA_fnc_waitUntilAndExecute;
    }];
};
