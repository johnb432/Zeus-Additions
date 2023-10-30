/*
 * Author: johnb43, cineafx
 * cineafx's gearscript updated and modified by johnb43.
 */

GVAR(gearIndex) = 0;
GVAR(gearPreset) = "default";
GVAR(loadoutTypes) = ["Default", "Leader", "AT", "AA", "AR", "Medic", "Engineer", "Single"];

[LSTRING(moduleCategoryLoadout), LSTRING(loadoutPresetsModuleName), {
    [LSTRING(loadoutPresetsModuleName), [
        ["EDIT", [LSTRING(loadoutCreatePreset), LSTRING(loadoutCreatePresetDesc)], "", true],
        ["COMBO", [LSTRING(loadoutSelectPreset), LSTRING(loadoutSelectPresetDesc)], [GETPRVAR(QGVAR(gearPresetNames),["default"]), GETPRVAR(QGVAR(gearPresetNames),["default"]), GVAR(gearIndex)]],
        ["EDIT", [LSTRING(loadoutImportPreset), LSTRING(loadoutImportPresetDesc)], "", true],
        ["TOOLBOX:YESNO", [LSTRING(loadoutExportPreset), LSTRING(loadoutExportPresetDesc)], false, true],
        ["TOOLBOX:YESNO", [LSTRING(loadoutResetPreset), LSTRING(loadoutResetPresetDesc)], false, true],
        ["TOOLBOX:YESNO", [LSTRING(loadoutDeletePreset), LSTRING(loadoutDeletePresetDesc)], false, true]
    ], {
        params ["_results"];
        _results params ["_newPreset", "_selectedPreset", "_importData", "_exportPreset", "_resetPreset", "_deletePreset"];

        // Remove whitespaces
        _newPreset = _newPreset splitString (toString WHITESPACE) joinString "";

        private _presets = GETPRVAR(QGVAR(gearPresetNames),["default"]);

        // If preset is supposed to be exported
        if (_exportPreset) exitWith {
            if (!GVAR(ACEClipboardLoaded)) exitWith {
                [LSTRING(aceClipboardDisabledMessage)] call zen_common_fnc_showMessage;
            };

            if (_selectedPreset == "") exitWith {
                [LSTRING(loadoutNoPresetSelectedMessage)] call zen_common_fnc_showMessage;
            };

            "ace_clipboard" callExtension ((str (GVAR(loadoutTypes) apply {parseSimpleArray (GETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_selectedPreset),"[]"))})) + ";");
            "ace_clipboard" callExtension "--COMPLETE--";

            [LSTRING(loadoutPresetExportedMessage), _selectedPreset] call zen_common_fnc_showMessage;
        };

        // If data is supposed to be imported
        if (_importData != "") exitWith {
            if (_newPreset == "" && {_selectedPreset == ""}) exitWith {
                [LSTRING(loadoutNoPresetSelectedImportMessage)] call zen_common_fnc_showMessage;
            };

            // A new preset has priority over a selected preset
            private _preset = [_selectedPreset, _newPreset] select (_newPreset != "");
            _importData = parseSimpleArray _importData;

            // If preset already exists, ask if overwrite or not
            private _toLowerPreset = toLower _preset;
            private _presetIndex = _presets findIf {_x == _toLowerPreset};

            if (_presetIndex != -1) then {
                [_preset, _presetIndex, _importData] spawn {
                    params ["_preset", "_presetIndex", "_importData"];

                    if ([format [LLSTRING(loadoutOverwritePresetMessage), _preset], localize "str_a3_a_hub_misc_mission_selection_box_title", LLSTRING_ZEN(common,yes), LLSTRING_ZEN(common,no), findDisplay IDD_RSCDISPLAYCURATOR] call BIS_fnc_guiMessage) then {
                        GVAR(gearIndex) = _presetIndex;
                        GVAR(gearPreset) = _preset;

                        {
                            SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_preset),_importData select _forEachIndex);
                        } forEach GVAR(loadoutTypes);

                        [LSTRING(loadoutOverwrittenPresetMessage), _preset] call zen_common_fnc_showMessage;
                    };
                };
            } else {
                // Add preset to preset list if not preset in list
                GVAR(gearIndex) = _presets pushBack _preset;
                GVAR(gearPreset) = _preset;
                SETPRVAR(QGVAR(gearPresetNames),_presets);

                {
                    SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_preset),_importData select _forEachIndex);
                } forEach GVAR(loadoutTypes);

                [LSTRING(loadoutImportedPresetMessage), _preset] call zen_common_fnc_showMessage;
            };
        };

        // If preset isn't empty string, try to make it if there isn't a preset with same name existent
        if (_newPreset != "") exitWith {
            if (_presets findIf {_x == _newPreset} != -1) exitWith {
                [LSTRING(loadoutAlreadyExistsPresetMessage), _newPreset] call zen_common_fnc_showMessage;
            };

            // Add preset to preset list
            GVAR(gearIndex) = _presets pushBack _newPreset;
            GVAR(gearPreset) = _newPreset;
            SETPRVAR(QGVAR(gearPresetNames),_presets);

            [LSTRING(loadoutCreatedPresetMessage), _newPreset] call zen_common_fnc_showMessage;
        };

        // Reset to default
        if (_resetPreset) exitWith {
            {
                SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_selectedPreset),"[]");
            } forEach GVAR(loadoutTypes);

            [LSTRING(loadoutResetPresetMessage), _selectedPreset] call zen_common_fnc_showMessage;
        };

        // Delete preset
        if (_deletePreset) exitWith {
            if (_selectedPreset == "default") exitWith {
                [LSTRING(loadoutCantDeletePresetMessage)] call zen_common_fnc_showMessage;
            };

            {
                SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_selectedPreset),nil);
            } forEach GVAR(loadoutTypes);

            private _index = _presets find _selectedPreset;

            if (_index == -1) exitWith {};

            _presets deleteAt _index;
            SETPRVAR(QGVAR(gearPresetNames),_presets);
            GVAR(gearIndex) = 0;

            [LSTRING(loadoutDeletedPresetMessage), _selectedPreset] call zen_common_fnc_showMessage;
        };

        GVAR(gearPreset) = _selectedPreset;

        [LSTRING(loadoutPresetSelectedMessage), _selectedPreset] call zen_common_fnc_showMessage;
    }] call zen_dialog_fnc_create;
}, ICON_PERSON] call zen_custom_modules_fnc_register;

