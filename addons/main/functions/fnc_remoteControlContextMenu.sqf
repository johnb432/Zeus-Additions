#include "script_component.hpp"

/*
 * Author: johnb43
 * Allows the Zeus to switch places with the selected AI unit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * cursorTarget call zeus_additions_main_fnc_remoteControlContextMenu;
 *
 * Public: No
 */

params ["_unit"];

_unit = effectiveCommander _unit;

if (isNull _unit) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorNull"] call zen_common_fnc_showMessage;
};

if (!alive _unit) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorDestroyed"] call zen_common_fnc_showMessage;
};

if (isPlayer _unit) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorPlayer"] call zen_common_fnc_showMessage;
};

if !(side group _unit in [west, east, independent, civilian]) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorEmpty"] call zen_common_fnc_showMessage;
};

private _owner = _unit getVariable ["bis_fnc_moduleRemoteControl_owner", objNull];

if ((!isNull _owner && {_owner in allPlayers}) || {isUAVConnected vehicle _unit}) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorControl"] call zen_common_fnc_showMessage;
};

if (unitIsUAV _unit) exitWith {
    ["Cannot remote control UAV units!"] call zen_common_fnc_showMessage;
};

// Save old player object
private _oldPlayer = player;
bis_fnc_moduleRemoteControl_unit = _unit;
_unit setvariable ["bis_fnc_moduleRemoteControl_owner", _oldPlayer, true];

GVAR(remoteControlArgs) = [_oldPlayer, _unit, isDamageAllowed _oldPlayer];

private _group = group _unit;
private _groupID = groupId _unit;
private _teamColor = assignedTeam _unit;

// Make unit local
if (!local _unit) then {
    ["zen_common_execute", [{
        params ["_clientOwner", "_unit", "_group", "_groupID", "_teamColor"];

        // If ownership was transferred successfully, quit
        if (_group setGroupOwner _clientOwner) exitWith {};

        // If unit still isn't local, try other solutions
        if ((count units _unit) > 1) then {
            // Create temp group if not alone
            _unit joinAsSilent [createGroup [side _unit, true], _groupID];
            _unit assignTeam _teamColor;
        } else {
            // Just change locality if alone
            _unit setOwner _clientOwner;
        };
    }, [clientOwner, _unit, _group, _groupID, _teamColor]]] call CBA_fnc_serverEvent;
};

[{
    // Wait until unit is local
    local (_this select 0)
}, {
    params ["_unit", "_oldPlayer", "_group", "_groupID", "_teamColor"];

    // Sometimes the unit that is being switched to gets teleported into the air; These are measures to prevent that
    private _pos = getPosASL _unit;

    // Start remote controlling
    selectPlayer _unit;

    // Freeze the old unit & Disable damage until Zeus has control of unit again; AI will take over and do dumb stuff
    _oldPlayer disableAI "ALL";
    _oldPlayer enableAI "ANIM";
    _oldPlayer allowDamage false;

    // If new group had to be created to change locality, add to old group
    if ((group _unit) != _group) then {
        _unit joinAsSilent [_group, _groupID];
        _unit assignTeam _teamColor;
    };

    [{
        // Wait until the Zeus interface is closed
        isNull (findDisplay IDD_RSCDISPLAYCURATOR)
    }, {
        // Check after we have taken over new unit whether it has been teleported; Randomly does that sometimes (could be locality issue)
        [{
            params ["_pos", "_unit"];

            // Prevents unit from respawning if killed
            setPlayerRespawnTime 10e10;

            if (isNull objectParent _unit && {_pos distance (getPosASL _unit) > 1}) then {
                _unit setPosASL _pos;
            };
        }, _this, 0.25] call CBA_fnc_waitAndExecute;

        // To exit the unit, the player must use the curator interface keybind or get killed
        GVAR(remoteControlArgs) append [
            addUserActionEventHandler ["curatorInterface", "Activate", FUNC(remoteControlStop)],
            (_this select 1) addEventHandler ["Killed", FUNC(remoteControlStop)]
        ];
    }, [_pos, _unit]] call CBA_fnc_waitUntilAndExecute;
}, [_unit, _oldPlayer, _group, _groupID, _teamColor], 5, {
    // If locality failed to be transferred after 5s, quit
    (_this select 0) setVariable ["bis_fnc_moduleRemoteControl_owner", nil, true];

    GVAR(remoteControlArgs) = nil;
    bis_fnc_moduleRemoteControl_unit = nil;

    ["Failed to remote control unit"] call zen_common_fnc_showMessage;
}] call CBA_fnc_waitUntilAndExecute;
