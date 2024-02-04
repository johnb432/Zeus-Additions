#include "..\script_component.hpp"
/*
 * Author: johnb43, based on Alganthe's zen_ai_fnc_garrison
 * Garrisons given units in a given building.
 *
 * Arguments:
 * 0: Building <OBJECT>
 * 1: Side <NUMBER>
 * 2: Unit types <ARRAY>
 * 3: Dynamic simulation <BOOL>
 * 4: Trigger enabled <BOOL>
 * 5: Trigger radius <NUMBER>
 * 6: Unit behaviour <NUMBER>
 * 7: Client <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!isServer) exitWith {};

params ["_building", "_side", "_unitTypes", "_dynamicSimulation", "_trigger", "_triggerRadius", "_unitBehaviour", "_client"];

if (isNull _building || {_unitTypes isEqualTo []}) exitWith {};

private _group = createGroup [[west, east, independent, civilian] select _side, true];
private _units = [];

private _fnc_moveUnit = {
    params ["_unitType", "_pos"];

    // Spawn the infantry units
    private _unit = _group createUnit [_unitType, [-10000, -10000, 0], [], 0, "CAN_COLLIDE"];

    if (surfaceIsWater _pos) then {
        _unit setPosASL AGLtoASL _pos;
    } else {
        _unit setPosATL _pos;
    };

    doStop _unit;

    _unit setVariable ["zen_ai_garrisoned", true, true];
    [["zen_common_disableAI", [_unit, "PATH"], QGVAR(path_) + hashValue _unit] call CBA_fnc_globalEventJIP, _unit] call CBA_fnc_removeGlobalEventJIP;

    _units pushBack _unit;
};

private _allBuildingPos = _building buildingPos -1;
private _buildingPos = [];

// Fill building randomly
while {_allBuildingPos isNotEqualTo []} do {
    _buildingPos = selectRandom _allBuildingPos;

    // Check if there is already a unit placed
    if (_buildingPos nearEntities ["CAManBase", 1] isEqualTo []) then {
        [_unitTypes deleteAt 0, _buildingPos] call _fnc_moveUnit;
    };

    // Delete the position, so it isn't used twice
    _allBuildingPos deleteAt (_allBuildingPos find _buildingPos);

    // If there are no more units to spawn, stop
    if (_unitTypes isEqualTo []) exitWith {};
};

// If there are unit types remaining, notify curator who used module, as not all units were placed down
if (_unitTypes isNotEqualTo [] && {!isMultiplayer || _client != 0}) then {
    ["zen_common_showMessage", [LSTRING_ZEN(ai,couldNotGarrisonAll)], _client] call CBA_fnc_ownerEvent;
};

[{
    params ["_building", "_units", "_group", "_unitBehaviour", "_dynamicSimulation", "_trigger", "_triggerRadius"];

    {
        // If outside, make the unit kneel
        _x setUnitPos (["MIDDLE", "UP"] select (round insideBuilding _x));

        _x setVariable ["lambs_danger_disableAI", true];
    } forEach _units;

    _group setVariable ["lambs_danger_disableGroupAI", false];

    // Adjust behaviour of infantry units if not default
    if (_unitBehaviour > 0) then {
        private _behaviour = ["SAFE", "AWARE", "COMBAT"] select (_unitBehaviour - 1);
        private _speedMode = ["LIMITED", "NORMAL"] select (_unitBehaviour > 1);

        _group setBehaviour _behaviour;
        _group setSpeedMode _speedMode;
    };

    if (_dynamicSimulation) then {
        [{
            _this enableDynamicSimulation true;
        }, _group, 1] call CBA_fnc_waitAndExecute;
    };

    if (_trigger) then {
        _trigger = createTrigger ["EmptyDetector", getPos _building];

        _trigger setVariable [QGVAR(garrisonedUnits), _units];
        _trigger setVariable [QGVAR(garrisonedGroup), _group];

        _trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, 15];
        _trigger setTriggerActivation ["ANYPLAYER", "PRESENT", false];
        _trigger setTriggerInterval 5;
        _trigger setTriggerStatements [
            "this",
            toString {
                private _units = (thisTrigger getVariable [QGVAR(garrisonedUnits), []]) select {alive _x};

                if (_units isEqualTo []) exitWith {};

                ["zen_ai_ungarrison", _units, _units] call CBA_fnc_targetEvent;

                (thisTrigger getVariable [QGVAR(garrisonedGroup), grpNull]) setVariable ["lambs_danger_disableGroupAI", false];

                {
                    _x setVariable ["lambs_danger_disableAI", false];

                    [["zen_common_enableAI", [_x, "PATH"], QGVAR(path_) + hashValue _x] call CBA_fnc_globalEventJIP, _x] call CBA_fnc_removeGlobalEventJIP;
                } forEach _units;
            },
            ""
        ];

        // Remove trigger when the group is deleted
        addMissionEventHandler ["GroupDeleted", {
            params ["_deletedGroup"];
            _thisArgs params ["_group", "_trigger"];

            if (_group isNotEqualTo _deletedGroup) exitWith {};

            removeMissionEventHandler [_thisEvent, _thisEventHandler];

            deleteVehicle _trigger;
        }, [_group, _trigger]];
    };
}, [_building, _units, _group, _unitBehaviour, _dynamicSimulation, _trigger, _triggerRadius], 3] call CBA_fnc_waitAndExecute;
