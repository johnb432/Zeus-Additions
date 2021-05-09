#include "script_component.hpp"

/*
 * Author: johnb43, with help from scripts from mharis001 (ZEN) & Kex (Achilles)
 * Finds doors of a building.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_findDoors;
 *
 * Public: No
 */

params ["_building"];

private _hashMapSelectionNames = [];

// Find doors
{
    if (_x find "door" isNotEqualTo -1 && {_x find "handle" isEqualTo -1} && {_x find "doorlocks" isEqualTo -1}) then {
        _hashMapSelectionNames pushBack (toLower _x);
    };
} forEach (selectionNames _building);

// If no doors found, exit
if (_hashMapSelectionNames isEqualTo []) exitWith {
    ["No doors were found for %1!", getText (configOf _building >> "displayName")] call zen_common_fnc_showMessage;
    nil;
};

_hashMapSelectionNames sort true;
_hashMapSelectionNames;
