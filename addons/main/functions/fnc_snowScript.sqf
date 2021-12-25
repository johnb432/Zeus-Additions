#include "script_component.hpp"

/*
 * Author: JW, AZCoder, modified by johnb43
 * Spawns a module that adds a snow script.
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

// Check if CUP is loaded
if (!isClass (configFile >> "CfgPatches" >> "CUP_Worlds")) exitWith {};

["Zeus Additions - Players", "Toggle Snow Script", {
    params ["", "_unit"];

    ["Toggle Snow Script", [
        ["OWNERS", ["Players selected", "Select sides/groups/players. Module can also be placed on a player."], [[], [], [], 0], true],
        ["TOOLBOX:ENABLED", ["Toggle script", "Turns the script on or off."], false],
        ["SLIDER", ["Snow Intensity", "Determines how many particles are spawned. 0 turns off script."], [0, 1000, 50, 0]],
        ["TOOLBOX:YESNO", ["Change Weather", "If yes, it will open another dialog after this one is closed to change the weather."], false],
        ["TOOLBOX:YESNO", ["Account for JIP players", "When players join in progress (JIP), it will automatically apply this setting."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_enableScript", "_intensitySnow", "_changeWeather", "_doJIP"];
        _selected params ["_sides", "_groups", "_players"];

        // If snow intensity is set to 0 or script is disabled, remove PFH
        if (_intensitySnow isEqualTo 0 || {!_enableScript}) then {
            _enableScript = false;
            _intensitySnow = 0;
        };

        // Only send function to all clients if script is enabled
        if (_enableScript && {isNil QFUNC(snowScriptPFH)}) then {
            // Define a function on the client
            DFUNC(snowScriptPFH) = {
                // Check if CUP is loaded on the client
                if (!isClass (configFile >> "CfgPatches" >> "CUP_Worlds")) exitWith {
                    hint "[Zeus Additions]: The snow script wasn't applied because CUP Core isn't loaded.";
                };

                [{
                    // Wait until the player is fully loaded
                    !isNull (findDisplay IDD_MISSION);
                }, {
                    [{
                        params ["_inc", "_handleID"];

                        // If game is not in focus or if player is dead, don't spawn in particles until game is focussed and player is alive again
                        if (!isGameFocused || {!alive player}) exitWith {};

                        private _intensitySnow = player getVariable [QGVAR(snow), 0];

                        // Stop PFH if intensity is set to nil
                        if (_intensitySnow isEqualTo 0) exitWith {
                            _handleID call CBA_fnc_removePerFrameHandler;
                        };

                        // See if there is a roof over the player's head
                        private _playerPos = getPosWorld player;
                        private _lines = lineIntersectsSurfaces [_playerPos, _playerPos vectorAdd [0, 0, 50], player, objNull, true, 1, "GEOM", "NONE"];

                        // If inside, don't do script
                        if (_lines isNotEqualTo [] && {(_lines select 0 select 3) isKindOf "House"}) exitWith {};

                        private _pos = getPosATL (vehicle player);
                        (velocity vehicle player) params ["_xVel", "_yVel"];

                        while {_inc < _intensitySnow} do {
                            for "_i" from 2 to 30 step 2 do {
                                drop [
                                    "\ca\data\cl_water", // shapeName
                                    "", // animationName
                                    "Billboard", // type
                                    1, // timerPeriod
                                    7, // lifeTime
                                    _pos vectorAdd [40 - random (80) + _xVel, 40 - random (80) + _yVel, _i], // position
                                    [0, 0, -1], // moveVelocity
                                    1, // rotationVelocity
                                    0.0000001, // weight
                                    0, // volume
                                    0.7, // rubbing
                                    [0.07], // size
                                    [[1, 1, 1, 0], [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1]], // color
                                    [0, 0], // animationPhase
                                    0.2, // randomDirectionPeriod
                                    1.2, // randomDirectionIntensity
                                    "", // onTimer
                                    "", // beforeDestroy
                                    "" // object
                                    // [angle, onSurface, bounceOnSurface, emissiveColor, vectorDir]
                                ];

                                _inc = _inc + 1;
                            };
                        };
                    }, 0.1, 0] call CBA_fnc_addPerFrameHandler;
                }, []] call CBA_fnc_waitUntilAndExecute;
            };

            // Broadcast function to everyone, so it can be executed for JIP players. Events don't seem to want to work with this
            publicVariable QFUNC(snowScriptPFH);
        };

        private _string = "Nothing was changed!";

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If specific unit is player, apply setting
            _string = if (isPlayer _unit) then {
                _unit setVariable [QGVAR(snow), _intensitySnow, true];

                if (_enableScript) then {
                    remoteExecCall [QFUNC(snowScriptPFH), _unit];

                    "Turned snow script on for player";
                } else {
                    "Turned snow script off for player";
                };
            } else {
                // If unit is AI, null or otherwise invalid, display error
                playSound "FD_Start_F";
                "Select a side/group/player (must be a player)!";
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // Handle JIP
        if (_doJIP) then {
            if (GETMVAR(QGVAR(handleServerJIP),false)) then {
                GVAR(snowSettingsJIP) = [_intensitySnow, _players apply {getPlayerUID _x}, _groups, _sides];
                publicVariableServer QGVAR(snowSettingsJIP);
            } else {
                hint "JIP disabled. Turn on in CBA Settings to enable it.";
            };
        };

        // Get all player that fit the criteria
        private _playerList = (call CBA_fnc_players) select {side _x in _sides || {group _x in _groups} || {_x in _players}};

        // Don't execute if no players are valid
        if (_playerList isNotEqualTo []) then {
            {
                _x setVariable [QGVAR(snow), _intensitySnow, true];
            } forEach _playerList;

            _string = if (_enableScript) then {
                remoteExecCall [QFUNC(snowScriptPFH), _playerList];

                "Turned snow script on for selected players";
            } else {
                "Turned snow script off for selected players";
            };
        };

        [_string] call zen_common_fnc_showMessage;

        if (!_changeWeather) exitWith {};

        // If a weather change is wanted, open ZEN weather module
        [objNull] call zen_modules_fnc_moduleWeather;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_WEATHER] call zen_custom_modules_fnc_register;
