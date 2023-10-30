#include "..\script_component.hpp"
/*
 * Author: johnb43, based off of by Karel Moricky (BIS_fnc_selectRespawnTemplate)
 * Gets the respawn time of a player based off of the mission config. This function can't account for previous 'setPlayerRespawnTime' executions.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Respawn time <NUMBER>
 *
 * Example:
 * call zeus_additions_main_fnc_getRespawnTime;
 *
 * Public: No
 */

// Get engine respawn and respawn templates
private _respawnTemplates = [configfile >> "CfgRespawnTemplates" >> "respawnTemplates" + ("" call BIS_fnc_missionRespawnType), "ARRAY", configNull] call CBA_fnc_getConfigEntry;

// Get respawn templates defined by the scenario (prioritize side specific ones)
if (isMultiplayer) then {
    _respawnTemplates = getMissionConfigValue ["respawnTemplates" + (if (player call BIS_fnc_isUnitVirtual) then {"VIRTUAL"} else {str (player call BIS_fnc_objectSide)}), getMissionConfigValue ["respawnTemplates", _respawnTemplates]];
};

if !(_respawnTemplates isEqualType []) then {
    _respawnTemplates = [_respawnTemplates];
};

private _respawnDelay = missionNamespace getVariable "BIS_selectRespawnTemplate_delay";

(if (!isNil "_respawnDelay") then {
    _respawnDelay
} else {
    _respawnDelay = getMissionConfigValue ["respawnDelay", 0];

    // Convert to number if misconfigured as a string
    if (_respawnDelay isEqualType "") then {
        _respawnDelay = parseNumber _respawnDelay;
    };

    // 'respawnDelay' in description.ext has priority (see https://community.bistudio.com/wiki/Arma_3:_Respawn#Custom_Respawn_Templates)
    if (_respawnDelay >= 0) exitWith {
        _respawnDelay
    };

    private _cfgRespawn = configNull;
    private _return = 0;

    // Get respawn times for every template
    {
        _cfgRespawn = [["CfgRespawnTemplates", _x], configNull] call BIS_fnc_loadClass;

        // Template specific respawn delay
        if (!isNull _cfgRespawn) then {
            _respawnDelay = [_cfgRespawn >> "respawnDelay", "NUMBER", -1] call CBA_fnc_getConfigEntry;

            if (_respawnDelay >= 0) exitWith {
                _return = _respawnDelay;
            };
        };
    } forEach _respawnTemplates;

    _return
}) max 0
