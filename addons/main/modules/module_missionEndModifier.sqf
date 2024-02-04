/*
 * Author: johnb43
 * Adds a module that allows you to change if people can kill each other at mission end.
 */

[LSTRING(moduleCategoryUtility), "str_a3_cfgvehicles_moduleendmission_f", {
    ["str_a3_cfgvehicles_moduleendmission_f", [
        ["LIST", ["str_a3_rscattributeendmission_title", LSTRING(missionEndModifierEndingDesc)], [
            ["EveryoneWon", "EveryoneLost", "SideScore", "GroupScore", "PlayerScore", "SideTickets"],
            ["str_a3_mission_completed_title", "str_a3_mission_failed_title", "str_a3_cfgvehicles_moduleendmission_f_arguments_type_values_sidescore", "str_a3_cfgvehicles_moduleendmission_f_arguments_type_values_groupscore", "str_a3_cfgvehicles_moduleendmission_f_arguments_type_values_playerscore", "str_a3_cfgvehicles_modulerespawntickets_f"], 0, 6]
        ],
        ["TOOLBOX:YESNO", [LSTRING_ZEN(modules,moduleMakeInvincible), LSTRING(missionEndModifierInvulvernabilityDesc)], false],
        ["COMBO", [LSTRING(missionEndModifier), LSTRING(missionEndModifierDesc)], [[0, 1, 2, 3], ["str_3den_attributes_triggeractivation_none_text", [LSTRING(missionEndModifierWeaponRemoval), LSTRING(missionEndModifierWeaponRemovalDesc)], [LSTRING(missionEndModifierDisableInput), LSTRING(missionEndModifierDisableInputDesc)], ["str_a3_death1", LSTRING(missionEndModifierDeathDesc)]], 0]],
        ["EDIT:MULTI", ["str_a3_rscattributeendmission_titledebriefing", LSTRING(missionEndModifierDebriefingDesc)], ["", {}, 5]]
    ], {
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
        if (_invincible && {_setting != 3}) then {
            {
                ["zen_common_allowDamage", [_x, false], _x] call CBA_fnc_targetEvent;
            } forEach (_allPlayers + _vehicles);
        };

        switch (_setting) do {
            case 1: {
                {
                     ["zen_common_execute", [{
                         removeAllWeapons _this;
                     }, _x], _x] call CBA_fnc_targetEvent;
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
                        [QGVAR(disableInput), true] call ace_common_fnc_setDisableUserInputStatus;

                        _this enableSimulationGlobal false;
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

        [QGVAR(executeFunction), ["BIS_fnc_endMissionServer", _endType]] call CBA_fnc_serverEvent;

        RscDisplayDebriefing_params = _debriefText;
        publicVariable "RscDisplayDebriefing_params";
    }] call zen_dialog_fnc_create;
}, "\a3\Modules_F_Curator\Data\portraitEndMission_ca.paa"] call zen_custom_modules_fnc_register;
