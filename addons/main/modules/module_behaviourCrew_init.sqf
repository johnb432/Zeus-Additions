/*
 * Author: johnb43
 * Init for crew behaviour module.
 */

INFO_1("Running %1",__FILE__);

DFUNC(addBehaviourEh) = [{
    params ["_vehicle"];

    if (!isNil {_vehicle getVariable QGVAR(turnOutEhIDs)}) exitWith {};

    _vehicle setVariable [QGVAR(turnOutEhIDs), [
        _vehicle addEventHandler ["TurnOut", {
            params ["_vehicle", "_unit"];

            if (!local _unit || {isPlayer _unit} || {call CBA_fnc_currentUnit == _unit}) exitWith {};

            // Make the unit turn in
            _unit action ["TurnIn", _vehicle];
            _unit setCombatBehaviour "COMBAT";
        }],
        _vehicle addEventHandler ["Killed", {
            params ["_vehicle"];

            if (!local _vehicle) exitWith {};

            _vehicle call FUNC(removeAiCrewBehaviour);
        }],
        _vehicle addEventHandler ["Deleted", {
            params ["_vehicle"];

            if (!local _vehicle) exitWith {};

            _vehicle call FUNC(removeAiCrewBehaviour);
        }],
        ["zen_remoteControlStopped", {
            params ["_unit"];

            if (!local _unit || {!(_unit in _thisArgs)} || {!isTurnedOut _unit}) exitWith {};

            // Make the unit turn in
            _unit action ["TurnIn", _thisArgs];
            _unit setCombatBehaviour "COMBAT";
        }, _vehicle] call CBA_fnc_addEventHandlerArgs
    ]];
}, true] call FUNC(sanitiseFunction);

DFUNC(removeBehaviourEh) = [{
    params ["_vehicle"];

    private _ehIDs = _vehicle getVariable QGVAR(turnOutEhIDs);

    if (isNil "_ehIDs") exitWith {};

    _vehicle removeEventHandler ["TurnOut", _ehIDs select 0];
    _vehicle removeEventHandler ["Killed", _ehIDs select 1];
    _vehicle removeEventHandler ["Deleted", _ehIDs select 2];
    ["zen_remoteControlStopped", _ehIDs select 3] call CBA_fnc_removeEventHandler;

    _vehicle setVariable [QGVAR(turnOutEhIDs), nil];
}, true] call FUNC(sanitiseFunction);

DFUNC(removeAiCrewBehaviour) = [{
    params ["_vehicle"];

    private _jipID = _vehicle getVariable QGVAR(turnOutJIP);

    if (isNil "_jipID") exitWith {};

    // FUNC(removeGlobalEventJIP) not guaranteed to exist on clients
    [QGVAR(removeEventJIP), [_jipID, objNull]] call CBA_fnc_serverEvent;

    _vehicle setVariable [QGVAR(turnOutJIP), nil, true];

    // Remove EH
    [QGVAR(executeFunction), [QFUNC(removeBehaviourEh), _vehicle]] call CBA_fnc_globalEvent;

    // Remove EH on server
    [QGVAR(executeFunction), [QFUNC(removeGetInOutEh), _vehicle]] call CBA_fnc_serverEvent;
}, true] call FUNC(sanitiseFunction);

DFUNC(setBehaviourVehicleCrew) = [{
    params ["_object", "_unit", "_leaveCrew", "_allowTurnOut", "_behaviour"];

    _unit enableAIFeature ["AUTOCOMBAT", _leaveCrew || _allowTurnOut];
    _unit enableAIFeature ["FSM", _leaveCrew];
    _unit setCombatBehaviour _behaviour;

    if (!_allowTurnOut && {isTurnedOut _unit}) then {
        _unit action ["TurnIn", _object];
    };
}, true] call FUNC(sanitiseFunction);

