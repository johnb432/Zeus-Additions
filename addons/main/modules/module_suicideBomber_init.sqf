/*
 * Author: johnb43
 * Init for suicide bomber module.
 */

INFO_ZA(FORMAT_1("Running %1",__FILE__));

DFUNC(addDetonateAction) = [{
    if (!isNil {_this getVariable QGVAR(suicideBomberActionID)}) exitWith {};

    _this setVariable [QGVAR(suicideBomberActionID),
        _this addAction [
            "<t color='#FF0000'>Detonate</t>",
            {
                params ["_unit"];

                // Detonate explosives
                {
                    _x setDamage 1;
                } forEach (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

                // Remove JIP, action and EHs
                _unit call FUNC(removeSuicideBomberIDs);
            },
            [],
            6,
            true,
            true,
            "",
            "_this == _originalTarget",
            1
        ]
    ];
}, true, true] call FUNC(sanitiseFunction);

DFUNC(addExplosives) = [{
    private _pos = getPosATL _this;

    // Create demo block belt and attach to unit
    private _expl1 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
    _expl1 attachTo [_this, [-0.1, 0.1, 0.15], "Pelvis", true];

    // Remove from JIP when object is deleted
    [["zen_common_setVectorDirAndUp", [_expl1, [[0.5, 0.5, 0], [-0.5, 0.5, 0]]]] call CBA_fnc_globalEventJIP, _expl1] call CBA_fnc_removeGlobalEventJIP;

    private _expl2 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
    _expl2 attachTo [_this, [0, 0.15, 0.15], "Pelvis", true];
    [["zen_common_setVectorDirAndUp", [_expl2, [[1, 0, 0], [0, 1, 0]]]] call CBA_fnc_globalEventJIP, _expl2] call CBA_fnc_removeGlobalEventJIP;

    private _expl3 = createVehicle ["DemoCharge_Remote_Ammo", _pos, [], 0, "CAN_COLLIDE"];
    _expl3 attachTo [_this, [0.1, 0.1, 0.15], "Pelvis", true];
    [["zen_common_setVectorDirAndUp", [_expl3, [[0.5, -0.5, 0], [0.5, 0.5, 0]]]] call CBA_fnc_globalEventJIP, _expl3] call CBA_fnc_removeGlobalEventJIP;

    _this setVariable [QGVAR(suicideBomberExplosives), [_expl1, _expl2, _expl3], true];
}, true, true] call FUNC(sanitiseFunction);

DFUNC(removeSuicideBomberEh) = [{
    params ["_unit", "_removeAction"];

    // Remove scroll wheel action
    if (_removeAction) then {
        private _actionID = _unit getVariable QGVAR(suicideBomberActionID);

        if (!isNil "_actionID") then {
            _unit removeAction _actionID;
            _unit setVariable [QGVAR(suicideBomberActionID), nil];
        };
    };

    // Remove dead man switch
    (_unit getVariable [QGVAR(suicideBomberDeadManSwitchEhIDs), []]) params ["_damageEhID", "_killedEhID"];

    if (isNil "_damageEhID") exitWith {};

    if (zen_common_aceMedical) then {
        ["ace_unconscious", _damageEhID] call CBA_fnc_removeEventHandler;
    } else {
        _unit removeEventHandler ["HandleDamage", _damageEhID];
    };

    _unit removeEventHandler ["Killed", _killedEhID];

    _unit setVariable [QGVAR(suicideBomberDeadManSwitchEhIDs), nil];
}, true, true] call FUNC(sanitiseFunction);

SEND_MP(addDetonateAction);
SEND_MP(addExplosives);
SEND_MP(removeSuicideBomberEh);
