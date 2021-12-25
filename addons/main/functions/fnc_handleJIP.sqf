#include "script_component.hpp"

/*
 * Author: johnb43
 * Adds JIP detection.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_handleJIP;
 *
 * Public: No
 */

// If PFH is already added or setting is disabled, exit
if (!GVAR(enableJIP) || {GETMVAR(QGVAR(handleServerJIP),false)}) exitWith {};

// Make sure only 1 EH is added to the server
SETMVAR(QGVAR(handleServerJIP),true,true);

// remoteExecCall can account for side (and probably group JIP), but not for individual player JIP. That's why this function exists
["zen_common_execute", [{
    addMissionEventHandler ["PlayerConnected", {
        params ["", "_uid", "_name", "_jip"];

        if (!_jip) exitWith {};

        [{
            // Wait for player to exist
            !isNull ((_this select 0) call BIS_fnc_getUnitByUID) || {(_this select 1) in (allPlayers apply {name _x})};
        }, {
            params ["_uid", "_name"];

            private _player = _uid call BIS_fnc_getUnitByUID;

            // If player is Virtual Curator, UID will not work for some reason; Find the player through his name
            if (isNull _player) then {
                _player = (allPlayers select {name _x isEqualTo _name}) param [0, objNull];
            };

            // If player can't be found, exit
            if (isNull _player) exitWith {
                ["[Zeus Additions]: Could not apply JIP features on player '%1', UID '%2'", _name, _uid] remoteExecCall ["zen_common_fnc_showMessage", allCurators];
            };

            // For chat channels
            if (!isNil QGVAR(channelSettingsJIP)) then {
                GVAR(channelSettingsJIP) params ["_enableArray", "_players", "_groups", "_sides"];

                if (_uid in _players || {(group _player) in _groups} || {(side _player) in _sides}) then {
                    {
                        _x remoteExecCall ["enableChannel", _player];
                    } forEach _enableArray;

                    "Zeus has changed channel visibility for you." remoteExecCall ["hint", _player];
                };
            };

            // For grass rendering
            if (!isNil QGVAR(grassSettingsJIP)) then {
                GVAR(grassSettingsJIP) params ["_setting", "_players", "_groups", "_sides"];

                if (_uid in _players || {(group _player) in _groups} || {(side _player) in _sides}) then {
                    _setting remoteExecCall ["setTerrainGrid", _player];
                };
            };

            // For TFAR radio range
            if (!isNil QGVAR(radioSettingsJIP)) then {
                GVAR(radioSettingsJIP) params ["_multiplier", "_players", "_groups", "_sides"];

                if (_uid in _players || {(group _player) in _groups} || {(side _player) in _sides}) then {
                    _player setVariable ["tf_sendingDistanceMultiplicator", _multiplier, true];
                };
            };

            // For snow script
            if (!isNil QGVAR(snowSettingsJIP)) then {
                GVAR(snowSettingsJIP) params ["_intensitySnow", "_players", "_groups", "_sides"];

                if (_intensitySnow isEqualTo 0) exitWith {};

                if (_uid in _players || {(group _player) in _groups} || {(side _player) in _sides}) then {
                    _player setVariable [QGVAR(snow), _intensitySnow, true];

                    // Using events doesn't seem to work
                    remoteExecCall [QFUNC(snowScriptPFH), _player];
                };
            };
        }, [_uid, _name], 60, {
            ["[Zeus Additions]: Could not apply JIP features on player '%1', UID '%2'", _this select 1, _this select 0] remoteExecCall ["zen_common_fnc_showMessage", allCurators];
        }] call CBA_fnc_waitUntilAndExecute;
    }];
}, []]] call CBA_fnc_serverEvent;
