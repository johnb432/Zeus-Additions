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

GVAR(switchUnitArgs) params ["", "_unit", "", "", "", "_userActionEH", "_killedEH"];

removeUserActionEventHandler ["curatorInterface", "Activate", _userActionEH];
_unit removeEventHandler ["Killed", _killedEH];

// Check if unit has been respawned
private _respawned = false;

if (!alive player) then {
    if (playerRespawnTime > 0) then {
        setPlayerRespawnTime 0;
    };

    _respawned = true;
};

[{
    alive player
}, {
    params ["_respawned"];

    private _respawnedUnit = objNull;

    // If unit has respawned, hide new unit
    if (_respawned) then {
        _respawnedUnit = player;

        [_respawnedUnit, true] remoteExecCall ["hideObjectGlobal", 2];
        _respawnedUnit enableSimulationGlobal false;
    };

    [{
        params ["_respawned"];
        GVAR(switchUnitArgs) params ["_oldPlayer", "_unit", "_isDamageAllowed", "_respawnTime", "_respawnTemplateDelay"];

        // Switch back to old player
        selectPlayer _oldPlayer;

        _oldPlayer enableAI "ALL";
        _oldPlayer allowDamage _isDamageAllowed;

        objNull remoteControl _unit;

        _unit setVariable ["bis_fnc_moduleRemoteControl_owner", nil, true];

        GVAR(switchUnitArgs) = nil;
        bis_fnc_moduleRemoteControl_unit = nil;

        // Call event for AI behaviour module
        ["zen_remoteControlStopped", _unit] call CBA_fnc_localEvent;

        // Reset respawn time
        if (_respawned) then {
            setPlayerRespawnTime _respawnTime;
        };

        if (BIS_selectRespawnTemplate_delay == 0.1234) then {
            BIS_selectRespawnTemplate_delay = _respawnTemplateDelay;
        };

        // Open curator interface, with a delay
        [{
            openCuratorInterface;

            params ["_respawned", "_respawnedUnit"];

            if (_respawned) then {
                deleteVehicle _respawnedUnit;
            };
        }, _this, 2] call CBA_fnc_execAfterNFrames;
    }, [_respawned, _respawnedUnit], 0.1] call CBA_fnc_waitAndExecute;
}, _respawned] call CBA_fnc_waitUntilAndExecute;
