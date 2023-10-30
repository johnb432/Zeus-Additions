/*
 * Author: johnb43
 * Init for crew behaviour module.
 */

INFO_ZA(FORMAT_1("Running %1",__FILE__));

DFUNC(addBehaviourEh) = [{
    if (!isNil {_this getVariable QGVAR(turnOutEhIDs)}) exitWith {};

    _this setVariable [QGVAR(turnOutEhIDs), [
        _this addEventHandler ["TurnOut", {
            params ["_object", "_unit"];

            if (!local _unit || {isPlayer _unit} || {call CBA_fnc_currentUnit == _unit}) exitWith {};

            // Make the unit turn in
            _unit action ["TurnIn", _object];
            _unit setCombatBehaviour "COMBAT";
        }],
        ["zen_remoteControlStopped", {
            params ["_unit"];

            if (!local _unit || {!(_unit in _thisArgs)} || {!isTurnedOut _unit}) exitWith {};

            // Make the unit turn in
            _unit action ["TurnIn", _thisArgs];
            _unit setCombatBehaviour "COMBAT";
        }, _object] call CBA_fnc_addEventHandlerArgs
    ]];
}, true, true] call FUNC(sanitiseFunction);

DFUNC(removeBehaviourEh) = [{
    private _ehIDs = _this getVariable QGVAR(turnOutEhIDs);

    if (isNil "_ehIDs") exitWith {};

    _this removeEventHandler ["TurnOut", _ehIDs select 0];
    ["zen_remoteControlStopped", _ehIDs select 1] call CBA_fnc_removeEventHandler;

    _this setVariable [QGVAR(turnOutEhIDs), nil];
}, true, true] call FUNC(sanitiseFunction);

DFUNC(addGetInOutEh) = [{
    if (!isNil {_this getVariable QGVAR(getInOutEhIDs)}) exitWith {};

    _this setVariable [QGVAR(getInOutEhIDs), [
        _this addEventHandler ["GetIn", {
            params ["", "", "_unit"];

            if (!alive _unit) exitWith {};

            _unit remoteExecCall [QFUNC(addBehaviourEh), _unit];
        }],
        _this addEventHandler ["GetOut", {
            params ["", "", "_unit"];

            _unit remoteExecCall [QFUNC(removeBehaviourEh), _unit];
        }]
    ]];
}, true, true] call FUNC(sanitiseFunction);

DFUNC(removeGetInOutEh) = [{
    private _ehIDs = _this getVariable QGVAR(getInOutEhIDs);

    if (isNil "_ehIDs") exitWith {};

    _this removeEventHandler ["GetIn", _ehIDs select 0];
    _this removeEventHandler ["GetOut", _ehIDs select 1];

    _this setVariable [QGVAR(getInOutEhIDs), nil];
}, true, true] call FUNC(sanitiseFunction);

SEND_MP(addBehaviourEh);
SEND_MP(removeBehaviourEh);

SEND_SERVER(addGetInOutEh);
SEND_SERVER(removeGetInOutEh);
