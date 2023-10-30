/*
 * Author: johnb43
 * Creates modules that can change dismount and turn out behaviour on AI.
 */

[LSTRING(moduleCategoryAI), LSTRING(aiBehaviourModuleName), {
    params ["", "_object"];

    if (isNull _object) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    if (!alive _object) exitWith {
        [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
    };

    if ((fullCrew [_object, "driver", true]) isEqualTo []) exitWith {
        [LSTRING_ZEN(modules,onlyVehicles)] call zen_common_fnc_showMessage;
    };

    [LSTRING(aiBehaviourModuleName), [
        ["TOOLBOX:ENABLED", [LSTRING(enablePassengerDismount), LSTRING(enablePassengerDismountDesc)], (getUnloadInCombat _object) select 0, true],
        ["TOOLBOX:ENABLED", [LSTRING(enableCrewDismount), LSTRING(enableCrewDismountDesc)], (getUnloadInCombat _object) select 1, true],
        ["TOOLBOX:ENABLED", [LSTRING(enableCrewStayImmobile), LSTRING(enableCrewStayImmobileDesc)], isAllowedCrewInImmobile _object, true],
        ["TOOLBOX:YESNO", [LSTRING(enableAiTurnOut), LSTRING(enableAiTurnOutDesc)], isNil {_object getVariable QGVAR(turnOutJIP)}, true]
    ], {
        params ["_results", "_object"];
        _results params ["_dismountPassengers", "_dismountCrew", "_stayCrew", "_allowTurnOut"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

        [_object, _stayCrew] remoteExecCall ["allowCrewInImmobile", _object];
        [[QGVAR(setUnloadInCombat), [_object, _dismountPassengers, _dismountCrew], QGVAR(setUnload_) + netId _object] call CBA_fnc_globalEventJIP, _object] call CBA_fnc_removeGlobalEventJIP;

        if (!_allowTurnOut) then {
            if (!isNil {_object getVariable QGVAR(turnOutJIP)}) exitWith {};

            if (isNil QFUNC(addBehaviourEh)) then {
                #include "module_behaviourCrew_init.sqf"
            };

            private _jipID = [QGVAR(addBehaviourEh), _object, QGVAR(addBehaviour_) + netId _object] call CBA_fnc_globalEventJIP;
            [_jipID, _object] call CBA_fnc_removeGlobalEventJIP;

            _object setVariable [QGVAR(turnOutJIP), _jipID, true];

            // Whenever a crew member mounts/dismounts, add/remove the EH
            _object remoteExecCall [QFUNC(addGetInOutEh), 2];
        } else {
            private _jipID = _object getVariable QGVAR(turnOutJIP);

            if (isNil "_jipID") exitWith {};

            // Remove JIP event
            _jipID call CBA_fnc_removeGlobalEventJIP;

            _object setVariable [QGVAR(turnOutJIP), nil, true];

            // Remove EH
            _object remoteExecCall [QFUNC(removeBehaviourEh), 0];

            // Remove EH on server
            _object remoteExecCall [QFUNC(removeGetInOutEh), 2];
        };

        private _behaviour = ["COMBAT", "AWARE"] select _allowTurnOut;

        _stayCrew = !_stayCrew;

        if (isNil QFUNC(setBehaviourVehicleCrew)) then {
            DFUNC(setBehaviourVehicleCrew) = [{
                params ["_object", "_unit", "_leaveCrew", "_allowTurnOut", "_behaviour"];

                if (!_allowTurnOut && {isTurnedOut _unit}) then {
                    _unit action ["TurnIn", _object];
                };

                _unit enableAIFeature ["AUTOCOMBAT", _leaveCrew || _allowTurnOut];
                _unit enableAIFeature ["FSM", _leaveCrew];
                _unit setCombatBehaviour _behaviour;
            }, true, true] call FUNC(sanitiseFunction);

            SEND_MP(setBehaviourVehicleCrew);
        };

        // ACE Vehicle Damage forces AI crew to dismount if critical hit; Can't be fixed until ACE adds something
        {
            [_object, _x, _stayCrew, _allowTurnOut, _behaviour] remoteExecCall [QFUNC(setBehaviourVehicleCrew), _x];
        } forEach ((crew _object) select {alive _x && {!isPlayer _x}});

        [LSTRING(changedAiBehaviourMessage)] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
