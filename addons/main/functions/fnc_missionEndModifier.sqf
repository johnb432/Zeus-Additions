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
        ["TOOLBOX:YESNO", ["Add Invincibility", "Invincibility will be applied with the modifier below."], false, false],
        ["COMBO", ["Mission end modifier", "Sets what type of action is applied to players at scenario end."], [[0, 1, 2, 3], ["None", ["Weapon removal", "All weapons are removed from every player."], ["Disable player movement", "Disables player movement and user input."], ["Death", "All player die."]], 0], false],
        ["EDIT:MULTI", ["Debrief text", "Text that will show up in the debriefing screen."], ["", {}, 5], false]
    ],
    {
        params ["_results"];
        _results params ["_endType", "_invincible", "_setting", "_debriefText"];

        // (call CBA_fnc_players) does not include curators
        private _allPlayers = call CBA_fnc_players;

        // If 2nd modifier isn't death, apply invincibility
        if (_invincible && {_setting isNotEqualTo 3}) then {
            {
                ["zen_common_allowDamage", [_x, false], _x] call CBA_fnc_targetEvent;

                // If player is in a vehicle, make that invincible too
                if (!isNull objectParent _x) then {
                    ["zen_common_allowDamage", [objectParent _x, false], objectParent _x] call CBA_fnc_targetEvent;
                };
            } forEach _allPlayers;
        };

        switch (_setting) do {
            case 1: {
                {
                     _x remoteExecCall ["removeAllWeapons", _x];
                } forEach _allPlayers;
            };
            case 2: {
                // Stops the player from spinning if player was in the middle of turning
                {
                     ["zen_common_enableSimulationGlobal", [_x, false]] call CBA_fnc_serverEvent;
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
