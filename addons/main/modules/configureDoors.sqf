/*
 * Author: johnb43, with help from scripts from mharis001 (ZEN) & Kex (Achilles)
 * Adds a module allows you to change if people can open doors on buildings.
 * Grenade Effect from here (tweaked by johnb43):
 * https://forums.bohemia.net/forums/topic/199056-need-to-make-a-small-explosion-on-trigger/?do=findComment&comment=3123988
 */

["Zeus Additions - Utility", "Configure Doors (Extended)", {
    params ["_pos"];

    // Position has to be AGL/ATL, ZEN gives ASL
    _pos set [2, 0.5];

    ["Configure Building Doors", [
        ["TOOLBOX", "Lock state", [0, 1, 4, ["Unbreachable", "Breachable", "Closed", "Open"]], false],
        ["EDIT", ["Explosives", "An array that contains all allowed explosives used for breaching.\nEach time this dialog is opened and not aborted, the array used for checking explosives compatibility will be updated."], GETPRVAR(QGVAR(explosivesBreach),"['DemoCharge_Remote_Mag']"), true],
        ["EDIT", ["Stun grenades", "An array that contains all allowed explosives."], GETPRVAR(QGVAR(stunsBreach),"['ACE_M84']"), true],
        ["CHECKBOX", ["Reset to default lists", "Resets the explosives & stuns lists above to the default."], false, true]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_mode", "_explosives", "_stuns", "_reset"];

        if (_reset) exitWith {
            SETPRVAR(QGVAR(explosivesBreach),"['DemoCharge_Remote_Mag']");
            SETPRVAR(QGVAR(stunsBreach),"['ACE_M84']");

            SETMVAR(QGVAR(explosivesBreach),['DemoCharge_Remote_Mag']);
            SETMVAR(QGVAR(stunsBreach),['ACE_M84']);

            ["Reset lists to default"] call zen_common_fnc_showMessage;
        };

        SETPRVAR(QGVAR(explosivesBreach),_explosives);
        SETPRVAR(QGVAR(stunsBreach),_stuns);

        SETMVAR(QGVAR(explosivesBreach),_explosives);
        SETMVAR(QGVAR(stunsBreach),_stuns);

        _building = nearestObject [_pos, "Building"];

        if (isNull _building) exitWith {
            ["No building found!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _sortedSelectionNames = _building call FUNC(findDoors);

        if (isNil "_sortedSelectionNames") exitWith {};

        private _lock = 1;

        switch (_mode) do {
            case 2: {_lock = 0};
            case 3: {_lock = 2};
            default {};
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
        } forEach _sortedSelectionNames;

        // Remove all previous breaching actions from building
        ["zen_common_execute", [{
            if (!hasInterface) exitWith {};

            {
                if ("Breach door using explosives" in ((_this actionParams _x) select 0)) then {
                    _this removeAction _x;
                };
            } forEach actionIDs _this;
        }, _building]] call CBA_fnc_globalEvent;

        [(["Building doors locked (not breachable)", "Building doors locked (breachable)", "Building doors unlocked", "Building doors opened"] select _mode)] call zen_common_fnc_showMessage;

        // 0 unbreachable, 1 breachable, 2 closed, 3 open
        if (_mode isNotEqualTo 1) exitwith {};

        {
            _jipID = ["zen_common_execute", [{
                if (!hasInterface) exitWith {};

                params ["_building", "_selectionName", "_index"];

                _building addAction [
                    "<t color='#FF0000'>Breach door using explosives</t>",
                    {
                        params ["_target", "_caller", "", "_args"];
                        _args params ["_door", "_doorID"];

                        // In case door has been unlocked by other means
                        if (([_target, _doorID] call zen_doors_fnc_getState) isNotEqualTo 1) exitWith {
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
                                } forEach actionIDs _target;
                            }, [_target, _door]]] call CBA_fnc_globalEvent;
                        };

                        private _explosive = nil;
                        private _explosives = GETMVAR(QGVAR(explosivesBreach),['DemoCharge_Remote_Mag']);

                        {
                            if (_x in _explosives) exitWith {
                               _explosive = _x;
                            };
                        } forEach magazines _caller;

                        if (isNil "_explosive") exitWith {
                            hint "You need a compatible explosive to breach!";
                        };

                        ["Configure Breaching Charge", [
                            ["TOOLBOX:YESNO", ["Use stun grenade", "Spawns a stun grenade when opening the door. Requires a stun grenade defined by the Zeus."], false],
                            ["SLIDER", ["Explosives Timer", "Sets how long the explosives take to blow after having interacted with them."], [5, 120, 20, 0]]
                        ],
                        {
                            params ["_results", "_args"];
                            _results params ["_useStun", "_timer"];
                            _args params ["_target", "_caller", "_explosive", "_door", "_doorID"];

                            private _exit = false;
                            private _stun = nil;

                            // Find stun compatible grenade if enabled
                            if (_useStun) then {
                                private _stuns = GETMVAR(QGVAR(stunsBreach),['ACE_M84']);

                                {
                                    if (_x in _stuns) exitWith {
                                       _stun = _x;
                                    };
                                } forEach magazines _caller;

                                if (isNil "_stun") exitWith {
                                    hint "You need a compatible stun grenade to open this door!";
                                    _exit = true;
                                };
                            };

                            if (_exit) exitWith {};

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
                                } forEach actionIDs _target;
                            }, [_target, _door]]] call CBA_fnc_globalEvent;

                            // Get rid of JIP handler
                            private _jipID = _target getVariable (format [QGVAR(doorJIP_%1_%2), _door, _doorID]);

                            if (!isNil "_jipID") then {
                                _jipID call CBA_fnc_removeGlobalEventJIP;

                                _target setVariable [format [QGVAR(doorJIP_%1_%2), _door, _doorID], nil, true];
                            };

                            if (_timer > 5) then {
                                hint format ["Breaching in %1s!", _timer];

                                [{
                                    hint "";
                                }, nil, 2] call CBA_fnc_waitAndExecute;
                            };

                            // Do place explosive animation
                            _caller playActionNow "PutDown";
                            _caller setVariable ["ace_explosives_PlantingExplosive", true];

                            [{
                                _this setVariable ["ace_explosives_PlantingExplosive", false];
                            }, _caller, 1.5] call CBA_fnc_waitAndExecute;

                            // Get door surface to place explosive on
                            private _unitPos = eyePos _caller;
                            private _intersection = (lineIntersectsSurfaces [_unitPos, _unitPos vectorAdd ((eyeDirection _caller) vectorMultiply 2.5), _caller, objNull, true, 1, "GEOM"]) select 0;

                            // If door is out of glass for example, it will not return anything
                            if (isNil "_intersection") exitWith {
                                hint "No surface could be found to place the explosive on.";
                            };

                            _intersection params ["_intersectPosASL", "_surfaceNormal", "_intersectObject", "_parentObject"];

                            // Spawn explosive
                            private _helperObject = "DemoCharge_F" createVehicle [0, 0, 0];
                            _helperObject setPosASL _intersectPosASL;

                            // If the surface is facing either facing N or S, we must rotate it, otherwise it isn't placed correctly
                            if ((_surfaceNormal select 0) isEqualTo 0 && {(_surfaceNormal select 2) isEqualTo 0}) then {
                                _helperObject setVectorDirAndUp [[0, 0, 1], _surfaceNormal];
                            } else {
                                _helperObject setVectorUp _surfaceNormal;
                            };

                            // Add object to Zeus interface
                            ["zen_common_addObjects", [[_helperObject]]] call CBA_fnc_serverEvent;

                            // Remove explosive & stun once everything is sure to go through, so player doesn't lose anything unfairly
                            _caller removeItem _explosive;

                            if (_useStun) then {
                                _caller removeItem _stun;
                            };

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
                                ["zen_common_execute", [{
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
                                    playSound3D ["A3\Sounds_F\arsenal\explosives\grenades\Explosion_HE_grenade_01.wss", _this, false, getPosASL _this, 1, 1, 0, 0, true];
                                }, _this]] call CBA_fnc_globalEvent;

                                // Only execute once after this
                                if (!local _this) exitWith {};

                                // Hide helper; This makes it as if it had blown up, however it can't be deleted too quickly, otherwise sound doesn't play
                                [_this, true] remoteExecCall ["hideObjectGlobal", 2];
                            }, _helperObject, _timer] call CBA_fnc_waitAndExecute;

                            [{
                                params ["_helperObject", "_surfaceNormal", "_useStun", "_target", "_door", "_doorID"];

                                // Delay lets the sound play correctly
                                deleteVehicle _helperObject;

                                if (_useStun && {isClass (configFile >> "CfgPatches" >> "ace_grenades")}) then {
                                    ["ACE_G_M84" createVehicle ((getPosATL _helperObject) vectorAdd (_surfaceNormal vectorMultiply -0.3))] call ace_grenades_fnc_flashbangThrownFuze;
                                };

                                [_target, _doorID, 2] call zen_doors_fnc_setState;
                            }, [_helperObject, _surfaceNormal, _useStun, _target, _door, _doorID], _timer + 0.5] call CBA_fnc_waitAndExecute;
                        }, {}, [_target, _caller, _explosive, _door, _doorID]] call zen_dialog_fnc_create;
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
        } forEach _sortedSelectionNames;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}, ICON_DOOR] call zen_custom_modules_fnc_register;
