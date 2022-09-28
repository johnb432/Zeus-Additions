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
private _id = if (!local _unit) then {
    // Save name to apply again later
    private _vehicleVarName = vehicleVarName _unit;

    _unit setVehicleVarName "";

    // Get unit position in group
    private _str = str _unit;

    _unit setVehicleVarName _vehicleVarName;

    _id = parseNumber (_str select [(_str find ":") + 1]);

    // Check if unit is alone in group or not
    if ((count units _unit) > 1) then {
        // Create temp group if not alone
        private _tempGroup = createGroup [side _unit, true];

        [_unit] joinSilent _tempGroup;
    } else {
        // Just change locality if alone
        [_unit, clientOwner] remoteExecCall ["setOwner", 2];
    };

    [-1, _id] select (!isNil "_id" && {_id isEqualType 0})
} else {
    -1
};

// Wait until unit is local
[{
    local (_this select 0)
}, {
    params ["_unit", "_oldPlayer", "_oldGroup", "_id"];

    // Sometimes the unit that is being switched to gets teleported into the air; These are measures to prevent that
    private _pos = getPosASL _unit;

    // Start remote controlling
    selectPlayer _unit;

    // Freeze the old unit & Disable damage until Zeus has control of unit again; AI will take over and do dumb stuff
    _oldPlayer disableAI "ALL";
    _oldPlayer enableAI "ANIM";
    _oldPlayer allowDamage false;

    // If new group had to be created to change locality, add to old group
    if ((group _unit) != _oldGroup) then {
        if (_id != -1) then {
            _unit joinAsSilent [_oldGroup, _id];
        } else {
            [_unit] joinSilent _oldGroup;
        };
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

        // To exit the unit, the player must get to the pause menu
        GVAR(remoteControlUserActionEH) = [missionNamespace, "OnGameInterrupt", {
            if (isNil QGVAR(remoteControlArgs)) exitWith {};

            [{
                // Wait until the pause menu has been opened
                !isNull _this
            }, {
                // Close the pause menu
                _this closeDisplay IDC_CANCEL;

                GVAR(remoteControlArgs) params ["_oldPlayer", "_unit", "_isDamageAllowed"];

                [missionNamespace, "OnGameInterrupt", GVAR(remoteControlUserActionEH)] call BIS_fnc_removeScriptedEventHandler;
                _unit removeEventHandler ["Killed", GVAR(remoteControlKilledEH)];

                // Switch back to old player
                selectPlayer _oldPlayer;

                _oldPlayer enableAI "ALL";
                _oldPlayer allowDamage _isDamageAllowed;

                objNull remoteControl _unit;

                _unit setVariable ["bis_fnc_moduleRemoteControl_owner", nil, true];

                GVAR(remoteControlArgs) = nil;
                GVAR(remoteControlUserActionEH) = nil;
                GVAR(remoteControlKilledEH) = nil;
                bis_fnc_moduleRemoteControl_unit = nil;

                // Open curator interface, with a delay
                {
                    {
                        openCuratorInterface;
                    } call CBA_fnc_execNextFrame;
                } call CBA_fnc_execNextFrame;
            }, _this select 0] call CBA_fnc_waitUntilAndExecute;
        }] call BIS_fnc_addScriptedEventHandler;

        // Handle killed with EH
        GVAR(remoteControlKilledEH) = (_this select 1) addEventHandler ["Killed", {
            if (isNil QGVAR(remoteControlArgs)) exitWith {};

            GVAR(remoteControlArgs) params ["_oldPlayer", "_unit", "_isDamageAllowed"];

            [missionNamespace, "OnGameInterrupt", GVAR(remoteControlUserActionEH)] call BIS_fnc_removeScriptedEventHandler;
            _unit removeEventHandler ["Killed", GVAR(remoteControlKilledEH)];

            // Switch back to old player
            selectPlayer _oldPlayer;

            _oldPlayer enableAI "ALL";
            _oldPlayer allowDamage _isDamageAllowed;

            objNull remoteControl _unit;

            _unit setVariable ["bis_fnc_moduleRemoteControl_owner", nil, true];

            GVAR(remoteControlArgs) = nil;
            GVAR(remoteControlUserActionEH) = nil;
            GVAR(remoteControlKilledEH) = nil;
            bis_fnc_moduleRemoteControl_unit = nil;

            // Open curator interface, with a delay
            {
                {
                    openCuratorInterface;
                } call CBA_fnc_execNextFrame;
            } call CBA_fnc_execNextFrame;
        }];
    }, [_pos, _unit]] call CBA_fnc_waitUntilAndExecute;
}, [_unit, _oldPlayer, _group, _id]] call CBA_fnc_waitUntilAndExecute;
