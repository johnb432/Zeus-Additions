#include "..\script_component.hpp"
/*
 * Author: Glowbal, commy2, johnb43
 * Handling of the open wounds & injuries upon the handleDamage eventhandler.
 * Based off of ACE3's ace_medical_damage_fnc_woundsHandlerSQF. For ACE 3.16.0+.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Arrays of wound size, number of wounds and fracture for each body part <ARRAY>
 * 2: Type of wound <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player,
 *    [[0, 4, false], [0, 0, false], [0, 0, false], [0, 0, false], [0, 0, false], [0, 0, false]],
 * "Avulsion"] call zeus_additions_main_fnc_createInjuriesHandler
 * --> 4 Minor avulsions to the Head
 *
 * Public: No
 */

params ["_unit", "_allDamages", "_woundTypeToAdd"];

if !(isDamageAllowed _unit && {_unit getVariable ["ace_medical_allowDamage", true]}) exitWith {};

// Administration for open wounds and ids
private _openWounds = _unit getVariable ["ace_medical_openWounds", createHashMap];

private _createdWounds = false;
private _updateDamageEffects = false;
private _painLevel = 0;
private _criticalDamage = false;
private _bodyPartDamage = _unit getVariable ["ace_medical_bodyPartDamage", [0, 0, 0, 0, 0, 0]];
private _bodyPartVisParams = [_unit, false, false, false, false]; // params array for EFUNC(medical_engine,updateBodyPartVisuals);
private _bodyParts = ["head", "body", "leftarm", "rightarm", "leftleg", "rightleg"];

// Process wounds separately for each body part
{
    _x params ["_category", "_woundNumber", "_doFracture"];

    private _bodyPart = _bodyParts select _forEachIndex;
    private _bodyPartNToAdd = _forEachIndex;

    // If forced fracture
    if (_doFracture) then {
        private _fractures = _unit getVariable ["ace_medical_fractures", [0, 0, 0, 0, 0, 0]];
        _fractures set [_bodyPartNToAdd, 1];
        _unit setVariable ["ace_medical_fractures", _fractures, true];

        ["ace_medical_fracture", [_unit, _bodyPartNToAdd]] call CBA_fnc_localEvent;

        _updateDamageEffects = true;
    };

    for "_i" from 1 to _woundNumber do {
        // Large wounds are > LARGE_WOUND_THRESHOLD
        // Medium is > LARGE_WOUND_THRESHOLD^2
        // Minor is > LARGE_WOUND_THRESHOLD^3

        // Add a bit of random variance to wounds
        private _dmgPerWound = (random [0.5, 0.75, 1]) / ([4, 2, 1] select _category);
        private _woundDamage = _dmgPerWound * random [0.9, 1, 1.1];
        private _woundSize = _woundDamage * 2;

        (ace_medical_damage_woundDetails get _woundTypeToAdd) params ["", "_injuryBleedingRate", "_injuryPain", "_causeLimping", "_causeFracture"];

        _bodyPartDamage set [_bodyPartNToAdd, (_bodyPartDamage select _bodyPartNToAdd) + _woundDamage];
        _bodyPartVisParams set [[1, 2, 3, 3, 4, 4] select _bodyPartNToAdd, true]; // Mark the body part index needs updating

        private _pain = _woundSize * _injuryPain;
        _painLevel = _painLevel + _pain;

        private _bleeding = _woundSize * _injuryBleedingRate;

        private _woundClassIDToAdd = ace_medical_damage_woundClassNames find _woundTypeToAdd;
        private _classComplex = 10 * _woundClassIDToAdd + _category;

        // Create a new injury; Format: [0:classComplex, 1:amountOf, 2:bleedingRate, 3:woundDamage]
        private _injury = [_classComplex, 1, _bleeding, _woundDamage];

        if (_bodyPart == "head" || {_bodyPart == "body" && {_woundDamage > ace_medical_const_penetrationThreshold}}) then {
            _criticalDamage = true;
        };

        if ([_unit, _bodyPartNToAdd, _bodyPartDamage, _woundDamage] call ace_medical_damage_fnc_determineIfFatal) then {
            if (!isPlayer _unit || {random 1 < ace_medical_deathChance}) then {
                ["ace_medical_fatalInjury", _unit] call CBA_fnc_localEvent;
            };
        };

        switch (true) do {
            case (
                !_doFracture &&
                {_causeFracture} &&
                {ace_medical_fractures > 0} &&
                {_bodyPartNToAdd > 1} &&
                {_woundDamage > ace_medical_const_fractureDamageThreshold} &&
                {random 1 < ace_medical_fractureChance}
            ): {
                private _fractures = _unit getVariable ["ace_medical_fractures", [0, 0, 0, 0, 0, 0]];
                _fractures set [_bodyPartNToAdd, 1];
                _unit setVariable ["ace_medical_fractures", _fractures, true];

                ["ace_medical_fracture", [_unit, _bodyPartNToAdd]] call CBA_fnc_localEvent;

                _updateDamageEffects = true;
            };
            case (
                _causeLimping &&
                {ace_medical_limping > 0} &&
                {_bodyPartNToAdd > 3} &&
                {_woundDamage > ace_medical_const_limpingDamageThreshold}
            ): {
                _updateDamageEffects = true;
            };
        };

        // If possible merge into existing wounds
        private _createNewWound = true;
        private _existingWounds = _openWounds getOrDefault [_bodyPart, [], true];

        {
            _x params ["_classID", "_oldAmountOf", "_oldBleeding", "_oldDamage"];

            if (
                (_classComplex == _classID) &&
                {(_bodyPart != "body") || {(_woundDamage < ace_medical_const_penetrationThreshold) == (_oldDamage < ace_medical_const_penetrationThreshold)}} && // penetrating body damage is handled differently
                {(_bodyPartNToAdd > 3) || {!_causeLimping} || {(_woundDamage <= ace_medical_const_limpingDamageThreshold) == (_oldDamage <= ace_medical_const_limpingDamageThreshold)}} // ensure limping damage is stacked correctly
            ) exitWith {
                private _newAmountOf = _oldAmountOf + 1;
                _x set [1, _newAmountOf];

                private _newBleeding = (_oldAmountOf * _oldBleeding + _bleeding) / _newAmountOf;
                _x set [2, _newBleeding];

                private _newDamage = (_oldAmountOf * _oldDamage + _woundDamage) / _newAmountOf;
                _x set [3, _newDamage];

                _createNewWound = false;
            };
        } forEach _existingWounds;

        if (_createNewWound) then {
            _existingWounds pushBack _injury;
        };

        _createdWounds = true;
    };
} forEach _allDamages;

// Add fractures to unit if necessary
if (_updateDamageEffects) then {
    _unit call ace_medical_engine_fnc_updateDamageEffects;
};

// Update damage and wounds
if (_createdWounds) then {
    _unit setVariable ["ace_medical_openWounds", _openWounds, true];
    _unit setVariable ["ace_medical_bodyPartDamage", _bodyPartDamage, true];

    _unit call ace_medical_status_fnc_updateWoundBloodLoss;

    _bodyPartVisParams call ace_medical_engine_fnc_updateBodyPartVisuals;

    ["ace_medical_injured", [_unit, _painLevel]] call CBA_fnc_localEvent;

    if (_critialDamage || {_painLevel > ace_medical_const_painUnconscious}) then {
        _unit call ace_medical_damage_fnc_handleIncapacitation;
    };
};
