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

["Zeus Additions", "Loadout: Set", {
    ["Set Loadout (Uses ACE arsenal export format)", [
        ["EDIT", ["Default", "Riflemen, Crew, etc. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearDefault),"[]"), true],
        ["EDIT", ["Leader", "Squad leaders, Team leaders. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearLeader),"[]"), true],
        ["EDIT", ["AT", "Anti-tank gunners, Anti-tank assistants. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearAT),"[]"), true],
        ["EDIT", ["AA", "Anti-air operators, Anti-air assistants. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearAA),"[]"), true],
        ["EDIT", ["AR", "Autoriflemen, Machine Gunners. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearAR),"[]"), true],
        ["EDIT", ["Medic", "Medics, Combat Life Savers. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearMedic),"[]"), true],
        ["EDIT", ["Engineer", "Engineers, Demo. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearEngineer),"[]"), true],
        ["EDIT", ["Single Unit", "Use this line to apply with Gear Set to Single Unit. Delete empty array and paste loadout then."], GETPRVAR(QGVAR(gearSingle),"[]"), true],
        ["CHECKBOX", ["Reset saved loadouts", "Resets saved loadouts (clears window on next open)."], false, true]
    ], {
        params ["_results"];

        if (_results select (count _results - 1)) exitWith {
            {
                SETPRVAR(_x,"[]");
            } forEach [QGVAR(gearDefault), QGVAR(gearLeader), QGVAR(gearAT), QGVAR(gearAA), QGVAR(gearAR), QGVAR(gearMedic), QGVAR(gearEngineer), QGVAR(gearSingle)];

            ["Loadouts reset"] call zen_common_fnc_showMessage;
        };

        _results deleteAt (count _results - 1);

        {
            if (_x == "") then {
                _results set [_forEachIndex, "[]"];
            };
        } forEach _results;

        {
            SETPRVAR(_x, _results select _forEachIndex);
        } forEach [QGVAR(gearDefault), QGVAR(gearLeader), QGVAR(gearAT), QGVAR(gearAA), QGVAR(gearAR), QGVAR(gearMedic), QGVAR(gearEngineer), QGVAR(gearSingle)];

        ["Loadouts saved"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions", "Loadout: Apply to single unit", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["No unit was selected!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    private _loadoutString = GETPRVAR(QGVAR(gearSingle),"[]");

    if (_loadoutString == "[]") then {
        _loadoutString =
        [
            GETPRVAR(QGVAR(gearDefault),"[]"),
            GETPRVAR(QGVAR(gearLeader),"[]"),
            GETPRVAR(QGVAR(gearAT),"[]"),
            GETPRVAR(QGVAR(gearAA),"[]"),
            GETPRVAR(QGVAR(gearAR),"[]"),
            GETPRVAR(QGVAR(gearMedic),"[]"),
            GETPRVAR(QGVAR(gearEngineer),"[]")
        ] select (_unit call FUNC(getRole));
     };

    _unit setUnitLoadout (parseSimpleArray (_loadoutString splitString " " joinString ""));

    ["Loadout applied"] call zen_common_fnc_showMessage;
}] call zen_custom_modules_fnc_register;

["Zeus Additions", "Loadout: Apply to group", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["No unit was selected!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    private _units = units group _unit;

    private _loadouts = [
        GETPRVAR(QGVAR(gearDefault),"[]"),
        GETPRVAR(QGVAR(gearLeader),"[]"),
        GETPRVAR(QGVAR(gearAT),"[]"),
        GETPRVAR(QGVAR(gearAA),"[]"),
        GETPRVAR(QGVAR(gearAR),"[]"),
        GETPRVAR(QGVAR(gearMedic),"[]"),
        GETPRVAR(QGVAR(gearEngineer),"[]")
    ];

    {
        _x setUnitLoadout (parseSimpleArray ((_loadouts select (_x call FUNC(getRole))) splitString " " joinString ""));
    } forEach _units;

    ["Loadouts applied"] call zen_common_fnc_showMessage;
}] call zen_custom_modules_fnc_register;
