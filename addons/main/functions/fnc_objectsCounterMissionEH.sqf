#include "..\script_component.hpp"
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
private _varName = FORMAT_1(QGVAR(curatorObjects_%1),getPlayerUID player);

GVAR(curatorEhIDs) params [["_oldCurator", objNull], "_deletedEhID", "_objectPlacedEhID", "_groupPlacedEhID", "_pingedEhID"];

// If setting is off or different curator unit and there is stuff still there, remove it
if (!GVAR(enableMissionCounter) || {_oldCurator != _curator}) exitWith {
    if (!isNil QGVAR(curatorTimer)) then {
        if (!isNil _varName) then {
            publicVariable _varName;
        };

        GVAR(curatorTimer) call CBA_fnc_removePerFrameHandler;
        GVAR(curatorTimer) = nil;
    };

    if (isNull _oldCurator || {isNil "_deletedEhID"}) exitWith {};

    _oldCurator removeEventHandler ["CuratorObjectDeleted", _deletedEhID];
    _oldCurator removeEventHandler ["CuratorObjectPlaced", _objectPlacedEhID];
    _oldCurator removeEventHandler ["CuratorGroupPlaced", _groupPlacedEhID];
    _oldCurator removeEventHandler ["CuratorPinged", _pingedEhID];

    GVAR(curatorEhIDs) = nil;
};

// If no new unit, exit
if (isNull _curator) exitWith {};

// If stats haven't been initialised; Make unique identifier for multiple people using the mod at the same time
if (isNil _varName) then {
    SETMVAR(_varname,createHashMap,true);
};

// Only broadcast publicly every 2 minutes
if (isNil QGVAR(curatorTimer) && {isMultiplayer}) then {
    GVAR(curatorTimer) = [{
        publicVariable (_this select 0);
    }, 120, _varName] call CBA_fnc_addPerFrameHandler;
};

// If EH have already been added, don't add them again
if (_oldCurator == _curator) exitWith {};

GVAR(curatorEhIDs) = [
    _curator,
    _curator addEventHandler ["CuratorObjectDeleted", {
        params ["", "_entity"];

        // Add the entity to the list of objects deleted
        {
            if (_entity isKindOf _x) exitWith {
                private _deleted = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),getPlayerUID player),createHashMap) getOrDefault [format ["deleted_%1", _x], createHashMap, true];
                private _config = configOf _entity;
                private _name = getText (_config >> "displayName");

                if (_name == "") then {
                    _name = str configName _config;
                };

                _deleted set [_name, (_deleted getOrDefault [_name, 0]) + 1];
            };
        } forEach ["CAManBase", "Car", "Tank", "StaticWeapon", "Helicopter", "Plane", "All"];
    }],
    _curator addEventHandler ["CuratorObjectPlaced", {
        params ["", "_entity"];

        // Add the entity to the list of objects placed
        {
            if (_entity isKindOf _x) exitWith {
                private _placed = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),getPlayerUID player),createHashMap) getOrDefault [format ["placed_%1", _x], createHashMap, true];
                private _config = configOf _entity;
                private _name = getText (_config >> "displayName");

                if (_name == "") then {
                    _name = str configName _config;
                };

                _placed set [_name, (_placed getOrDefault [_name, 0]) + 1];
            };
        } forEach ["CAManBase", "Car", "Tank", "StaticWeapon", "Helicopter", "Plane", "All"];
    }],
    _curator addEventHandler ["CuratorGroupPlaced", {
        private _curatorObjects = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),getPlayerUID player),createHashMap);
        _curatorObjects set ["groups", (_curatorObjects getOrDefault ["groups", 0]) + 1];
    }],
    _curator addEventHandler ["CuratorPinged", {
        params ["", "_player"];

        _player = getPlayerUID _player;

        // Add the player to the list of players pinged
        private _pings = GETMVAR(FORMAT_1(QGVAR(curatorObjects_%1),getPlayerUID player),createHashMap) getOrDefault ["pings", createHashMap, true];
        _pings set [_player, (_pings getOrDefault [_player, 0]) + 1];
    }]
];
