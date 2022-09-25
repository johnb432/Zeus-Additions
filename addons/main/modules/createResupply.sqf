/*
 * Author: johnb43
 * Creates 2 modules that allow for resupplies in crates.
 */

["Zeus Additions - Resupply", "Spawn Ammo Resupply for Players", {
    ["Spawn Ammo Resupply for Players", [
        ["OWNERS", ["Players selected", "Select sides/groups/players to determine which ammunition to spawn. Module can also be placed on a player."], [[], [], [], 2], true],
        ["SLIDER", ["Primary Magazines", "Spawns in x amount of each primary weapon compatible magazines for each unit (not x total!)."], [0, 200, 20, 0]],
        ["SLIDER", ["Sidearm Magazines", "Spawns in x amount of each sidearm compatible magazines for each unit (not x total!)."], [0, 200, 10, 0]],
        ["SLIDER", ["Tertiary Magazine", "Spawns in x amount of each launcher compatible magazines for each unit (not x total!)."], [0, 200, 5, 0]],
        ["TOOLBOX:YESNO", ["Allow blacklisted ammo", "Allows ammo that is normally blacklisted to be spawned in."], false, true],
        ["TOOLBOX:WIDE", ["Spawn Ammo Box", "If no, it selects the object the module was placed on and places items in its inventory. Units are excluded from this."], [0, 1, 3, ["Spawn Ammo Box", "Insert in inventory", "Clear inventory and insert"]]]
    ],
    {
        params ["_results", "_args"];

        _results params ["_selected", "_numPrim", "_numHand", "_numSec", "_allowBlackList", "_emptyInventory"];
        _args params ["_pos", "_object"];
        _selected params ["_sides", "_groups", "_players"];

        if (alive _object && {isPlayer _object} && {_object isKindOf "CAManBase"}) then {
            _players pushBackUnique _object;
        };

        // If no player is selected in the dialog and the module isn't placed on a player, exit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            ["Place module on a player or select units from the list"] call zen_common_fnc_showMessage;
        };

        // If insert into inventory, but no inventory found or enabled
        if (_emptyInventory > 0 && {!alive _object || {maxLoad _object == 0} || {getNumber (configOf _object >> "disableInventory") == 1}}) exitWith {
            ["Object has no inventory"] call zen_common_fnc_showMessage;
        };

        // If "spawn ammo box", make a new object
        if (_emptyInventory == 0) then {
            _object = "Box_NATO_Ammo_F" createVehicle _pos;
            ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
            clearMagazineCargoGlobal _object;

            if (!GVAR(ACEDraggingLoaded)) exitWith {};;

            // Make crate draggable and carryable, with correct offsets to position and direction, along with overweight dragging possibility
            // Remove event immediately so that it's removed from JIP queue in case object gets deleted. https://cbateam.github.io/CBA_A3/docs/files/events/fnc_removeGlobalEventJIP-sqf.html
            [["zen_common_execute", [{
                params ["_object", "_config"];

                // Dragging & Carrying
                [_object, true, [_config, "ace_dragging_dragPosition", [0, 1.25, 0]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_dragDirection", 0] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setDraggable;
                [_object, true, [_config, "ace_dragging_carryPosition", [0, 1.25, 0.5]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_carryDirection", 90] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setCarryable;
            }, [_object, configOf _object]]] call CBA_fnc_globalEventJIP, _object] call CBA_fnc_removeGlobalEventJIP;
        };

        if (_numPrim == 0 && {_numHand == 0} && {_numSec == 0}) exitWith {
            ["Empty ammo crate created"] call zen_common_fnc_showMessage;
        };

        // Clear all content of other types of inventories
        if (_emptyInventory == 2) then {
            clearItemCargoGlobal _object;
            clearMagazineCargoGlobal _object;
            clearWeaponCargoGlobal _object;
            clearBackpackCargoGlobal _object;
        };

        // Check if blacklist is enabled
        private _blackList = [GVAR(blacklist), []] select _allowBlackList;

        // Spawn ammo
        {
            if (_numPrim > 0 && {(primaryWeapon _x) != ""}) then {
                {
                    _object addItemCargoGlobal [_x, _numPrim];
                } forEach (compatibleMagazines (primaryWeapon _x) - _blackList);
            };

            if (_numHand > 0 && {(handgunWeapon _unit) != ""}) then {
                {
                    _object addItemCargoGlobal [_x, _numHand];
                } forEach (compatibleMagazines (handgunWeapon _x) - _blackList);
            };

            if (_numSec > 0 && {(secondaryWeapon _unit) != ""}) then {
                {
                    _object addItemCargoGlobal [_x, _numSec];
                } forEach (compatibleMagazines (secondaryWeapon _x) - _blackList);
            };
        } forEach ((call CBA_fnc_players) select {(side _x) in _sides || {(group _x) in _groups || {_x in _players}}});

        ["Ammo resupply created"] call zen_common_fnc_showMessage;
    }, {}, _this] call zen_dialog_fnc_create;
}, ICON_INVENTORY] call zen_custom_modules_fnc_register;

["Zeus Additions - Resupply", "Spawn Ammo Resupply for Players (Selection)", {
    ["Spawn Ammo Resupply (Magazine selection comes after this dialog)", [
        ["OWNERS", ["Players selected", "Select sides/groups/players to determine which ammunition to spawn. Module can also be placed on a player."], [[], [], [], 2], true],
        ["SLIDER", ["LAT BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["LAT REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["MAT BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["MAT REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["HAT BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]], // 5
        ["SLIDER", ["HAT REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["AA BLUFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["SLIDER", ["AA REDFOR", RESUPPLY_TEXT], [0, 200, 0, 0]],
        ["TOOLBOX:WIDE", ["Spawn Ammo Box", "If no, it selects the object the module was placed on and places items in its inventory. Units are excluded from this."], [0, 1, 3, ["Spawn Ammo Box", "Insert in inventory", "Clear inventory and insert"]]]
    ],
    {
        params ["_results", "_args"];

        _args params ["_pos", "_object"];
        (_results deleteAt 0) params ["_sides", "_groups", "_players"];

        if (alive _object && {isPlayer _object} && {_object isKindOf "CAManBase"}) then {
            _players pushBackUnique _object;
        };

        private _emptyInventory = _results deleteAt (count _results - 1);

        // If insert into inventory, but no inventory found or enabled
        if (_emptyInventory > 0 && {!alive _object || {maxLoad _object == 0} || {getNumber (configOf _object >> "disableInventory") == 1}}) exitWith {
            ["Object has no inventory"] call zen_common_fnc_showMessage;
        };

        // If "spawn ammo box", make a new object
        if (_emptyInventory == 0) then {
            _object = "Box_NATO_Ammo_F" createVehicle _pos;
            ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
            clearMagazineCargoGlobal _object;

            if (!GVAR(ACEDraggingLoaded)) exitWith {};

            // Make crate draggable and carryable, with correct offsets to position and direction, along with overweight dragging possibility
            // Remove event immediately so that it's removed from JIP queue in case object gets deleted. https://cbateam.github.io/CBA_A3/docs/files/events/fnc_removeGlobalEventJIP-sqf.html
            [["zen_common_execute", [{
                params ["_object", "_config"];

                // Dragging & Carrying
                [_object, true, [_config, "ace_dragging_dragPosition", [0, 1.25, 0]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_dragDirection", 0] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setDraggable;
                [_object, true, [_config, "ace_dragging_carryPosition", [0, 1.25, 0.5]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_carryDirection", 90] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setCarryable;
            }, [_object, configOf _object]]] call CBA_fnc_globalEventJIP, _object] call CBA_fnc_removeGlobalEventJIP;
        };

        // Clear all content of other types of inventories
        if (_emptyInventory == 2) then {
            clearItemCargoGlobal _object;
            clearMagazineCargoGlobal _object;
            clearWeaponCargoGlobal _object;
            clearBackpackCargoGlobal _object;
        };

        private _num = 0;

        // Spawn items
        {
            _num = _x;

            if (_num > 0) then {
                {
                    _object addItemCargoGlobal [_x, _num];
                } forEach (GVAR(magsTotal) select _forEachIndex);
            };
        } forEach _results;

        // Pass inventory object to uiNamespace
        SETUVAR(QGVAR(magazineInventory),_object);

        // Get all weapons from all players (even from inventories)
        private _weapons = flatten (((call CBA_fnc_players) select {(side _x) in _sides || {(group _x) in _groups || {_x in _players}}}) apply {weapons _x});

        // Spawn ammo GUI
        [_weapons arrayIntersect _weapons] spawn FUNC(createResupplyGUI);
    }, {}, _this] call zen_dialog_fnc_create;
}, ICON_INVENTORY] call zen_custom_modules_fnc_register;
