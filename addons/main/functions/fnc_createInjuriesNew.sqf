#include "script_component.hpp"
/*
 * Author: johnb43
 * Adds a module that can create injuries on units.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_createInjuries;
 *
 * Public: No
 */

["Zeus Additions", "Create injuries", {
    params ["", "_unit"];

    ["Create injuries", [
        ["LIST", ["Damage Head", ""], [
            ["Minor","Medium","Large"],
            ["Small/Minor","Medium","Large"], 0, 3]],
        ["SLIDER", ["Number of Wounds Head", ""], [0, 20, 0, 0]],

        ["LIST", ["Damage Torso", ""], [
            ["Minor","Medium","Large"],
            ["Small/Minor","Medium","Large"], 0, 3]],
        ["SLIDER", ["Number of Wounds Torso", ""], [0, 20, 0, 0]],

        ["LIST", ["Damage Left Arm", ""], [
            ["Minor","Medium","Large"],
            ["Small/Minor","Medium","Large"], 0, 3]],
        ["SLIDER", ["Number of Wounds Left Arm", ""], [0, 20, 0, 0]],
        ["CHECKBOX", ["Set Fracture to Left Arm", "Forces a fracture to occur."], false],

        ["LIST", ["Damage Right Arm", ""], [
            ["Minor","Medium","Large"],
            ["Small/Minor","Medium","Large"], 0, 3]],
        ["SLIDER", ["Number of Wounds Right Arm", ""], [0, 20, 0, 0]],
        ["CHECKBOX", ["Set Fracture to Right Arm", "Forces a fracture to occur."], false],

        ["LIST", ["Damage Left Leg", ""], [
            ["Minor","Medium","Large"],
            ["Small/Minor","Medium","Large"], 0, 3]],
        ["SLIDER", ["Number of Wounds Left Leg", ""], [0, 20, 0, 0]],
        ["CHECKBOX", ["Set Fracture to Left Leg", "Forces a fracture to occur."], false],

        ["LIST", ["Damage Right Leg", ""], [
            ["Minor","Medium","Large"],
            ["Small/Minor","Medium","Large"], 0, 3]],
        ["SLIDER", ["Number of Wounds Right Leg", ""], [0, 20, 0, 0]],
        ["CHECKBOX", ["Set Fracture to Right Leg", "Forces a fracture to occur."], false],

        ["LIST", ["Wound Type", ""], [
            ["Abrasion","Avulsion","Contusion","Crush","Cut","Laceration","VelocityWound","PunctureWound"],
            ["Abrasion","Avulsion","Contusion","Crush","Cut","Laceration","Velocity Wound","Puncture Wound"], 0]
        ]
    ],
    {
        params ["_results", "_unit"];

        if (isNull _unit) exitWith {
            ["You must select a unit!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _formattedResults = [];

        // iterate over results and copy all values except last one, so (count - 1) - 1 + 2 = count
        for "_i" from 0 to (count _results) step 1 do {
            if (_i == 2 || {_i == 4}) then {
                _formattedResults pushBack false;
            };

            if ((_results select _i) isEqualType 0) then {
                _formattedResults pushBack (round (_results select _i));
            } else {
                _formattedResults pushBack (_results select _i);
            };
        };

        [_unit, _formattedResults, (_results select (count _results - 1))] call FUNC(woundsHandler);

        if (isPlayer _unit) then {
            ["Zeus has injured you using a module.", false, 10, 3] remoteExec ["ace_common_fnc_displayText", _unit];
        };

        ["Injuries created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
