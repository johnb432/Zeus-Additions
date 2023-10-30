#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Adds JIP detection.
 *
 * Arguments:
 * 0: Add or remove <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * true call zeus_additions_main_fnc_handleJIP;
 *
 * Public: No
 */

if (!isMultiplayer) exitWith {};

if (_this) then {
    if (!isNil QGVAR(handleServerJIPEhID)) exitWith {};

    GVAR(handleServerJIPEhID) = addMissionEventHandler ["PlayerConnected", {
        params ["", "_uid", "_name", "_jip", "", "_idstr"];

        if (!_jip) exitWith {};

        [{
            // Wait for player to exist; If player is Virtual Curator, BIS_fnc_getUnitByUID does not work, use getUserInfo instead
            !isNull ((getUserInfo (_this select 1)) select 10)
        }, {
            params ["_uid", "_idstr"];

            private _player = (getUserInfo _idstr) select 10;
            private _group = group _player;
            private _side = side _player;

            // For chat channels
            if (!isNil QGVAR(channelSettingsJIP)) then {
                GVAR(channelSettingsJIP) params ["_players", "_groups", "_sides", "_enableArray"];

                if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                    {
                        _x remoteExecCall ["enableChannel", _player];
                    } forEach _enableArray;

                    "Zeus has changed channel visibility for you." remoteExecCall ["hint", _player]
                };
            };

            // For grass rendering
            if (!isNil QGVAR(grassSettingsJIP)) then {
                GVAR(grassSettingsJIP) params ["_players", "_groups", "_sides", "_setting"];

                if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                    _setting remoteExecCall ["setTerrainGrid", _player];
                };
            };

            // For TFAR radio range
            if (!isNil QGVAR(radioSettingsJIP)) then {
                GVAR(radioSettingsJIP) params ["_players", "_groups", "_sides", "_txMultiplier", "_rxMultiplier"];

                if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                    // Events do not work with JIP (they do not wait until locality has changed from server to client)
                    [_player, ["tf_sendingDistanceMultiplicator", _txMultiplier]] remoteExecCall ["setVariable", _player];
                    [_player, ["tf_receivingDistanceMultiplicator", _rxMultiplier]] remoteExecCall ["setVariable", _player];
                };
            };

            // For snow script
            if (!isNil QGVAR(stormSettingsJIP)) then {
                GVAR(stormSettingsJIP) params ["_players", "_groups", "_sides", "_stormIntensity"];

                if (_stormIntensity == 0) exitWith {};

                if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                    _player setVariable [QGVAR(stormIntensity), _stormIntensity, true];

                    remoteExecCall [QFUNC(stormScriptPFH), _player];
                };
            };
        }, [_uid, _idstr, _name], 60, {
            ["[Zeus Additions]: Could not apply JIP features on player '%1', UID '%2'", _this select 2, _this select 0] remoteExecCall ["zen_common_fnc_showMessage", allCurators];
        }] call CBA_fnc_waitUntilAndExecute;
    }];

    publicVariable QGVAR(handleServerJIPEhID);
} else {
    if (isNil QGVAR(handleServerJIPEhID)) exitWith {};

    removeMissionEventHandler ["PlayerConnected", GVAR(handleServerJIPEhID)];

    GVAR(handleServerJIPEhID) = nil;
    publicVariable QGVAR(handleServerJIPEhID);
};
