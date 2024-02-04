/*
 * Author: johnb43
 * Creates a module that allow for a medical resupply in crates.
 */

[LSTRING(moduleCategoryResupply), LSTRING(medicalResupplyModuleName), {
    [LSTRING(medicalResupplyModuleName), [
        ["SLIDER", LSTRING_ACE(medical_Treatment,bandage_Elastic_Display), [0, 300, GETPRVAR(QGVAR(elastic),200), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,packing_Bandage_Display), [0, 300, GETPRVAR(QGVAR(packing),200), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,quikClot_Display), [0, 300, GETPRVAR(QGVAR(quickclot),50), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,bandage_Basic_Display), [0, 300, GETPRVAR(QGVAR(elastic),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,blood_IV), [0, 50, GETPRVAR(QGVAR(blood1000),25), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,blood_IV_500), [0, 100, GETPRVAR(QGVAR(blood500),50), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,blood_IV_250), [0, 100, GETPRVAR(QGVAR(blood250),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,plasma_IV), [0, 50, GETPRVAR(QGVAR(plasma1000),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,plasma_IV_500), [0, 100, GETPRVAR(QGVAR(plasma500),30), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,plasma_IV_250), [0, 100, GETPRVAR(QGVAR(plasma250),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,saline_IV), [0, 50, GETPRVAR(QGVAR(saline1000),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,saline_IV_500), [0, 100, GETPRVAR(QGVAR(saline500),30), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,saline_IV_250), [0, 100, GETPRVAR(QGVAR(saline250),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,epinephrine_Display), [0, 50, GETPRVAR(QGVAR(epinephrine),30), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,morphine_Display), [0, 50, GETPRVAR(QGVAR(morphine),30), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,adenosine_Display), [0, 50, GETPRVAR(QGVAR(adenosine),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,splint_Display), [0, 100, GETPRVAR(QGVAR(splint),50), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,tourniquet_Display), [0, 100, GETPRVAR(QGVAR(tourniquet),40), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,bodybag_Display), [0, 50, GETPRVAR(QGVAR(bodybag),20), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,surgicalKit_Display), [0, 100, GETPRVAR(QGVAR(surgical),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,suture_Display), [0, 100, GETPRVAR(QGVAR(suture),0), 0], true],
        ["SLIDER", LSTRING_ACE(medical_Treatment,aid_Kit_Display), [0, 100, GETPRVAR(QGVAR(PAK),0), 0], true],
        ["TOOLBOX:WIDE", [LSTRING(spawnCreate), LSTRING(spawnCreateDesc)], [0, 1, 3, [LSTRING(spawnCreate), LSTRING(insertInventory), LSTRING(clearInventory)]]],
        ["CHECKBOX", [LSTRING(medicalResupplyReset)], false, true]
    ], {
        params ["_results", "_args"];
        _args params ["_pos", "_object"];

        // If reset if wanted
        if (_results select -1) exitWith {
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
            SETPRVAR(QGVAR(suture),0);
            SETPRVAR(QGVAR(PAK),0);

            [LSTRING(medicalResupplyReset)] call zen_common_fnc_showMessage;
        };

        private _emptyInventory = _results select -2;

        // If insert into inventory, but no inventory found or enabled
        if (_emptyInventory > 0 && {!alive _object || {maxLoad _object == 0} || {getNumber (configOf _object >> "disableInventory") == 1}}) exitWith {
            [LSTRING(objectHasNoInventory)] call zen_common_fnc_showMessage;
        };

        // If "spawn medical crate", make a new object
        if (_emptyInventory == 0) then {
            // Spawn medical crate
            _object = "ACE_medicalSupplyCrate_advanced" createVehicle _pos;
            _object call zen_common_fnc_updateEditableObjects;
            clearItemCargoGlobal _object;

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
            [[QGVAR(executeFunction), [QFUNC(setResupplyDraggable), [_object, configOf _object]], QGVAR(dragging_) + hashValue _object] call FUNC(globalEventJIP), _object] call FUNC(removeGlobalEventJIP);
        };

        // Clear all content of other types of inventories
        if (_emptyInventory == 2) then {
            clearItemCargoGlobal _object;
            clearMagazineCargoGlobal _object;
            clearWeaponCargoGlobal _object;
            clearBackpackCargoGlobal _object;
        };

        // Add items to crate and set profile to have number of items
        {
            _object addItemCargoGlobal [_x select 1, _results select _forEachIndex];
            SETPRVAR(_x select 0,_results select _forEachIndex);
        } forEach [
            [QGVAR(elastic),"ACE_elasticBandage"], [QGVAR(packing),"ACE_packingBandage"], [QGVAR(quickclot),"ACE_quikclot"], [QGVAR(basic),"ACE_fieldDressing"],
            [QGVAR(blood1000),"ACE_bloodIV"], [QGVAR(blood500),"ACE_bloodIV_500"], [QGVAR(blood250),"ACE_bloodIV_250"],
            [QGVAR(plasma1000),"ACE_plasmaIV"], [QGVAR(plasma500),"ACE_plasmaIV_500"], [QGVAR(plasma250),"ACE_plasmaIV_250"],
            [QGVAR(saline1000),"ACE_salineIV"], [QGVAR(saline500),"ACE_salineIV_500"], [QGVAR(saline250),"ACE_salineIV_250"],
            [QGVAR(epinephrine),"ACE_epinephrine"], [QGVAR(morphine),"ACE_morphine"], [QGVAR(adenosine),"ACE_adenosine"],
            [QGVAR(splint),"ACE_splint"], [QGVAR(tourniquet),"ACE_tourniquet"],
            [QGVAR(bodybag),"ACE_bodyBag"], [QGVAR(surgical),"ACE_surgicalKit"], [QGVAR(suture),"ACE_suture"], [QGVAR(PAK),"ACE_personalAidKit"]
        ];

        [LSTRING(medicalResupplyMessage)] call zen_common_fnc_showMessage;
    }, {}, _this] call zen_dialog_fnc_create;
}, ICON_MEDICAL] call zen_custom_modules_fnc_register;