[LSTRING(moduleCategoryLoadout), LSTRING(loadoutSetModuleName), {
    [LSTRING(loadoutPresetSelectedMessage), GVAR(gearPreset)] call zen_common_fnc_showMessage;

    [LSTRING(loadoutSetModuleName), [
        ["EDIT", ["STR_A3_OPTIONS_DEFAULT", LSTRING(loadoutDefaultDesc)], GETPRVAR(QGVAR(gearDefault_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["str_leader", LSTRING(loadoutLeaderDesc)], GETPRVAR(QGVAR(gearLeader_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["STR_A3_CfgMagazines_6Rnd_AAT_missiles_dns", LSTRING(loadoutATDesc)], GETPRVAR(QGVAR(gearAT_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["STR_A3_CfgMagazines_680Rnd_35mm_AA_shells_dns", LSTRING(loadoutAADesc)], GETPRVAR(QGVAR(gearAA_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["str_b_soldier_ar_f0", LSTRING(loadoutARDesc)], GETPRVAR(QGVAR(gearAR_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["STR_A3_Medic", LSTRING(loadoutMedicDesc)], GETPRVAR(QGVAR(gearMedic_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["str_b_engineer_f0", LSTRING(loadoutEngineerDesc)], GETPRVAR(QGVAR(gearEngineer_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", [LSTRING(loadoutSingleUnit), LSTRING(loadoutSingleUnitDesc)], GETPRVAR(QGVAR(gearSingle_) + GVAR(gearPreset),"[]"), true]
    ], {
        params ["_results"];

        private _result = "";

        {
            _result = _results select _forEachIndex;
            SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,GVAR(gearPreset)),[ARR_2("[]",_result)] select (_result != ""));
        } forEach GVAR(loadoutTypes);

        [LSTRING(loadoutSaved), GVAR(gearPreset)] call zen_common_fnc_showMessage;
    }] call zen_dialog_fnc_create;
}, ICON_PERSON] call zen_custom_modules_fnc_register;

[LSTRING(moduleCategoryLoadout), LSTRING(loadoutApplyUnitModuleName), {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
    };

    // If opening on a vehicle, effectiveCommander returns objNull when unit is dead
    if (alive _unit) then {
        _unit = effectiveCommander _unit;
    };

    // Can be applied to dead units too!
    if !(_unit isKindOf "CAManBase" && {!(_unit isKindOf "VirtualCurator_F")}) exitWith {
        [LSTRING_ZEN(modules,onlyInfantry)] call zen_common_fnc_showMessage;
    };

    private _loadoutString = GETPRVAR(QGVAR(gearSingle_) + GVAR(gearPreset),"[]");

    if (_loadoutString == "[]") then {
        _loadoutString = GETPRVAR(FORMAT_2(QGVAR(gear%1_%2),GVAR(loadoutTypes) select (_unit call FUNC(getRole)),GVAR(gearPreset)),"[]");
     };

    [_unit, parseSimpleArray _loadoutString] call CBA_fnc_setLoadout;

    [LSTRING(loadoutPresetAppliedMessage), GVAR(gearPreset)] call zen_common_fnc_showMessage;
}, ICON_PERSON] call zen_custom_modules_fnc_register;

[LSTRING(moduleCategoryLoadout), LSTRING(loadoutApplyGroupModuleName), {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
    };

    // If opening on a vehicle, effectiveCommander returns objNull when unit is dead
    if (alive _unit) then {
        _unit = effectiveCommander _unit;
    };

    // Can be applied to dead units too!
    if !(_unit isKindOf "CAManBase" && {!(_unit isKindOf "VirtualCurator_F")}) exitWith {
        [LSTRING_ZEN(modules,onlyInfantry)] call zen_common_fnc_showMessage;
    };

    private _loadout = [];
    private _loadouts = GVAR(loadoutTypes) apply {parseSimpleArray (GETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,GVAR(gearPreset)),"[]"))};

    // If loadout is not defined, use default loadout instead
    {
        _loadout = _loadouts select (_x call FUNC(getRole));
        [_x, [_loadouts select 0, _loadout] select (_loadout isNotEqualTo [])] call CBA_fnc_setLoadout;
    } forEach (units _unit);

    [LSTRING(loadoutPresetAppliedMessage), GVAR(gearPreset)] call zen_common_fnc_showMessage;
}, ICON_PERSON] call zen_custom_modules_fnc_register;
