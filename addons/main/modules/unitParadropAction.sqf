/*
 * Author: johnb43
 * Spawns a module that allows players to paradrop.
 * Some code usage from BIS_fnc_locationDescription.
 */

["Zeus Additions - Utility", "Paradrop Unit Action", {
    ["Paradrop Units", [
        ["TOOLBOX", "Mode", [0, 1, 2, ["Add", "Remove"]]]
    ], {
        params ["_results", "_args"];
        _args params ["_pos", "_object"];

        // If no object was selected, make a teleport pole
        if (isNull _object) then {
            _object = "FlagPole_F" createVehicle _pos;

            ["zen_common_updateEditableObjects", [[_object]]] call CBA_fnc_serverEvent;
        };

        // Add action
        private _string = if ((_results select 0) == 0) then {
            if (!isNil {_object getVariable QGVAR(paradropActionJIP)}) exitWith {
                "Object already has paradrop action"
            };

            // Only send function to all clients if script is enabled
            if (isNil QFUNC(addParachute)) then {
                // Define a function on the client
                DFUNC(addParachute) = compileScript [format ["\%1\%2\%3\%4\functions\fnc_addParachute.sqf", QUOTE(MAINPREFIX), QUOTE(PREFIX), QUOTE(SUBPREFIX), QUOTE(COMPONENT)], true];

                // Broadcast function to everyone, so it can be executed for all players
                publicVariable QFUNC(addParachute);
            };

            private _jipID = ["zen_common_execute", [{
                if (!hasInterface) exitWith {};

                private _actionID = _this addAction [
                    "<t color='#FF0000'>Paradrop (click on map)</t>", {
                        params ["", "_caller"];

                        // If unit is already paradropping, don't do anything
                        if (_caller getVariable [QGVAR(isParadropping), false]) exitWith {};

                        openMap true;

                        if (!isNil {_caller getVariable QGVAR(handleMapParadrop)}) exitWith {};

                        _caller setVariable [QGVAR(handleMapParadrop), true];

                        addMissionEventHandler ["MapSingleClick", {
                            // Remove mapclick EH
                            removeMissionEventHandler [_thisEvent, _thisEventHandler];

                            [_this select 1, _thisArgs select 0] spawn {
                                params ["_pos", "_unit"];

                                _unit setVariable [QGVAR(handleMapParadrop), nil];

                                // Find the nearest to the given position location with text
                                private _location = locationNull;
                                private _mapCenter = worldSize / 2;

                                {
                                    if (text _x != "") exitWith {
                                        _location = _x
                                    };
                                } forEach nearestLocations [[_mapCenter, _mapCenter], ["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "NameMarine", "Hill", "HandDrawnCamp"], sqrt (2 * _mapCenter ^ 2), _pos];

                                // No suitable location exists
                                private _text = if (isNull _location) then {
                                    format [localize "STR_A3_BIS_fnc_locationDescription_grid", mapGridPosition _pos]
                                } else {
                                    // Location exists and close
                                    if (_pos in _location) exitWith {
                                        format [localize "STR_A3_BIS_fnc_locationDescription_near", text _location]
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
                                    ]
                                };

                                // Close map
                                openMap false;

                                // Wait for confirmation
                                if !([format ["Are you sure you want to teleport to and paradrop %1?", _text], "Confirmation", "Yes", "No"] call BIS_fnc_guiMessage) exitWith {};

                                // Allow player to give some information about paradrop
                                ["Set Paradrop Height", [
                                    ["SLIDER", ["Paradrop Altitude", "Determines how far up you are paradropped over terrain level."], [150, 5000, 1000, 0]],
                                    ["TOOLBOX:YESNO", ["Give Yourself a Parachute", "Stores your backpack and gives you a parachute automatically. Upon landing you get your backpacks back."], true]
                                ],
                                {
                                    params ["_results", "_args"];
                                    _results params ["_height", "_giveUnitParachute"];
                                    _args params ["_pos", "_unit"];

                                    // If unit is already paradropping, don't TP
                                    if (_unit getVariable [QGVAR(isParadropping), false]) exitWith {};

                                    _unit setVariable [QGVAR(isParadropping), true, true];

                                    // Set correct height
                                    _pos set [2, _height];

                                    // Start paradrop
                                    [_unit, _pos, _giveUnitParachute] call FUNC(addParachute);
                                }, {}, [_pos, _unit]] call zen_dialog_fnc_create;
                            }
                        }, [_caller]];
                    }
                ];

                _this setVariable [QGVAR(paradropActionID), _actionID];
            }, _object]] call CBA_fnc_globalEventJIP;

            _object setVariable [QGVAR(paradropActionJIP), _jipID, true];

            // Remove from JIP if object is deleted
            [_jipID, _object] call CBA_fnc_removeGlobalEventJIP;

            "Added paradrop action to object"
        } else {
            private _jipID = _object getVariable QGVAR(paradropActionJIP);

            if (isNil "_jipID") exitWith {
                "Object already has paradrop action removed"
            };

            _jipID call CBA_fnc_removeGlobalEventJIP;

            _object setVariable [QGVAR(paradropActionJIP), nil, true];

            // Remove action from object; actionIDs are not the same on all clients!!!
            ["zen_common_execute", [{
                if (!hasInterface) exitWith {};

                private _actionID = _this getVariable QGVAR(paradropActionID);

                if (isNil "_actionID") exitWith {};

                _this removeAction _actionID;
            }, _object]] call CBA_fnc_globalEvent;

            "Removed paradrop action from object"
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _this] call zen_dialog_fnc_create;
}, ICON_PARADROP] call zen_custom_modules_fnc_register;
