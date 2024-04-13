/*
 * Author: johnb43
 * Creates a module that can change various channel's visibility (including custom ones, which can be added or removed during mission without issues).
 */

[LSTRING(moduleCategoryPlayers), LSTRING(channelVisibilityModuleName), {
    params ["", "_unit"];

    // Make array of default dialog choices
    private _dialogChoices = [
        ["OWNERS", [LSTRING_ZEN(context_Actions,selected), LSTRING(selectSidesGroupsUnits)], [[], [], [], 0], true],
        ["TOOLBOX:YESNO", [LSTRING(changeYourself), LSTRING(changeYourselfDesc)], false, true],
        ["TOOLBOX:WIDE", ["str_channel_global", format [LLSTRING(channelVisibilityChangeChannelDesc), localize "str_channel_global"]], OPTION_ARRAY],
        ["TOOLBOX:WIDE", ["str_channel_side", format [LLSTRING(channelVisibilityChangeChannelDesc), localize "str_channel_side"]], OPTION_ARRAY],
        ["TOOLBOX:WIDE", ["str_channel_command", format [LLSTRING(channelVisibilityChangeChannelDesc), localize "str_channel_command"]], OPTION_ARRAY],
        ["TOOLBOX:WIDE", ["str_channel_group", format [LLSTRING(channelVisibilityChangeChannelDesc), localize "str_channel_group"]], OPTION_ARRAY],
        ["TOOLBOX:WIDE", ["str_channel_vehicle", format [LLSTRING(channelVisibilityChangeChannelDesc), localize "str_channel_vehicle"]], OPTION_ARRAY],
        ["TOOLBOX:WIDE", ["str_channel_direct", format [LLSTRING(channelVisibilityChangeChannelDesc), localize "str_channel_direct"]], OPTION_ARRAY]
    ];

    // Add default channels
    private _channelIDs = [0, 1, 2, 3, 4, 5];

    // Add custom channels if existent
    for "_i" from 1 to 10 step 1 do {
        (radioChannelInfo _i) params ["", "_name", "", "", "", "_exists"];

        if (_exists) then {
            _dialogChoices pushBack (["TOOLBOX:WIDE", [format ["%1: '%2'", localize "str_a3_cfgvehicles_modulechat_f_arguments_channel_0", _name], format [LLSTRING(channelVisibilityChangeChannelDesc), _name]], OPTION_ARRAY]);
            _channelIDs pushBack (_i + 5);
        };
    };

    // Add JIP to dialog
    _dialogChoices pushBack (["TOOLBOX:YESNO", [LSTRING(accountForJip), LSTRING(accountForJipDesc)], false, false]);

    [LSTRING(channelVisibilityModuleName), _dialogChoices, {
        params ["_results", "_args"];
        _args params ["_unit", "_channelIDs"];

        // Save results so that they can be deleted; Get all channel settings in one array
        private _doJIP = _results deleteAt (count _results - 1);
        private _self = _results deleteAt 1;
        (_results deleteAt 0) params ["_sides", "_groups", "_players"];

        private _enableArray = [];

        // Make array ready to be used with enableChannel
        {
            switch (_x) do {
                case 0: {_enableArray pushBack [_channelIDs select _forEachIndex, [false, false]]};
                case 1: {_enableArray pushBack [_channelIDs select _forEachIndex, [true, false]]};
                case 2: {_enableArray pushBack [_channelIDs select _forEachIndex, [false, true]]};
                default {_enableArray pushBack [_channelIDs select _forEachIndex, [true, true]]};
            };
        } forEach _results;

        // If self is checked
        if (_self) then {
            {
                (_x select 0) enableChannel (_x select 1);
            } forEach _enableArray;
        };

        // If alive, commander, in case it's a vehicle
        if (alive _unit) then {
            _unit = effectiveCommander _unit;
        };

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If unit is player, apply setting
            private _string = if (isPlayer _unit) then {
                ["zen_common_execute", [{
                    {
                        (_x select 0) enableChannel (_x select 1);
                    } forEach _this;

                    hint "Zeus has changed channel visibility for you.";
                } call FUNC(sanitiseFunction), _enableArray], _unit] call CBA_fnc_targetEvent;

                LSTRING(changedChanneLVisibilityOnPlayerMessage)
            } else {
                // If unit is AI, null or otherwise invalid, display error if not something done to self
                [LSTRING_ZEN(modules,noUnitSelected), LSTRING(changedChanneLVisibilityOnYourselfMessage)] select (_self)
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // Handle JIP
        if (_doJIP) then {
            GVAR(channelSettingsJIP) = [_players apply {getPlayerUID _x}, _groups, _sides, _enableArray];
            publicVariable QGVAR(channelSettingsJIP);
        };

        ["zen_common_execute", [{
            {
                (_x select 0) enableChannel (_x select 1);
            } forEach _this;

            hint "Zeus has changed channel visibility for you.";
        } call FUNC(sanitiseFunction), _enableArray], (call CBA_fnc_players) select {_group = group _x; (side _group) in _sides || _group in _groups || _x in _players}] call CBA_fnc_targetEvent;

        [LSTRING(changedChanneLVisibilityOnPlayersMessage)] call zen_common_fnc_showMessage;
    }, {}, [_unit, _channelIDs]] call zen_dialog_fnc_create;
}, "x\zen\addons\modules\ui\chat_ca.paa"] call zen_custom_modules_fnc_register;