// Run on server
DFUNC(addGetInOutEh) = [{
    params ["_vehicle"];

    if (!isNil {_vehicle getVariable QGVAR(getInOutEhIDs)}) exitWith {};

    _vehicle setVariable [QGVAR(getInOutEhIDs), [
        _vehicle addEventHandler ["GetIn", {
            params ["_vehicle", "", "_unit"];

            if (isPlayer _unit) exitWith {};

            (_vehicle getVariable [QGVAR(turnOutBehaviour), []]) params ["_stayCrew", "_allowTurnOut", "_behaviour"];

            // Force unit to turn in
            [QGVAR(executeFunction), [QFUNC(setBehaviourVehicleCrew), [_vehicle, _unit, _stayCrew, _allowTurnOut, _behaviour]], _unit] call CBA_fnc_targetEvent;
        }],
        _vehicle addEventHandler ["GetOut", {
            params ["_vehicle", "", "_unit"];

            // Reset unit
            [QGVAR(executeFunction), [QFUNC(setBehaviourVehicleCrew), [_vehicle, _unit, true, true, "AWARE"]], _unit] call CBA_fnc_targetEvent;
        }]
    ]];
}, true] call FUNC(sanitiseFunction);

DFUNC(removeGetInOutEh) = [{
    params ["_vehicle"];

    private _ehIDs = _vehicle getVariable QGVAR(getInOutEhIDs);

    if (isNil "_ehIDs") exitWith {};

    _vehicle removeEventHandler ["GetIn", _ehIDs select 0];
    _vehicle removeEventHandler ["GetOut", _ehIDs select 1];

    _vehicle setVariable [QGVAR(getInOutEhIDs), nil];
}, true] call FUNC(sanitiseFunction);

DFUNC(addAiDriverEh) = [{
    params ["_unit"];

    if (!isNil {_unit getVariable QGVAR(aiDriverEhIDs)}) exitWith {};

    // Don't need to save these, as unit will be deleted
    _unit addEventHandler ["GetOutMan", {
        params ["_unit", "", "_vehicle"];

        [_vehicle, _unit] call FUNC(removeAiDriverEh);
    }];

    _unit addEventHandler ["SeatSwitchedMan", {
        params ["_unit", "", "_vehicle"];

        [_vehicle, _unit] call FUNC(removeAiDriverEh);
    }];

    _unit addEventHandler ["Deleted", {
        params ["_unit"];

        [objectParent _unit, _unit, true] call FUNC(removeAiDriverEh);
    }];

    // Unit is not guaranteed to be local to the server
    _unit setVariable [QGVAR(aiDriverEhID),
        addMissionEventHandler ["EntityKilled", {
            params ["_entity"];
            _thisArgs params ["_unit"];

            if (_entity isNotEqualTo _unit) exitWith {};

            [objectParent _unit, _unit] call FUNC(removeAiDriverEh);
        }, [_unit]]
    ];
}, true] call FUNC(sanitiseFunction);

DFUNC(removeAiDriverEh) = [{
    params ["_vehicle", "_unit", ["_isDeletedEH", false]];

    _vehicle call FUNC(removeAiCrewBehaviour);

    ["zen_common_execute", [{
        params ["_vehicle", "_unit", "_isDeletedEH"];

        // Unlock driver position
        _vehicle lockDriver false;

        // Delete the unit (prevent recursiveness)
        if (!_isDeletedEH) then {
            _vehicle deleteVehicleCrew _unit;
        };
    }, [_vehicle, _unit, _isDeletedEH]], _vehicle] call CBA_fnc_targetEvent;

    private _ehID = _vehicle getVariable QGVAR(aiDriverEhID);

    if (isNil "_ehID") exitWith {};

    removeMissionEventHandler ["EntityKilled", _ehID];

    _vehicle setVariable [QGVAR(aiDriverEhID), nil];
}, true] call FUNC(sanitiseFunction);

SEND_MP(addBehaviourEh);
SEND_MP(removeBehaviourEh);
SEND_MP(removeAiCrewBehaviour);
SEND_MP(setBehaviourVehicleCrew);

SEND_SERVER(addGetInOutEh);
SEND_SERVER(removeGetInOutEh);
SEND_SERVER(addAiDriverEh);
SEND_SERVER(removeAiDriverEh);
