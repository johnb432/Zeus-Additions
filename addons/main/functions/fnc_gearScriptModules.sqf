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
        ["EDIT", ["Default", "Riflemen, Medics, etc. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearDefault", "[]"], true],
        ["EDIT", ["Leader", "Squad leaders, Team leaders. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearLeader", "[]"], true],
        ["EDIT", ["AT", "Anti-tank gunners, Anti-tank assistants. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearAT", "[]"], true],
        ["EDIT", ["AA", "Anti-air operators, Anti-air assistants. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearAA", "[]"], true],
        ["EDIT", ["AR", "Autoriflemen, Machine Gunners. Delete empty array and paste loadout then."], profileNamespace getVariable ["gearAR", "[]"], true],
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
        profileNamespace setVariable ["gearSingle", _results select 5];

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
        private _gearDefault = profileNamespace getVariable ["gearDefault", "[]"];
        private _gearLeader = profileNamespace getVariable ["gearLeader", "[]"];
        private _gearAT = profileNamespace getVariable ["gearAT", "[]"];
        private _gearAA = profileNamespace getVariable ["gearAA", "[]"];
        private _gearAR = profileNamespace getVariable ["gearAR", "[]"];

        private _loadouts = [_gearDefault, _gearLeader, _gearAT, _gearAA, _gearAR];

        private _unitType = typeOf _x;
        private _type = 0;

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

    private _gearDefault = profileNamespace getVariable ["gearDefault", "[]"];
    private _gearLeader = profileNamespace getVariable ["gearLeader", "[]"];
    private _gearAT = profileNamespace getVariable ["gearAT", "[]"];
    private _gearAA = profileNamespace getVariable ["gearAA", "[]"];
    private _gearAR = profileNamespace getVariable ["gearAR", "[]"];

    private _loadouts = [_gearDefault, _gearLeader, _gearAT, _gearAA, _gearAR];

    {
        private _unitType = typeOf _x;
        private _type = 0;

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

        _x setUnitLoadout (parseSimpleArray ((_loadouts select _type) splitString " " joinString ""));
    } forEach _units;

    ["Loadouts applied"] call zen_common_fnc_showMessage;
}] call zen_custom_modules_fnc_register;
