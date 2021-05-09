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

if (!hasInterface) exitWith {};

["Zeus Additions - Resupply", "Spawn Medical Resupply Crate", {
    params ["_pos"];

    ["Spawn Medical Resupply Crate", [
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
        ["CHECKBOX", ["Reset to default"], false, true]
    ],
    {
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
            SETPRVAR(QGVAR(adenosine),0);
            SETPRVAR(QGVAR(splint),50);
            SETPRVAR(QGVAR(tourniquet),40);
            SETPRVAR(QGVAR(bodybag),20);
            SETPRVAR(QGVAR(surgical),0);
            SETPRVAR(QGVAR(PAK),0);

            ["Reset to default completed"] call zen_common_fnc_showMessage;
        };

        _results deleteAt (count _results - 1);

        private _object = "ACE_medicalSupplyCrate_advanced" createVehicle _pos;
        ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
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

        ["zen_common_execute", [ace_dragging_fnc_setDraggable, [_object, true, [0, 1.25, 0], 90, true]]] call CBA_fnc_globalEventJIP;
        ["zen_common_execute", [ace_dragging_fnc_setCarryable, [_object, true, [0, 0.8, 0.8], 0, true]]] call CBA_fnc_globalEventJIP;

        ["Medical crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
