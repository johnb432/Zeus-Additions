#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates 2 modules that allow for resupplies in crates.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_createInjuries;
 *
 * Public: No
 */

["Zeus Additions", "Spawn Ammo Resupply Crate", {
    params ["_pos"];

    ["Spawn Ammo Resupply Crate", [
        ["EDIT", ["AK/RPK 5.45x39mm", RESUPPLY_TEXT], 0],
        ["EDIT", ["AK/RPK 7.62x39mm", RESUPPLY_TEXT], 0],
        ["EDIT", ["PKM/SVD 7.62x54mmR", RESUPPLY_TEXT], 0],
        ["EDIT", ["Odd BLUFOR", RESUPPLY_TEXT], 0],
        ["EDIT", ["STANAG 5.56x45mm", RESUPPLY_TEXT], 0], // 5
        ["EDIT", ["Misc 5.56x45mm", RESUPPLY_TEXT], 0],
        ["EDIT", ["Belts/C-Mags 5.56x45mm", RESUPPLY_TEXT], 0],
        ["EDIT", ["QBZ 5.8x42/KH2002 6.5x39", RESUPPLY_TEXT], 0],
        ["EDIT", ["MX 6.5x39mm", RESUPPLY_TEXT], 0],
        ["EDIT", ["ACE/FAL/SCAR 7.62x51mm", RESUPPLY_TEXT], 0], // 10
        ["EDIT", ["Belts 7.62x51mm", RESUPPLY_TEXT], 0],
        ["EDIT", ["12 Gauge", RESUPPLY_TEXT], 0],
        ["EDIT", ["Pistol BLUFOR", RESUPPLY_TEXT], 0],
        ["EDIT", ["Pistol REDFOR", RESUPPLY_TEXT], 0],
        ["EDIT", ["UGL BLUFOR", RESUPPLY_TEXT], 0], // 15
        ["EDIT", ["UGL REDFOR", RESUPPLY_TEXT], 0],
        ["EDIT", ["LAT BLUFOR", RESUPPLY_TEXT], 0],
        ["EDIT", ["LAT REDFOR", RESUPPLY_TEXT], 0],
        ["EDIT", ["MAT BLUFOR", RESUPPLY_TEXT], 0],
        ["EDIT", ["MAT REDFOR", RESUPPLY_TEXT], 0], // 20
        ["EDIT", ["HAT BLUFOR (Ammo)", RESUPPLY_TEXT], 0],
        ["EDIT", ["HAT BLUFOR (Launcher)", RESUPPLY_TEXT], 0],
        ["EDIT", ["CLU for BAF Javelin", "Spawns x amount of BAF CLUs."], 0],
        ["EDIT", ["HAT REDFOR", RESUPPLY_TEXT], 0],
        ["EDIT", ["AA BLUFOR", RESUPPLY_TEXT], 0], // 25
        ["EDIT", ["AA REDFOR", RESUPPLY_TEXT], 0]
    ],
    {
        params ["_results", "_pos"];

        private _object = "Box_NATO_Equip_F" createVehicle _pos;
        {
            [_x, [[_object], true]] remoteExec ["addCuratorEditableObjects", _x, true];
        } forEach allCurators;
        clearItemCargoGlobal _object;

        private _numAT = [_results select 16, _results select 17, _results select 21, _results select 22];

        _results deleteRange [16, 2];
        _results deleteRange [19, 2];

        private _num = 0;

        {
            _num = parseNumber _x;
            if (_num > 0) then {
                {
                    _object addItemCargoGlobal [_x, _num];
                } forEach (GVAR(magsTotal) select _forEachIndex);
            };
        } forEach _results;

        {
            _num = parseNumber _x;
            if (_num > 0) then {
                {
                    _object addWeaponCargoGlobal [_x, _num];
                } forEach (GVAR(weaponsTotal) select _forEachIndex);
            };
        } forEach _numAT;

        [_object, true, [0,0,0], 0, true] remoteExec ["ace_dragging_fnc_setDraggable", 0, true];
        [_object, true, [0,0,0], 0, true] remoteExec ["ace_dragging_fnc_setCarryable", 0, true];

        ["Ammo crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;



["Zeus Additions", "Spawn Ammo Resupply for unit", {
    params ["_pos", "_unit"];

    ["Spawn Ammo Resupply Crate", [
        ["OWNERS", ["Player selected", "Select a player from the list to determine which ammunition to spawn. If multiple are chosen only the first one selected will be looked at."], [[], [], [], 2], true],
        ["EDIT", ["Primary Magazines", "Spawns in x amount of each primary weapon compatible magazines (not x total!)."], 20],
        ["EDIT", ["Sidearm Magazines", "Spawns in x amount of each sidearm compatible magazines (not x total!)."], 10],
        ["EDIT", ["Tertiary Magazine", "Spawns in x amount of each launcher compatible magazines (not x total!)."], 5],
        ["CHECKBOX", ["Include UGL ammo", "Also checks for UGLs and spawns ammo for UGLs if enabled."], false, true],
        ["CHECKBOX", ["Allow blacklisted ammo", "Allows ammo that is normally blacklisted to be spawned in."], false, true]
    ],
    {
        params ["_results", "_info"];

        _results params ["_players", "_numPrim", "_numHand", "_numSec", "_allowUGL", "_allowBlackList"];
        _info params ["_pos", "_unit"];

        if  (_players select 2 isEqualTo [] && {isNull _unit}) exitWith {
            ["Select a player!"] call zen_common_fnc_showMessage;
        };

        if (!(_players select 0 isEqualTo []) || {!(_players select 1 isEqualTo [])}) exitWith {
            ["Select a player only!"] call zen_common_fnc_showMessage;
        };

        private _player = _players select 2 select 0;

        if (!isNull _player) then {
            _unit = _player;
        };

        private _object = "Box_NATO_Equip_F" createVehicle _pos;
        {
            [_x, [[_object], true]] remoteExec ["addCuratorEditableObjects", _x, true];
        } forEach allCurators;
        clearItemCargoGlobal _object;

        _numPrim = parseNumber _numPrim;
        _numHand = parseNumber _numHand;
        _numSec = parseNumber _numSec;

        if (_numPrim == 0 && {_numHand == 0} && {_numSec == 0}) exitWith {
            ["Empty ammo crate created"] call zen_common_fnc_showMessage;
        };

        private _blackList = if !(_allowBlackList) then {GVAR(blacklist)} else {[]};

        if (_numPrim > 0 && {!isNil {primaryWeapon _unit}}) then {
            private _magsPrim = [primaryWeapon _unit, _allowUGL] call CBA_fnc_compatibleMagazines;
            _magsPrim = _magsPrim - _blackList;
            {
                _object addItemCargoGlobal [_x, _numPrim];
            } forEach _magsPrim;
        };

        if (_numHand > 0 && {!isNil {handgunWeapon _unit}}) then {
            private _magsHand = [handgunWeapon _unit] call CBA_fnc_compatibleMagazines;
            _magsHand = _magsHand - _blackList;
            {
                _object addItemCargoGlobal [_x, _numHand];
            } forEach _magsHand;
        };

        if (_numSec > 0 && {!isNil {secondaryWeapon _unit}}) then {
            private _magsSec = [secondaryWeapon _unit] call CBA_fnc_compatibleMagazines;
            {
                _object addItemCargoGlobal [_x, _numSec];
            } forEach _magsSec;
        };

        [_object, true, [0,0,0], 0, true] remoteExec ["ace_dragging_fnc_setDraggable", 0, true];
        [_object, true, [0,0,0], 0, true] remoteExec ["ace_dragging_fnc_setCarryable", 0, true];

        ["Ammo crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_pos, _unit]] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
