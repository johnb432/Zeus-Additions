/*
 * Author: johnb43
 * Adds a module that can alter a unit's TFAR radio range.
 */

[LSTRING(moduleCategoryPlayers), LSTRING(tfarRangeModuleName), {
    params ["", "_unit"];

    [LSTRING(tfarRangeModuleName), [
        ["OWNERS", [LSTRING_ZEN(context_Actions,selected), LSTRING(selectSidesGroupsUnits)], [[], [], [], 0], true],
        ["TOOLBOX:YESNO", [LSTRING(changeYourself), LSTRING(changeYourselfDesc)], false, true],
        ["SLIDER", [LSTRING(transmissionRange), LSTRING(transmissionRangeDesc)], [0, 50, 1, 2]],
        ["SLIDER", [LSTRING(receptionRange), LSTRING(receptionRangeDesc)], [0, 50, 1, 2]],
        ["TOOLBOX:YESNO", [LSTRING(accountForJip), LSTRING(accountForJipDesc)], false]
    ], {
        params ["_results", "_unit"];
        _results params ["_selected", "_self", "_txMultiplier", "_rxMultiplier", "_doJIP"];
        _selected params ["_sides", "_groups", "_players"];

        // If self is checked
        if (_self) then {
            player setVariable ["tf_sendingDistanceMultiplicator", _txMultiplier];
            player setVariable ["tf_receivingDistanceMultiplicator", _rxMultiplier];
        };

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If unit is player, apply setting
            private _string = if (isPlayer _unit) then {
                ["zen_common_execute", [{
                    params ["_unit", "_txMultiplier", "_rxMultiplier"];

                    _unit setVariable ["tf_sendingDistanceMultiplicator", _txMultiplier];
                    _unit setVariable ["tf_receivingDistanceMultiplicator", _rxMultiplier];
                }, [_unit, _txMultiplier, _rxMultiplier]], _unit] call CBA_fnc_targetEvent;

                LSTRING(changedRangesOnPlayerMessage)
            } else {
                // If unit is AI, null or otherwise invalid, display error if not something done to self
                if (_self) then {
                    LSTRING(changedRangesOnYourselfMessage)
                } else {
                    LSTRING_ZEN(modules,noUnitSelected)
                };
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // Set multiplier on all selected units
        {
            ["zen_common_execute", [{
                params ["_unit", "_txMultiplier", "_rxMultiplier"];

                _unit setVariable ["tf_sendingDistanceMultiplicator", _txMultiplier];
                _unit setVariable ["tf_receivingDistanceMultiplicator", _rxMultiplier];
            }, [_x, _txMultiplier, _rxMultiplier]], _x] call CBA_fnc_targetEvent;
        } forEach ((call CBA_fnc_players) select {_group = group _x; (side _group) in _sides || _group in _groups || _x in _players});

        // Handle JIP
        if (_doJIP) then {
            GVAR(radioSettingsJIP) = [_players apply {getPlayerUID _x}, _groups, _sides, _txMultiplier, _rxMultiplier];
            publicVariable QGVAR(radioSettingsJIP);
        };

        [LSTRING(changedRangesOnPlayersMessage)] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_RADIO] call zen_custom_modules_fnc_register;
