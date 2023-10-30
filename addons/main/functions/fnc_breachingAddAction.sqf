#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Adds a local breaching action to a locked door on a building.
 *
 * Arguments:
 * 0: Building <OBJECT>
 * 1: Selection name for door <STRING>
 * 2: Door index <NUMBER>
 *
 * Return Value:
 * Action ID <NUMBER>
 *
 * Example:
 * [cursorObject player, "door_1", 1] call zeus_additions_main_fnc_breachingAddAction;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

params ["_building", "_selectionName", "_index"];

_building addAction [
    "<t color='#FF0000'>Breach door using explosives</t>",
    {
        params ["_building", "_caller", "_actionID", "_args"];
        _args params ["_door", "_doorID"];

        // In case door has been unlocked by other means
        if ([_building, _doorID] call zen_doors_fnc_getState != 1) exitWith {
            hint "You find the door to be unlocked.";

            // Remove the action globally; actionIDs are not the same on all clients!!!
            [_building, _door] remoteExecCall [QFUNC(breachingRemoveAction), 0];
        };

        private _explosives = GETMVAR(QGVAR(explosivesBreach),[]);

        if ((_explosives param [_explosives findAny (itemsWithMagazines _caller), ""]) == "") exitWith {
            hint "You need a compatible item to breach!";
        };

        ["str_a3_cfghints_curator_placemines_displayname", [
            ["SLIDER", ["STR_3DEN_Trigger_AttributeCategory_Timer", "Sets how long the explosives take to blow after having interacted with them."], [3, 120, 20, 0]]
        ], {
            params ["_results", "_args"];
            _results params ["_timer"];
            _args params ["_building", "_caller", "_explosives", "_door", "_doorID", "_actionID"];

            // Check if action hasn't alredy been used, while unit was in menu
            if !(_actionID in (actionIDs _building)) exitWith {
                hint "You find the door to be unlocked.";
            };

            // Check if the item hasn't disappeared since the last check
            private _explosive = _explosives param [_explosives findAny (itemsWithMagazines _caller), ""];

            if (_explosive == "") exitWith {
                hint "You need a compatible item to breach!";
            };

            // Get door surface to place explosive on
            private _unitPos = eyePos _caller;
            private _intersection = (lineIntersectsSurfaces [_unitPos, _unitPos vectorAdd ((getCameraViewDirection _caller) vectorMultiply 2.5), _caller, objNull, true, 1, "GEOM", "FIRE"]) param [0, []];

            // If door is out of glass for example, it will not return anything
            if (_intersection isEqualTo []) exitWith {
                hint "No surface could be found to place the explosive on.";
            };

            _intersection params ["_intersectPosASL", "_surfaceNormal", "_intersectObj", "", "_selectionNames"];

            // If the intersect object isn't the building or if it's the incorrect selection
            if !(_intersectObj == _building && {_door in _selectionNames}) exitWith {};

            // Spawn explosive
            private _helperObject = "DemoCharge_F" createVehicle [0, 0, 0];
            _helperObject setPosASL _intersectPosASL;

            // If the surface is facing either facing N or S, we must rotate it, otherwise it isn't placed correctly; Remove from JIP when object is deleted
            if ((_surfaceNormal select 0) == 0 && {(_surfaceNormal select 2) == 0}) then {
                [["zen_common_setVectorDirAndUp", [_helperObject, [[0, 0, 1], _surfaceNormal]]] call CBA_fnc_globalEventJIP, _helperObject] call CBA_fnc_removeGlobalEventJIP;
            } else {
                _helperObject setVectorUp _surfaceNormal;
            };

            // Add object to Zeus interface
            _helperObject call zen_common_fnc_updateEditableObjects;

            _timer = round _timer;

            // Remove the action globally; actionIDs are not the same on all clients!!!
            [_building, _door] remoteExecCall [QFUNC(breachingRemoveAction), 0];

            // Get rid of JIP handler
            private _jipID = _building getVariable (format [QGVAR(doorJIP_%1_%2), _door, _doorID]);

            if (!isNil "_jipID") then {
                _jipID call CBA_fnc_removeGlobalEventJIP;

                _building setVariable [format [QGVAR(doorJIP_%1_%2), _door, _doorID], nil, true];
            };

            // Notify player
            if (_timer >= 5) then {
                hint format ["Breaching in %1s...", _timer];

                [{
                    hint "";
                }, nil, 1.95] call CBA_fnc_waitAndExecute;
            };

            // Do place explosive animation
            _caller playActionNow "PutDown";
            _caller setVariable ["ace_explosives_PlantingExplosive", true];

            [{
                _this setVariable ["ace_explosives_PlantingExplosive", false];
            }, _caller, 1.5] call CBA_fnc_waitAndExecute;

            // Remove explosive
            _caller removeItem _explosive;

            // Do the countdown
            for "_i" from 3 to 1 step -1 do {
                [{
                    hint format ["Breaching in %1s...", _this];
                }, _i, _timer - _i] call CBA_fnc_waitAndExecute;
            };

            [{
                hint "";
            }, nil, _timer] call CBA_fnc_waitAndExecute;

            // Run code on server, in case player disconnects
            [_helperObject, _building, _doorID, _timer] remoteExecCall [QFUNC(breachingEffects), 2];
        }, {}, [_building, _caller, _explosives, _door, _doorID, _actionID]] call zen_dialog_fnc_create;
    },
    [_selectionName, _index],
    1.5,
    true,
    true,
    "",
    "true",
    2,
    false,
    _selectionName
]
