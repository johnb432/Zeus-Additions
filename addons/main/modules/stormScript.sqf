/*
 * Author: johnb43
 * Spawns a module that adds storm scripts.
 */

["Zeus Additions - Players", "Toggle Dust Storm Script", {
    params ["", "_unit"];

    ["Toggle Dust Storm Script", [
        ["OWNERS", ["Players selected", "Select sides/groups/players. Module can also be placed on a player."], [[], [], [], 0], true],
        ["SLIDER", ["Intensity", "Determines how many particles are spawned. 0 turns off script."], [0, 1000, 50, 0]],
        ["TOOLBOX:YESNO", ["Change Weather", "If yes, it will open another dialog after this one is closed to change the weather."], false],
        ["TOOLBOX:YESNO", ["Account for JIP players", "When players join in progress (JIP), it will automatically apply this setting."], false],
        ["TOOLBOX:YESNO", ["Set precipitation type to snow", "If yes, rain particles become snow. Weather must be set to rain."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_stormIntensity", "_changeWeather", "_doJIP", "_isSnow"];
        _selected params ["_sides", "_groups", "_players"];

        ////////// Remove once ZEN releases Snow in weather module
        ([[], [
            "a3\data_f\snowflake4_ca.paa", // rainDropTexture
            4, // texDropCount
            0.01, // minRainDensity
            25, // effectRadius
            0.05, // windCoef
            2.5, // dropSpeed
            0.5, // rndSpeed
            0.5, // rndDir
            0.07, // dropWidth
            0.07, // dropHeight
            [1, 1, 1, 0.5], // dropColor
            0.0, // lumSunFront
            0.2, // lumSunBack
            0.5, // refractCoef
            0.5, // refractSaturation
            true, // snow
            false // dropColorStrong
        ]] select _isSnow) remoteExecCall ["BIS_fnc_setRain", 2];

        // If a weather change is wanted, open ZEN weather module
        if (_changeWeather) then {
            [objNull] call zen_modules_fnc_moduleWeather;
        };

        private _enabledStormScript = _stormIntensity != 0;

        // Only send function to all clients if script is enabled
        if (_enabledStormScript && {isNil QFUNC(stormScriptPFH)}) then {
            // Define a function on the client
            DFUNC(stormScriptPFH) = compileScript [format ["\%1\%2\%3\%4\functions\fnc_stormScriptPFH.sqf", QUOTE(MAINPREFIX), QUOTE(PREFIX), QUOTE(SUBPREFIX), QUOTE(COMPONENT)], true];

            // Broadcast function to everyone, so it can be executed for JIP players; Events don't seem to want to work with this
            publicVariable QFUNC(stormScriptPFH);
        };

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If specific unit is player, apply setting
            private _string = if (isPlayer _unit) then {
                _unit setVariable [QGVAR(stormIntensity), _stormIntensity, true];

                if (_enabledStormScript) then {
                    remoteExecCall [QFUNC(stormScriptPFH), _unit];

                    "Turned Dust Storm Script on for player"
                } else {
                    "Turned Dust Storm Script off for player"
                };
            } else {
                // If unit is AI, null or otherwise invalid, display error
                "Select a side/group/player (must be a player)"
            };

            [_string] call zen_common_fnc_showMessage;
        };

        private _string = "Nothing was changed",

        // Handle JIP
        if (_doJIP) then {
            if (GETMVAR(QGVAR(handleServerJIP),false)) then {
                GVAR(snowSettingsJIP) = [_players apply {getPlayerUID _x}, _groups, _sides, _stormIntensity];
                publicVariableServer QGVAR(snowSettingsJIP);
                _string = "Dust Storm Script JIP setting changed";
            } else {
                hint "JIP disabled. Turn on in CBA Settings to enable it.";
            };
        };

        // Get all player that fit the criteria
        private _playerList = (call CBA_fnc_players) select {(side _x) in _sides || {(group _x) in _groups} || {_x in _players}};

        // Don't execute if no players are valid
        if (_playerList isNotEqualTo []) then {
            {
                _x setVariable [QGVAR(stormIntensity), _stormIntensity, true];
            } forEach _playerList;

            _string = if (_enabledStormScript) then {
                remoteExecCall [QFUNC(stormScriptPFH), _playerList];

                "Turned Dust Storm Script on for selected players"
            } else {
                "Turned Dust Storm Script off for selected players"
            };
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_WEATHER] call zen_custom_modules_fnc_register;
