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
 * call zeus_additions_main_medicalResupply;
 *
 * Public: No
 */

["Zeus Additions", "Spawn Medical Resupply Crate", {
    params ["_pos"];

    ["Spawn Medical Resupply Crate", [
        ["EDIT", "Bandages (Elastic)", profileNamespace getVariable ["elastic", 200], true],
        ["EDIT", "Bandages (Packing)", profileNamespace getVariable ["packing", 200], true],
        ["EDIT", "Bandages (Quickclot)", profileNamespace getVariable ["quickclot", 50], true],
        ["EDIT", "Bandages (Basic)", profileNamespace getVariable ["basic", 0], true],
        ["EDIT", "1000ml Blood", profileNamespace getVariable ["blood1000", 25], true],
        ["EDIT", "500ml Blood", profileNamespace getVariable ["blood500", 50], true],
        ["EDIT", "250ml Blood", profileNamespace getVariable ["blood250", 0], true],
        ["EDIT", "1000ml Plasma", profileNamespace getVariable ["plasma1000", 0], true],
        ["EDIT", "500ml Plasma", profileNamespace getVariable ["plasma500", 30], true],
        ["EDIT", "250ml Plasma", profileNamespace getVariable ["plasma250", 0], true],
        ["EDIT", "1000ml Saline", profileNamespace getVariable ["saline1000", 0], true],
        ["EDIT", "500ml Saline", profileNamespace getVariable ["saline500", 30], true],
        ["EDIT", "250ml Saline", profileNamespace getVariable ["saline250", 0], true],
        ["EDIT", "Epinephrine autoinjector", profileNamespace getVariable ["epinephrine", 30], true],
        ["EDIT", "Morphine autoinjector", profileNamespace getVariable ["morphine", 30], true],
        ["EDIT", "Adenosine autoinjector", profileNamespace getVariable ["adenosine", 10], true],
        ["EDIT", "Splint", profileNamespace getVariable ["splint", 50], true],
        ["EDIT", "Tourniquet (CAT)", profileNamespace getVariable ["tourniquet", 40], true],
        ["EDIT", "Bodybag", profileNamespace getVariable ["bodybag", 20], true],
        ["EDIT", "Surgical Kit", profileNamespace getVariable ["surgical", 0], true],
        ["EDIT", "Personal Aid Kit", profileNamespace getVariable ["surgical", 0], true],
        ["CHECKBOX", ["Reset to default"], false, true]
    ], {
        params ["_results", "_pos"];

        if (_results select (count _results - 1)) exitWith {
            profileNamespace setVariable ["elastic", 200];
            profileNamespace setVariable ["packing", 200];
            profileNamespace setVariable ["quickclot", 50];
            profileNamespace setVariable ["basic", 0];
            profileNamespace setVariable ["blood1000", 25];
            profileNamespace setVariable ["blood500", 50];
            profileNamespace setVariable ["blood250", 0];
            profileNamespace setVariable ["plasma1000", 0];
            profileNamespace setVariable ["plasma500", 30];
            profileNamespace setVariable ["plasma250", 0];
            profileNamespace setVariable ["saline1000", 0];
            profileNamespace setVariable ["saline500", 30];
            profileNamespace setVariable ["saline250", 0];
            profileNamespace setVariable ["epinephrine", 30];
            profileNamespace setVariable ["morphine", 30];
            profileNamespace setVariable ["adenosine", 10];
            profileNamespace setVariable ["splint", 50];
            profileNamespace setVariable ["tourniquet", 40];
            profileNamespace setVariable ["bodybag", 20];
            profileNamespace setVariable ["surgical", 0];
            profileNamespace setVariable ["PAK", 0];

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
            _object addItemCargoGlobal [_items select _forEachIndex, parseNumber _x];
        } forEach _results;

        profileNamespace setVariable ["elastic", _results select 0];
        profileNamespace setVariable ["packing", _results select 1];
        profileNamespace setVariable ["quickclot", _results select 2];
        profileNamespace setVariable ["basic", _results select 3];
        profileNamespace setVariable ["blood1000", _results select 4];
        profileNamespace setVariable ["blood500", _results select 5];
        profileNamespace setVariable ["blood250", _results select 6];
        profileNamespace setVariable ["plasma1000", _results select 7];
        profileNamespace setVariable ["plasma500", _results select 8];
        profileNamespace setVariable ["plasma250", _results select 9];
        profileNamespace setVariable ["saline1000", _results select 10];
        profileNamespace setVariable ["saline500", _results select 11];
        profileNamespace setVariable ["saline250", _results select 12];
        profileNamespace setVariable ["epinephrine", _results select 13];
        profileNamespace setVariable ["morphine", _results select 14];
        profileNamespace setVariable ["adenosine", _results select 15];
        profileNamespace setVariable ["splint", _results select 16];
        profileNamespace setVariable ["tourniquet", _results select 17];
        profileNamespace setVariable ["bodybag", _results select 18];
        profileNamespace setVariable ["surgical", _results select 19];
        profileNamespace setVariable ["PAK", _results select 20];

        [_object, true, [0,0,0], 0, true] remoteExec ["ace_dragging_fnc_setDraggable", 0, true];
        [_object, true, [0,0,0], 0, true] remoteExec ["ace_dragging_fnc_setCarryable", 0, true];

        ["Medical crate created"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
