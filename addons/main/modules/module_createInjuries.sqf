/*
 * Author: johnb43
 * Adds a module that can create ACE medical injuries on units.
 */

[LSTRING(moduleCategoryMedical), LSTRING(createInjuriesModuleName), {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
    };

    // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
    if (alive _unit) then {
        _unit = effectiveCommander _unit;
    };

    // Can be applied to dead units too!
    if !(_unit isKindOf "CAManBase" && {getNumber ((configOf _unit) >> "isPlayableLogic") == 0}) exitWith {
        [LSTRING_ZEN(modules,onlyInfantry)] call zen_common_fnc_showMessage;
    };

    [LSTRING(createInjuriesModuleName), [
        ["TOOLBOX", LSTRING_ACE(medical_GUI,head), [0, 1, 3, [LSTRING_ACE(medical_GUI,small), LSTRING_ACE(medical_GUI,medium), LSTRING_ACE(medical_GUI,large)]]],
        ["SLIDER", "str_a3_cfgvehicles_moduleanimals_f_arguments_count", [0, 20, 0, 0]],

        ["TOOLBOX", LSTRING_ACE(medical_GUI,torso), [0, 1, 3, [LSTRING_ACE(medical_GUI,small), LSTRING_ACE(medical_GUI,medium), LSTRING_ACE(medical_GUI,large)]]],
        ["SLIDER", "str_a3_cfgvehicles_moduleanimals_f_arguments_count", [0, 20, 0, 0]],

        ["TOOLBOX", LSTRING_ACE(medical_GUI,leftArm), [0, 1, 3, [LSTRING_ACE(medical_GUI,small), LSTRING_ACE(medical_GUI,medium), LSTRING_ACE(medical_GUI,large)]]],
        ["SLIDER", "str_a3_cfgvehicles_moduleanimals_f_arguments_count", [0, 20, 0, 0]],
        ["CHECKBOX", [LSTRING_ACE(medical_GUI,status_fractured), LSTRING(createInjuriesForceFracturesDesc)], false],

        ["TOOLBOX", LSTRING_ACE(medical_GUI,rightArm), [0, 1, 3, [LSTRING_ACE(medical_GUI,small), LSTRING_ACE(medical_GUI,medium), LSTRING_ACE(medical_GUI,large)]]],
        ["SLIDER", "str_a3_cfgvehicles_moduleanimals_f_arguments_count", [0, 20, 0, 0]],
        ["CHECKBOX", [LSTRING_ACE(medical_GUI,status_fractured), LSTRING(createInjuriesForceFracturesDesc)], false],

        ["TOOLBOX", LSTRING_ACE(medical_GUI,leftLeg), [0, 1, 3, [LSTRING_ACE(medical_GUI,small), LSTRING_ACE(medical_GUI,medium), LSTRING_ACE(medical_GUI,large)]]],
        ["SLIDER", "str_a3_cfgvehicles_moduleanimals_f_arguments_count", [0, 20, 0, 0]],
        ["CHECKBOX", [LSTRING_ACE(medical_GUI,status_fractured), LSTRING(createInjuriesForceFracturesDesc)], false],

        ["TOOLBOX", LSTRING_ACE(medical_GUI,rightLeg), [0, 1, 3, [LSTRING_ACE(medical_GUI,small), LSTRING_ACE(medical_GUI,medium), LSTRING_ACE(medical_GUI,large)]]],
        ["SLIDER", "str_a3_cfgvehicles_moduleanimals_f_arguments_count", [0, 20, 0, 0]],
        ["CHECKBOX", [LSTRING_ACE(medical_GUI,status_fractured), LSTRING(createInjuriesForceFracturesDesc)], false],

        ["LIST", "str_a3_cfgvehicles_moduleendmission_f_arguments_type", [ace_medical_damage_woundClassNames, ace_medical_damage_woundClassNames apply {localize format ["STR_ACE_Medical_Damage_%1", _x]}, 0, count ace_medical_damage_woundClassNames min 3], false],

        ["SLIDER", [LSTRING(createInjuriesRandomDamage), LSTRING(createInjuriesRandomDamageDesc)], [0, 5, 0, 2]],
        ["SLIDER", "str_a3_cfgvehicles_moduleanimals_f_arguments_count", [0, 20, 0, 0]],
        ["TOOLBOX:WIDE", [LSTRING(createInjuriesRandomDamageType), LSTRING(createInjuriesRandomDamageTypeDesc)], [0, 1, 6, [
            LSTRING(createInjuriesRandomDamageTypeGrenade),
            LSTRING(createInjuriesRandomDamageTypeExplosive),
            LSTRING(createInjuriesRandomDamageTypeShell),
            LSTRING(createInjuriesRandomDamageTypeVehicleCrash),
            LSTRING(createInjuriesRandomDamageTypeCollision),
            LSTRING(createInjuriesRandomDamageTypeBackblast)
        ]]]
    ], {
        params ["_results", "_unit"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _unit) exitWith {
            [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
        };

        // Only send function to all clients if script is enabled
        if (isNil QFUNC(createInjuriesHandler)) then {
            PREP_SEND_MP(createInjuriesHandler);
        };

        _results insert [4, [false], false];
        _results insert [2, [false], false];

        private _formattedResults = [];

        for "_i" from 0 to 5 step 1 do {
            // Round number of wounds
            _formattedResults pushBack [_results select (_i * 3), round (_results select (_i * 3 + 1)), _results select (_i * 3 + 2)];
        };

        // Apply wounds using function
        [QGVAR(executeFunction), [QFUNC(createInjuriesHandler), [_unit, _formattedResults, _results select -4]], _unit] call CBA_fnc_targetEvent;

        // Apply random damage
        private _randomDamage = _results select -3;
        private _randomNumberWounds = round (_results select -2);

        if (_randomDamage > 0 && {_randomNumberWounds > 0}) then {
            ["zen_common_execute", [{
                params ["_unit", "_randomNumberWounds", "_randomDamage", "_damageType"];

                if !(isDamageAllowed _unit && {_unit getVariable ["ace_medical_allowDamage", true]}) exitWith {};

                for "_i" from 0 to _randomNumberWounds step 1 do {
                    ["ace_medical_woundReceived", [_unit, [[_randomDamage, selectRandom ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"], _randomDamage]], objNull, _damageType]] call CBA_fnc_localEvent;
                };
            } call FUNC(sanitiseFunction), [_unit, _randomNumberWounds, _randomDamage, ["grenade", "explosive", "shell", "vehiclecrash", "collision", "backblast"] select (_results select -1)]], _unit] call CBA_fnc_targetEvent;
        };

        [LSTRING(createInjuriesMessage)] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
