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
private _hashMapSelectionNames = createHashMap;

/* Alternative find doors
{
    if ("opendoor" in toLower configName _x) then {
        _door = _building selectionPosition (getText (_x >> "position"));
        _doorPositionsUserActions pushBack _door;
        _doorPositionsUserActionsNames pushBack (toLower (configName _x));
    };
} forEach configProperties [configOf _building >> "UserActions", "isClass _x"];
*/

// Find doors
{
    if (_x find "door" isNotEqualTo -1 && {_x find "handle" isEqualTo -1} && {_x find "doorlocks" isEqualTo -1}) then {
        _hashMapSelectionNames set [toLower _x, (_building modelToWorld (_building selectionPosition _x)) select 2];
    };
} forEach (selectionNames _building);

// If no doors found, exit
if (count _hashMapSelectionNames isEqualTo 0) exitWith {
    ["No doors were found for %1!", getText (configFile >> "CfgVehicles" >> typeOf _building >> "displayName")] call zen_common_fnc_showMessage;
    nil;
};

private _sortedKeysSelectionNames = keys _hashMapSelectionNames;
_sortedKeysSelectionNames sort true;
_sortedKeysSelectionNames;
