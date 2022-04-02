#include "script_component.hpp"

/*
 * Author: johnb43, with help from scripts from mharis001 (ZEN) & Kex (Achilles)
 * Finds doors of a building.
 *
 * Arguments:
 * 0: Building <OBJECT>
 *
 * Return Value:
 * Selection names of doors <ARRAY>
 *
 * Example:
 * call zeus_additions_main_fnc_findDoors;
 *
 * Public: No
 */

params ["_building"];

private _selectionNames = [];

// Find doors
{
    if (((_x find "door") isNotEqualTo -1) && {(_x find "handle") isEqualTo -1} && {(_x find "doorlocks") isEqualTo -1}) then {
        _selectionNames pushBack _x;
    };
} forEach ((selectionNames _building) apply {toLowerANSI _x});

// If no doors found, exit
if (_selectionNames isEqualTo []) exitWith {
    ["No doors were found for %1!", getText (configOf _building >> "displayName")] call zen_common_fnc_showMessage;
    nil;
};

_selectionNames sort true;
_selectionNames;
