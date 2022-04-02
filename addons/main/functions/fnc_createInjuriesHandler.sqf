#include "script_component.hpp"

/*
 * Author: Glowbal, commy2, johnb43
 * Handling of the open wounds & injuries upon the handleDamage eventhandler.
 * Based off of ACE3's ace_medical_damage_fnc_woundsHandlerSQF.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Array of wound size, number of wounds and fracture for each body part <ARRAY>
 * 2: Type of wound <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player,
 *    [0, 4, false, 0, 0, false, 0, 0, false, 0, 0, false, 0, 0, false, 0, 0, false],
 * 1] call zeus_additions_main_fnc_createInjuriesHandler
 * --> 4 Minor avulsions to the Head
 *
 * Public: No
 */

params ["_unit", "_args", "_woundClassIDToAdd"];

// Administration for open wounds and ids
private _openWounds = _unit getVariable ["ace_medical_openWounds", []];

// Get wound information (since only 1 type of wound can be applied at a time)
private _damageType = ["Abrasion","Avulsion","Contusion","Crush","Cut","Laceration","VelocityWound","PunctureWound"] select _woundClassIDToAdd;
private _injuryBleedingRate = getNumber (configFile >> "ACE_Medical_Injuries" >> "wounds" >> _damageType >> "bleeding");
private _injuryPain = getNumber (configFile >> "ACE_Medical_Injuries" >> "wounds" >> _damageType >> "pain");

// Various things to update after having taken damage and fractures
private _updateDamageEffects = false;
private _painLevel = 0;
private _critialDamage = false;
private _bodyPartDamage = _unit getVariable ["ace_medical_bodyPartDamage", [0, 0, 0, 0, 0, 0]];
private _bodyPartVisParams = [_unit, false, false, false, false]; // params array for EFUNC(medical_engine,updateBodyPartVisuals);
private _fractures = _unit getVariable ["ace_medical_fractures", [0, 0, 0, 0, 0, 0]];

// For every bunch of 3 arguments
for "_i" from 0 to (count _args - 3) step 3 do {
    private _woundSize = _args select _i;
    private _woundNumber = _args select (_i + 1);
    private _doFracture = _args select (_i + 2);

    private _bodyPartNToAdd = _i / 3;

    if (_woundNumber > 0) then {
        private _woundDamage = 0.25 + (_woundSize * 0.25); // wound category (minor [0.25-0.5], medium [0.5-0.75], large [0.75+])

        _bodyPartDamage set [_bodyPartNToAdd, (_bodyPartDamage select _bodyPartNToAdd) + _woundDamage];
        _bodyPartVisParams set [[1, 2, 3, 3, 4, 4] select _bodyPartNToAdd, true]; // Mark the body part index needs updating

        // Damage to limbs/head is scaled higher than torso by engine
        // Anything above this value is guaranteed worst wound possible
        private _worstDamage = [2, 1, 4, 4, 4, 4] select _bodyPartNToAdd;

        // More wounds means more likely to get nasty wound
        private _countModifier = 1 + random (_woundNumber - 1);

        // Config specifies bleeding and pain for worst possible wound
        // Worse wound correlates to higher damage, damage is not capped at 1
        private _bleedModifier = linearConversion [0.1, _worstDamage, _woundDamage * _countModifier, 0.25, 1, true];
        private _painModifier = (_bleedModifier * random [0.7, 1, 1.3]) min 1; // Pain isn't directly scaled to bleeding

        private _bleeding = _injuryBleedingRate * _bleedModifier;
        _painLevel = _painLevel + (_injuryPain * _painModifier);

        private _classComplex = 10 * _woundClassIDToAdd + _woundSize;

        // Create a new injury. Format [0:classComplex, 1:bodypart, 2:amountOf, 3:bleedingRate, 4:woundDamage]
        private _injury = [_classComplex, _bodyPartNToAdd, _woundNumber, _bleeding, _woundDamage];

        if (_bodyPartNToAdd isEqualTo 0 || {_bodyPartNToAdd isEqualTo 1 && {_woundDamage > ace_medical_const_penetrationThreshold}}) then {
            _critialDamage = true;
        };

        // if possible merge into existing wounds
        private _createNewWound = true;
        {
            _x params ["_classID", "_bodyPartN", "_oldAmountOf", "_oldBleeding", "_oldDamage"];

            // penetrating body damage is handled differently
            if ((_classComplex isEqualTo _classID) && {_bodyPartNToAdd isEqualTo _bodyPartN} && {(_bodyPartNToAdd isNotEqualTo 1) || {(_woundDamage < ace_medical_const_penetrationThreshold) isEqualTo (_oldDamage < ace_medical_const_penetrationThreshold)}}) exitWith { // don't want/care limping
                private _newAmountOf = _oldAmountOf + _woundNumber;
                _x set [2, _newAmountOf];
                _x set [3, ((_oldAmountOf * _oldBleeding + _bleeding) / _newAmountOf)]; // new bleeding
                _x set [4, ((_oldAmountOf * _oldDamage + _woundDamage) / _newAmountOf)]; // new damage
                _createNewWound = false;
            };
        } forEach _openWounds;

        if (_createNewWound) then {
            _openWounds pushBack _injury;
        };
    };

    if (_doFracture) then {
        _fractures set [_bodyPartNToAdd, 1];

        ["ace_medical_fracture", [_unit, _bodyPartNToAdd], _unit] call CBA_fnc_targetEvent;
        _updateDamageEffects = true;
    };
};

// Add fractures to unit if necessary
if (_updateDamageEffects) then {
    _unit setVariable ["ace_medical_fractures", _fractures, true];

    [_unit] remoteExecCall ["ace_medical_engine_fnc_updateDamageEffects", _unit];
};

// Update damage and wounds
_unit setVariable ["ace_medical_openWounds", _openWounds, true];
_unit setVariable ["ace_medical_bodyPartDamage", _bodyPartDamage, true];

[_unit] remoteExecCall ["ace_medical_status_fnc_updateWoundBloodLoss", _unit];
_bodyPartVisParams remoteExecCall ["ace_medical_engine_fnc_updateBodyPartVisuals", _unit];
["ace_medical_injured", [_unit, _painLevel], _unit] call CBA_fnc_targetEvent;

if (_critialDamage || {_painLevel > ace_medical_const_painUnconscious}) then {
    [_unit] remoteExecCall ["ace_medical_damage_fnc_handleIncapacitation", _unit];
};
