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

// Prevention of controlling units that died when this was called
if (!alive _unit) exitWith {
    ["Unit is dead!"] call zen_common_fnc_showMessage;
};

if (unitIsUAV _unit) exitWith {
    ["Cannot remote control UAV units!"] call zen_common_fnc_showMessage;
};

// Save old player object
private _oldPlayer = player;
bis_fnc_moduleRemoteControl_unit = _unit;

GVAR(remoteControlArgs) = [_oldPlayer, _unit, isDamageAllowed _oldPlayer];

// Sometimes the unit that is being switched to gets teleported into the air; These are measures to prevent that
private _pos = getPosASL _unit;

// Start remote controlling
selectPlayer _unit;

// Freeze the old unit & Disable damage until Zeus has control of unit again; AI will take over and do dumb stuff
_oldPlayer disableAI "ALL";
_oldPlayer enableAI "ANIM";
_oldPlayer allowDamage false;

[{
    // Wait until the Zeus interface is closed
    isNull (findDisplay IDD_RSCDISPLAYCURATOR);
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
            !isNull _this;
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

            GVAR(remoteControlArgs) = nil;
            GVAR(remoteControlUserActionEH) = nil;
            GVAR(remoteControlKilledEH) = nil;
            bis_fnc_moduleRemoteControl_unit = nil;

            // Open curator interface
            {
                openCuratorInterface;
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

        GVAR(remoteControlArgs) = nil;
        GVAR(remoteControlUserActionEH) = nil;
        GVAR(remoteControlKilledEH) = nil;
        bis_fnc_moduleRemoteControl_unit = nil;

        // Open curator interface
        {
            openCuratorInterface;
        } call CBA_fnc_execNextFrame;
    }];
}, [_pos, _unit]] call CBA_fnc_waitUntilAndExecute;
