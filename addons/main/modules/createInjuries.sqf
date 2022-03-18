/*
 * Author: johnb43
 * Adds two modules that can create ACE medical injuries on units.
 */

["Zeus Additions - Medical", "Create ACE Injuries", {
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

    ["Create ACE Injuries (Random Damage does not work on dead units!)", [
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

        ["TOOLBOX:WIDE", ["Wound Type", ""], [0, 1, 8, ["Abrasion", "Avulsion", "Contusion" ,"Crush", "Cut", "Laceration", "Velocity W.", "Puncture W."]], false],

        ["SLIDER", ["Random Damage Amount", "More damage will usually cause more wounds."], [0, 30, 0, 2]],
        ["TOOLBOX:WIDE", ["Random Damage Type", "Various types of damages produce different results."], [0, 1, 6, ["Grenade", "Explosive", "Shell", "Vehicle Crash", "Collision", "Backblast"]]]
    ],
    {
        params ["_results", "_unit"];

        private _formattedResults = [];
        private _temp = 0;

        for "_i" from 0 to 16 step 1 do {
            // Add "false" to fractures to head and torso; Easier for usage
            if (_i isEqualTo 2 || {_i isEqualTo 4}) then {
                _formattedResults pushBack false;
            };

            _temp = _results select _i;

            // If it's a number, round it; For number of wounds
            if (_temp isEqualType 0) then {
                _temp = round _temp;
            };

            _formattedResults pushBack _temp;
        };

        // Apply wounds using function
        [_unit, _formattedResults, _results select 16] call FUNC(createInjuriesHandler);

        // Apply random damage
        private _randomDamage = _results select 17;

        if (_randomDamage > 0 && {alive _unit}) then {
            [_unit, _randomDamage, selectRandom ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"], ["grenade", "explosive", "shell", "vehiclecrash", "collision", "backblast"] select (_results select 18)] remoteExecCall ["ace_medical_fnc_addDamageToUnit", _unit];
        };

        // Notify the player if affected unit is a player; For fairness reasons
        if (isPlayer _unit) then {
            "Zeus has injured you using a module." remoteExecCall ["hint", _unit];
        };

        ["Injuries created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
