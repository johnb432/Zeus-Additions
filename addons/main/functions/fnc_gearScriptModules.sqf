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
 * call zeus_additions_main_gearScriptModules;
 *
 * Public: No
 */

["Zeus Additions", "Loadout: Set", {
    ["Set Loadout (Uses ACE arsenal export format)", [
        ["EDIT", ["Default", "Riflemen, Crew, etc. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearDefault", "[]"], true],
        ["EDIT", ["Leader", "Squad leaders, Team leaders. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearLeader", "[]"], true],
        ["EDIT", ["AT", "Anti-tank gunners, Anti-tank assistants. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearAT", "[]"], true],
        ["EDIT", ["AA", "Anti-air operators, Anti-air assistants. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearAA", "[]"], true],
        ["EDIT", ["AR", "Autoriflemen, Machine Gunners. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearAR", "[]"], true],
        ["EDIT", ["Medic", "Medics, Combat Life Savers. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearMedic", "[]"], true],
        ["EDIT", ["Engineer", "Engineers, Demo. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearEngineer", "[]"], true],
        ["EDIT", ["Single Unit", "Use this line to apply with Gear Set to Single Unit. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearSingle", "[]"], true],
        ["CHECKBOX", ["Reset saved loadouts", "Resets saved loadouts (clears window on next open)."], false, true]
    ], {
        params ["_results"];

        if (_results select (count _results - 1)) exitWith {
            profileNamespace setVariable ["gearDefault", "[]"];
            profileNamespace setVariable ["gearLeader", "[]"];
            profileNamespace setVariable ["gearAT", "[]"];
            profileNamespace setVariable ["gearAA", "[]"];
            profileNamespace setVariable ["gearAR", "[]"];
            profileNamespace setVariable ["gearMedic", "[]"];
            profileNamespace setVariable ["gearEngineer", "[]"];
            profileNamespace setVariable ["gearSingle", "[]"];

            ["Loadouts reset"] call zen_common_fnc_showMessage;
        };

        _results deleteAt (count _results - 1);

        {
            if (_x == "") then {
                _results set [_forEachIndex, "[]"];
            };
        } forEach _results;

        profileNamespace setVariable ["gearDefault", _results select 0];
        profileNamespace setVariable ["gearLeader", _results select 1];
        profileNamespace setVariable ["gearAT", _results select 2];
        profileNamespace setVariable ["gearAA", _results select 3];
        profileNamespace setVariable ["gearAR", _results select 4];
        profileNamespace setVariable ["gearMedic", _results select 5];
        profileNamespace setVariable ["gearEngineer", _results select 6];
        profileNamespace setVariable ["gearSingle", _results select 7];

        ["Loadouts saved"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions", "Loadout: Apply to single unit", {
    params ["", "_object"];

    if (isNull _object) exitWith {
        ["No unit was selected!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    private _loadoutString = profileNamespace getVariable ["gearSingle", "[]"];

    if (_loadoutString == "[]") then {
        private _loadouts = [
            profileNamespace getVariable ["gearDefault", "[]"],
            profileNamespace getVariable ["gearLeader", "[]"],
            profileNamespace getVariable ["gearAT", "[]"],
            profileNamespace getVariable ["gearAA", "[]"],
            profileNamespace getVariable ["gearAR", "[]"],
            profileNamespace getVariable ["gearMedic", "[]"],
            profileNamespace getVariable ["gearEngineer", "[]"]
        ];

        private _type = -1;

        if (isText(configFile >> "CfgVehicles" >> typeOf _object >> "icon")) then {
            private _icon = getText(configFile >> "CfgVehicles" >> typeOf _object >> "icon");

            if (_icon isEqualTo "iconManLeader") then {
                _type = 1;
            };
            if (_icon isEqualTo "iconManMG") then {
                _type = 4;
            };
            if (_icon isEqualTo "iconManMedic") then {
                _type = 5;
            };
            if (_icon isEqualTo "iconManEngineer") then {
                _type = 6;
            };
        };

        if (_type isEqualTo -1) then {
            private _weapon = nil;

            if (!isNil {primaryWeapon _object}) then {
                _weapon = primaryWeapon _object
            };

            if (!isNil {secondaryWeapon _object}) then {
                _weapon = secondaryWeapon _object
            };

            if (isText(configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) then {
                switch (getText(configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) do {
                    case "\A3\weapons_f\data\UI\icon_mg_CA.paa": {_type = 4};
                    case "\A3\Weapons_F\Data\UI\icon_aa_CA.paa": {_type = 3};
                    case "\A3\Weapons_F\Data\UI\icon_at_CA.paa": {_type = 2};
                    case "\A3\weapons_f\data\UI\icon_regular_CA.paa": {_type = 0};
                    default {};
                };
            };

            if (_type isEqualTo -1) then {
                private _unitType = typeOf _object;
                _type = 0;

                if ("AR" in _unitType) then {
                    _type = 4;
                };
                if ("AA" in _unitType) then {
                    _type = 3;
                };
                if ("AT" in _unitType) then {
                    _type = 2;
                };
                if ("SL" in _unitType || {"TL" in _unitType}) then {
                    _type = 1;
                };
            };
        };

        _loadoutString = _loadouts select _type;
    };

    _object setUnitLoadout (parseSimpleArray (_loadoutString splitString " " joinString ""));

    ["Loadout applied"] call zen_common_fnc_showMessage;
}] call zen_custom_modules_fnc_register;

["Zeus Additions", "Loadout: Apply to group", {
    params ["", "_object"];

    if (isNull _object) exitWith {
        ["No unit was selected!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    private _units = units group _object;

    private _loadouts = [
        profileNamespace getVariable ["gearDefault", "[]"],
        profileNamespace getVariable ["gearLeader", "[]"],
        profileNamespace getVariable ["gearAT", "[]"],
        profileNamespace getVariable ["gearAA", "[]"],
        profileNamespace getVariable ["gearAR", "[]"],
        profileNamespace getVariable ["gearMedic", "[]"],
        profileNamespace getVariable ["gearEngineer", "[]"]
    ];

    {
        private _type = -1;

        if (isText(configFile >> "CfgVehicles" >> typeOf _x >> "icon")) then {
            private _icon = getText(configFile >> "CfgVehicles" >> typeOf _x >> "icon");

            if (_icon isEqualTo "iconManLeader") then {
                _type = 1;
            };
            if (_icon isEqualTo "iconManMG") then {
                _type = 4;
            };
            if (_icon isEqualTo "iconManMedic") then {
                _type = 5;
            };
            if (_icon isEqualTo "iconManEngineer") then {
                _type = 6;
            };
        };

        if (_type isEqualTo -1) then {
            private _weapon = nil;

            if (!isNil {primaryWeapon _x}) then {
                _weapon = primaryWeapon _x
            };

            if (!isNil {secondaryWeapon _x}) then {
                _weapon = secondaryWeapon _x
            };

            if (isText(configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) then {
                switch (getText(configFile >> "CfgWeapons" >> _weapon >> "UiPicture")) do {
                    case "\A3\weapons_f\data\UI\icon_mg_CA.paa": {_type = 4};
                    case "\A3\Weapons_F\Data\UI\icon_aa_CA.paa": {_type = 3};
                    case "\A3\Weapons_F\Data\UI\icon_at_CA.paa": {_type = 2};
                    case "\A3\weapons_f\data\UI\icon_regular_CA.paa": {_type = 0};
                    default {};
                };
            };

            if (_type isEqualTo -1) then {
                private _unitType = typeOf _x;
                _type = 0;

                if ("AR" in _unitType) then {
                    _type = 4;
                };
                if ("AA" in _unitType) then {
                    _type = 3;
                };
                if ("AT" in _unitType) then {
                    _type = 2;
                };
                if ("SL" in _unitType || {"TL" in _unitType}) then {
                    _type = 1;
                };
            };
        };

        _x setUnitLoadout (parseSimpleArray ((_loadouts select _type) splitString " " joinString ""));
    } forEach _units;

    ["Loadouts applied"] call zen_common_fnc_showMessage;
}] call zen_custom_modules_fnc_register;
