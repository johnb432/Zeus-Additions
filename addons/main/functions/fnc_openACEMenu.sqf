#include "script_component.hpp"

/*
 * Author: johnb43
 * Opens a given menu on an object.
 *
 * Arguments:
 * 0: Object <OBJECT>
 * 1: Menu type: <NUMBER>
 * 2: Additional parameters <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorTarget, 0] call zeus_additions_main_fnc_openACEMenu;
 *
 * Public: No
 */

params ["_object", "_menuType", ["_previousCoeffValue", 5, [0]]];

// Create a helper unit to access medical menu
private _helperUnit = createAgent ["C_man_1", [0, 0, 0], [], 0, "CAN_COLLIDE"];

switch (_menuType) do {
    case CARGO_MENU: {
        private _bbr = boundingBoxReal _object;

        // Put the helper unit to the right of the object
        _helperUnit setPosATL ((getPosATL _object) vectorAdd ((vectorNormalized ((vectorDir _object) vectorCrossProduct (vectorUp _object))) vectorMultiply (((_bbr select 1 select 0) - (_bbr select 0 select 0)) / 2)));
        _helperUnit attachTo [_object];
    };
    default {_helperUnit attachTo [_object, [0, -1, 0]]};
};

// Remove all items of the helper unit
removeAllWeapons _helperUnit;
removeAllAssignedItems _helperUnit;
removeAllContainers _helperUnit;
removeHeadgear _helperUnit;
removeGoggles _helperUnit;
_helperUnit setVariable ["ACE_medical_medicClass", 2, true];

// Do not allow the unit to move or interact with other objects
_helperUnit enableSimulationGlobal false;

// Make invisible and invincible
[_helperUnit, true] remoteExecCall ["hideObjectGlobal", 2];
_helperUnit allowDamage false;

// Start remote controlling
_helperUnit call zen_remote_control_fnc_start;

// ACE common is required by both cargo and medical gui, so it can be used here
private _display = switch (_menuType) do {
    case MEDICAL_MENU: {
        // Open medical menu once in new unit
        _object call ace_medical_gui_fnc_openMenu;

        ["To quit, exit the medical menu.", false, 5, 2] call ace_common_fnc_displayText;

        "ace_medical_gui_menuDisplay";
    };
    case CARGO_MENU: {
        ace_cargo_interactionVehicle = _object;
        ace_cargo_interactionParadrop = false;
        createDialog "ace_cargo_menu";

        ["To quit, exit the cargo menu.", false, 5, 2] call ace_common_fnc_displayText;

        "ace_cargo_menuDisplay";
    };
    default {""};
};

[{
    // Wait for the medical menu to close
    isNull (GETUVAR(_this select 0,displayNull));
}, {
    params ["_display", "_helperUnit", "_previousCoeffValue"];

    // Delete helper unit, makes the remote controlling stop
    detach _helperUnit;
    deleteVehicle _helperUnit;

    if (_display isEqualTo "ace_cargo_menuDisplay") then {
        ace_cargo_loadTimeCoefficient = _previousCoeffValue;
    };
}, [_display, _helperUnit, _previousCoeffValue]] call CBA_fnc_waitUntilAndExecute;
