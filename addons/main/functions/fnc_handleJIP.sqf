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
if (!GVAR(enableJIP) || {missionNamespace getVariable [QGVAR(handleServerJIP), false]}) exitWith {};

// Make sure only 1 EH is added to the server
missionNamespace setVariable [QGVAR(handleServerJIP), true, true];

[
    [],
    {
        addMissionEventHandler ["PlayerConnected", {
            params ["", "_uid", "_name", "_jip"];

            if (!_jip) exitWith {};

            [{
                // Wait for player to exist
                !isNull ((_this select 0) call BIS_fnc_getUnitByUID) || {(_this select 1) in (allPlayers apply {name _x})};
            }, {
                params ["_uid", "_name"];

                // If player is Virtual Curator, UID will not work for some reason
                private _player = if (isNull (_uid call BIS_fnc_getUnitByUID)) then {
                    // Find the player through his name
                    private _playerNames = allPlayers apply {name _x};
                    private _index = _playerNames find _name;

                    if (_index isEqualTo -1) exitWith {
                        objNull;
                    };

                    _playerNames select _index;
                } else {
                    _uid call BIS_fnc_getUnitByUID;
                };

                // For chat channels
                if (!isNil QGVAR(channelSettingsJIP)) then {
                    GVAR(channelSettingsJIP) params ["_enableArray", "_players", "_groups", "_sides"];

                    if (_uid in _players || {(group _player) in _groups} || {(side _player) in _sides}) then {
                        {
                            _x remoteExecCall ["enableChannel", _player];
                        } forEach _enableArray;

                        ["zen_common_hint", ["Zeus has changed channel visibility for you."], _player] call CBA_fnc_targetEvent;
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

                    if (_uid in _players || {(group _player) in _groups} || {(side _player) in _sides}) then {
                        _player setVariable [QGVAR(snow), _intensitySnow, true];

                        // Using events doesn't seem to work
                        remoteExecCall [QFUNC(snowScriptPFH), _player];
                    };
                };
            }, [_uid, _name], 60, {
                params ["_uid", "_name"];

                ["zen_common_execute", [zen_common_fnc_showMessage, ["[Zeus Additions]: Could not apply JIP features on player '%1', UID '%2'", _name, _uid]], allCurators] call CBA_fnc_targetEvent;
            }] call CBA_fnc_waitUntilAndExecute;
        }];
    }
] remoteExecCall ["call", 2];
