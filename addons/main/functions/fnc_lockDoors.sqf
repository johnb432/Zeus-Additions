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

if (!hasInterface) exitWith {};

["Zeus Additions - Utility", "[WIP] Lock building doors", {
    params ["_pos"];

    ["Change building lock", [
        ["TOOLBOX", "Lock state", [0, 1, 4, ["Unbreachable", "Breachable", "Closed", "Open"]], false],
        ["EDIT", ["Explosives", "An array that contains all allowed explosives used for breaching."], GETPRVAR(QGVAR(explosivesBreach),"['DemoCharge_Remote_Mag']"), true],
        ["CHECKBOX", ["Disable explosion", "Disables the explosion. Still requires a breaching charge."], false],
        ["CHECKBOX", ["Use stun grenade", "Spawns a stun grenade when opening the door. Requires a stun grenade from the list below."], false],
        ["EDIT", ["Stun grenades", "An array that contains all allowed explosives."], GETPRVAR(QGVAR(stunsBreach),"['ACE_M84']"), true],
        ["SLIDER", ["Explosives Timer", "Sets how long the explosives take to blow after having interacted with them."], [8, 60, 20, 0]],
        ["CHECKBOX", ["Reset to default lists", "Resets the explosives & stuns lists above to the default."], false, true]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_mode", "_explosives", "_disableExplosion", "_useStun", "_stuns", "_timer", "_reset"];

        if (_reset) exitWith {
            SETPRVAR(QGVAR(explosivesBreach),"['DemoCharge_Remote_Mag']");
            SETPRVAR(QGVAR(stunsBreach),"['ACE_M84']");
            ["Reset lists to default"] call zen_common_fnc_showMessage;
        };

        SETPRVAR(QGVAR(explosivesBreach),_explosives);
        SETPRVAR(QGVAR(stunsBreach),_stuns);

        private _building = nearestObject [_pos, "Building"];

        if (isNull _building) exitWith {
            ["No building found!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        _timer = round _timer;
        private _timerString = (format ["Breach door using explosives (%1s Timer)", _timer]);
        private _sortedKeysSelectionNames = _building call FUNC(findDoors);

        if (isNil "_sortedKeysSelectionNames") exitWith {};

        private _lock = 1;

        switch (_mode) do {
            case 2: {_lock = 0};
            case 3: {_lock = 2};
            default {};
        };

        {
            [_building, _forEachIndex + 1, _lock] call zen_doors_fnc_setState;
        } forEach _sortedKeysSelectionNames;

        // Remove all previous breaching actions from building
        {
            if ("Breach door" in ((_building actionParams _x) select 0)) then {
                _building removeAction _x;
            };
        } forEach (actionIDs _building);

        [(["Building doors locked (not breachable)", "Building doors locked (breachable)", "Building doors unlocked", "Building doors opened"] select _mode)] call zen_common_fnc_showMessage;

        // 0 unbreachable, 1 breachable, 2 unlocked
        if (_mode isNotEqualTo 1) exitwith {};

        {
            [_building, [
                _timerString,
                {
                    params ["_target", "_caller", "_actionId", "_args"];
                    _args params ["_door", "_doorID", "_explosives", "_disableExplosion", "_timer", "_useStun", "_stuns"];

                    if (([_target, _doorID] call zen_doors_fnc_getState) isNotEqualTo 1) exitWith {
                        hint "You find the door to be unlocked.";
                        _target removeAction _actionId;
                    };

                    private _foundExplosive = nil;

                    {
                        if (_x in _explosives) exitWith {
                           _foundExplosive = _x;
                        };
                    } forEach (magazines _caller);

                    if (isNil "_foundExplosive") exitWith {
                        hint "You need a compatible explosive to place onto breach spot!";
                    };

                    private _exit = false;
                    private _foundStun = nil;

                    if (_useStun) then {
                        {
                            if (_x in _stuns) exitWith {
                               _foundStun = _x;
                            };
                        } forEach (magazines _caller);

                        if (isNil "_foundStun") exitWith {
                            hint "You need a compatible stun grenade to open this door!";
                            _exit = true;
                        };
                    };

                    if (_exit) exitWith {};

                    _target removeAction _actionId;

                    // Do place explosive animation
                    [_caller, "PutDown"] call ace_common_fnc_doGesture;
                    _caller setVariable ["ace_explosives_PlantingExplosive", true];

                    // Get door surface to place explosive on
                    private _unitPos = eyePos _caller;
                    private _intersection = (lineIntersectsSurfaces [_unitPos, _unitPos vectorAdd ((vectorDir _caller) vectorMultiply 2.5), _caller]) select 0;

                    // If door is out of glass for example, it will not return anything.
                    if (isNil "_intersection") exitWith {
                        hint "No surface could be found to place the explosive on.";
                    };

                    _intersection params ["_intersectPosASL", "_surfaceNormal", "_intersectObject", "_parentObject"];

                    // Spawn explosive
                    private _helperObject = "DemoCharge_F" createVehicle _intersectPosASL;
                    _helperObject setPosASL _intersectPosASL;

                    // If the surface is facing either facing N or S, we must rotate it, otherwise it isn't placed correctly.
                    if ((_surfaceNormal select 0) isEqualTo 0 && {(_surfaceNormal select 2) isEqualTo 0}) then {
                        _helperObject setVectorDirAndUp [[0, 0, 1], _surfaceNormal];
                    } else {
                        _helperObject setVectorUp _surfaceNormal;
                    };

                    // Add object to Zeus interface
                    ["zen_common_addObjects", [[_helperObject]]] call CBA_fnc_serverEvent;

                    // Remove explosives once everything is sure to go through, so player doesn't lose any.
                    _caller removeMagazine _foundExplosive;
                    if (_useStun) then {
                        _caller removeMagazine _foundStun;
                    };

                    sleep 1.5;

                    _caller setVariable ["ace_explosives_PlantingExplosive", false];
                    [(format ["Breaching in %1s!", _timer]), false, 1, 2] call ace_common_fnc_displayText;

                    sleep (_timer - 5);
                    hint "Breaching in 5...";

                    if (!_disableExplosion) then {
                        private _explosion = "mini_Grenade" createVehicle (getPosATL _helperObject);
                        _explosion attachTo [_helperObject];
                        ["zen_common_hideObjectGlobal", [_explosion, true]] call CBA_fnc_serverEvent;
                        _explosion setShotParents [_caller, _caller];
                        _explosion setDamage 1;
                    };

                    sleep 1;
                    hint "Breaching in 4...";
                    sleep 1;
                    hint "Breaching in 3...";
                    sleep 1;
                    hint "Breaching in 2...";
                    sleep 1;
                    ["Breaching in 1...", false, 1, 2] call ace_common_fnc_displayText;
                    sleep 1;

                    if (_useStun) then {
                        ["ACE_G_M84" createVehicle (getPosATL _helperObject)] call ace_grenades_fnc_flashbangThrownFuze;
                    };

                    deleteVehicle _helperObject;
                    [_target, _doorID, 2] call zen_doors_fnc_setState;
                },
                [_x, (_forEachIndex + 1), _explosives, _disableExplosion, _timer, _useStun, _stuns],
                1.5,
                true,
                true,
                "",
                "true",
                2,
                false,
                _x
             ]] remoteExecCall ["addAction", 0, true];
        } forEach _sortedKeysSelectionNames;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
