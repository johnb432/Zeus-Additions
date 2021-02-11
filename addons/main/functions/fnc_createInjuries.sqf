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
        ["SLIDER", ["Damage Head", "Not all damage types will apply wounds to the selected bodyparts."], [0, 5, 0, 2]],
        ["SLIDER", ["Damage Torso", "Not all damage types will apply wounds to the selected bodyparts."], [0, 5, 0, 2]],
        ["SLIDER", ["Damage Left Arm", "Not all damage types will apply wounds to the selected bodyparts."], [0, 5, 0, 2]],
        ["CHECKBOX", ["Set Fracture to Left Arm", "Forces a fracture to occur. However fractures also occur if the right damage sort and value is given."], false],
        ["SLIDER", ["Damage Right Arm", "Not all damage types will apply wounds to the selected bodyparts."], [0, 5, 0, 2]],
        ["CHECKBOX", ["Set Fracture to Right Arm", "Forces a fracture to occur. However fractures also occur if the right damage sort and value is given."], false],
        ["SLIDER", ["Damage Left Leg", "Not all damage types will apply wounds to the selected bodyparts."], [0, 5, 0, 2]],
        ["CHECKBOX", ["Set Fracture to Left Leg", "Forces a fracture to occur. However fractures also occur if the right damage sort and value is given."], false],
        ["SLIDER", ["Damage Right Leg", "Not all damage types will apply wounds to the selected bodyparts."], [0, 5, 0, 2]],
        ["CHECKBOX", ["Set Fracture to Right Leg", "Forces a fracture to occur. However fractures also occur if the right damage sort and value is given."], false],
        ["LIST", ["Damage Type", "Various types of damages produce different results. Use 'Drowning' if you want to apply fractures only as it doesn't cause any damage."], [
            ["bullet","grenade","explosive","shell","vehiclecrash","collision","backblast","stab","punch","falling","ropeburn","drowning"],
            ["Bullet","Grenade","Explosive","Shell","Vehicle Crash","Collision","Backblast","Stab","Punch","Falling","Ropeburn","Drowning"], 0]
        ]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_damageHead", "_damageBody", "_damageLeftArm", "_setFractureLeftArm", "_damageRightArm", "_setFractureRightArm", "_damageLeftLeg", "_setFractureLeftLeg", "_damageRightLeg", "_setFractureRightLeg", "_damageType"];

        if (isNull _unit) exitWith {
            ["You must select a unit!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _allBodyParts = ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"];
        private _fractureLimbs = [false, false, _setFractureLeftArm, _setFractureRightArm, _setFractureLeftLeg, _setFractureRightLeg];
        private _runUpdateEffects = false;
        private _fractures = _unit getVariable ["ace_medical_fractures", [0,0,0,0,0,0]];

        {
            if (_x > 0) then {
                private _bodyPart = _allBodyParts select _forEachIndex;

                if (local _unit) then {
                    [_unit, _x, _bodyPart, _damageType] call ace_medical_fnc_addDamageToUnit;
                } else {
                    [_unit, _x, _bodyPart, _damageType] remoteExec ["ace_medical_fnc_addDamageToUnit", _unit/*, true*/];

                    if (isPlayer _unit) then {
                        ["Zeus has injured you using a module."] remoteExec ["hint", _unit];
                    };
                };
            };

            if (_fractureLimbs select _forEachIndex) then {
                _fractures set [_forEachIndex, 1];
                _runUpdateEffects = true;
            };
        } forEach [_damageHead, _damageBody, _damageLeftArm, _damageRightArm, _damageLeftLeg, _damageRightLeg];

        if (_runUpdateEffects) then {
            _unit setVariable ["ace_medical_fractures", _fractures, true];

            if (local _unit) then {
                [_unit] call ace_medical_engine_fnc_updateDamageEffects;
            } else {
                [_unit] remoteExec ["ace_medical_engine_fnc_updateDamageEffects", _unit/*, true*/];
            };
        };

        ["Injuries created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
