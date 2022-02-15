/*
 * Author: johnb43
 * Creates a module that allow for a medical resupply in crates.
 */

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
        ["TOOLBOX:WIDE", ["Spawn Medical Crate", "If no, it selects the object the module was placed on and places items in its inventory."], [0, 1, 3, ["Spawn Medical Crate", "Insert in inventory", "Clear inventory and insert"]]],
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

        private _config = configOf _object;

        // If insert into inventory, but no inventory found or enabled
        if (_emptyInventory > 0 && {!alive _object || {getNumber (_config >> "maximumLoad") isEqualTo 0} || {getNumber (_config >> "disableInventory") isEqualTo 1}}) exitWith {
            ["Object has no inventory!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        // If "spawn medical crate", make a new object
        if (_emptyInventory isEqualTo 0) then {
            // Spawn medical crate
            _object = "ACE_medicalSupplyCrate_advanced" createVehicle _pos;
            ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
            clearItemCargoGlobal _object;

            _config = configOf _object;

            if (!GVAR(ACEDraggingLoaded)) exitWith {};

            // Make crate draggable and carryable, with correct offsets to position and direction, along with overweight dragging possibility
            // Remove event immediately so that it's removed from JIP queue in case object gets deleted. https://cbateam.github.io/CBA_A3/docs/files/events/fnc_removeGlobalEventJIP-sqf.html
            [["zen_common_execute", [{
                params ["_object", "_config"];

                // Dragging & Carrying
                [_object, true, [_config, "ace_dragging_dragPosition", [0, 1.25, 0]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_dragDirection", 90] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setDraggable;
                [_object, true, [_config, "ace_dragging_carryPosition", [0, 0.8, 0.8]] call BIS_fnc_returnConfigEntry, [_config, "ace_dragging_carryDirection", 0] call BIS_fnc_returnConfigEntry, true] call ace_dragging_fnc_setCarryable;
            }, [_object, _config]]] call CBA_fnc_globalEventJIP, _object] call CBA_fnc_removeGlobalEventJIP;
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

        ["Medical resupply created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_pos, _object]] call zen_dialog_fnc_create;
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
