/*
 * Author: johnb43
 * Creates 2 modules that allow for resupplies in crates.
 */

[LSTRING(moduleCategoryResupply), LSTRING(ammoResupplyModuleName), {
    [LSTRING(ammoResupplyModuleName), [
        ["OWNERS", [LSTRING_ZEN(context_Actions,selected), LSTRING(selectSidesGroupsUnits)], [[], [], [], 2], true],
        ["SLIDER", ["str_a3_cfgvehicleclasses_weaponsprimary0", LSTRING(ammoResupplyAmountDesc)], [0, 200, 20, 0]],
        ["SLIDER", ["str_a3_cfgvehicleclasses_weaponshandguns0", LSTRING(ammoResupplyAmountDesc)], [0, 200, 10, 0]],
        ["SLIDER", ["str_a3_cfgvehicleclasses_weaponssecondary0", LSTRING(ammoResupplyAmountDesc)], [0, 200, 5, 0]],
        ["TOOLBOX:YESNO", [LSTRING(ammoResupplyallowBlacklist), LSTRING(ammoResupplyallowBlacklistDesc)], false, true],
        ["TOOLBOX:WIDE", [LSTRING(spawnCreate), LSTRING(spawnCreateDesc)], [0, 1, 3, [LSTRING(spawnCreate), LSTRING(insertInventory), LSTRING(clearInventory)]]]
    ], {
        params ["_results", "_args"];

        _results params ["_selected", "_numPrim", "_numHand", "_numSec", "_allowBlackList", "_emptyInventory"];
        _args params ["_pos", "_object"];
        _selected params ["_sides", "_groups", "_players"];

        if (alive _object && {isPlayer _object} && {_object isKindOf "CAManBase"} && {!(_object isKindOf "VirtualCurator_F")}) then {
            _players pushBackUnique _object;
        };

        // If no player is selected in the dialog and the module isn't placed on a player, exit
        if (_sides isEqualTo [] && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            [LSTRING_ZEN(modules,onlyPlayers)] call zen_common_fnc_showMessage;
        };

        // If insert into inventory, but no inventory found or enabled
        if (_emptyInventory > 0 && {!alive _object || {maxLoad _object == 0} || {getNumber (configOf _object >> "disableInventory") == 1}}) exitWith {
            [LSTRING(objectHasNoInventory)] call zen_common_fnc_showMessage;
        };

        // If "spawn ammo box", make a new object
        if (_emptyInventory == 0) then {
            _object = "Box_NATO_Ammo_F" createVehicle _pos;
            _object call zen_common_fnc_updateEditableObjects;
            clearMagazineCargoGlobal _object;

            if (isNil "ace_dragging") exitWith {};

            if (isNil QFUNC(setResupplyDraggable)) then {
                DFUNC(setResupplyDraggable) = [{
                    params ["_object", "_config"];

                    // Dragging & Carrying
                    [_object, true, [_config, "ace_dragging_dragPosition", [0, 1.25, 0]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_dragDirection", 0] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setDraggable;
                    [_object, true, [_config, "ace_dragging_carryPosition", [0, 1.25, 0.5]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_carryDirection", 90] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setCarryable;
                }, true, true] call FUNC(sanitiseFunction);

                SEND_MP(setResupplyDraggable);
            };

            // Make crate draggable and carryable, with correct offsets to position and direction, along with overweight dragging possibility; Overwrite previous entry in JIP queue
            [[QGVAR(setResupplyDraggable), [_object, configOf _object], QGVAR(dragging_) + netId _object] call CBA_fnc_globalEventJIP, _object] call CBA_fnc_removeGlobalEventJIP;
        };

        if (_numPrim == 0 && {_numHand == 0} && {_numSec == 0}) exitWith {
            [LSTRING(ammoResupplyEmptyCrateMessage)] call zen_common_fnc_showMessage;
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

        // Spawn ammo; 'addItemCargoGlobal' allows overloading of inventories
        {
            if (_numPrim > 0 && {(primaryWeapon _x) != ""}) then {
                {
                    _object addItemCargoGlobal [_x, _numPrim];
                } forEach (compatibleMagazines (primaryWeapon _x) - _blackList);
            };

            if (_numHand > 0 && {(handgunWeapon _x) != ""}) then {
                {
                    _object addItemCargoGlobal [_x, _numHand];
                } forEach (compatibleMagazines (handgunWeapon _x) - _blackList);
            };

            if (_numSec > 0 && {(secondaryWeapon _x) != ""}) then {
                {
                    _object addItemCargoGlobal [_x, _numSec];
                } forEach (compatibleMagazines (secondaryWeapon _x) - _blackList);
            };
        } forEach ((call CBA_fnc_players) select {(side _x) in _sides || {(group _x) in _groups || {_x in _players}}});

        [LSTRING(ammoResupplyMessage)] call zen_common_fnc_showMessage;
    }, {}, _this] call zen_dialog_fnc_create;
}, ICON_INVENTORY] call zen_custom_modules_fnc_register;

[LSTRING(moduleCategoryResupply), LSTRING(ammoResupplySelectionModuleName), {
    [LSTRING(ammoResupplySelectionModuleName), [
        ["OWNERS", [LSTRING_ZEN(context_Actions,selected), LSTRING(selectSidesGroupsUnits)], [[], [], [], 2], true],
        ["SLIDER", ["LAT BLUFOR", LSTRING(ammoResupplyDesc)], [0, 200, 0, 0]],
        ["SLIDER", ["LAT REDFOR", LSTRING(ammoResupplyDesc)], [0, 200, 0, 0]],
        ["SLIDER", ["MAT BLUFOR", LSTRING(ammoResupplyDesc)], [0, 200, 0, 0]],
        ["SLIDER", ["MAT REDFOR", LSTRING(ammoResupplyDesc)], [0, 200, 0, 0]],
        ["SLIDER", ["HAT BLUFOR", LSTRING(ammoResupplyDesc)], [0, 200, 0, 0]], // 5
        ["SLIDER", ["HAT REDFOR", LSTRING(ammoResupplyDesc)], [0, 200, 0, 0]],
        ["SLIDER", ["AA BLUFOR", LSTRING(ammoResupplyDesc)], [0, 200, 0, 0]],
        ["SLIDER", ["AA REDFOR", LSTRING(ammoResupplyDesc)], [0, 200, 0, 0]],
        ["TOOLBOX:WIDE", [LSTRING(spawnCreate), LSTRING(spawnCreateDesc)], [0, 1, 3, [LSTRING(spawnCreate), LSTRING(insertInventory), LSTRING(clearInventory)]]]
    ], {
        params ["_results", "_args"];

        _args params ["_pos", "_object"];
        (_results deleteAt 0) params ["_sides", "_groups", "_players"];

        if (alive _object && {isPlayer _object} && {_object isKindOf "CAManBase"} && {!(_object isKindOf "VirtualCurator_F")}) then {
            _players pushBackUnique _object;
        };

        private _emptyInventory = _results deleteAt (count _results - 1);

        // If insert into inventory, but no inventory found or enabled
        if (_emptyInventory > 0 && {!alive _object || {maxLoad _object == 0} || {getNumber (configOf _object >> "disableInventory") == 1}}) exitWith {
            [LSTRING(objectHasNoInventory)] call zen_common_fnc_showMessage;
        };

        // If "spawn ammo box", make a new object
        if (_emptyInventory == 0) then {
            _object = "Box_NATO_Ammo_F" createVehicle _pos;
            _object call zen_common_fnc_updateEditableObjects;
            clearMagazineCargoGlobal _object;

            if (isNil "ace_dragging") exitWith {};

            if (isNil QFUNC(setResupplyDraggable)) then {
                DFUNC(setResupplyDraggable) = [{
                    params ["_object", "_config"];

                    // Dragging & Carrying
                    [_object, true, [_config, "ace_dragging_dragPosition", [0, 1.25, 0]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_dragDirection", 0] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setDraggable;
                    [_object, true, [_config, "ace_dragging_carryPosition", [0, 1.25, 0.5]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_carryDirection", 90] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setCarryable;
                }, true, true] call FUNC(sanitiseFunction);

                SEND_MP(setResupplyDraggable);
            };

            // Make crate draggable and carryable, with correct offsets to position and direction, along with overweight dragging possibility; Overwrite previous entry in JIP queue
            [[QGVAR(setResupplyDraggable), [_object, configOf _object], QGVAR(dragging_) + netId _object] call CBA_fnc_globalEventJIP, _object] call CBA_fnc_removeGlobalEventJIP;
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
