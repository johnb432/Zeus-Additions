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
 * call zeus_additions_main_fnc_ammoResupply;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

["Zeus Additions - Resupply", "Spawn Ammo Resupply Crate", {
    params ["_pos", "_object"];

    ["Spawn Ammo Resupply Crate", [
        ["SLIDER", ["AK/RPK 5.45x39mm", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["AK/RPK 7.62x39mm", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["PKM/SVD 7.62x54mmR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["Odd BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["STANAG 5.56x45mm", RESUPPLY_TEXT], [0, 200, 0, 0]], // 5
        ["SLIDER", ["Misc 5.56x45mm", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["Belts/C-Mags 5.56x45mm", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["QBZ 5.8x42/KH2002 6.5x39", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["MX 6.5x39mm", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["ACE/FAL/SCAR 7.62x51mm", RESUPPLY_TEXT], [0, 200, 0, 0]], // 10
        ["SLIDER", ["Belts 7.62x51mm", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["12 Gauge", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["Pistol BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["Pistol REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["UGL BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]], // 15
        ["SLIDER", ["UGL REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["LAT BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["LAT REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["MAT BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["MAT REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]], // 20
        ["SLIDER", ["HAT BLUFOR (Ammo)", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["HAT BLUFOR (Launcher)", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["CLU for BAF Javelin", "Spawns x amount of BAF CLUs."], [0, 200, 0, 0]],
        ["SLIDER", ["HAT REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["AA BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]], // 25
        ["SLIDER", ["AA REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["TOOLBOX:WIDE", ["Spawn Ammo Box", "If no, it selects the object the module was placed on and places stuff in its inventory."], [0, 1, 3, ["Spawn Ammo Box","Put in inventory","Clear inventory and insert"]], false]
    ],
    {
        params ["_results", "_args"];
        _args params ["_pos", "_object"];

        private _exit = false;

        private _emptyInventory = _results select (count _results - 1);

        // If make a new object
        if (_emptyInventory isEqualTo 0) then {
            _object = "Box_NATO_Equip_F" createVehicle _pos;
            ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
            clearItemCargoGlobal _object;

            ["zen_common_execute", [ace_dragging_fnc_setDraggable, [_object, true, [0, 1.25, 0], 0, true]]] call CBA_fnc_globalEventJIP;
            ["zen_common_execute", [ace_dragging_fnc_setCarryable, [_object, true, [0, 1.25, 0.5], 90, true]]] call CBA_fnc_globalEventJIP;
        };

        private _config = configOf _object;

        // If insert into inventory, but no inventory found or enabled
        if (_emptyInventory > 0 && {isNull _object || {getNumber (_config >> "maximumLoad") isEqualTo 0} || {getNumber (_config >> "disableInventory") isEqualTo 1}}) exitWith {
            ["Object has no inventory!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        // Clear all content of other types of inventories
        if (_emptyInventory isEqualTo 2) then {
            clearItemCargoGlobal _object;
            clearMagazineCargoGlobal _object;
            clearWeaponCargoGlobal _object;
            clearBackpackCargoGlobal _object;
        };

        _results deleteAt (count _results - 1);

        private _numAT = [_results select 16, _results select 17, _results select 21, _results select 22];

        _results deleteRange [16, 2];
        _results deleteRange [19, 2];

        private _num;

        {
            _num = _x;
            if (_num > 0) then {
                {
                    _object addItemCargoGlobal [_x, _num];
                } forEach (GVAR(magsTotal) select _forEachIndex);
            };
        } forEach _results;

        {
            _num = _x;
            if (_num > 0) then {
                {
                    _object addWeaponCargoGlobal [_x, _num];
                } forEach (GVAR(weaponsTotal) select _forEachIndex);
            };
        } forEach _numAT;

        ["Ammo crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_pos, _object]] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions - Resupply", "Spawn Ammo Resupply for unit", {
    params ["_pos", "_unit"];

    ["Spawn Ammo Resupply Crate", [
        ["OWNERS", ["Player selected", "Select a player from the list to determine which ammunition to spawn. If multiple are chosen only the first one selected will be looked at."], [[], [], [], 2], true],
        ["SLIDER", ["Primary Magazines", "Spawns in x amount of each primary weapon compatible magazines (not x total!)."], [0, 200, 20, 0]],
        ["SLIDER", ["Sidearm Magazines", "Spawns in x amount of each sidearm compatible magazines (not x total!)."], [0, 200, 10, 0]],
        ["SLIDER", ["Tertiary Magazine", "Spawns in x amount of each launcher compatible magazines (not x total!)."], [0, 200, 5, 0]],
        ["TOOLBOX:YESNO", ["Include UGL ammo", "Also checks for UGLs and spawns ammo for UGLs if enabled."], false, true],
        ["TOOLBOX:YESNO", ["Allow blacklisted ammo", "Allows ammo that is normally blacklisted to be spawned in."], false, true]
    ],
    {
        params ["_results", "_info"];

        _results params ["_players", "_numPrim", "_numHand", "_numSec", "_allowUGL", "_allowBlackList"];
        _info params ["_pos", "_unit"];

        if (_players select 2 isEqualTo [] && {isNull _unit}) exitWith {
            ["Place module on a player or select a player from the list!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _player = _players select 2 select 0;

        if (!isNull _player) then {
            _unit = _player;
        };

        private _object = "Box_NATO_Equip_F" createVehicle _pos;
        ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
        clearItemCargoGlobal _object;

        ["zen_common_execute", [ace_dragging_fnc_setDraggable, [_object, true, [0, 1.25, 0], 0, true]]] call CBA_fnc_globalEventJIP;
        ["zen_common_execute", [ace_dragging_fnc_setCarryable, [_object, true, [0, 1.25, 0.5], 90, true]]] call CBA_fnc_globalEventJIP;

        if (_numPrim isEqualTo 0 && {_numHand isEqualTo 0} && {_numSec isEqualTo 0}) exitWith {
            ["Empty ammo crate created"] call zen_common_fnc_showMessage;
        };

        private _blackList = [GVAR(blacklist), []] select _allowBlackList;

        if (_numPrim > 0 && {!isNil {primaryWeapon _unit}}) then {
            {
                _object addItemCargoGlobal [_x, _numPrim];
            } forEach (([primaryWeapon _unit, _allowUGL] call CBA_fnc_compatibleMagazines) - _blackList);
        };

        if (_numHand > 0 && {!isNil {handgunWeapon _unit}}) then {
            {
                _object addItemCargoGlobal [_x, _numHand];
            } forEach (([handgunWeapon _unit] call CBA_fnc_compatibleMagazines) - _blackList);
        };

        if (_numSec > 0 && {!isNil {secondaryWeapon _unit}}) then {
            {
                _object addItemCargoGlobal [_x, _numSec];
            } forEach (([secondaryWeapon _unit] call CBA_fnc_compatibleMagazines) - _blackList);
        };

        ["Ammo crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_pos, _unit]] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
