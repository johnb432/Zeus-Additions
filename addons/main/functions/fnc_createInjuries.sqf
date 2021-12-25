#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds two modules that can create ACE medical injuries on units.
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

if (!GVAR(ACEMedicalLoaded)) exitWith {};

["Zeus Additions - Medical", "Create ACE Injuries", {
    params ["", "_unit"];

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if !(_unit isKindOf "CAManBase") exitWith {
         ["Select a unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    ["Create ACE Injuries", [
        ["TOOLBOX", "Damage Head", [0, 1, 3, ["Small/Minor", "Medium", "Large"]]],
        ["SLIDER", "Number of Wounds Head", [0, 20, 0, 0]],

        ["TOOLBOX", "Damage Torso", [0, 1, 3, ["Small/Minor", "Medium", "Large"]]],
        ["SLIDER", "Number of Wounds Torso", [0, 20, 0, 0]],

        ["TOOLBOX", "Damage Left Arm", [0, 1, 3, ["Small/Minor", "Medium", "Large"]]],
        ["SLIDER", "Number of Wounds Left Arm", [0, 20, 0, 0]],
        ["CHECKBOX", ["Set Fracture to Left Arm", "Forces a fracture to occur."], false],

        ["TOOLBOX", "Damage Right Arm", [0, 1, 3, ["Small/Minor", "Medium", "Large"]]],
        ["SLIDER", "Number of Wounds Right Arm", [0, 20, 0, 0]],
        ["CHECKBOX", ["Set Fracture to Right Arm", "Forces a fracture to occur."], false],

        ["TOOLBOX", "Damage Left Leg", [0, 1, 3, ["Small/Minor", "Medium", "Large"]]],
        ["SLIDER", "Number of Wounds Left Leg", [0, 20, 0, 0]],
        ["CHECKBOX", ["Set Fracture to Left Leg", "Forces a fracture to occur."], false],

        ["TOOLBOX", "Damage Right Leg", [0, 1, 3, ["Small/Minor", "Medium", "Large"]]],
        ["SLIDER", "Number of Wounds Right Leg", [0, 20, 0, 0]],
        ["CHECKBOX", ["Set Fracture to Right Leg", "Forces a fracture to occur."], false],

        ["TOOLBOX:WIDE", ["Wound Type", ""], [0, 1, 8, ["Abrasion", "Avulsion", "Contusion" ,"Crush", "Cut", "Laceration", "Velocity W.", "Puncture W."]], false]
    ],
    {
        params ["_results", "_unit"];

        private _formattedResults = [];
        private _temp = 0;

        // Iterate over results and copy all values except last one, so (count - 1) - 1 + 2 = count
        for "_i" from 0 to (count _results) step 1 do {
            // Add "false" to fractures to head and torso; easier for usage
            if (_i isEqualTo 2 || {_i isEqualTo 4}) then {
                _formattedResults pushBack false;
            };

            _temp = _results select _i;

            // If it's a number, round it; for number of wounds
            if (_temp isEqualType 0) then {
                _temp = round _temp;
            };

            _formattedResults pushBack _temp;
        };

        // Apply wounds using function
        [_unit, _formattedResults, _results select (count _results - 1)] call FUNC(createInjuriesHandler);

        // Notify the player if affected unit is a player; for fairness reasons
        if (isPlayer _unit) then {
            "Zeus has injured you using a module." remoteExecCall ["hint", _unit];
        };

        ["Injuries created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;

["Zeus Additions - Medical", "Create Random ACE Injuries", {
    params ["", "_unit"];

    // If opening on a vehicle
    _unit = effectiveCommander _unit;

    if !(_unit isKindOf "CAManBase") exitWith {
         ["Select a unit!"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
    };

    ["Create Random ACE Injuries", [
        ["SLIDER", ["Damage amount", "More damage will usually make more wounds. It can be lethal! Minor [0.25-0.5], Medium [0.5-0.75], Large [0.75+]"], [0, 20, 0, 2]],
        ["TOOLBOX:YESNO", ["Set Fracture to Left Arm", "Forces a fracture to occur. However fractures also occur if the right sort of damage is given."], false],
        ["TOOLBOX:YESNO", ["Set Fracture to Right Arm", "Forces a fracture to occur. However fractures also occur if the right sort of damage is given."], false],
        ["TOOLBOX:YESNO", ["Set Fracture to Left Leg", "Forces a fracture to occur. However fractures also occur if the right sort of damage is given."], false],
        ["TOOLBOX:YESNO", ["Set Fracture to Right Leg", "Forces a fracture to occur. However fractures also occur if the right sort of damage is given."], false],
        ["TOOLBOX:WIDE", ["Damage Type", "Various types of damages produce different results."], [0, 1, 6, ["Grenade", "Explosive", "Shell", "Vehicle Crash", "Collision", "Backblast"]]]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_damage", "_setFractureLeftArm", "_setFractureRightArm", "_setFractureLeftLeg", "_setFractureRightLeg", "_damageType"];

        if (_damage > 0) then {
            [_unit, _damage, selectRandom ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"], ["grenade", "explosive", "shell", "vehiclecrash", "collision", "backblast"] select _damageType] remoteExecCall ["ace_medical_fnc_addDamageToUnit", _unit];
        };

        private _runUpdateEffects = false;
        private _fractures = _unit getVariable ["ace_medical_fractures", [0, 0, 0, 0, 0, 0]];

        // Add fractures
        {
            if (_x) then {
                _fractures set [_forEachIndex + 2, 1];
                _runUpdateEffects = true;
            };
        } forEach [_setFractureLeftArm, _setFractureRightArm, _setFractureLeftLeg, _setFractureRightLeg];

        // Notify the player if affected unit is a player; for fairness reasons
        if (isPlayer _unit) then {
            "Zeus has injured you using a module." remoteExecCall ["hint", _unit];
        };

        if (_runUpdateEffects) then {
            _unit setVariable ["ace_medical_fractures", _fractures, true];
            [_unit] remoteExecCall ["ace_medical_engine_fnc_updateDamageEffects", _unit];
        };

        ["Random injuries created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
