#include "script_component.hpp"

/*
 * Author: johnb43
 * Opens the medical menu on a unit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * cursorTarget call zeus_additions_main_fnc_openMedicalMenuContextMenu;
 *
 * Public: No
 */

params ["_unit"];

// Create a helper unit to access medical menu
private _helperUnit = createAgent ["C_man_1", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_helperUnit attachTo [_unit, [0, -1, 0]];
removeUniform _helperUnit;
removeGoggles _helperUnit;
_helperUnit setVariable ["ACE_medical_medicClass", 2, true];

// Do not allow the unit to move or interact with other objects
["zen_common_enableSimulationGlobal", [_helperUnit, false]] call CBA_fnc_serverEvent;

// Make invisible and invincible
["zen_common_hideObjectGlobal", [_helperUnit, true]] call CBA_fnc_serverEvent;
["zen_common_allowDamage", [_helperUnit, false]] call CBA_fnc_localEvent;

// Start remote controlling
_helperUnit call zen_remote_control_fnc_start;

// Open medical menu once in new unit
_unit call ace_medical_gui_fnc_openMenu;

["To quit, exit the medical menu.", false, 5, 2] call ace_common_fnc_displayText;

[{
    // Wait for the medical menu to close
    isNull (uiNamespace getVariable ["ace_medical_gui_menuDisplay", displayNull]);
}, {
    // Delete helper unit, makes the remote controlling stop
    detach _this;
    deleteVehicle _this;
}, _helperUnit] call CBA_fnc_waitUntilAndExecute;
