#include "script_component.hpp"

/*
 * Author: johnb43
 * Spawns a module that allows players to paradrop.
 * Some code usage from BIS_fnc_locationDescription.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_unitParadropAction;
 *
 * Public: No
 */

["Zeus Additions - Utility", "[WIP] Paradrop Unit Action", {
    params ["_pos", "_object"];

    ["Paradrop Units", [
        ["TOOLBOX", "Mode", [0, 1, 2, ["Add", "Remove"]], false]
    ],
    {
        params ["_results", "_args"];
        _results params ["_mode"];
        _args params ["_pos", "_object"];

        // If no object was selected, make a teleport pole
        if (isNull _object) then {
            _object = "FlagPole_F" createVehicle _pos;

            ["zen_common_addObjects", [[_object]]] call CBA_fnc_serverEvent;
        };

        // Add action
        if (_mode isEqualTo 0) then {
            if (!isNil {_object getVariable QGVAR(paradropActionJIP)}) exitWith {
                ["Object already has paradrop action!"] call zen_common_fnc_showMessage;
            };

            _object setVariable [QGVAR(paradropActionJIP),
                [
                    _object, [
                        "<t color='#FF0000'>Paradrop (click on map)</t>",
                        {
                            params ["", "_caller"];

                            openMap true;

                            if (!isNil {_caller getVariable QGVAR(handleMapParadrop)}) exitWith {};

                            _caller setVariable [QGVAR(handleMapParadrop),
                                addMissionEventHandler ["MapSingleClick", {
                                    [_this select 1, _thisArgs select 0] spawn {
                                        params ["_pos", "_unit"];

                                        private _mapCenter = worldSize / 2;

                                        // Find the nearest to the given position location with text
                                        private _location = locationNull;

                                        {
                                            if (text _x isNotEqualTo "") exitWith {
                                                _location = _x
                                            };
                                        } forEach nearestLocations [[_mapCenter, _mapCenter], ["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "NameMarine", "Hill", "HandDrawnCamp"], sqrt (2 * _mapCenter ^ 2), _pos];

                                        // No suitable location exists
                                        private _text = if (isNull _location) then {
                                            format [localize "STR_A3_BIS_fnc_locationDescription_grid", mapGridPosition _pos];
                                        } else {
                                            // Location exists and close
                                            if (_pos in _location) exitWith {
                                                format [localize "STR_A3_BIS_fnc_locationDescription_near", text _location];
                                            };

                                            private _locPos = locationPosition _location;

                                            // Location exists and not close, format the heading message
                                            format [
                                                "%1m %2",
                                                _pos vectorDistance _locPos,
                                                format [
                                                    localize (switch (round ((_locPos getDir _pos) % 360 / 45)) do {
                                                        default {"STR_A3_BIS_fnc_locationDescription_n"};
                                                        case 1: {"STR_A3_BIS_fnc_locationDescription_ne"};
                                                        case 2: {"STR_A3_BIS_fnc_locationDescription_e"};
                                                        case 3: {"STR_A3_BIS_fnc_locationDescription_se"};
                                                        case 4: {"STR_A3_BIS_fnc_locationDescription_s"};
                                                        case 5: {"STR_A3_BIS_fnc_locationDescription_sw"};
                                                        case 6: {"STR_A3_BIS_fnc_locationDescription_w"};
                                                        case 7: {"STR_A3_BIS_fnc_locationDescription_nw"};
                                                    }),
                                                    text _location
                                                ]
                                            ];
                                        };

                                        // Wait for confirmation
                                        if !([format ["Are you sure you want to teleport to %1?", _text], "Confirmation", "Yes", "No"] call BIS_fnc_guiMessage) exitWith {
                                            // Remove mapclick EH
                                            removeMissionEventHandler ["MapSingleClick", _unit getVariable QGVAR(handleMapParadrop)];
                                            _unit setVariable [QGVAR(handleMapParadrop), nil];

                                            // Close map
                                            openMap false;
                                        };

                                        // Allow player to give some information about paradrop
                                        ["Set Paradrop Height", [
                                            ["SLIDER", ["Paradrop Altitude", "Determines how far up you are paradropped over terrain level."], [150, 5000, 1000, 0]],
                                            ["TOOLBOX:YESNO", ["Give Yourself a Parachute", "Stores your backpack and gives you a parachute automatically. Upon landing you get your backpacks back."], true]
                                        ],
                                        {
                                            params ["_results", "_args"];
                                            _results params ["_height", "_giveUnitParachute"];
                                            _args params ["_pos", "_unit"];

                                            // Set correct height
                                            _pos set [2, _height];

                                            // Remove mapclick EH
                                            removeMissionEventHandler ["MapSingleClick", _unit getVariable QGVAR(handleMapParadrop)];
                                            _unit setVariable [QGVAR(handleMapParadrop), nil];

                                            // Close map
                                            openMap false;

                                            // If unit is already paradropping, don't TP
                                            if (_unit getVariable [QGVAR(isParadropping), false]) exitWith {};

                                            _unit setVariable [QGVAR(isParadropping), true, true];

                                            // Transition screen and inform about paradrop
                                            [["You are being paradropped...", "BLACK OUT", 2, true]] remoteExecCall ["cutText", _unit];
                                            ["zen_common_hint", ["The parachute will automatically deploy if you haven't deployed it before reaching 100m above ground level. Your backpack will be returned upon landing."], _unit] call CBA_fnc_targetEvent;

                                            // Teleport and add parachute
                                            ["zen_common_execute", [
                                                CBA_fnc_waitAndExecute, [
                                                    {
                                                        params ["_unit", "_pos", "_giveUnitParachute"];

                                                        _unit setPosATL _pos;

                                                        // Spawn parachute
                                                        if (_giveUnitParachute) then {
                                                            _unit addBackpack "B_Parachute";
                                                        };

                                                        [["", "BLACK IN", 2, true]] remoteExecCall ["cutText", _unit];
                                                    }, [_unit, _pos, _giveUnitParachute], 3
                                                ]
                                            ], _unit] call CBA_fnc_targetEvent;

                                            // If automatic parachute distribution is disabled, don't continue
                                            if (!_giveUnitParachute) exitWith {};

                                            // Store old backpack information, then delete backpack
                                            _unit setVariable [QGVAR(backpackUnit), backpack _unit, true];
                                            _unit setVariable [QGVAR(backpackContents), backpackItems _unit, true];
                                            removeBackpackGlobal _unit;

                                            [{
                                                ["zen_common_execute", [
                                                    CBA_fnc_waitUntilAndExecute, [
                                                        {
                                                            // If the unit is on the ground or in water
                                                            isTouchingGround _this || {(eyePos _this) select 2 < 1};
                                                        }, {
                                                            // Unit is no longer paradropping
                                                            _this setVariable [QGVAR(isParadropping), false, true];

                                                            // Remove parachute and give old backpack back
                                                            removeBackpackGlobal _this;
                                                            private _backpack = _this getVariable QGVAR(backpackUnit);

                                                            if (isNil "_backpack") exitWith {};

                                                            _this addBackpack _backpack;
                                                            _this setVariable [QGVAR(backpackUnit), nil, true];

                                                            // Return old content
                                                            private _contents = _this getVariable [QGVAR(backpackContents), []];

                                                            if (_contents isEqualTo []) exitWith {};

                                                            {
                                                                _this addItemToBackpack _x;
                                                            } forEach _contents;

                                                            _this setVariable [QGVAR(backpackContents), nil, true];
                                                        }, _this
                                                    ]
                                                ], _this] call CBA_fnc_targetEvent;

                                                ["zen_common_execute", [
                                                    CBA_fnc_waitUntilAndExecute, [
                                                        {
                                                            // If the units is <100m AGL, deploy parachute to prevent them splatting on the ground
                                                            (eyePos _this) select 2 < 100 || {!alive _this};
                                                        }, {
                                                            // If parachute is already open or unit is unconscious or dead, don't do action
                                                            if ((((objectParent _this) call BIS_fnc_objectType) select 1) isEqualTo "Parachute" || {_this getVariable ["ACE_isUnconscious", false]} || {!alive _this}) exitWith {};

                                                            _this action ["OpenParachute", _this];
                                                        }, _this
                                                    ]
                                                ], _this] call CBA_fnc_targetEvent;
                                            }, _unit, 3.5] call CBA_fnc_waitAndExecute;
                                        }, {
                                            private _unit = _this select 1 select 1;

                                            // Remove mapclick EH
                                            removeMissionEventHandler ["MapSingleClick", _unit getVariable QGVAR(handleMapParadrop)];
                                            _unit setVariable [QGVAR(handleMapParadrop), nil];

                                            // Close map
                                            openMap false;
                                        }, [_pos, _unit]] call zen_dialog_fnc_create;
                                    }
                                }, [_caller]]
                            ];
                        }
                    ]
                ] remoteExecCall ["addAction", 0, true], true
            ];

            ["Added paradrop action to object"] call zen_common_fnc_showMessage;
        } else {
            private _handleJIP = _object getVariable QGVAR(paradropActionJIP);

            if (isNil "_handleJIP") exitWith {
                ["Object already has paradrop action removed!"] call zen_common_fnc_showMessage;
            };

            remoteExecCall ["", _handleJIP];

            _object setVariable [QGVAR(paradropActionJIP), nil, true];

            // Remove action from object
            {
                if ("Paradrop (click on map)" in ((_object actionParams _x) select 0)) exitWith {
                    [_object, _x] remoteExecCall ["removeAction", 0];
                };
            } forEach actionIDs _object;

            ["Removed paradrop action from object"] call zen_common_fnc_showMessage;
        };
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, [_pos, _object]] call zen_dialog_fnc_create;
}, ICON_PARADROP] call zen_custom_modules_fnc_register;
