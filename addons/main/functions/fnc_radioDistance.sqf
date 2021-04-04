#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module that can alter a unit's TFAR radio range.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_radioDistance;
 *
 * Public: No
 */

if (hasInterface) then {
    GVAR(radioMultiplicatorJIP) = 1;

    ["Zeus Additions - Players", "TFAR Radio Range Multiplier", {
        params ["", "_unit"];

        ["Radio range", [
            ["OWNERS", ["Units selected", "Select a side/group/player."], [[], [], [], 2], true],
            ["SLIDER", ["Range Multiplier", "Determines how far a radio can transmit. Default is 1.0."], [0, 10, 1, 2]],
            ["CHECKBOX", ["Account for JIP players", "This option only works if the mod is on the server aswell."], false, false]
        ],
        {
            params ["_results", "_unit"];
            _results params ["_selected", "_multiplier", "_doJIP"];
            _selected params ["_sides", "_groups", "_players"];

            if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
                if (isNull _unit) then {
                    ["Select a side/group/unit!"] call zen_common_fnc_showMessage;
                    playSound "FD_Start_F";
                } else {
                    _unit setVariable ["tf_sendingDistanceMultiplicator", _multiplier, true];
                    ["Multiplier set on unit"] call zen_common_fnc_showMessage;
                };
            };

            private _side;
            {
                _side = _x;
                {
                    if (side _x isEqualTo _side) then {
                        _x setVariable ["tf_sendingDistanceMultiplicator", _multiplier, true];
                    };
                } forEach allPlayers;
            } forEach _sides;

            private _group;
            {
                _group = _x;
                {
                    if (group _x isEqualTo _group) then {
                        _x setVariable ["tf_sendingDistanceMultiplicator", _multiplier, true];
                    };
                } forEach allPlayers;
            } forEach _groups;

            {
                _x setVariable ["tf_sendingDistanceMultiplicator", _multiplier, true];
            } forEach _players;

            if (_doJIP) then {
                GVAR(radioMultiplicatorJIP) = _multiplier;
                publicVariable QGVAR(radioMultiplicatorJIP);

                GVAR(radioMultiplicatorPlayersJIP) = _players apply {getPlayerUID _x};
                publicVariable QGVAR(radioMultiplicatorPlayersJIP);

                GVAR(radioMultiplicatorGroupsJIP) = _groups;
                publicVariable QGVAR(radioMultiplicatorGroupsJIP);

                GVAR(radioMultiplicatorSidesJIP) = _sides;
                publicVariable QGVAR(radioMultiplicatorSidesJIP);
            };

            ["Multiplier set"] call zen_common_fnc_showMessage;
        }, {
            ["Aborted"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        }, _unit] call zen_dialog_fnc_create;
    }] call zen_custom_modules_fnc_register;
};

if (isServer) then {
    addMissionEventHandler ["PlayerConnected", {
    	   params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

        if (!_jip) exitWith {};

        [{
            !isNull (_this call BIS_fnc_getUnitByUID)
        }, {
            private _player = _this call BIS_fnc_getUnitByUID;

            if !(!isNil QGVAR(radioMultiplicatorPlayersJIP) && {_this in GVAR(radioMultiplicatorPlayersJIP)}) exitWith {};
            if !(!isNil QGVAR(radioMultiplicatorGroupsJIP) && {(group _player) in GVAR(radioMultiplicatorGroupsJIP)}) exitWith {};
            if !(!isNil QGVAR(radioMultiplicatorSidesJIP) && {(side _player) in GVAR(radioMultiplicatorSidesJIP)}) exitWith {};

            _player setVariable ["tf_sendingDistanceMultiplicator", GVAR(radioMultiplicatorJIP), true];
        }, _uid, 60, {
            ["Could not apply 'TFAR radio range' module on JIP player '%1'", _this call BIS_fnc_getUnitByUID] call zen_common_fnc_showMessage;
        }] call CBA_fnc_waitUntilAndExecute;
    }];
};
