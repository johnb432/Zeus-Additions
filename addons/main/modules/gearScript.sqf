/*
 * Author: johnb43, cineafx
 * cineafx's gearscript updated and modified by johnb43.
 */

GVAR(gearIndex) = 0;
GVAR(gearPreset) = "default";
GVAR(loadoutTypes) = [ARR_8("Default","Leader","AT","AA","AR","Medic","Engineer","Single")];

["Zeus Additions - Loadout", "Loadout: Presets", {
    ["Set Loadout Presets", [
        ["EDIT", ["Create new loadout preset", "Allows you to store multiple presets of loadouts. Profiles names are case insensitive. DO NOT USE PUNCUATION MARKS."], "", true],
        ["COMBO", ["Select loadout preset", "Allows you to select a preset to edit and apply."], [GETPRVAR(QGVAR(gearPresetNames),["default"]), GETPRVAR(QGVAR(gearPresetNames),["default"]), GVAR(gearIndex)]],
        ["EDIT", ["Import new loadout preset", "Place the array of loadouts here if you are importing a profile."], "", true],
        ["TOOLBOX:YESNO", ["Export current preset", "Exports preset to clipboard."], false, true],
        ["TOOLBOX:YESNO", ["Reset saved loadouts", "Resets saved loadouts in currently selected preset."], false, true],
        ["TOOLBOX:YESNO", ["Delete preset", "Deletes the currently selected preset. If you chose a preset in the current window, it will delete that one."], false, true]
    ],
    {
        params ["_results"];
        _results params ["_newPreset", "_selectedPreset", "_importData", "_exportPreset", "_resetPreset", "_deletePreset"];

        // Remove whitespaces
        _newPreset = _newPreset splitString " " joinString "";

        private _presets = GETPRVAR(QGVAR(gearPresetNames),["default"]);

        // If preset is supposed to be exported
        if (_exportPreset) exitWith {
            if (!GVAR(ACEClipboardLoaded)) exitWith {
                ["ACE clipboard is disabled!"] call zen_common_fnc_showMessage;
            };

            if (_selectedPreset isEqualTo "") exitWith {
                ["No preset was chosen!"] call zen_common_fnc_showMessage;
            };

            private _loadouts = [];

            {
                _loadouts pushBack parseSimpleArray (GETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_selectedPreset),"[]"));
            } forEach GVAR(loadoutTypes);

            "ace_clipboard" callExtension ((str _loadouts) + ";");
            "ace_clipboard" callExtension "--COMPLETE--";

            ["Preset '%1' has been exported to your clipboard", _selectedPreset] call zen_common_fnc_showMessage;
        };

        // If data is supposed to be imported
        if (_importData isNotEqualTo "") exitWith {
            if (_newPreset isEqualTo "" && {_selectedPreset isEqualTo ""}) exitWith {
                ["No preset name was provided for import!"] call zen_common_fnc_showMessage;
            };

            // A new preset has priority over a selected preset
            private _preset = [_selectedPreset, _newPreset] select (_newPreset isNotEqualTo "");
            _importData = parseSimpleArray _importData;

            // If preset already exists, ask if overwrite or not
            private _presetIndex = (_presets apply {toLower _x}) find (toLower _preset);

            if (_presetIndex isNotEqualTo -1) then {
                [_preset, _presetIndex, _importData] spawn {
                    params ["_preset", "_presetIndex", "_importData"];

                    if ([format ["Are you sure you want to overwrite preset '%1'?", _preset], "Confirmation", "Yes", "No", findDisplay IDD_RSCDISPLAYCURATOR] call BIS_fnc_guiMessage) then {
                        GVAR(gearIndex) = _presetIndex;
                        GVAR(gearPreset) = _preset;

                        {
                            SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_preset),_importData select _forEachIndex);
                        } forEach GVAR(loadoutTypes);

                        ["Preset '%1' overwritten and chosen", _preset] call zen_common_fnc_showMessage;
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

                ["New preset '%1' imported and chosen", _preset] call zen_common_fnc_showMessage;
            };
        };

        // If preset isn't empty string, try to make it. Make everything lowercase for string comparison
        if (_newPreset isNotEqualTo "") exitWith {
            if ((toLower _newPreset) in (_presets apply {toLower _x})) exitWith {
                ["Preset '%1' already exists!", _newPreset] call zen_common_fnc_showMessage;
            };

            // Add preset to preset list
            GVAR(gearIndex) = _presets pushBack _newPreset;
            GVAR(gearPreset) = _newPreset;
            SETPRVAR(QGVAR(gearPresetNames),_presets);

            ["New preset '%1' created and chosen", _newPreset] call zen_common_fnc_showMessage;
        };

        // Reset to default
        if (_resetPreset) exitWith {
            {
                SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_selectedPreset),"[]");
            } forEach GVAR(loadoutTypes);

            ["Loadouts in preset '%1' reset", _selectedPreset] call zen_common_fnc_showMessage;
        };

        // Delete preset
        if (_deletePreset) exitWith {
            if (_selectedPreset isEqualTo "default") exitWith {
                ["You can't delete the default preset!"] call zen_common_fnc_showMessage;
            };

            {
                SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,_selectedPreset),nil);
            } forEach GVAR(loadoutTypes);

            private _index = _presets find _selectedPreset;

            if (_index isEqualTo -1) exitWith {};

            _presets deleteAt _index;
            SETPRVAR(QGVAR(gearPresetNames),_presets);
            GVAR(gearIndex) = 0;

            ["Preset '%1' deleted", _selectedPreset] call zen_common_fnc_showMessage;
        };

        GVAR(gearPreset) = _selectedPreset;

        ["Chosen preset: %1", _selectedPreset] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}, ICON_PERSON] call zen_custom_modules_fnc_register;

