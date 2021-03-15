#include "script_component.hpp"

/*
 * Author: johnb43, with help from scripts from mharis001 (ZEN) & Kex (Achilles)
 * Adds a module allows you to change if people can open doors on buildings.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_lockDoors;
 *
 * Public: No
 */

["Zeus Additions - Utility", "[WIP] Lock building doors", {
    params ["_pos"];

    ["Change building lock", [
        ["TOOLBOX", "Lock state", [0, 1, 3, ["Unbreachable", "Breachable", "Unlocked"]], false],
        ["SLIDER", ["Radius", "Determines how far out the module takes affect from the placement point."], [0, 200, 20, 0]],
        ["CHECKBOX", ["Select closest building only", "Disregards all buildings in the search except the nearest one."], false],
        ["EDIT", ["Explosives", "An array that contains all allowed explosives."], GETPRVAR(QGVAR(explosivesBreach),"['DemoCharge_Remote_Mag']"), true],
        ["CHECKBOX", ["Disable explosion", "Disables the explosion. Still requires a breaching charge."], false],
        ["CHECKBOX", ["Use stun grenade", "Spawns a stun grenade when opening the door. Requires a stun grenade from the list below."], false],
        ["EDIT", ["Stun grenades", "An array that contains all allowed explosives."], GETPRVAR(QGVAR(stunsBreach),"['ACE_M84']"), true],
        ["SLIDER", ["Explosives Timer", "Sets how long the explosives take to blow after having interacted with them."], [8, 60, 20, 0]],
        ["CHECKBOX", ["Reset to default lists", "Resets the explosives & stuns lists above to the default."], false, true]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_mode", "_radius", "_closestOnly", "_explosives", "_disableExplosion", "_useStun", "_stuns", "_timer", "_reset"];

        if (_reset) exitWith {
            SETPRVAR(QGVAR(explosivesBreach),"['DemoCharge_Remote_Mag']");
            SETPRVAR(QGVAR(stunsBreach),"['ACE_M84']");
            ["Reset lists to default"] call zen_common_fnc_showMessage;
        };

        SETPRVAR(QGVAR(explosivesBreach),_explosives);
        SETPRVAR(QGVAR(stunsBreach),_stuns);

        private _buildings = nearestObjects [_pos, ["Building"], _radius, true];

        if (_closestOnly) then {
            _buildings resize 1;
        };

        if (_buildings isEqualTo []) exitWith {
            ["No buildings found!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        _timer = round _timer;
        private _timerString = (format ["Breach door (%1s Timer)", _timer]);

        // Used for Zeus interface updating of editable objects
        private _helperObjectListTotal = [];
        private _string = ["%1 Buildings locked (not breachable)", "%1 Buildings locked (but breachable)", "%1 Buildings unlocked"] select _mode;

        {
           	private _building = _x;
            private _doorPositionsUserActions = [];
            private _doorPositionsUserActionsNames = [];
            // Like [_building] call zen_doors_fnc_getDoors, but includes the door names aswell
            {
                if ("opendoor" in toLower configName _x) then {
                    _door = _building selectionPosition (getText (_x >> "position"));
                    _doorPositionsUserActions pushBack _door;
                    _doorPositionsUserActionsNames pushBack (toLower (configName _x));
                };
            } forEach configProperties [configOf _building >> "UserActions", "isClass _x"];

            // No doors found
            if (_doorPositionsUserActions isEqualTo []) exitWith {
                ["No doors were found for %1!", getText (configFile >> "CfgVehicles" >> typeOf _building >> "displayName")] call zen_common_fnc_showMessage;
            };

            // Remove old helpers with interactions to place new ones if wanted
            if (_building getVariable [QGVAR(breachableDoorCount), nil] > 0) then {
                {
                    [{deleteVehicle _this}, _x] call CBA_fnc_execNextFrame;
                } forEach (_building getVariable [QGVAR(helperObjectList), []]);
            };

            // 0 unbreachable, 1 breachable, 2 unlocked
            if (_mode isNotEqualTo 1) then {
                {
                    [_building, _forEachIndex + 1, ([0, 1] select (_mode isEqualTo 0))] call zen_doors_fnc_setState;
                } forEach _doorPositionsUserActions;
            } else { // Breach
                if (isNil {_building getVariable [QGVAR(breachableDoorCount), nil]}) then {
                    _building setVariable [QGVAR(breachableDoorCount), count _doorPositionsUserActions, true];
                };

                // Used for Zeus interface updating of editable objects and storing helper objects to buildings
                private _helperObjectList = [];
                private _direction = direction _building;
                private _index;
                private _doorPosZ = [];
                private _doorPosZNames = [];
                private _doorPosZSorted = [];

                // In alphabetical order (e.g door_1)
                {
                   	if (_x find "door" isNotEqualTo -1 && {_x find "handle" isEqualTo -1}) then {
                        _selectionPos = _building selectionPosition _x;
                        if (_selectionPos isEqualTo [0, 0, 0]) exitWith {};
                        _posZ = (_building modelToWorld _selectionPos) select 2;
                      		_doorPosZ pushBack _posZ;
                        _doorPosZNames pushBack (toLower _x);
                   	};
                } forEach (selectionNames _building);

                {
                    _doorPositionsUserActionsName = _x;
                    _index = _doorPosZNames findIf {_x in _doorPositionsUserActionsName};
                    if (_index isNotEqualTo -1) then {
                        _doorPosZSorted pushBack (_doorPosZ select _index);
                    };
                } forEach _doorPositionsUserActionsNames;

               	{
                    [_building, _forEachIndex + 1, 1] call zen_doors_fnc_setState;

                    private _helperObject = "DemoCharge_F" createVehicle (getPosATL _building);

                    private _pos = getPosATL _building;
                    private _dirVector = [_x, _direction, 2] call BIS_fnc_rotateVector3D;
                    private _helperObject = "DemoCharge_F" createVehicle [0, 0, 0];
                    _helperObject setDir (360 - _direction);
                    _helperObject setPosATL [(_pos select 0) + (_dirVector select 0), (_pos select 1) + (_dirVector select 1), (_doorPosZSorted select _forEachIndex) + 1.25];
                    _helperObject setVariable [QGVAR(building), _building, true];
                    _helperObjectList pushBack _helperObject;
                    _helperObject attachTo [_building, _x];

                    [_helperObject, [
                        _timerString,
                        {
                            params ["_target", "_caller", "_actionId", "_arguments"];
                            _arguments params ["_doorID", "_explosives", "_disableExplosion", "_timer", "_useStun", "_stuns"];

                            private _foundExplosive = false;

                            {
                                if (_x in _explosives) exitWith {
                                   _caller removeMagazine _x;
                                   _foundExplosive = true;
                                };
                            } forEach (magazines _caller);

                            if (!_foundExplosive) exitWith {
                                ["You need a compatible explosive to place onto breach spot!", false, 5, 2] remoteExecCall ["ace_common_fnc_displayText", _caller];
                            };

                            private _exit = false;

                            if (_useStun) then {
                                private _foundStun = false;
                                {
                                    if (_x in _stuns) exitWith {
                                       _caller removeMagazine _x;
                                       _foundStun = true;
                                    };
                                } forEach (magazines _caller);

                                if (!_foundStun) exitWith {
                                    ["You need a compatible stun grenade to open this door!", false, 5, 2] remoteExecCall ["ace_common_fnc_displayText", _caller];
                                    _exit = true;
                                };
                            };

                            if (_exit) exitWith {};

                            _target removeAction _actionId;

                            private _building = _target getVariable [QGVAR(building), objNull];

                            if (isNull _building) exitWith {};

                            [_caller, "PutDown"] call ace_common_fnc_doGesture;
                            _caller setVariable ["ace_explosives_PlantingExplosive", true];
                            [{_this setVariable ["ace_explosives_PlantingExplosive", false]}, _caller, 1.5] call CBA_fnc_waitAndExecute;

                            [(format ["Breaching in %1s!", _timer]), false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _caller];

                            [{
                                params ["_caller", "_target", "_building", "_doorID", "_disableExplosion", "_useStun"];

                                if (!_disableExplosion) then {
                                    private _explosion = "mini_Grenade" createVehicle (getPosATL _target);
                                    _explosion attachTo [_target];
                                    _explosion remoteExecCall ["hideObject", 0];
                                    _explosion setShotParents [_caller, _caller];
                                    _explosion setDamage 1;

                                    [{
                                        (_this select 0) isEqualTo objNull
                                    }, {
                                        params ["_explosion", "_target", "_building", "_doorID", "_useStun"];

                                        if (_useStun) then {
                                            ["ACE_G_M84" createVehicle (getPosATL _target)] call ace_grenades_fnc_flashbangThrownFuze;
                                        };

                                        deleteVehicle _target;
                                        [_building, _doorID, 2] call zen_doors_fnc_setState;
                                    }, [_explosion, _target, _building, _doorID, _useStun]] call CBA_fnc_waitUntilAndExecute;
                                } else {
                                    // Spawns too soon
                                    [{
                                        params ["_target", "_building", "_doorID", "_useStun"];

                                        if (_useStun) then {
                                            ["ACE_G_M84" createVehicle (getPosATL _target)] call ace_grenades_fnc_flashbangThrownFuze;
                                        };

                                        deleteVehicle _target;
                                        [_building, _doorID, 2] call zen_doors_fnc_setState;
                                    }, [_target, _building, _doorID, _useStun], _timer] call CBA_fnc_waitAndExecute;
                                };
                            }, [_caller, _target, _building, _doorID, _disableExplosion, _useStun], _timer - 2.5] call CBA_fnc_waitAndExecute;

                            [{["Breaching in 5...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, _timer - 5] call CBA_fnc_waitAndExecute;
                            [{["Breaching in 4...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, _timer - 4] call CBA_fnc_waitAndExecute;
                            [{["Breaching in 3...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, _timer - 3] call CBA_fnc_waitAndExecute;
                            [{["Breaching in 2...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, _timer - 2] call CBA_fnc_waitAndExecute;
                            [{["Breaching in 1...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, _timer - 1] call CBA_fnc_waitAndExecute;
                        },
                        [(_forEachIndex + 1), _explosives, _disableExplosion, _timer, _useStun, _stuns],
                        1.5,
                        true,
                        true,
                        "",
                        "true",
                        10
                    ]] remoteExecCall ["addAction", 0, true];

                    [_helperObject, ["Deleted",
                    {
                        params ["_helperObject"];
                        private _building = _helperObject getVariable [QGVAR(building), objNull];
                        if (isNull _building) exitWith {};

                        private _doorCount = _building getVariable [QGVAR(breachableDoorCount), nil];
                        _doorCount = _doorCount - 1;
                        _building setVariable [QGVAR(breachableDoorCount), ([_doorCount, nil] select (_doorCount isEqualTo 0)), true];

                        private _helperObjectList = _building getVariable [QGVAR(helperObjectList), []];
                        if (_helperObjectList isEqualTo []) exitWith {};

                        private _index = _helperObjectList findIf {_x isEqualTo _helperObject};
                        if (_index isNotEqualTo -1) then {
                            _helperObjectList deleteAt _index;
                        };
                    }]] remoteExecCall ["addEventHandler", 2];
               	} forEach _doorPositionsUserActions;

                _building setVariable [QGVAR(helperObjectList), _helperObjectList, true];
                _helperObjectListTotal append _helperObjectList;
            };
        } forEach _buildings;

        {
            [_x, [_helperObjectListTotal, true]] remoteExecCall ["addCuratorEditableObjects", _x, true];
        } forEach allCurators;

        [_string, count _buildings] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
