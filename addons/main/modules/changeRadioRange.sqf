/*
 * Author: johnb43
 * Adds a module that can alter a unit's TFAR radio range.
 */

["Zeus Additions - Players", "Change TFAR Radio Range", {
    params ["", "_unit"];

    ["Change TFAR Radio Range", [
        ["OWNERS", ["Players selected", "Select sides/groups/units. Module can also be placed on a player."], [[], [], [], 0], true],
        ["TOOLBOX:YESNO", ["Change yourself", "You can use this whilst as a curator to set your multiplier."], false, true],
        ["SLIDER", ["Range Multiplier", "Determines how far a radio can transmit. Default is 1.0."], [0, 50, 1, 2]],
        ["TOOLBOX:YESNO", ["Account for JIP players", "When players join in progress (JIP), it will automatically apply this setting."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_self", "_multiplier", "_doJIP"];
        _selected params ["_sides", "_groups", "_players"];

        // If self is checked
        if (_self) then {
            player setVariable ["tf_sendingDistanceMultiplicator", _multiplier, true];
        };

        // If no sides, groups or units were selected in the dialog, check if module was placed on a unit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            // If unit is player, apply setting
            private _string = if (isPlayer _unit) then {
                _unit setVariable ["tf_sendingDistanceMultiplicator", _multiplier, true];
                "Multiplier set on player";
            } else {
                // If unit is AI, null or otherwise invalid, display error if not something done to self
                if (_self) then {
                    "Multiplier set on yourself";
                } else {
                    playSound "FD_Start_F";
                    "Select a side/group/player or even yourself (must be a player)!";
                };
            };

            [_string] call zen_common_fnc_showMessage;
        };

        // Set multiplier on all selected units
        {
            _x setVariable ["tf_sendingDistanceMultiplicator", _multiplier, true];
        } forEach ((call CBA_fnc_players) select {side _x in _sides || {group _x in _groups} || {_x in _players}});

        // Handle JIP
        if (_doJIP) then {
            if (GETMVAR(QGVAR(handleServerJIP),false)) then {
                GVAR(radioSettingsJIP) = [_multiplier, _players apply {getPlayerUID _x}, _groups, _sides];
                publicVariableServer QGVAR(radioSettingsJIP);
            } else {
                hint "JIP disabled. Turn on in CBA Settings to enable it.";
            };
        };

        ["Multiplier set on selected players"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_RADIO] call zen_custom_modules_fnc_register;
