#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Stop remote controlling a unit that was controlled using 'selectPlayer'.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_switchUnitStop;
 *
 * Public: No
 */

if (isNil QGVAR(switchUnitArgs)) exitWith {};

GVAR(switchUnitArgs) params ["_oldPlayer", "_unit", "_isDamageAllowed", "_userActionEH", "_pfhID", "_deathEH"];

// Switch back to old player
selectPlayer _oldPlayer;

_oldPlayer enableAI "ALL";
_oldPlayer allowDamage _isDamageAllowed;

objNull remoteControl _unit;

_unit setVariable ["BIS_fnc_moduleRemoteControl_owner", nil, true];

GVAR(switchUnitArgs) = nil;
BIS_fnc_moduleRemoteControl_unit = nil;

// Call event for AI behaviour module
["zen_remoteControlStopped", _unit] call CBA_fnc_localEvent;

removeUserActionEventHandler ["curatorInterface", "Activate", _userActionEH];

_pfhID call CBA_fnc_removePerFrameHandler;

if (!isNil "ace_medical_status") then {
    ["ace_medical_death", _deathEH] call CBA_fnc_removeEventHandler;
} else {
    _oldPlayer removeEventHandler ["HandleDamage", _deathEH];
};

// Open curator interface, with a delay
[{
    openCuratorInterface;
}, _this, 2] call CBA_fnc_execAfterNFrames;
