/*
 * Author: johnb43, with help from scripts from mharis001 (ZEN) & Kex (Achilles)
 * Adds a module allows you to change if people can open doors on buildings.
 * Grenade Effect from here (tweaked by johnb43):
 * https://forums.bohemia.net/forums/topic/199056-need-to-make-a-small-explosion-on-trigger/?do=findComment&comment=3123988
 */

["Zeus Additions - Utility", "Configure Doors (Extended)", {
    ["Configure Building Doors", [
        ["TOOLBOX", "Lock state", [0, 1, 4, ["Unbreachable", "Breachable", "Closed", "Open"]], false],
        ["EDIT", ["Explosives/Items", "An array that contains all allowed explosives/items used for breaching.\nEach time this dialog is opened and not aborted, the array used for checking explosives/items compatibility will be updated."], GETPRVAR(QGVAR(explosivesBreach), str ['DemoCharge_Remote_Mag']), true],
        ["CHECKBOX", ["Reset to default lists", "Resets the explosives list above to the default."], false, true]
    ], {
        params ["_results", "_args"];
        _results params ["_mode", "_explosives", "_reset"];
        _args params ["_pos", "_object"];

        if (_reset) exitWith {
            SETPRVAR(QGVAR(explosivesBreach),str ['DemoCharge_Remote_Mag']);
            SETMVAR(QGVAR(explosivesBreach),["DemoCharge_Remote_Mag"],true);

            ["Reset lists to default"] call zen_common_fnc_showMessage;
        };

        // Convert to config case and remove non-existent items
        _explosives = ((parseSimpleArray _explosives) apply {configName (_x call CBA_fnc_getItemConfig)}) - [""];

        SETPRVAR(QGVAR(explosivesBreach),str _explosives);
        SETMVAR(QGVAR(explosivesBreach),_explosives,true);

        // Use passed object if valid
        private _building = if (isNull _object || {!(_object isKindOf "Building")}) then {
            // Position has to be AGL/ATL, ZEN gives ASL
            nearestObject [ASLToATL _pos, "Building"]
        } else {
            _object
        };

        if (isNull _building) exitWith {
            ["STR_ZEN_Modules_BuildingTooFar"] call zen_common_fnc_showMessage;
        };

        private _selectionNames = [];

        // Find doors; Done with help from scripts from mharis001 (ZEN) & Kex (Achilles)
        {
            if ("door" in _x && {!("handle" in _x)} && {!("doorlocks" in _x )}) then {
                _selectionNames pushBack _x;
            };
        } forEach ((selectionNames _building) apply {toLowerANSI _x});

        // If no doors found, exit
        if (_selectionNames isEqualTo []) exitWith {
            ["No doors were found for %1", getText (configOf _building >> "displayName")] call zen_common_fnc_showMessage;
        };

        _selectionNames sort true;

        private _lock = switch (_mode) do {
            case 2: {0};
            case 3: {2};
            default {1};
        };

        private _jipID = "";

        // Close doors and remove old JIP handlers
        {
            [_building, _forEachIndex + 1, _lock] call zen_doors_fnc_setState;

            _jipID = _building getVariable (format [QGVAR(doorJIP_%1_%2), _x, _forEachIndex + 1]);

            // Remove action from JIP
            if (!isNil "_jipID") then {
                _jipID call CBA_fnc_removeGlobalEventJIP;

                _building setVariable [format [QGVAR(doorJIP_%1_%2), _x, _forEachIndex + 1], nil, true];
            };
        } forEach _selectionNames;

        // Remove all previous breaching actions from building
        ["zen_common_execute", [{
            if (!hasInterface) exitWith {};

            {
                if ("Breach door using explosives" in ((_this actionParams _x) select 0)) then {
                    _this removeAction _x;
                };
            } forEach (actionIDs _this);
        }, _building]] call CBA_fnc_globalEvent;

        [(["Building doors locked (not breachable)", "Building doors locked (breachable)", "Building doors unlocked", "Building doors opened"] select _mode)] call zen_common_fnc_showMessage;

        // 0 unbreachable, 1 breachable, 2 closed, 3 open
        if (_mode != 1) exitwith {};

        {
            _jipID = ["zen_common_execute", [{
                if (!hasInterface) exitWith {};

                params ["_building", "_selectionName", "_index"];

                _building addAction [
                    "<t color='#FF0000'>Breach door using explosives</t>",
                    {
                        params ["_target", "_caller", "_actionID", "_args"];
                        _args params ["_door", "_doorID"];

                        // In case door has been unlocked by other means
                        if ([_target, _doorID] call zen_doors_fnc_getState != 1) exitWith {
                            hint "You find the door to be unlocked.";

                            // Remove the action globally; actionIDs are not the same on all clients!!!
                            ["zen_common_execute", [{
                                if (!hasInterface) exitWith {};

                                params ["_target", "_door"];

                                private _actionParams = [];

                                {
                                    _actionParams = _target actionParams _x;

                                    if ("Breach door using explosives" in (_actionParams select 0) && {_door == (_actionParams select 12)}) then {
                                        _target removeAction _x;
                                    };
                                } forEach (actionIDs _target);
                            }, [_target, _door]]] call CBA_fnc_globalEvent;
                        };

                        private _explosives = GETMVAR(QGVAR(explosivesBreach),['DemoCharge_Remote_Mag']);

                        if ((_explosives param [_explosives findAny (itemsWithMagazines _caller), ""]) == "") exitWith {
                            hint "You need a compatible item to breach!";
                        };

                        ["Configure Breaching Charge", [
                            ["SLIDER", ["Explosives Timer", "Sets how long the explosives take to blow after having interacted with them."], [5, 120, 20, 0]]
                        ], {
                            params ["_results", "_args"];
                            _results params ["_timer"];
                            _args params ["_target", "_caller", "_explosives", "_door", "_doorID", "_actionID"];

                            // Check if action hasn't alredy been used, while unit was in menu
                            if !(_actionID in (actionIDs _target)) exitWith {
                                hint "Door has already been breached!";
                            };

                            // Check if the item hasn't disappeared since the last check
                            private _explosive = _explosives param [_explosives findAny (itemsWithMagazines _caller), ""];

                            if (_explosive == "") exitWith {
                                hint "You need a compatible item to breach!";
                            };

                            // Get door surface to place explosive on
                            private _unitPos = eyePos _caller;
                            private _intersection = (lineIntersectsSurfaces [_unitPos, _unitPos vectorAdd ((eyeDirection _caller) vectorMultiply 2.5), _caller, objNull, true, 1, "GEOM"]) param [0, []];

                            // If door is out of glass for example, it will not return anything
                            if (_intersection isEqualTo []) exitWith {
                                hint "No surface could be found to place the explosive on.";
                            };

                            _intersection params ["_intersectPosASL", "_surfaceNormal"];

                            // Spawn explosive
                            private _helperObject = "DemoCharge_F" createVehicle [0, 0, 0];
                            _helperObject setPosASL _intersectPosASL;

                            // If the surface is facing either facing N or S, we must rotate it, otherwise it isn't placed correctly; Remove from JIP when object is deleted
                            if ((_surfaceNormal select 0) == 0 && {(_surfaceNormal select 2) == 0}) then {
                                [["zen_common_setVectorDirAndUp", [_helperObject, [[0, 0, 1], _surfaceNormal]]] call CBA_fnc_globalEventJIP, _helperObject] call CBA_fnc_removeGlobalEventJIP;
                            } else {
                                [["zen_common_setVectorUp", [_helperObject, _surfaceNormal]] call CBA_fnc_globalEventJIP, _helperObject] call CBA_fnc_removeGlobalEventJIP;
                            };

                            // Add object to Zeus interface
                            ["zen_common_addObjects", [[_helperObject]]] call CBA_fnc_serverEvent;

                            _timer = round _timer;

                            // Remove the action globally; actionIDs are not the same on all clients!!!
                            ["zen_common_execute", [{
                                if (!hasInterface) exitWith {};

                                params ["_target", "_door"];

                                private _actionParams = [];

                                {
                                    _actionParams = _target actionParams _x;

                                    if ("Breach door using explosives" in (_actionParams select 0) && {_door == (_actionParams select 12)}) then {
                                        _target removeAction _x;
                                    };
                                } forEach (actionIDs _target);
                            }, [_target, _door]]] call CBA_fnc_globalEvent;

                            // Get rid of JIP handler
                            private _jipID = _target getVariable (format [QGVAR(doorJIP_%1_%2), _door, _doorID]);

                            if (!isNil "_jipID") then {
                                _jipID call CBA_fnc_removeGlobalEventJIP;

                                _target setVariable [format [QGVAR(doorJIP_%1_%2), _door, _doorID], nil, true];
                            };

                            // Notify player
                            hint format ["Breaching in %1s!", _timer];

                            [{
                                hint "";
                            }, nil, 2] call CBA_fnc_waitAndExecute;

                            // Do place explosive animation
                            _caller playActionNow "PutDown";
                            _caller setVariable ["ace_explosives_PlantingExplosive", true];

                            [{
                                _this setVariable ["ace_explosives_PlantingExplosive", false];
                            }, _caller, 1.5] call CBA_fnc_waitAndExecute;

                            // Remove explosive
                            _caller removeItem _explosive;

                            // Do the countdown
                            [{
                                hint "Breaching in 5...";
                            }, nil, _timer - 5] call CBA_fnc_waitAndExecute;
                            [{
                                hint "Breaching in 4...";
                            }, nil, _timer - 4] call CBA_fnc_waitAndExecute;
                            [{
                                hint "Breaching in 3...";
                            }, nil, _timer - 3] call CBA_fnc_waitAndExecute;
                            [{
                                hint "Breaching in 2...";
                            }, nil, _timer - 2] call CBA_fnc_waitAndExecute;
                            [{
                                hint "Breaching in 1...";
                            }, nil, _timer - 1] call CBA_fnc_waitAndExecute;
                            [{
                                hint "";
                            }, nil, _timer] call CBA_fnc_waitAndExecute;

                            // Spawn grenade effect to make an explosion globally
                            [{
                                params ["_helperObject", "_target", "_doorID"];

                                ["zen_common_execute", [{
                                    // Hide helper; This makes it as if it had blown up, however it can't be deleted too quickly, otherwise sound doesn't play
                                    if (isServer) then {
                                        _helperObject hideObjectGlobal true;
                                    };

                                    if (!hasInterface) exitWith {};

                                    private _pos = getPosATL _this;

                                    // Create blast effect
                                    private _source1 = "#particlesource" createVehicleLocal _pos;
                                    _source1 setParticleClass "IEDFlameS";
                                    _source1 setParticleParams [
                                    	["\A3\data_f\ParticleEffects\Universal\Universal", 16, 0, 32, 0], "", "Billboard", 0.3, 0.3, [0, 0, 0], [0, 1, 0], 0, 10, 7.9, 0.1, [1.00375, 0.50375],
                                    	[[1, 1, 1, -6], [1, 1, 1, 0]], [1], 0.2, 0.2, "", "", "", 0, false, 0.6, [[30, 30, 30, 0], [0, 0, 0, 0]]
                                    ];
                                    _source1 setParticleRandom [0, [0.4, 0.1, 0.4], [0.2, 0.5, 0.2], 90, 0.5, [0, 0, 0, 0], 0, 0, 1, 0.0];
                                    _source1 setParticleCircle [0, [0, 0, 0]];

                                    // Create smoke effect
                                    private _source2 = "#particlesource" createVehicleLocal _pos;
                                    _source2 setParticleClass "LaptopSmoke";
                                    _source2 setParticleParams [
                                    	["\A3\data_f\ParticleEffects\Universal\Universal", 16, 9, 1, 0], "", "Billboard", 1, 8, [0, 0, 0], [0, 1.5, 0], 0, 0.0522, 0.04, 0.24, [3.104, 6.1, 8.104, 10.104],
                                    	[[0.7, 0.7, 0.7, 0.36], [0.8, 0.8, 0.8, 0.24], [0.85, 0.85, 0.85, 0.14], [0.9, 0.9, 0.9, 0.08], [0.9, 0.9, 0.9, 0.04], [1, 1, 1, 0.01]], [1000], 0.2, 0.2, "", "", "", 0, false, 0.6, [[30, 30, 30, 0], [0, 0, 0, 0]]
                                    ];
                                    _source2 setParticleRandom [2, [0.8, 0.2, 0.8], [2.5, 3.5, 2.5], 3, 0.4, [0, 0, 0, 0], 0.5, 0.02, 1, 0.0];
                                    _source2 setParticleCircle [0, [0, 0, 0]];
                                    _source2 setDropInterval 0.08;

                                    // Create lighting change
                                    private _light = "#lightPoint" createVehicleLocal _pos;
                                    _light setLightAmbient [0, 0, 0];
                                    _light setLightBrightness 10;
                                    _light setLightColor [1, 0.6, 0.4];
                                    _light setLightIntensity 10000;
                                    _light setLightAttenuation [0, 0, 0, 2.2, 500, 1000];

                                    // Delete objects after set amount of time
                                    [{
                                    	{
                                    		deleteVehicle _x;
                                    	} forEach _this;
                                    }, [_source1, _light], 0.1] call CBA_fnc_waitAndExecute;

                                    [{deleteVehicle _this}, _source2, 1] call CBA_fnc_waitAndExecute;

                                    // Play locally because it doesn't always work globally
                                    playSound3D ["A3\Sounds_F\arsenal\explosives\grenades\Explosion_HE_grenade_01.wss", _this, (insideBuilding _this) > 0.5, getPosASL _this, 1, 1, 0, 0, true];
                                }, _helperObject]] call CBA_fnc_globalEvent;

                                [{
                                    params ["_helperObject", "_target", "_doorID"];

                                    // Delay lets the sound play correctly
                                    deleteVehicle _helperObject;

                                    [_target, _doorID, 2] call zen_doors_fnc_setState;
                                }, _this, 0.5] call CBA_fnc_waitAndExecute;
                            }, [_helperObject, _target, _doorID], _timer] call CBA_fnc_waitAndExecute;
                        }, {}, [_target, _caller, _explosives, _door, _doorID, _actionID]] call zen_dialog_fnc_create;
                    },
                    [_selectionName, _index + 1],
                    1.5,
                    true,
                    true,
                    "",
                    "true",
                    2,
                    false,
                    _selectionName
                ];
            }, [_building, _x, _forEachIndex]]] call CBA_fnc_globalEventJIP;

            _building setVariable [format [QGVAR(doorJIP_%1_%2), _x, _forEachIndex + 1], _jipID, true];

            [_jipID, _building] call CBA_fnc_removeGlobalEventJIP;
        } forEach _selectionNames;
    }, {}, _this] call zen_dialog_fnc_create;
}, ICON_DOOR] call zen_custom_modules_fnc_register;
