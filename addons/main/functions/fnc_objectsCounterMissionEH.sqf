#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds the EH related to the mission object counter.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_objectsCounterMissionEH;
 *
 * Public: No
 */

private _curator = getAssignedCuratorLogic player;

if (isNull _curator) exitWith {};

// If stats haven't been initialised; make unique identifier for multiple people using the mod at the same time
if (isNil FORMAT_1(QGVAR(curatorObjects_%1),str _curator)) then {
    // [infantry, cars, tanks, statics, helos, planes, all, pings, deletedEntities, placedGroup]; In case of disconnect, stats are not lost
    SETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),str _curator),[ARR_10(createHashMap,createHashMap,createHashMap,createHashMap,createHashMap,createHashMap,createHashMap,createHashMap,createHashMap,createHashMap)],true);
};

// If EH have already been added, don't add them again
if (!isNil QGVAR(curatorHandleIDs)) exitWith {};

GVAR(curatorHandleIDs) = [
    _curator addEventHandler ["CuratorObjectDeleted", {
        params ["_curator", "_entity"];

        private _data = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),str _curator),nil) select 8;

        _data set ["numDeleted", (_data getOrDefault ["numDeleted", 0]) + 1];

        publicVariable FORMAT_1(QGVAR(curatorObjects_%1),str _curator);
    }],
    _curator addEventHandler ["CuratorObjectPlaced", {
        params ["_curator", "_entity"];

        // Add the entity to the list of objects spawned
        {
            if (_entity isKindOf _x) exitWith {
                private _items = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),str _curator),nil) select _forEachIndex;
                private _name = getText (configOf _entity >> "displayName");

                _items set [_name, (_items getOrDefault [_name, 0]) + 1];
            };
        } forEach ["CAManBase", "Car", "Tank", "StaticWeapon", "Helicopter", "Plane", "All"];

        publicVariable FORMAT_1(QGVAR(curatorObjects_%1),str _curator);
    }],
    _curator addEventHandler ["CuratorGroupPlaced", {
        params ["_curator", "_group"];

        private _data = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),str _curator),nil) select 9;

        _data set ["numGroupsPlaced", (_data getOrDefault ["numGroupsPlaced", 0]) + 1];

        publicVariable FORMAT_1(QGVAR(curatorObjects_%1),str _curator);
    }],
    _curator addEventHandler ["CuratorPinged", {
        params ["_curator", "_player"];

        // "Convert" to string
        _player = getPlayerUID _player;

        // Get pings hashmap with data: which player and how many times
        private _pings = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),str _curator),nil) select 7;
        _pings set [_player, (_pings getOrDefault [_player, 0]) + 1];

        publicVariable FORMAT_1(QGVAR(curatorObjects_%1),str _curator);
    }]
];
