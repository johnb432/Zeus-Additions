#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Spawns visual and sound effects when a door is breached.
 *
 * Arguments:
 * 0: Object at whose position the effect will be spawned at <OBJECT>
 * 1: Building <OBJECT>
 * 2: Door ID <NUMBER>
 * 3: Delay after which effects happen <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject player, 1, 5] call zeus_additions_main_fnc_breachingEffects;
 *
 * Public: No
 */

params ["_helperObject", "_building", "_doorID", "_timer"];

// Spawn grenade effect to make an explosion globally
[{
    params ["_helperObject", "_building", "_doorID"];

    // Visual effects
    [QGVAR(executeFunction), [QFUNC(breachingEffectsVisual), [getPosATL _helperObject]]] call CBA_fnc_globalEvent;

    // Play explosion sound
    playSound3D [format ["A3\Sounds_F\arsenal\explosives\grenades\%1_0%2.wss", selectRandom ["Explosion_gng_grenades", "Explosion_HE_grenade", "Explosion_mini_grenade"], floor (random 4) + 1], objNull, round insideBuilding _helperObject == 1, getPosASL _helperObject];

    // Delete demo block
    deleteVehicle _helperObject;

    // Open door (from zen_doors_fnc_setState)
    _building setVariable [format ["bis_disabled_door_%1", _doorID], 0, true];
    _building animateSource [format ["door_%1_sound_source", _doorID], 1, 4];
    _building animateSource [format ["door_%1_noSound_source", _doorID], 1, 4];
}, [_helperObject, _building, _doorID], _timer] call CBA_fnc_waitAndExecute;
