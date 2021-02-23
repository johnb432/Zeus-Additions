#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds two modules that can create injuries on units.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_createInjuries;
 *
 * Public: No
 */

 ["Zeus Additions", "Create injuries", {
     params ["", "_unit"];

     if (isNull _unit) exitWith {
         ["You must select a unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
     };

     ["Create injuries", [
         ["TOOLBOX", "Damage Head", [0, 1, 3, ["Small/Minor", "Medium", "Large"]], false],
         ["SLIDER", ["Number of Wounds Head", ""], [0, 20, 0, 0]],

         ["TOOLBOX", "Damage Torso", [0, 1, 3, ["Small/Minor", "Medium", "Large"]], false],
         ["SLIDER", ["Number of Wounds Torso", ""], [0, 20, 0, 0]],

         ["TOOLBOX", "Damage Left Arm", [0, 1, 3, ["Small/Minor", "Medium", "Large"]], false],
         ["SLIDER", ["Number of Wounds Left Arm", ""], [0, 20, 0, 0]],
         ["CHECKBOX", ["Set Fracture to Left Arm", "Forces a fracture to occur."], false],

         ["TOOLBOX", "Damage Right Arm", [0, 1, 3, ["Small/Minor", "Medium", "Large"]], false],
         ["SLIDER", "Number of Wounds Right Arm", [0, 20, 0, 0]],
         ["CHECKBOX", ["Set Fracture to Right Arm", "Forces a fracture to occur."], false],

         ["TOOLBOX", "Damage Left Leg", [0, 1, 3, ["Small/Minor", "Medium", "Large"]], false],
         ["SLIDER", ["Number of Wounds Left Leg", ""], [0, 20, 0, 0]],
         ["CHECKBOX", ["Set Fracture to Left Leg", "Forces a fracture to occur."], false],

         ["TOOLBOX", "Damage Right Leg", [0, 1, 3, ["Small/Minor", "Medium", "Large"]], false],
         ["SLIDER", ["Number of Wounds Right Leg", ""], [0, 20, 0, 0]],
         ["CHECKBOX", ["Set Fracture to Right Leg", "Forces a fracture to occur."], false],

         ["TOOLBOX:WIDE", ["Wound Type", ""], [0, 1, 8, ["Abrasion","Avulsion","Contusion","Crush","Cut","Laceration","Velocity W.","Puncture W."]], false]
     ],
     {
         params ["_results", "_unit"];

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

["Zeus Additions", "[WIP] Create random injuries", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["You must select a unit!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Create random injuries", [
        ["SLIDER", ["Damage amount (Minor [0.25-0.5], Medium [0.5-0.75], Large [0.75+])", "More damage will usually make more wounds. It can be lethal!"], [0, 20, 0, 2]],
        ["CHECKBOX", ["Set Fracture to Left Arm", "Forces a fracture to occur. However fractures also occur if the right sort of damage is given."], false],
        ["CHECKBOX", ["Set Fracture to Right Arm", "Forces a fracture to occur. However fractures also occur if the right sort of damage is given."], false],
        ["CHECKBOX", ["Set Fracture to Left Leg", "Forces a fracture to occur. However fractures also occur if the right sort of damage is given."], false],
        ["CHECKBOX", ["Set Fracture to Right Leg", "Forces a fracture to occur. However fractures also occur if the right sort of damage is given."], false],
        ["LIST", ["Damage Type", "Various types of damages produce different results."], [
            ["grenade","explosive","shell","vehiclecrash","collision","backblast"],
            ["Grenade","Explosive","Shell","Vehicle Crash","Collision","Backblast"], 0]
        ]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_damage", "_setFractureLeftArm", "_setFractureRightArm", "_setFractureLeftLeg", "_setFractureRightLeg", "_damageType"];

        private _allBodyParts = ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"];
        private _fractureLimbs = [false, false, _setFractureLeftArm, _setFractureRightArm, _setFractureLeftLeg, _setFractureRightLeg];
        private _runUpdateEffects = false;
        private _fractures = _unit getVariable ["ace_medical_fractures", [0,0,0,0,0,0]];
        private _local = local _unit;

        if (_damage > 0) then {
            private _bodyPart = selectRandom _allBodyParts;

            if (_local) then {
                [_unit, _damage, _bodyPart, _damageType] call ace_medical_fnc_addDamageToUnit;
            } else {
                [_unit, _damage, _bodyPart, _damageType] remoteExec ["ace_medical_fnc_addDamageToUnit", _unit];
            };
        };

        {
            if (_x) then {
                _fractures set [(_forEachIndex + 2), 1];
                _runUpdateEffects = true;
            };
        } forEach [_setFractureLeftArm, _setFractureRightArm, _setFractureLeftLeg, _setFractureRightLeg];

        if (isPlayer _unit) then {
            ["Zeus has injured you using a module.", false, 10, 3] remoteExec ["ace_common_fnc_displayText", _unit];
        };

        if (_runUpdateEffects) then {
            _unit setVariable ["ace_medical_fractures", _fractures, true];

            if (_local) then {
                [_unit] call ace_medical_engine_fnc_updateDamageEffects;
            } else {
                [_unit] remoteExec ["ace_medical_engine_fnc_updateDamageEffects", _unit];
            };
        };

        ["Injuries created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
