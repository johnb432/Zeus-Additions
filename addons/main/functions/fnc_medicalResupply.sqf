#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds a module that spawns a medical resupply crate.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_medicalResupply;
 *
 * Public: No
 */

["Zeus Additions", "Spawn Medical Resupply Crate", {
    params ["_pos"];

    ["Spawn Medical Resupply Crate", [
        ["EDIT", "Bandages (Elastic)", GETPRVAR(QGVAR(elastic),200), true],
        ["EDIT", "Bandages (Packing)", GETPRVAR(QGVAR(packing),200), true],
        ["EDIT", "Bandages (Quickclot)", GETPRVAR(QGVAR(quickclot),50), true],
        ["EDIT", "Bandages (Basic)", GETPRVAR(QGVAR(basic),0), true],
        ["EDIT", "1000ml Blood", GETPRVAR(QGVAR(blood1000),25), true],
        ["EDIT", "500ml Blood", GETPRVAR(QGVAR(blood500),50), true],
        ["EDIT", "250ml Blood", GETPRVAR(QGVAR(blood250),0), true],
        ["EDIT", "1000ml Plasma", GETPRVAR(QGVAR(plasma1000),0), true],
        ["EDIT", "500ml Plasma", GETPRVAR(QGVAR(plasma500),30), true],
        ["EDIT", "250ml Plasma", GETPRVAR(QGVAR(plasma250),0), true],
        ["EDIT", "1000ml Saline", GETPRVAR(QGVAR(saline1000),0), true],
        ["EDIT", "500ml Saline", GETPRVAR(QGVAR(saline500),30), true],
        ["EDIT", "250ml Saline", GETPRVAR(QGVAR(saline250),0), true],
        ["EDIT", "Epinephrine autoinjector", GETPRVAR(QGVAR(epinephrine),30), true],
        ["EDIT", "Morphine autoinjector", GETPRVAR(QGVAR(morphine),30), true],
        ["EDIT", "Adenosine autoinjector", GETPRVAR(QGVAR(adenosine),10), true],
        ["EDIT", "Splint", GETPRVAR(QGVAR(splint),50), true],
        ["EDIT", "Tourniquet (CAT)", GETPRVAR(QGVAR(tourniquet),40), true],
        ["EDIT", "Bodybag", GETPRVAR(QGVAR(bodybag),20), true],
        ["EDIT", "Surgical Kit", GETPRVAR(QGVAR(surgical),0), true],
        ["EDIT", "Personal Aid Kit", GETPRVAR(QGVAR(PAK),0), true],
        ["CHECKBOX", ["Reset to default"], false, true]
    ], {
        params ["_results", "_pos"];

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
            SETPRVAR(QGVAR(adenosine),10);
            SETPRVAR(QGVAR(splint),50);
            SETPRVAR(QGVAR(tourniquet),40);
            SETPRVAR(QGVAR(bodybag),20);
            SETPRVAR(QGVAR(surgical),0);
            SETPRVAR(QGVAR(PAK),0);

            ["Reset to default completed"] call zen_common_fnc_showMessage;
        };

        _results deleteAt (count _results - 1);

        private _object = "ACE_medicalSupplyCrate_advanced" createVehicle _pos;
        {
            [_x, [[_object], true]] remoteExec ["addCuratorEditableObjects", _x, true];
        } forEach allCurators;
        clearItemCargoGlobal _object;

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

        {
            _object addItemCargoGlobal [_items select _forEachIndex, parseNumber (_results select _forEachIndex)];
            SETPRVAR(_x, _results select _forEachIndex);
        } forEach [
            QGVAR(elastic), QGVAR(packing), QGVAR(quickclot), QGVAR(basic),
            QGVAR(blood1000), QGVAR(blood500), QGVAR(blood250),
            QGVAR(plasma1000), QGVAR(plasma500), QGVAR(plasma250),
            QGVAR(saline1000), QGVAR(saline500), QGVAR(saline250),
            QGVAR(epinephrine), QGVAR(morphine), QGVAR(adenosine),
            QGVAR(splint), QGVAR(tourniquet),
            QGVAR(bodybag), QGVAR(surgical), QGVAR(PAK)
        ];

        [_object, true, [0,0,0], 0, true] remoteExec ["ace_dragging_fnc_setDraggable", 0, true];
        [_object, true, [0,0,0], 0, true] remoteExec ["ace_dragging_fnc_setCarryable", 0, true];

        ["Medical crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
