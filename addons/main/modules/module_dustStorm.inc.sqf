/*
 * Author: johnb43
 * Spawns a module that adds a dust storm.
 */

[LSTRING(moduleCategoryPlayers), LSTRING(dustStormModuleName), {
    params ["", "_unit"];

    [LSTRING(dustStormModuleName), [
        ["OWNERS", [LSTRING_ZEN(context_Actions,selected), LSTRING(selectSidesGroupsUnits)], [[], [], [], 0], true],
        ["SLIDER", [LSTRING_ZEN(modules,moduleEarthquake_Intensity), LSTRING(dustStormIntensityDesc)], [0, 1000, 50, 0]],
        ["TOOLBOX:YESNO", [LSTRING_ZEN(modules,moduleWeather), LSTRING(dustStormWeatherDesc)], false],
        ["TOOLBOX:YESNO", [LSTRING(accountForJip), LSTRING(accountForJipDesc)], false]
    ], {
        params ["_results", "_unit"];
        _results params ["_selected", "_stormIntensity", "_changeWeather", "_doJIP"];
        _selected params ["_sides", "_groups", "_players"];

        // If a weather change is wanted, open ZEN weather module
        if (_changeWeather) then {
            [objNull] call zen_modules_fnc_moduleWeather;
        };

        private _enabledStormScript = _stormIntensity != 0;

        // Only send function to all clients if script is enabled
        if (_enabledStormScript && {isNil QFUNC(dustStormPFH)}) then {
            PREP_SEND_MP(dustStormPFH);
        };

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If specific unit is player, apply setting
            private _string = if (isPlayer _unit) then {
                _unit setVariable [QGVAR(stormIntensity), _stormIntensity, true];

                if (_enabledStormScript) then {
                    [QGVAR(executeFunction), [QFUNC(dustStormPFH), []], _unit] call CBA_fnc_targetEvent;

                    LSTRING(dustStormTurnOnPlayerMessage)
                } else {
                    LSTRING(dustStormTurnOffPlayerMessage)
                };
            } else {
                // If unit is AI, null or otherwise invalid, display error
                LSTRING_ZEN(modules,noUnitSelected)
            };

            [_string] call zen_common_fnc_showMessage;
        };

        private _string = LSTRING(dustStormNothingChangedMessage);

        // Handle JIP
        if (_doJIP) then {
            GVAR(stormSettingsJIP) = [_players apply {getPlayerUID _x}, _groups, _sides, _stormIntensity];
            publicVariable QGVAR(stormSettingsJIP);

            _string = LSTRING(dustStormJipSettingsChangedMessage);
        };

        // Get all players that fit the criteria
        private _playerList = (call CBA_fnc_players) select {_group = group _x; (side _group) in _sides || _group in _groups || _x in _players};

        // Don't execute if no players are valid
        if (_playerList isNotEqualTo []) then {
            {
                _x setVariable [QGVAR(stormIntensity), _stormIntensity, true];
            } forEach _playerList;

            _string = if (_enabledStormScript) then {
                [QGVAR(executeFunction), [QFUNC(dustStormPFH), []], _playerList] call CBA_fnc_targetEvent;

                LSTRING(dustStormTurnOnPlayersMessage)
            } else {
                LSTRING(dustStormTurnOffPlayersMessage)
            };
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, "\a3\3DEN\Data\Displays\Display3DEN\ToolBar\intel_ca.paa"] call zen_custom_modules_fnc_register;
