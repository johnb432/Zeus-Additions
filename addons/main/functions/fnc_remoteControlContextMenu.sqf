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

// Save old player object
private _oldPlayer = player;
private _isDamageAllowed = isDamageAllowed _oldPlayer;

// Save old name so it can be applied again later
private _name = name _oldPlayer;

// If virtual curator, ignore
if !(_oldPlayer isKindOf "VirtualCurator_F") then {
    // Freeze the old unit; AI will take over and do dumb stuff
    _oldPlayer disableAI "all";

    // Disable damage until Zeus has control of unit again
    if (_isDamageAllowed) then {
        _oldPlayer allowDamage false;
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
    isNull (findDisplay IDD_RSCDISPLAYCURATOR);
}, {
    // Check after we have taken over new unit whether it has been teleported; Randomly does that sometimes (could be locality issue)
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
            !isNull _this;
        }, {
            // Close the pause menu
            _this closeDisplay IDC_CANCEL;

            // Remove EH
            [missionNamespace, "OnGameInterrupt", GVAR(remoteControlHandleID)] call BIS_fnc_removeScriptedEventHandler;

            GVAR(remoteControlArgs) params ["_oldPlayer", "_isDamageAllowed", "_playerJIP"];

            // If virtual curator, ignore
            if !(_oldPlayer isKindOf "VirtualCurator_F") then {
                // Unfreeze the old unit
                [_oldPlayer, "all"] remoteExecCall ["enableAI", _oldPlayer];

                // Enable damage again
                if (_isDamageAllowed) then {
                    [_oldPlayer, false] remoteExecCall ["allowDamage", _oldPlayer];
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
        }, _this select 0] call CBA_fnc_waitUntilAndExecute;
    }] call BIS_fnc_addScriptedEventHandler;
}, [_pos, _unit]] call CBA_fnc_waitUntilAndExecute;
