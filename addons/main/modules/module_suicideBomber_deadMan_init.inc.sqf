/*
 * Author: johnb43
 * Init for suicide bomber module.
 */

INFO_1("Running %1",__FILE__);

DFUNC(addSuicideEh) = [{
    private _unconEhID = if (!isNil "ace_medical_status") then {
        // ACE Medical
        ["ace_unconscious", {
            params ["_unit", "_unconscious"];

            if (!local _unit || {!_unconscious}) exitWith {};

            _thisArgs params ["_target"];

            if (_unit != _target) exitWith {};

            [{
                params ["_unit"];

                // Detonate explosives
                {
                    _x setDamage 1;
                } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                // Remove JIP, action and EHs
                _unit call FUNC(removeSuicideBomberIDs);
            }, _this, random 2] call CBA_fnc_waitAndExecute;
        }, [_this]] call CBA_fnc_addEventHandlerArgs;
    } else {
        // Vanilla
        _this addEventHandler ["HandleDamage", {
            params ["_unit"];

            if (!local _unit || {lifeState _unit != "INCAPACITATED"}) exitWith {};

            [{
                params ["_unit"];

                // Detonate explosives
                {
                    _x setDamage 1;
                } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                // Remove JIP, action and EHs
                _unit call FUNC(removeSuicideBomberIDs);
            }, _this, random 2] call CBA_fnc_waitAndExecute;
        }];
    };

    _this setVariable [QGVAR(suicideBomberDeadManSwitchEhIDs), [
        _unconEhID,
        _this addEventHandler ["Killed", {
            [{
                params ["_unit"];

                if (!local _unit) exitWith {};

                // Detonate explosives
                {
                    _x setDamage 1;
                } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                // Remove JIP, action and EHs
                _unit call FUNC(removeSuicideBomberIDs);
            }, _this, random 2] call CBA_fnc_waitAndExecute;
        }]
    ]];
}, true] call FUNC(sanitiseFunction);

SEND_MP(addSuicideEh);
