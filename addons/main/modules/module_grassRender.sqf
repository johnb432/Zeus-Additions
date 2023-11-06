/*
 * Author: johnb43
 * Adds a module that can change grass rendering density.
 */

[LSTRING(moduleCategoryPlayers), LSTRING(grassRenderModuleName), {
    params ["", "_unit"];

    [LSTRING(grassRenderModuleName), [
        ["OWNERS", [LSTRING_ZEN(context_Actions,selected), LSTRING(selectSidesGroupsUnits)], [[], [], [], 0], true],
        ["TOOLBOX:YESNO", [LSTRING(changeYourself), LSTRING(changeYourselfDesc)], false, true],
        ["LIST", ["str_a3_cfgvehicles_modulecuratoraddpoints_f_arguments_value", LSTRING(grassRenderSettingDesc)], [[50, 25, 12.5, 6.25, 3.125], ["STR_A3_OPTIONS_LOW", "STR_A3_OPTIONS_STANDARD", "STR_A3_OPTIONS_HIGH", "STR_A3_OPTIONS_VERYHIGH", "STR_A3_OPTIONS_ULTRA"], 0, 5]],
        ["TOOLBOX:YESNO", [LSTRING(accountForJip), LSTRING(accountForJipDesc)], false]
    ], {
        params ["_results", "_unit"];
        _results params ["_selected", "_self", "_setting", "_doJIP"];
        _selected params ["_sides", "_groups", "_players"];

        // If self is checked
        if (_self) then {
            setTerrainGrid _setting;
        };

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If unit is player, apply setting
            private _string = if (isPlayer _unit) then {
                _setting remoteExecCall ["setTerrainGrid", _unit];

                LSTRING(changedGrassRenderingOnPlayerMessage)
            } else {
                // If unit is AI, null or otherwise invalid, display error if not something done to self
                if (_self) then {
                    LSTRING(changedGrassRenderingOnYourselfMessage)
                } else {
                    LSTRING_ZEN(modules,noUnitSelected)
                };
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // Handle JIP
        if (_doJIP) then {
            if (!isNil QGVAR(handleServerJIPEhID)) then {
                GVAR(grassSettingsJIP) = [_players apply {getPlayerUID _x}, _groups, _sides, _setting];
                publicVariableServer QGVAR(grassSettingsJIP);
            } else {
                hint LLSTRING(jipDisabledMessage);
            };
        };

        // Add all sides, groups and units into one array, to apply settings more easily
        _players append _groups;
        _players append _sides;

        _setting remoteExecCall ["setTerrainGrid", _players];

        [LSTRING(changedGrassRenderingOnPlayersMessage)] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, "\a3\modules_f\data\hideterrainobjects\icon32_ca.paa"] call zen_custom_modules_fnc_register;