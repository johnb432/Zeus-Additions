#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module that allows you to change if people can kill each other at mission end.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_missionEndModifier;
 *
 * Public: No
 */

["Zeus Additions - Utility", "End Scenario with Player Modifier", {
    ["End Scenario with Player Modifier", [
        ["LIST", ["Mission ending", "Sets the type of ending."], [["EveryoneWon", "EveryoneLost", "SideScore", "GroupScore", "PlayerScore", "SideTickets"], ["Mission completed", "Mission failed", "Side with best score wins", "Group with best score wins", "Player with best score wins", "Side with most tickets wins"], 0, 6]],
        ["TOOLBOX:YESNO", ["Add Invincibility", "Invincibility will be applied with the modifier below."], false],
        ["COMBO", ["Mission end modifier", "Sets what type of action is applied to players at scenario end."], [[0, 1, 2, 3], ["None", ["Weapon removal", "All weapons are removed from every player."], ["Disable player movement", "Disables player movement and user input."], ["Death", "All player die."]], 0]],
        ["EDIT:MULTI", ["Debrief text", "Text that will show up in the debriefing screen."], ["", {}, 5]]
    ],
    {
        params ["_results"];
        _results params ["_endType", "_invincible", "_setting", "_debriefText"];

        // CBA_fnc_players does not include curators
        private _allPlayers = call CBA_fnc_players;
        private _vehicles = [];

        {
            if (!isNull objectParent _x) then {
                _vehicles pushBackUnique (objectParent _x);
            };
        } forEach _allPlayers;

        // If 2nd modifier isn't death, apply invincibility
        if (_invincible && {_setting isNotEqualTo 3}) then {
            {
                [_x, false] remoteExecCall ["allowDamage", _x];
            } forEach (_allPlayers + _vehicles);
        };

        switch (_setting) do {
            case 1: {
                {
                     _x remoteExecCall ["removeAllWeapons", _x];
                } forEach _allPlayers;

                // Remove all ammo from all vics
                {
                    [_x, 0] remoteExecCall ["zen_common_fnc_setVehicleAmmo", _x];
                } forEach _vehicles;
            };
            case 2: {
                // Stops the player from spinning if player was in the middle of turning
                {
                     [_x, false] remoteExecCall ["enableSimulation", _x];
                } forEach _allPlayers;

                true remoteExecCall ["disableUserInput", _allPlayers, true];
            };
            case 3: {
                {
                    _x setDamage 1;
                } forEach _allPlayers;
            };
            default {};
        };

        _endType remoteExecCall ["BIS_fnc_endMissionServer", 2];

        RscDisplayDebriefing_params = _debriefText;
        publicVariable "RscDisplayDebriefing_params";
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}, ICON_END] call zen_custom_modules_fnc_register;
