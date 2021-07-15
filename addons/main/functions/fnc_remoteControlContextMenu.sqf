#include "script_component.hpp"

/*
 * Author: johnb43
 * Allows the Zeus to switch places with the selected AI unit.
 *
 * Arguments:
 * None
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

// Save old player object
private _oldPlayer = player;
private _isDamageAllowed = isDamageAllowed _oldPlayer;

// Save old name so it can be applied again later
private _name = name _oldPlayer;

// If virtual curator, ignore
if !(_oldPlayer isKindOf "VirtualCurator_F") then {
    // Freeze the old unit; AI will take over and do dumb stuff
    ["zen_common_disableAI", [_oldPlayer, "all"]] call CBA_fnc_localEvent;

    // Disable damage until Zeus has control of unit again
    if (_isDamageAllowed) then {
        ["zen_common_allowDamage", [_oldPlayer, false]] call CBA_fnc_serverEvent;
    };
};

// Sometimes the unit that is being switched to gets teleported into the air; These are measures to prevent that
private _pos = getPosASL _unit;

// Start remote controlling
selectPlayer _unit;

// Set a name (to avoid TFAR bugs)
GVAR(remoteControlArgs) = [_oldPlayer, _isDamageAllowed, ["zen_common_setName", [_oldPlayer, _name]] call CBA_fnc_globalEventJIP];

[{
    // Wait until the Zeus interface is closed
    isNull (findDisplay IDD_RSCDISPLAYCURATOR)
}, {
    // Check after we have taken over new unit whether it has been teleported; Randomly does that sometimes
    [{
        params ["_pos", "_unit"];

        if (_pos distance (getPosASL _unit) > 1) then {
            _unit setPosASL _pos;
        };
    }, _this, 0.25] call CBA_fnc_waitAndExecute;

    // To exit the unit, the player must get to the pause menu; Still works if unit is killed
    GVAR(remoteControlHandleID) = [missionNamespace, "OnGameInterrupt", {
        [{
            // Wait until the pause menu has been opened
            !isNull (findDisplay IDD_INTERRUPT);
        }, {
            // Close the pause menu
            (findDisplay IDD_INTERRUPT) closeDisplay IDC_CANCEL;

            // Remove EH
            [missionNamespace, "OnGameInterrupt", GVAR(remoteControlHandleID)] call BIS_fnc_removeScriptedEventHandler;

            GVAR(remoteControlArgs) params ["_oldPlayer", "_isDamageAllowed", "_playerJIP"];

            // If virtual curator, ignore
            if !(_oldPlayer isKindOf "VirtualCurator_F") then {
                // Unfreeze the old unit
                ["zen_common_enableAI", [_oldPlayer, "all"]] call CBA_fnc_localEvent;

                // Enable damage again
                if (_isDamageAllowed) then {
                    ["zen_common_allowDamage", [_oldPlayer, false]] call CBA_fnc_serverEvent;
                };
            };

            // Remove JIP events for names
            _playerJIP call CBA_fnc_removeGlobalEventJIP;

            // Switch back to old player
            selectPlayer _oldPlayer;

            GVAR(remoteControlHandleID) = nil;
            GVAR(remoteControlArgs) = nil;

            // Open curator interface
            {
                openCuratorInterface;
            } call CBA_fnc_execNextFrame;
        }] call CBA_fnc_waitUntilAndExecute;
    }] call BIS_fnc_addScriptedEventHandler;
}, [_pos, _unit]] call CBA_fnc_waitUntilAndExecute;
