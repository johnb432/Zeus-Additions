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

//JIP ?

["Zeus Additions", "[WIP] TFAR Radio Range Multiplier", {
    params ["", "_unit"];

    ["Radio range (NOT TESTED; DOES NOT ACCOUNT FOR PLAYERS JOINING AFTER HAVING PLACED THE MODULE)", [
        ["OWNERS", ["Player selected", "Select a player from the list to determine which ammunition to spawn. If multiple are chosen only the first one selected will be looked at."], [[], [], [], 2], true],
        ["SLIDER", ["Range Multiplier", "Determines how far a radio can transmit. Default is 1.0."], [0, 5, 1, 2]]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_selected", "_multiplier"];
        _selected params ["_sides", "_groups", "_players"];

        if  (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            if (isNull _unit) then {
                ["Select a side/group/unit!"] call zen_common_fnc_showMessage;
                playSound "FD_Start_F";
            } else {
                _unit setVariable ["tf_sendingDistanceMultiplicator", _multiplier];
                ["Multiplier set on unit"] call zen_common_fnc_showMessage;
            };
        };

        private _side = "";
        {
            _side = _x;
            {
                if (side _x isEqualTo _side) then {
                    _x setVariable ["tf_sendingDistanceMultiplicator", _multiplier];
                };
            } forEach allPlayers;
        } forEach _sides;

        private _group = "";
        {
            _group = _x;
            {
                if (group _x isEqualTo _group) then {
                    _x setVariable ["tf_sendingDistanceMultiplicator", _multiplier];
                };
            } forEach allPlayers;
        } forEach _groups;

        {
            _x setVariable ["tf_sendingDistanceMultiplicator", _multiplier];
        } forEach _players;

        ["Multiplier set"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
