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

// If EH is already added or setting is disabled, exit
if (!isMultiplayer || {!GVAR(enableJIP)} || {GETMVAR(QGVAR(handleServerJIP),false)}) exitWith {};

// Make sure only 1 EH is added to the server
SETMVAR(QGVAR(handleServerJIP),true,true);

// remoteExecCall can account for side (and group JIP), but not for individual player JIP. That's why this function exists
["zen_common_execute", [{
    addMissionEventHandler ["PlayerConnected", {
        params ["", "_uid", "_name", "_jip", "", "_idstr"];

        if (!_jip) exitWith {};

        [{
            // Wait for player to exist; If player is Virtual Curator, BIS_fnc_getUnitByUID does not work; use getUserInfo instead
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

                    "Zeus has changed channel visibility for you." remoteExecCall ["hint", _player];
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
                    ["zen_common_execute", [{
                        params ["_unit", "_txMultiplier", "_rxMultiplier"];

                        _unit setVariable ["tf_sendingDistanceMultiplicator", _txMultiplier];
                        _unit setVariable ["tf_receivingDistanceMultiplicator", _rxMultiplier];
                    }, [_player, _txMultiplier, _rxMultiplier]], _unit] call CBA_fnc_targetEvent;
                };
            };

            // For snow script
            if (!isNil QGVAR(snowSettingsJIP)) then {
                GVAR(snowSettingsJIP) params ["_players", "_groups", "_sides", "_stormIntensity"];

                if (_stormIntensity == 0) exitWith {};

                if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                    _player setVariable [QGVAR(stormIntensity), _stormIntensity, true];

                    // Using events doesn't seem to work
                    remoteExecCall [QFUNC(snowScriptPFH), _player];
                };
            };
        }, [_uid, _idstr, _name], 60, {
            ["[Zeus Additions]: Could not apply JIP features on player '%1', UID '%2'", _this select 2, _this select 0] remoteExecCall ["zen_common_fnc_showMessage", allCurators];
        }] call CBA_fnc_waitUntilAndExecute;
    }];
}, []]] call CBA_fnc_serverEvent;
