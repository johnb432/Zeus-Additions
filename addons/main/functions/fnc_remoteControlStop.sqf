#include "script_component.hpp"

/*
 * Author: johnb43
 * Stop remote controlling a unit that was controled using 'selectPlayer'.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_remoteControlStop;
 *
 * Public: No
 */

if (isNil QGVAR(remoteControlArgs)) exitWith {};

GVAR(remoteControlArgs) params ["_oldPlayer", "_unit", "_isDamageAllowed", "_userActionEH", "_killedEH"];

removeUserActionEventHandler ["curatorInterface", "Activate", _userActionEH];
_unit removeEventHandler ["Killed", _killedEH];

// Switch back to old player
selectPlayer _oldPlayer;

_oldPlayer enableAI "ALL";
_oldPlayer allowDamage _isDamageAllowed;

objNull remoteControl _unit;

_unit setVariable ["bis_fnc_moduleRemoteControl_owner", nil, true];

GVAR(remoteControlArgs) = nil;
bis_fnc_moduleRemoteControl_unit = nil;

// Call event for AI behaviour module
["zen_remoteControlStopped", _unit] call CBA_fnc_localEvent;

// Open curator interface, with a delay
{
    {
        openCuratorInterface;
    } call CBA_fnc_execNextFrame;
} call CBA_fnc_execNextFrame;
