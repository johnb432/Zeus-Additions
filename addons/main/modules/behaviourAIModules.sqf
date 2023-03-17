/*
 * Author: johnb43
 * Creates modules that can change dismount and turn out behaviour on AI.
 */

["Zeus Additions - AI", "Change AI Crew Behaviour", {
    params ["", "_object"];

    if (isNull _object) exitWith {
        ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
    };

    if (!alive _object) exitWith {
        ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
    };

    if ((fullCrew [_object, "driver", true]) isEqualTo []) exitWith {
        ["STR_ZEN_Modules_OnlyVehicles"] call zen_common_fnc_showMessage;
    };

    ["Change AI Crew Behaviour", [
        ["TOOLBOX:ENABLED", ["Passenger dismount in combat", "Allow passengers to dismount while in combat."], (getUnloadInCombat _object) select 0, true],
        ["TOOLBOX:ENABLED", ["Crew dismount in combat", "Allow crews to dismount while in combat."], (getUnloadInCombat _object) select 1, true],
        ["TOOLBOX:ENABLED", ["Crew stay in immobile vehicles", "Allow crews to stay in immobile vehicles. THIS DOES NOT WORK IF ACE VEHICLE DAMAGE IS ENABLED."], isAllowedCrewInImmobile _object, true],
        ["TOOLBOX:YESNO", ["Allow AI to Turn Out", "Makes the AI able to turn out or not."], isNil {_object getVariable QGVAR(turnOutJIP)}, true]
    ], {
        params ["_results", "_object"];
        _results params ["_dismountPassengers", "_dismountCrew", "_stayCrew", "_allowTurnOut"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            ["STR_ZEN_Modules_NoObjectSelected"] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            ["STR_ZEN_Modules_OnlyAlive"] call zen_common_fnc_showMessage;
        };

        // Execute where vehicle is local
        ["zen_common_execute", [{
            params ["_object", "_dismountPassengers", "_dismountCrew", "_stayCrew"];

            _object setUnloadInCombat [_dismountPassengers, _dismountCrew];
            _object allowCrewInImmobile _stayCrew;
        }, [_object, _dismountPassengers, _dismountCrew, _stayCrew]], _object] call CBA_fnc_targetEvent;

        if (!_allowTurnOut) then {
            if (!isNil {_object getVariable QGVAR(turnOutJIP)}) exitWith {};

            private _jipID = ["zen_common_execute", [{
                // Add handle damage EH to every client and JIP
                _this setVariable [QGVAR(turnOutEhIDs),
                    _this addEventHandler ["TurnOut", {
                        params ["_object", "_unit"];

                        if (!local _unit || {isPlayer _unit} || {call CBA_fnc_currentUnit == _unit}) exitWith {};

                        // Make the unit turn in
                        _unit action ["TurnIn", _object];
                    }],
                    ["zen_remoteControlStopped", {
                        params ["_unit"];
                        _thisArgs params ["_object"];

                        if (!local _unit || {!(_unit in _object)} || {!isTurnedOut _unit}) exitWith {};

                        // Make the unit turn in
                        _unit action ["TurnIn", _object];
                    }, [_object]] call CBA_fnc_addEventHandlerArgs
                ];
            }, _object]] call CBA_fnc_globalEventJIP;

            _object setVariable [QGVAR(turnOutJIP), _jipID, true];

            // In case object is deleted
            [_jipID, _object] call CBA_fnc_removeGlobalEventJIP;
        } else {
            if (isNil {_object getVariable QGVAR(turnOutJIP)}) exitWith {};

            // Remove JIP event
            _jipID call CBA_fnc_removeGlobalEventJIP;

            _object setVariable [QGVAR(turnOutJIP), nil, true];

            ["zen_common_execute", [{
                // Remove handle damage EH for object
                (_this getVariable [QGVAR(turnOutEhIDs), []]) params ["_turnOutEhID", "_stoppedRemoteControlEhID"];

                if (isNil "_turnOutEhID") exitWith {};

                _this removeEventHandler ["TurnOut", _turnOutEhID];
                ["zen_remoteControlStopped", _stoppedRemoteControlEhID] call CBA_fnc_removeEventHandler;

                _this setVariable [QGVAR(turnOutEhIDs), nil];
            }, _object]] call CBA_fnc_globalEvent;
        };

        private _behaviour = ["COMBAT", "SAFE"] select _stayCrew;

        _stayCrew = !_stayCrew;

        // ACE Vehicle Damage forces AI crew to dismount if critical hit; Can't be fixed until ACE adds something
        {
            // Execute where AI is local
            ["zen_common_execute", [{
                params ["_object", "_unit", "_stayCrew", "_allowTurnOut", "_behaviour"];

                if (!_allowTurnOut && {isTurnedOut _unit}) then {
                    _unit action ["TurnIn", _object];
                };

                _unit enableAIFeature ["AUTOCOMBAT", _stayCrew || _allowTurnOut];
                _unit enableAIFeature ["FSM", _stayCrew];
                _unit setBehaviour _behaviour;
                _unit setCombatBehaviour _behaviour;
            }, [_object, _x, _stayCrew, _allowTurnOut, _behaviour]], _x] call CBA_fnc_targetEvent;
        } forEach ((crew _object) select {alive _x && {!isPlayer _x}});

        ["Changed crew behaviour on vehicle"] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
