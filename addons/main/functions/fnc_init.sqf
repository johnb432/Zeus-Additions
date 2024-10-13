#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Initialises Zeus Additions on PCs.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_init;
 *
 * Public: No
 */

// Don't run function more than once on a PC
if (!isNil QGVAR(init)) exitWith {};

GVAR(init) = true;

INFO_4("Init: Net mode: %1 - %2 loaded: %3 - clientOwner %4",call BIS_fnc_getNetMode,toUpperANSI QUOTE(PREFIX),!isNil QUOTE(ADDON),clientOwner);

[QGVAR(executeFunction), {
    (_this select 1) call (GETMVAR(_this select 0,{}));
}] call CBA_fnc_addEventHandler;

[QGVAR(setUnloadInCombat), {
    (_this select 0) setUnloadInCombat [_this select 1, _this select 2];
}] call CBA_fnc_addEventHandler;

[QGVAR(awake), {
    (_this select 0) awake (_this select 1);
}] call CBA_fnc_addEventHandler;

// If single player, finish here
if (!isMultiplayer) exitWith {
    GVAR(functionsSent) = true;
};

if (isServer) then {
    // Whenever a player disconnects, reset his reasons
    addMissionEventHandler ["PlayerDisconnected", {
        [QGVAR(buildingDestruction), _this select 1, false, QFUNC(handleBuildingDestruction)] call FUNC(changeReason);
    }];

    // JIP event handling
    GVAR(jipEventQueue) = createHashMap;

    [QGVAR(addEventJIP), {
        params ["_eventName", "_params", "_jipID"];

        GVAR(jipEventQueue) set [_jipID, [_eventName, _params]];
    }] call CBA_fnc_addEventHandler;

    [QGVAR(removeEventJIP), {
        params ["_jipID", "_object"];

        if (isNull _object) then {
            GVAR(jipEventQueue) deleteAt _jipID;
        } else {
            [_object, "Deleted", {
                GVAR(jipEventQueue) deleteAt _thisArgs;
            }, _jipID] call CBA_fnc_addBISEventHandler;
        };
    }] call CBA_fnc_addEventHandler;

    [QGVAR(requestEventsJip), {
        {
            [_x select 0, _x select 1, _this] call CBA_fnc_ownerEvent;
        } forEach (values GVAR(jipEventQueue));
    }] call CBA_fnc_addEventHandler;
} else {
    // Headless clients
    if (!hasInterface) exitWith {
        [QGVAR(requestEventsJip), clientOwner] call CBA_fnc_serverEvent;
    };

    [{
        // Wait for player to exist and be local
        local player
    }, {
        [QGVAR(requestEventsJip), clientOwner] call CBA_fnc_serverEvent;

        private _unit = player;
        private _uid = getPlayerUID _unit;
        private _group = group _unit;
        private _side = side _unit;

        // For chat channels
        if (!isNil QGVAR(channelSettingsJIP)) then {
            GVAR(channelSettingsJIP) params ["_players", "_groups", "_sides", "_enableArray"];

            if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                {
                    (_x select 0) enableChannel (_x select 1);
                } forEach _enableArray;

                hint "Zeus has changed channel visibility for you.";
            };
        };

        // For grass rendering
        if (!isNil QGVAR(grassSettingsJIP)) then {
            GVAR(grassSettingsJIP) params ["_players", "_groups", "_sides", "_setting"];

            if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                setTerrainGrid _setting;
            };
        };

        // For TFAR radio range
        if (!isNil QGVAR(radioSettingsJIP)) then {
            GVAR(radioSettingsJIP) params ["_players", "_groups", "_sides", "_txMultiplier", "_rxMultiplier"];

            if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                _unit setVariable ["tf_sendingDistanceMultiplicator", _txMultiplier];
                _unit setVariable ["tf_receivingDistanceMultiplicator", _rxMultiplier];
            };
        };

        // For snow script
        if (!isNil QGVAR(stormSettingsJIP)) then {
            GVAR(stormSettingsJIP) params ["_players", "_groups", "_sides", "_stormIntensity"];

            if (_stormIntensity == 0) exitWith {};

            if (_uid in _players || {_group in _groups} || {_side in _sides}) then {
                _unit setVariable [QGVAR(stormIntensity), _stormIntensity, true];

                call FUNC(dustStormPFH);
            };
        };
    }, [], 60] call CBA_fnc_waitUntilAndExecute;
};

// Send functions to server once (if necessary)
if (!isNil QUOTE(ADDON) && {isNil QGVAR(functionsSent)}) then {
    if (!isServer) then {
        SEND_SERVER(changeReason);
        SEND_MP(handleBuildingDestruction);
    };

    GVAR(functionsSent) = true;
    publicVariable QGVAR(functionsSent);
};
