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
 * call zeus_additions_main_fnc_createResupply;
 *
 * Public: No
 */

["Zeus Additions - Resupply", "Spawn Ammo Resupply", {
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
        ["TOOLBOX:WIDE", ["Spawn Ammo Box", "If no, it selects the object the module was placed on and places items in its inventory."], [0, 1, 3, ["Spawn Ammo Box", "Insert in inventory", "Clear inventory and insert"]], false]
    ],
    {
        params ["_results", "_args"];
        _args params ["_pos", "_object"];

        private _emptyInventory = _results select (count _results - 1);

        // If "spawn ammo box", make a new object
        if (_emptyInventory isEqualTo 0) then {
            _object = "Box_NATO_Ammo_F" createVehicle _pos;
            ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
            clearMagazineCargoGlobal _object;

            ["zen_common_execute", [ace_dragging_fnc_setDraggable, [_object, true, [configOf _object, "ace_dragging_dragPosition", [0, 1.25, 0]] call BIS_fnc_returnConfigEntry, [configOf _object, "ace_dragging_dragDirection", 0] call BIS_fnc_returnConfigEntry, true]]] call CBA_fnc_globalEventJIP;
            ["zen_common_execute", [ace_dragging_fnc_setCarryable, [_object, true, [configOf _object, "ace_dragging_carryPosition", [0, 1.25, 0.5]] call BIS_fnc_returnConfigEntry, [configOf _object, "ace_dragging_carryDirection", 90] call BIS_fnc_returnConfigEntry, true]]] call CBA_fnc_globalEventJIP;
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

        // Get weapons (so anything AT)
        private _numAT = [_results select 16, _results select 17, _results select 21, _results select 22];

        _results deleteRange [16, 2];
        _results deleteRange [19, 2];

        private _num = 0;

        // Spawn magazines
        {
            _num = _x;
            if (_num > 0) then {
                {
                    _object addItemCargoGlobal [_x, _num];
                } forEach (GVAR(magsTotal) select _forEachIndex);
            };
        } forEach _results;

        // Spawn weapons
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
}, ICON_INVENTORY] call zen_custom_modules_fnc_register;

["Zeus Additions - Resupply", "Spawn Ammo Resupply for Unit", {
    params ["_pos", "_object"];

    ["Spawn Ammo Resupply for Unit", [
        ["OWNERS", ["Player selected", "Select a player from the list to determine which ammunition to spawn. If multiple are chosen only the first one selected will be looked at."], [[], [], [], 2], true],
        ["SLIDER", ["Primary Magazines", "Spawns in x amount of each primary weapon compatible magazines (not x total!)."], [0, 200, 20, 0]],
        ["SLIDER", ["Sidearm Magazines", "Spawns in x amount of each sidearm compatible magazines (not x total!)."], [0, 200, 10, 0]],
        ["SLIDER", ["Tertiary Magazine", "Spawns in x amount of each launcher compatible magazines (not x total!)."], [0, 200, 5, 0]],
        ["TOOLBOX:YESNO", ["Include UGL ammo", "Also checks for UGLs and spawns ammo for UGLs if enabled."], false, true],
        ["TOOLBOX:YESNO", ["Allow blacklisted ammo", "Allows ammo that is normally blacklisted to be spawned in."], false, true],
        ["TOOLBOX:WIDE", ["Spawn Ammo Box", "If no, it selects the object the module was placed on and places items in its inventory. Units are excluded from this."], [0, 1, 3, ["Spawn Ammo Box", "Insert in inventory", "Clear inventory and insert"]], false]
    ],
    {
        params ["_results", "_args"];

        _results params ["_players", "_numPrim", "_numHand", "_numSec", "_allowUGL", "_allowBlackList", "_emptyInventory"];
        _args params ["_pos", "_object"];

        // Find if the module was placed on a unit
        private _unit = [objNull, _object] select (_object isKindOf "CAManBase" && {isPlayer _object});

        // If no player is selected in the dialog and the module isn't placed on a player, exit
        if ((_players select 2) isEqualTo [] && {!isPlayer _unit}) exitWith {
            ["Place module on a player or select a player from the list!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        // Select first player from dialog
        private _player = _players select 2 select 0;

        // If no player found, take unit on which the module was placed
        if (!isNull _player) then {
            _unit = _player;
        };

        // If "spawn ammo box", make a new object
        if (_emptyInventory isEqualTo 0) then {
            _object = "Box_NATO_Ammo_F" createVehicle _pos;
            ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
            clearMagazineCargoGlobal _object;

            ["zen_common_execute", [ace_dragging_fnc_setDraggable, [_object, true, [configOf _object, "ace_dragging_dragPosition", [0, 1.25, 0]] call BIS_fnc_returnConfigEntry, [configOf _object, "ace_dragging_dragDirection", 0] call BIS_fnc_returnConfigEntry, true]]] call CBA_fnc_globalEventJIP;
            ["zen_common_execute", [ace_dragging_fnc_setCarryable, [_object, true, [configOf _object, "ace_dragging_carryPosition", [0, 1.25, 0.5]] call BIS_fnc_returnConfigEntry, [configOf _object, "ace_dragging_carryDirection", 90] call BIS_fnc_returnConfigEntry, true]]] call CBA_fnc_globalEventJIP;
        };

        if (_numPrim isEqualTo 0 && {_numHand isEqualTo 0} && {_numSec isEqualTo 0}) exitWith {
            ["Empty ammo crate created"] call zen_common_fnc_showMessage;
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

        // Check if blacklist is enabled
        private _blackList = [GVAR(blacklist), []] select _allowBlackList;

        // Add primary weapon ammo
        if (_numPrim > 0 && {!isNil {primaryWeapon _unit}}) then {
            {
                _object addItemCargoGlobal [_x, _numPrim];
            } forEach (([primaryWeapon _unit, _allowUGL] call CBA_fnc_compatibleMagazines) - _blackList);
        };

        // Add side arm ammo
        if (_numHand > 0 && {!isNil {handgunWeapon _unit}}) then {
            {
                _object addItemCargoGlobal [_x, _numHand];
            } forEach (([handgunWeapon _unit] call CBA_fnc_compatibleMagazines) - _blackList);
        };

        // Add tertiary weapon ammo (launchers etc)
        if (_numSec > 0 && {!isNil {secondaryWeapon _unit}}) then {
            {
                _object addItemCargoGlobal [_x, _numSec];
            } forEach (([secondaryWeapon _unit] call CBA_fnc_compatibleMagazines) - _blackList);
        };

        ["Ammo crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_pos, _object]] call zen_dialog_fnc_create;
}, ICON_INVENTORY] call zen_custom_modules_fnc_register;

["Zeus Additions - Resupply", "Spawn ACE Medical Resupply", {
    params ["_pos", "_object"];

    ["Spawn ACE Medical Resupply", [
        ["SLIDER", "Bandages (Elastic)", [0, 300, GETPRVAR(QGVAR(elastic),200), 0], true],
        ["SLIDER", "Bandages (Packing)", [0, 300, GETPRVAR(QGVAR(packing),200), 0], true],
        ["SLIDER", "Bandages (Quickclot)", [0, 300, GETPRVAR(QGVAR(quickclot),50), 0], true],
        ["SLIDER", "Bandages (Basic)", [0, 300, GETPRVAR(QGVAR(elastic),0), 0], true],
        ["SLIDER", "1000ml Blood", [0, 50, GETPRVAR(QGVAR(blood1000),25), 0], true],
        ["SLIDER", "500ml Blood", [0, 100, GETPRVAR(QGVAR(blood500),50), 0], true],
        ["SLIDER", "250ml Blood", [0, 100, GETPRVAR(QGVAR(blood250),0), 0], true],
        ["SLIDER", "1000ml Plasma", [0, 50, GETPRVAR(QGVAR(plasma1000),0), 0], true],
        ["SLIDER", "500ml Plasma", [0, 100, GETPRVAR(QGVAR(plasma500),30), 0], true],
        ["SLIDER", "250ml Plasma", [0, 100, GETPRVAR(QGVAR(plasma250),0), 0], true],
        ["SLIDER", "1000ml Saline", [0, 50, GETPRVAR(QGVAR(saline1000),0), 0], true],
        ["SLIDER", "500ml Saline", [0, 100, GETPRVAR(QGVAR(saline500),30), 0], true],
        ["SLIDER", "250ml Saline", [0, 100, GETPRVAR(QGVAR(saline250),0), 0], true],
        ["SLIDER", "Epinephrine autoinjector", [0, 50, GETPRVAR(QGVAR(epinephrine),30), 0], true],
        ["SLIDER", "Morphine autoinjector", [0, 50, GETPRVAR(QGVAR(morphine),30), 0], true],
        ["SLIDER", "Adenosine autoinjector", [0, 50, GETPRVAR(QGVAR(adenosine),0), 0], true],
        ["SLIDER", "Splint", [0, 100, GETPRVAR(QGVAR(splint),50), 0], true],
        ["SLIDER", "Tourniquet (CAT)", [0, 100, GETPRVAR(QGVAR(tourniquet),40), 0], true],
        ["SLIDER", "Bodybag", [0, 50, GETPRVAR(QGVAR(bodybag),20), 0], true],
        ["SLIDER", "Surgical Kit", [0, 100, GETPRVAR(QGVAR(surgical),0), 0], true],
        ["SLIDER", "Personal Aid Kit", [0, 100, GETPRVAR(QGVAR(PAK),0), 0], true],
        ["TOOLBOX:WIDE", ["Spawn Medical Crate", "If no, it selects the object the module was placed on and places items in its inventory."], [0, 1, 3, ["Spawn Medical Crate", "Insert in inventory", "Clear inventory and insert"]], false],
        ["CHECKBOX", ["Reset to default"], false, true]
    ],
    {
        params ["_results", "_args"];
        _args params ["_pos", "_object"];

        // If reset if wanted
        if (_results select (count _results - 1)) exitWith {
            SETPRVAR(QGVAR(elastic),200);
            SETPRVAR(QGVAR(packing),200);
            SETPRVAR(QGVAR(quickclot),50);
            SETPRVAR(QGVAR(basic),0);
            SETPRVAR(QGVAR(blood1000),25);
            SETPRVAR(QGVAR(blood500),50);
            SETPRVAR(QGVAR(blood250),0);
            SETPRVAR(QGVAR(plasma1000),0);
            SETPRVAR(QGVAR(plasma500),30);
            SETPRVAR(QGVAR(plasma250),0);
            SETPRVAR(QGVAR(saline1000),0);
            SETPRVAR(QGVAR(saline500),30);
            SETPRVAR(QGVAR(saline250),0);
            SETPRVAR(QGVAR(epinephrine),30);
            SETPRVAR(QGVAR(morphine),30);
            SETPRVAR(QGVAR(adenosine),0);
            SETPRVAR(QGVAR(splint),50);
            SETPRVAR(QGVAR(tourniquet),40);
            SETPRVAR(QGVAR(bodybag),20);
            SETPRVAR(QGVAR(surgical),0);
            SETPRVAR(QGVAR(PAK),0);

            ["Reset to default completed"] call zen_common_fnc_showMessage;
        };

        private _emptyInventory = _results select (count _results - 2);

        // If "spawn medical crate", make a new object
        if (_emptyInventory isEqualTo 0) then {
            // Spawn medical crate
            _object = "ACE_medicalSupplyCrate_advanced" createVehicle _pos;
            ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
            clearItemCargoGlobal _object;

            // Make crate draggable and carryable, with correct offsets to position and direction, along with overweight dragging possibility
            ["zen_common_execute", [ace_dragging_fnc_setDraggable, [_object, true, [configOf _object, "ace_dragging_dragPosition", [0, 1.25, 0]] call BIS_fnc_returnConfigEntry, [configOf _object, "ace_dragging_dragDirection", 90] call BIS_fnc_returnConfigEntry, true]]] call CBA_fnc_globalEventJIP;
            ["zen_common_execute", [ace_dragging_fnc_setCarryable, [_object, true, [configOf _object, "ace_dragging_carryPosition", [0, 0.8, 0.8]] call BIS_fnc_returnConfigEntry, [configOf _object, "ace_dragging_carryDirection", 0] call BIS_fnc_returnConfigEntry, true]]] call CBA_fnc_globalEventJIP;
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

        private _items = [
            "ACE_elasticBandage",
            "ACE_packingBandage",
            "ACE_quikclot",
            "ACE_fieldDressing",
            "ACE_bloodIV",
            "ACE_bloodIV_500",
            "ACE_bloodIV_250",
            "ACE_plasmaIV",
            "ACE_plasmaIV_500",
            "ACE_plasmaIV_250",
            "ACE_salineIV",
            "ACE_salineIV_500",
            "ACE_salineIV_250",
            "ACE_epinephrine",
            "ACE_morphine",
            "ACE_adenosine",
            "ACE_splint",
            "ACE_tourniquet",
            "ACE_bodyBag",
            "ACE_surgicalKit",
            "ACE_personalAidKit"
        ];

        // Add items to crate and set profile to have number of items
        {
            _object addItemCargoGlobal [_items select _forEachIndex, _results select _forEachIndex];
            SETPRVAR(_x,_results select _forEachIndex);
        } forEach [
            QGVAR(elastic), QGVAR(packing), QGVAR(quickclot), QGVAR(basic),
            QGVAR(blood1000), QGVAR(blood500), QGVAR(blood250),
            QGVAR(plasma1000), QGVAR(plasma500), QGVAR(plasma250),
            QGVAR(saline1000), QGVAR(saline500), QGVAR(saline250),
            QGVAR(epinephrine), QGVAR(morphine), QGVAR(adenosine),
            QGVAR(splint), QGVAR(tourniquet),
            QGVAR(bodybag), QGVAR(surgical), QGVAR(PAK)
        ];

        ["Medical crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_pos, _object]] call zen_dialog_fnc_create;
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
