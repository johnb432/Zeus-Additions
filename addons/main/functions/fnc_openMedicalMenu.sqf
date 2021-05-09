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
 * cursorTarget call zeus_additions_main_fnc_openMedicalMenu;
 *
 * Public: No
 */

params ["_unit"];

// Create a helper unit to access medical menu
private _helperUnit = createAgent ["B_Survivor_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_helperUnit attachTo [_unit, [0, -1, 0]];
removeUniform _helperUnit;
removeGoggles _helperUnit;
_helperUnit setVariable ["ACE_medical_medicClass", 2, true];
GVAR(helperUnit) = _helperUnit;

// Make invisible and invincible
["zen_common_hideObjectGlobal", [_helperUnit, true]] call CBA_fnc_serverEvent;
["zen_common_allowDamage", [_helperUnit, false]] call CBA_fnc_localEvent;

// Start remote controlling
_helperUnit call zen_remote_control_fnc_start;

// Open medical menu once in new unit
_unit call ace_medical_gui_fnc_openMenu;

["To quit, exit the medical menu, then press the Zeus key.", false, 5, 2] call ace_common_fnc_displayText;

[{
    isNull (findDisplay 312)
}, {
    // Wait for the curator display to close first
    [{
        !isNull (findDisplay 312)
    }, {
        // Delete unit when loaded back into Zeus interface
        detach GVAR(helperUnit);
        deleteVehicle GVAR(helperUnit);
    }] call CBA_fnc_waitUntilAndExecute;
}] call CBA_fnc_waitUntilAndExecute;
