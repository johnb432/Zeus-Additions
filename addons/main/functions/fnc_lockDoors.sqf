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

["Zeus Additions", "[WIP] Lock building doors", {
    params ["_pos"];

    ["Change building lock", [
        ["TOOLBOX", "Lock state", [0, 1, 3, ["Unbreachable", "Breachable", "Unlocked"]], false],
        ["SLIDER", ["Radius", "Determines how far out the module takes affect from the placement point."], [0, 100, 20, 0]],
        ["CHECKBOX", ["Select closest building only", "Disregards all buildings in the search except the nearest one."], false],
        ["EDIT", ["Explosives", "An array that contains all allowed explosives."], GETPRVAR(QGVAR(explosivesBreach),"['DemoCharge_Remote_Mag']"), true],
        ["CHECKBOX", ["Reset to default explosives list", "Resets the explosives list above to the default, which contains only the vanilla demolition block."], false, true]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_mode", "_radius", "_closestOnly", "_explosives", "_reset"];

        if (_reset) exitWith {
            SETPRVAR(QGVAR(explosivesBreach),"['DemoCharge_Remote_Mag']");
            ["Reset explosives list to default"] call zen_common_fnc_showMessage;
        };

        SETPRVAR(QGVAR(explosivesBreach),_explosives);

        private _buildings = nearestObjects [_pos, ["Building"], _radius, true];

        if (_closestOnly) then {
            _buildings resize 1;
        };

        if (_buildings isEqualTo []) exitWith {
            ["No buildings found!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        // Used for Zeus interface updating of editable objects
        private _helperObjectListTotal = [];
        private _string = ["%1 Buildings locked (not breachable)", "%1 Buildings locked (but breachable)", "%1 Buildings unlocked"] select _mode;

        {
           	private _building = _x;
            private _doors = [_building] call zen_doors_fnc_getDoors;

            // no doors found
            if (_doors isEqualTo []) exitWith {
                ["No doors were found for %1!", getText (configFile >> "CfgVehicles" >> typeOf _building >> "displayName")] call zen_common_fnc_showMessage;
            };

            // 0 unbreachable, 1 breachable, 2 unlocked
            if (_mode != 1) then {
                if (_building getVariable [QGVAR(breachableDoorCount), nil] > 0) then {
                    private _list = _building getVariable [QGVAR(helperObjectList), []];

                    {
                        [{deleteVehicle _this}, _x] call CBA_fnc_execNextFrame;
                    } forEach _list;
                };

                private _stateChange = [0, 1] select (_mode isEqualTo 0);

                {
                    [_building, _forEachIndex + 1, _stateChange] call zen_doors_fnc_setState;
                } forEach _doors;
            } else { // Breach
                private _doorCount = _building getVariable [QGVAR(breachableDoorCount), nil];

                if (_doorCount > 0) exitWith {
                    ["%1 already has breachable doors!", getText (configFile >> "CfgVehicles" >> typeOf _building >> "displayName")] call zen_common_fnc_showMessage;
                };

                if (isNil "_doorCount") then {
                    _building setVariable [QGVAR(breachableDoorCount), count _doors, true];
                };

                // Used for Zeus interface updating of editable objects and storing helper objects to buildings
                private _helperObjectList = [];

               	{
                    [_building, _forEachIndex + 1, 1] call zen_doors_fnc_setState;

                    private _helperObject = "DemoCharge_F" createVehicle [0, 0, 0];
                    _helperObject attachTo [_building, _x];
                    _helperObject setVariable [QGVAR(building), _building, true];
                    _helperObjectList pushBack _helperObject;

                    [_helperObject, [
                        "Breach door (30s Timer)",
                        {
                            params ["_target", "_caller", "_actionId", "_arguments"];
                            _arguments params ["_doorID", "_explosives"];

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

                            _target removeAction _actionId;

                            private _building = _target getVariable [QGVAR(building), objNull];

                            if (isNull _building) exitWith {};

                            [_caller, "PutDown"] call ace_common_fnc_doGesture;
                            _caller setVariable ["ace_explosives_PlantingExplosive", true];
                            [{_this setVariable ["ace_explosives_PlantingExplosive", false]}, _caller, 1.5] call CBA_fnc_waitAndExecute;

                            ["Breaching in 30s!", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _caller];

                            [{
                                params ["_caller", "_target"];

                                private _explosion = "mini_Grenade" createVehicle (getPosATL _target);
                                _explosion attachTo [_target];
                                _explosion remoteExecCall ["hideObject", 0];
                                _explosion setShotParents [_caller, _caller];
                                _explosion setDamage 1;
                            }, [_caller, _target], 27.5] call CBA_fnc_waitAndExecute;

                            [{["Breaching in 5...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, 25] call CBA_fnc_waitAndExecute;
                            [{["Breaching in 4...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, 26] call CBA_fnc_waitAndExecute;
                            [{["Breaching in 3...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, 27] call CBA_fnc_waitAndExecute;
                            [{["Breaching in 2...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, 28] call CBA_fnc_waitAndExecute;
                            [{["Breaching in 1...", false, 1, 2] remoteExecCall ["ace_common_fnc_displayText", _this];}, _caller, 29] call CBA_fnc_waitAndExecute;

                            [{
                                params ["_target", "_building", "_doorID"];

                                deleteVehicle _target;
                                [_building, _doorID, 2] call zen_doors_fnc_setState;
                            }, [_target, _building, _doorID], 30] call CBA_fnc_waitAndExecute;
                        },
                        [(_forEachIndex + 1), _explosives],
                        1.5,
                        true,
                        true,
                        "",
                        "true",
                        10
                    ]] remoteExecCall ["addAction", 0];

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

                        if (_index != -1) then {
                            _helperObjectList deleteAt _index;
                        };
                    }]] remoteExecCall ["addEventHandler", 2];
               	} forEach _doors;

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
