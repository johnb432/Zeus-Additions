/*
 * Author: JW, AZCoder, modified by johnb43
 * Spawns a module that adds a snow script.
 * https://forums.bohemia.net/forums/topic/215391-light-snowfall-script/?tab=comments#comment-3276526
 */

["Zeus Additions - Players", "[WIP] Toggle Storm Script", {
    params ["", "_unit"];

    ["Toggle Snow Script", [
        ["OWNERS", ["Players selected", "Select sides/groups/players. Module can also be placed on a player."], [[], [], [], 0], true],
        ["TOOLBOX", ["Storm Type", "Selects type of storm that will be applied. Wind is NOT automatically turned on."], [0, 1, 2, ["Snow", "Dust"]]],
        ["SLIDER", ["Intensity", "Determines how many particles are spawned. 0 turns off script."], [0, 1000, 50, 0]],
        ["TOOLBOX:YESNO", ["Change Weather", "If yes, it will open another dialog after this one is closed to change the weather."], false],
        ["TOOLBOX:YESNO", ["Account for JIP players", "When players join in progress (JIP), it will automatically apply this setting."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_stormType", "_stormIntensity", "_changeWeather", "_doJIP"];
        _selected params ["_sides", "_groups", "_players"];

        private _enabledStormScript = _stormIntensity isNotEqualTo 0;

        // Only send function to all clients if script is enabled
        if (_enabledStormScript && {isNil QFUNC(snowScriptPFH)}) then {
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

                        private _player = player;

                        // If game is not in focus or if player is dead, don't spawn in particles until game is focussed and player is alive again
                        if (isGamePaused || {!isGameFocused} || {!alive _player}) exitWith {};

                        private _stormIntensity = _player getVariable [QGVAR(stormIntensity), 0];

                        // Stop PFH if intensity is set to nil
                        if (_stormIntensity isEqualTo 0) exitWith {
                            _handleID call CBA_fnc_removePerFrameHandler;
                        };

                        // See if there is a roof over the player's head
                        private _playerPos = getPosWorld _player;
                        private _lines = lineIntersectsSurfaces [_playerPos, _playerPos vectorAdd [0, 0, 50], _player, objNull, true, 1, "GEOM", "NONE"];

                        // If inside, don't do script
                        if (_lines isNotEqualTo [] && {(_lines select 0 select 3) isKindOf "House"}) exitWith {};

                        private _vehicle = vehicle _player;
                        private _pos = getPosATL _vehicle;
                        (velocity _vehicle) params ["_xVel", "_yVel"];

                        if ((_player getVariable [QGVAR(stormType), 0]) isEqualTo 0) then {
                            while {_inc < _stormIntensity} do {
                                for "_i" from 2 to 30 step 2 do {
                                    drop [
                                        "\ca\data\cl_water", // shapeName
                                        "", // animationName
                                        "Billboard", // type
                                        1, // timerPeriod
                                        7, // lifeTime
                                        _pos vectorAdd [40 - random 80 + _xVel, 40 - random 80 + _yVel, _i], // position
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
                        } else {
                            while {_inc < _stormIntensity} do {
                                drop [
                                ["\A3\data_f\cl_basic", 1, 0, 1], // shapeName
                                    "", // animationName
                                    "Billboard", // type
                                    1, // timerPeriod
                                    3, // lifeTime
                                    _pos vectorAdd [50 - (random 100) + _xVel, 50 - (random 100) + _yVel, 0], // position
                                    [0, 0, 0], // moveVelocity
                                    3, // rotationVelocity
                                    10, // weight
                                    8, // volume
                                    1, // rubbing
                                    [10, 10, 20], // size
                                    [[0.65, 0.5, 0.5, 0], [0.65, 0.6, 0.5, 0.3], [1, 0.95, 0.8, 0]], // color
                                    [0.08], // animationPhase
                                    0, // randomDirectionPeriod
                                    0, // randomDirectionIntensity
                                    "", // onTimer
                                    "", // beforeDestroy
                                    "" // object
                                    // [angle, onSurface, bounceOnSurface, emissiveColor, vectorDir]
                                ];

                                _inc = _inc + 50;
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
                _unit setVariable [QGVAR(stormIntensity), _stormIntensity, true];
                _unit setVariable [QGVAR(stormType), _stormType, true];

                if (_enabledStormScript) then {
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
                GVAR(snowSettingsJIP) = [_stormIntensity, _stormType, _players apply {getPlayerUID _x}, _groups, _sides];
                publicVariableServer QGVAR(snowSettingsJIP);
                _string = "Snow script JIP setting changed";
            } else {
                hint "JIP disabled. Turn on in CBA Settings to enable it.";
            };
        };

        // Get all player that fit the criteria
        private _playerList = (call CBA_fnc_players) select {side _x in _sides || {group _x in _groups} || {_x in _players}};

        // Don't execute if no players are valid
        if (_playerList isNotEqualTo []) then {
            {
                _x setVariable [QGVAR(stormIntensity), _stormIntensity, true];
                _x setVariable [QGVAR(stormType), _stormType, true];
            } forEach _playerList;

            _string = if (_enabledStormScript) then {
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