["Zeus Additions - Loadout", "Loadout: Set", {
    ["Preset '%1' is selected", GVAR(gearPreset)] call zen_common_fnc_showMessage;

    ["Set Loadout (Uses ACE arsenal export format)", [
        ["EDIT", ["Default", "Riflemen, Crew, etc. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearDefault_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["Leader", "Squad leaders, Team leaders. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearLeader_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["AT", "Anti-tank gunners, Anti-tank assistants. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearAT_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["AA", "Anti-air operators, Anti-air assistants. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearAA_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["AR", "Autoriflemen, Machine Gunners. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearAR_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["Medic", "Medics, Combat Life Savers. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearMedic_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["Engineer", "Engineers, Demo. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearEngineer_) + GVAR(gearPreset),"[]"), true],
        ["EDIT", ["Single Unit", "Use this line to apply with Gear Set to Single Unit. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearSingle_) + GVAR(gearPreset),"[]"), true]
    ],
    {
        params ["_results"];

        private _result = "";

        {
            _result = _results select _forEachIndex;
            SETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,GVAR(gearPreset)),[ARR_2("[]",_result)] select (_result isNotEqualTo ""));
        } forEach GVAR(loadoutTypes);

        ["Loadouts saved to '%1'", GVAR(gearPreset)] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}, ICON_PERSON] call zen_custom_modules_fnc_register;

["Zeus Additions - Loadout", "Loadout: Apply to single unit", {
    params ["", "_unit"];

    // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
    if (alive _unit) then {
        _unit = effectiveCommander _unit;
    };

    // Can be applied to dead units too!
    if !(_unit isKindOf "CAManBase") exitWith {
        ["Select a unit!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    private _loadoutString = GETPRVAR(QGVAR(gearSingle_) + GVAR(gearPreset),"[]");

    if (_loadoutString isEqualTo "[]") then {
        _loadoutString = GETPRVAR(FORMAT_2(QGVAR(gear%1_%2),GVAR(loadoutTypes) select (_unit call FUNC(getRole)),GVAR(gearPreset)),"[]");
     };

    _unit setUnitLoadout (parseSimpleArray _loadoutString);

    ["Preset '%1' applied", GVAR(gearPreset)] call zen_common_fnc_showMessage;
}, ICON_PERSON] call zen_custom_modules_fnc_register;

["Zeus Additions - Loadout", "Loadout: Apply to group", {
    params ["", "_unit"];

    // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
    if (alive _unit) then {
        _unit = effectiveCommander _unit;
    };

    // Can be applied to dead units too!
    if !(_unit isKindOf "CAManBase") exitWith {
        ["Select a unit!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    private _loadouts = [];

    {
        _loadouts pushBack parseSimpleArray (GETPRVAR(FORMAT_2(QGVAR(gear%1_%2),_x,GVAR(gearPreset)),"[]"));
    } forEach GVAR(loadoutTypes);

    private _loadout = [];

    // If loadout is not defined, use default loadout instead
    {
        _loadout = _loadouts select (_x call FUNC(getRole));
        _x setUnitLoadout ([_loadouts select 0, _loadout] select (_loadout isNotEqualTo []));
    } forEach units _unit;

    ["Preset '%1' applied", GVAR(gearPreset)] call zen_common_fnc_showMessage;
}, ICON_PERSON] call zen_custom_modules_fnc_register;
