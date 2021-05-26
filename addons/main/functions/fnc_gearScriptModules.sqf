#include "script_component.hpp"

/*
 * Author: johnb43, cineafx
 * cineafx's gearscript updated and modified by johnb43
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_gearScriptModules;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

GVAR(gearPreset) = "default";
GVAR(gearIndex) = 0;
GVAR(loadoutTypes) = [ARR_8("Default","Leader","AT","AA","AR","Medic","Engineer","Single")];

["Zeus Additions - Loadout", "Loadout: Presets", {
    ["Set Loadout (Uses ACE arsenal export format)", [
        ["EDIT", ["Create new loadout preset", "Allows you to store multiple presets of loadouts. DO NOT USE PUNCUATION MARKS."], "", true],
        ["COMBO", ["Select loadout preset", "Allows you to select a preset to edit and apply."], [GETPRVAR(QGVAR(gearPresetNames),["default"]), GETPRVAR(QGVAR(gearPresetNames),["default"]), GVAR(gearIndex)], false],
        ["TOOLBOX:YESNO", ["Reset saved loadouts", "Resets saved loadouts in currently selected preset."], false, true],
        ["TOOLBOX:YESNO", ["Delete preset", "Deletes the currently selected preset. If you chose a preset in the current window, it will delete that one."], false, true]
    ],
    {
        params ["_results"];
        _results params ["_newPreset", "_selectedPreset", "_resetPreset", "_deletePreset"];

        _newPreset = _newPreset splitString " " joinString "";

        private _presets = GETPRVAR(QGVAR(gearPresetNames),["default"]);

        if (_newPreset isNotEqualTo "" && {!(_newPreset in _presets)}) exitWith {
            _presets pushBack _newPreset;
            SETPRVAR(QGVAR(gearPresetNames),_presets);
            GVAR(gearPreset) = _newPreset;
            GVAR(gearIndex) = _presets findIf {_x isEqualTo _newPreset};

            ["New preset %1 created and chosen", _newPreset] call zen_common_fnc_showMessage;
        };

        if (_resetPreset) exitWith {
            {
                SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_selectedPreset),"[]");
            } forEach GVAR(loadoutTypes);

            ["Loadouts in %1 preset reset", _selectedPreset] call zen_common_fnc_showMessage;
        };

        if (_deletePreset) exitWith {
            if (_selectedPreset isEqualTo "default") exitWith {
                ["You can't delete the default preset!"] call zen_common_fnc_showMessage;
            };

            {
                SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_selectedPreset),nil);
            } forEach GVAR(loadoutTypes);

            private _index = _presets findIf {_x isEqualTo _selectedPreset};
            if (_index isEqualTo -1) exitWith {};

            _presets deleteAt _index;
            SETPRVAR(QGVAR(gearPresetNames),_presets);
            GVAR(gearIndex) = 0;

            ["Loadout preset %1 deleted", _selectedPreset] call zen_common_fnc_showMessage;
        };

        GVAR(gearPreset) = _selectedPreset;
        ["Chosen preset: %1", _selectedPreset] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions - Loadout", "Loadout: Set", {
    ["Set Loadout (Uses ACE arsenal export format)", [
        ["EDIT", ["Default", "Riflemen, Crew, etc. Delete empty array and paste loadout then."], GETPRVAR("zeus_additions_main_gearDefault_" + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["Leader", "Squad leaders, Team leaders. Delete empty array and paste loadout then."], GETPRVAR("zeus_additions_main_gearLeader_" + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["AT", "Anti-tank gunners, Anti-tank assistants. Delete empty array and paste loadout then."], GETPRVAR("zeus_additions_main_gearAT_" + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["AA", "Anti-air operators, Anti-air assistants. Delete empty array and paste loadout then."], GETPRVAR("zeus_additions_main_gearAA_" + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["AR", "Autoriflemen, Machine Gunners. Delete empty array and paste loadout then."], GETPRVAR("zeus_additions_main_gearAR_" + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["Medic", "Medics, Combat Life Savers. Delete empty array and paste loadout then."], GETPRVAR("zeus_additions_main_gearMedic_" + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["Engineer", "Engineers, Demo. Delete empty array and paste loadout then."], GETPRVAR("zeus_additions_main_gearEngineer_" + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["Single Unit", "Use this line to apply with Gear Set to Single Unit. Delete empty array and paste loadout then."], GETPRVAR("zeus_additions_main_gearSingle_" + GVAR(gearPreset),"[]"), true]
    ],
    {
        params ["_results"];

        private _result;

        {
            _result = _results select _forEachIndex;
            SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,GVAR(gearPreset)),[ARR_2("[]",_result)] select (_result isNotEqualTo ""));
        } forEach GVAR(loadoutTypes);

        ["Loadouts saved"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions - Loadout", "Loadout: Apply to single unit", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["No unit was selected!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    private _loadoutString = GETPRVAR("zeus_additions_main_gearSingle_" + GVAR(gearPreset),"[]");

    if (_loadoutString isEqualTo "[]") then {
        _loadoutString = GETPRVAR(FORMAT_2(QGVAR(gear%1_%2),GVAR(loadoutTypes) select (_unit call FUNC(getRole)),GVAR(gearPreset)),"[]");
     };

    _unit setUnitLoadout (parseSimpleArray _loadoutString);

    ["Loadout applied"] call zen_common_fnc_showMessage;
}] call zen_custom_modules_fnc_register;

["Zeus Additions - Loadout", "Loadout: Apply to group", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["No unit was selected!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    private _loadouts = [];

    {
        _loadouts pushBack parseSimpleArray (GETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,GVAR(gearPreset)),"[]"));
    } forEach GVAR(loadoutTypes);

    private _loadout;
    // If loadout is not defined, use default loadout instead
    {
        _loadout = _loadouts select (_x call FUNC(getRole));
        _x setUnitLoadout ([_loadouts select 0, _loadout] select (_loadout isNotEqualTo []));
    } forEach (units group _unit);

    ["Loadouts applied"] call zen_common_fnc_showMessage;
}] call zen_custom_modules_fnc_register;
