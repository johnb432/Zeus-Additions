/*
 * Author: johnb43
 * Adds a module that allows you to change if people can kill each other at mission end.
 */

["Zeus Additions - Utility", "End Scenario with Player Modifier", {
    ["End Scenario with Player Modifier", [
        ["LIST", ["Mission ending", "Sets the type of ending."], [["EveryoneWon", "EveryoneLost", "SideScore", "GroupScore", "PlayerScore", "SideTickets"], ["Mission completed", "Mission failed", "Side with best score wins", "Group with best score wins", "Player with best score wins", "Side with most tickets wins"], 0, 6]],
        ["TOOLBOX:YESNO", ["Add Invincibility", "Invincibility will be applied with the modifier below."], false],
        ["COMBO", ["Mission end modifier", "Sets what type of action is applied to players at scenario end."], [[0, 1, 2, 3], ["None", ["Weapon removal", "All weapons are removed from every player."], ["Disable player input", "Disables player movement and user input."], ["Death", "All players die."]], 0]],
        ["EDIT:MULTI", ["Debrief text", "Text that will show up in the debriefing screen."], ["", {}, 5]]
    ],
    {
        params ["_results"];
        _results params ["_endType", "_invincible", "_setting", "_debriefText"];

        // CBA_fnc_players does not include curators
        private _allPlayers = call CBA_fnc_players;
        private _vehicles = [];
        private _vehicle = objNull;

        {
            _vehicle = objectParent _x;

            if (!isNull _vehicle) then {
                _vehicles pushBackUnique _vehicle;
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
                    [_x, 0] call zen_common_fnc_setVehicleAmmo;
                } forEach _vehicles;
            };
            case 2: {
                // Stops the player from spinning if player was in the middle of turning
                {
                    ["zen_common_execute", [{
                        _this enableSimulationGlobal false;
                        true call ace_common_fnc_disableUserInput;
                    }, _x], _x] call CBA_fnc_targetEvent;
                } forEach _allPlayers;
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
