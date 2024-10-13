/*
 * Author: Fred, with modifications made by johnb43
 * Creates a module that spawns a dog.
 */

[LSTRING(moduleCategoryAI), LSTRING(dogAttackModuleName), {
    params ["_pos"];

    // Position has to be AGL/ATL, ZEN gives ASL
    _pos = ASLToATL _pos;

    [LSTRING(dogAttackModuleName), [
        ["SIDES", ["str_a3_cfgvehicles_modulechat_f_arguments_channel_values_side_0", LSTRING(dogAttackSideDesc)], []],
        ["SIDES", ["str_a3_smartmarkers_smartmarker_t_distraction_f_sections_markertext0", LSTRING(dogAttackDesc)], []],
        ["SLIDER", [LSTRING_CBA(modules,searchRadius), LSTRING(dogAttackSearchDesc)], [0, 1000, 100, 0]],
        [["SLIDER:PERCENT", ["str_a3_normaldamage1", LSTRING(dogAttackDamageDesc)], [0, 1, 0.1]], ["SLIDER", ["str_a3_normaldamage1", LSTRING(dogAttackDamageDesc)], [0, 50, 3, 2]]] select (GETMVAR("ace_medical_enabled",zen_common_aceMedical)),
        ["TOOLBOX:YESNO", [LSTRING(dogAttackLightning), LSTRING(dogAttackLightningDesc)], false],
        ["TOOLBOX:YESNO", ["str_3den_trigger_attribute_sound_displayname", LSTRING(dogAttackThunderDesc)], false],
        ["TOOLBOX:YESNO", [LSTRING(disablePathingContextMenu), LSTRING(dogAttackPathingDesc)], false],
        ["EDIT", ["str_3den_object_attribute_unitname_displayname", LSTRING(dogAttackNameDesc)], ""]
    ], {
        params ["_results", "_pos"];
        _results params ["_sides", "_attackSides", "_radius", "_damage", "_spawnLightning", "_spawnBolt", "_animalBehaviour", "_name"];

        if (_sides isEqualTo []) exitWith {
            ["You must select a side"] call zen_common_fnc_showMessage;
        };

        private _lightning = objNull;

        // Make lightning bolt
        if (_spawnLightning) then {
            // Only send function to all clients if script is enabled
            if (isNil QFUNC(spawnLight)) then {
                DFUNC(spawnLight) = [{
                    if (!hasInterface) exitWith {};

                    private _light = createVehicleLocal ["#lightpoint", _this vectorAdd [0, 0, 10], [], 0, "CAN_COLLIDE"];
                    _light setLightDayLight true;
                    _light setLightBrightness 300;
                    _light setLightAmbient [0.05, 0.05, 0.1];
                    _light setLightColor [1, 1, 2];

                    [{
                        _this setLightBrightness (100 + random 100);

                        [{
                            _this setLightBrightness (100 + random 100);

                            [{
                                deleteVehicle _this;
                            }, _this, 0.15] call CBA_fnc_waitAndExecute;
                        }, _this, 0.15] call CBA_fnc_waitAndExecute;
                    }, _light, 0.15] call CBA_fnc_waitAndExecute;
                }, true] call FUNC(sanitiseFunction);

                SEND_MP(spawnLight);
            };

            _lightning = createVehicle [format ["Lightning%1_F", floor (random 2) + 1], _pos, [], 0, "CAN_COLLIDE"];
            _lightning setDir random 360;
            _lightning setVehiclePosition [_pos, [], 0, "CAN_COLLIDE"];

            [QGVAR(executeFunction), [QFUNC(spawnLight), _pos]] call CBA_fnc_globalEvent;

            [{
                deleteVehicle _this;
            }, _lightning, 0.4 + random [0, 0.1, 0.2]] call CBA_fnc_waitAndExecute; // https://en.wikipedia.org/wiki/Lightning#Distribution,_frequency_and_extent
        };

        // Make sound for lightning bolt
        if (_spawnBolt) then {
            (createVehicle ["LightningBolt", _pos, [], 0, "CAN_COLLIDE"]) setDamage 1;
        };

        [{
            // Wait until lightning bolt has been deleted
            isNull (_this select 0)
         }, {
            params ["", "_side", "_attackSides", "_radius", "_damage", "_pos", "_animalBehaviour", "_name"];

            // Create dog
            private _group = createGroup _side;
            private _dog = _group createUnit ["Fin_random_F", _pos, [], 0, "CAN_COLLIDE"];

            _dog call zen_common_fnc_updateEditableObjects;

            if (_name == "") then {
                _name = selectRandom ["Fluffy", "Doggo", "Cuddles", "Santa's Little Helper", "Biter", "Foxer", "Boxy", "Death", "Sir KillsALot"];
            };

            [["zen_common_setName", [_dog, _name], QGVAR(dogName_) + hashValue _dog] call CBA_fnc_globalEventJIP, _dog] call CBA_fnc_removeGlobalEventJIP;

            // If no side to be attacked are provided, dog is peaceful
            if (_attackSides isEqualTo []) exitWith {
                // Helper unit needs to be the leader, so do it here if no helper unit present
                [_dog] joinSilent _group;

                // If dog is peaceful, dog can be allowed to have own AI
                if (!_animalBehaviour) then {
                    _dog setVariable ["BIS_fnc_animalBehaviour_disable", true, true];
                };
            };

            // Create helper to which the dog is attached to; This way, orders can be given to the dog via Zeus
            private _helperUnit = _group createUnit ["B_Soldier_F", _pos, [], 0, "CAN_COLLIDE"];

            // Make helper leader, otherwise problems arise
            [_helperUnit, _dog] joinSilent _group;

            _helperUnit call zen_common_fnc_updateEditableObjects;
            [["zen_common_setUnitIdentity", [_helperUnit, _name, "WhiteHead_01", ["NoVoice", "ACE_NoVoice"] select (!isNil "ace_common"), 1, ""]] call CBA_fnc_globalEventJIP, _helperUnit] call CBA_fnc_removeGlobalEventJIP;

            // Make helper unit invincible and invisible
            _helperUnit allowDamage false;
            ["zen_common_hideObjectGlobal", [_helperUnit, true]] call CBA_fnc_serverEvent;

            _dog attachTo [_helperUnit];

            // Remove all items of the helper unit
            removeAllWeapons _helperUnit;
            removeAllAssignedItems _helperUnit;
            removeAllContainers _helperUnit;
            removeHeadgear _helperUnit;
            removeGoggles _helperUnit;

            // Turn off AI in dog
            _dog setVariable ["BIS_fnc_animalBehaviour_disable", true, true];

            // Turn off AI in helper unit, but enable important AI parts
            _helperUnit disableAI "ALL";
            _helperUnit enableAI "ANIM";
            _helperUnit enableAI "MOVE";
            _helperUnit enableAI "PATH";
            _helperUnit enableAI "TEAMSWITCH";
            _helperUnit setBehaviour "CARELESS";
            _helperUnit setUnitPos "UP";
            _helperUnit enableStamina false;

            // Set up time trackers
            _helperUnit setVariable [QGVAR(timeDog), time - 5];
            _helperUnit setVariable [QGVAR(timeBark), time - 5];
            _helperUnit setVariable [QGVAR(currentPosWP), [0, 0, 0]];
            _helperUnit setVariable [QGVAR(isHelperUnit), true, true];

            [{
                params ["_args", "_pfhID"];
                _args params ["_dog", "_helperUnit", "_attackSides", "_radius", "_damage"];

                // If dog has died, stop looking for targets
                if (!alive _dog) exitWith {
                    deleteVehicle _helperUnit;

                    _pfhID call CBA_fnc_removePerFrameHandler;
                };

                private _speed = speed _helperUnit;

                // Set various animations for various speeds
                _dog playMoveNow (switch (true) do {
                    case (_speed > 22): {"Dog_Sprint"};
                    case (_speed > 14): {"Dog_Run"};
                    case (_speed > 0): {"Dog_Walk"};
                    default {"Dog_Stop"};
                });

                private _dogNearestEnemy = _helperUnit getVariable [QGVAR(dogNearestEnemy), objNull];
                private _time = time;
                private _group = group _helperUnit;
                private _currentWaypoint = [_group, currentWaypoint _group];
                private _posWaypoint = waypointPosition _currentWaypoint;

                // Get waypoint as soon as possible, as waypoint sometimes delete themselves very quickly
                if (waypointType _currentWaypoint in ["DESTROY", "SAD"]  && {(_helperUnit getVariable QGVAR(currentPosWP)) isNotEqualTo _posWaypoint}) then {
                    private _dogNearestEnemies = _posWaypoint nearEntities ["CAManBase", 5];

                    _dogNearestEnemy = _dogNearestEnemies param [_dogNearestEnemies findIf {
                        (lifeState _x) in ["HEALTHY", "INJURED"] &&
                        {isNull objectParent _x} &&
                        {(side _x) in _attackSides} &&
                        {_x != _helperUnit} &&
                        {!(_x getVariable [QGVAR(isHelperUnit), false])} &&
                        {getNumber ((configOf _x) >> "isPlayableLogic") == 0}
                    }, objNull];

                    _helperUnit setVariable [QGVAR(dogNearestEnemy), _dogNearestEnemy];
                    _helperUnit setVariable [QGVAR(currentPosWP), _posWaypoint];
                };

                // Prevents unnecessary orders and commands
                if (_time >= (_helperUnit getVariable [QGVAR(timeDog), -1]) + 2.5) then {
                    _helperUnit setVariable [QGVAR(timeDog), _time];

                    // If no valid target, find one
                    if !((lifeState _dogNearestEnemy) in ["HEALTHY", "INJURED"]) then {
                        // Look for the closest enemy: Exclude invalid classes, helper units, dead or unconscious units
                        private _dogNearestEnemies = (getPosATL _helperUnit) nearEntities ["CAManBase", _radius];

                        _dogNearestEnemy = _dogNearestEnemies param [_dogNearestEnemies findIf {
                            (lifeState _x) in ["HEALTHY", "INJURED"] &&
                            {isNull objectParent _x} &&
                            {(side _x) in _attackSides} &&
                            {_x != _helperUnit} &&
                            {!(_x getVariable [QGVAR(isHelperUnit), false])} &&
                            {getNumber ((configOf _x) >> "isPlayableLogic") == 0}
                        }, objNull];

                        _helperUnit setVariable [QGVAR(dogNearestEnemy), _dogNearestEnemy];
                    };

                    if (!isNull _dogNearestEnemy) then {
                        private _distance = _helperUnit distance _dogNearestEnemy;

                        // Only if the AI hasn't been ordered to do something else, move to target
                        if !(waypointType _currentWaypoint in ["MOVE", "SCRIPTED"]) then {
                            private _pos = getPosATL _dogNearestEnemy;

                            _helperUnit lookAt _pos;

                            if (_distance > 3) then {
                                _helperUnit move _pos;
                            };
                        };

                        // Inflict damage if in range
                        if (_distance <= 3) then {
                            ["zen_common_execute", [{
                                params ["_dogNearestEnemy", "_dog", "_damage"];

                                if !(isDamageAllowed _dogNearestEnemy && {_dogNearestEnemy getVariable ["ace_medical_allowDamage", true]}) exitWith {};

                                if (GETMVAR("ace_medical_enabled",zen_common_aceMedical)) then {
                                    [_dogNearestEnemy, _damage, selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "stab", _dog, [], false] call ace_medical_fnc_addDamageToUnit;
                                } else {
                                    private _hitPoint = selectRandom ["HitArms", "HitHands", "HitLegs"];
                                    _dogNearestEnemy setHitPointDamage [_hitPoint, (_dogNearestEnemy getHitPointDamage _hitPoint) + _damage, true, _dog, _dog];
                                };
                            } call FUNC(sanitiseFunction), [_dogNearestEnemy, _dog, _damage]], _dogNearestEnemy] call CBA_fnc_targetEvent;
                        };

                        // Prevents excessive barking
                        if (_time >= ((_helperUnit getVariable [QGVAR(timeBark), -1]) + 5) && {random 1 < 0.4}) then {
                            playSound3D [format ["A3\Sounds_F\ambient\animals\dog%1.wss", floor (random 4) + 1], objNull, round insideBuilding _dog == 1, getPosASL _dog, 5, 0.75, 300];
                            _helperUnit setVariable [QGVAR(timeBark), _time];
                        };
                    };
                };
            }, 0.25, [_dog, _helperUnit, _attackSides, _radius, _damage]] call CBA_fnc_addPerFrameHandler;
        }, [_lightning, _sides select 0, _attackSides, _radius, _damage, _pos, _animalBehaviour, _name]] call CBA_fnc_waitUntilAndExecute;
    }, {}, _pos] call zen_dialog_fnc_create;
}, "\a3\Modules_F_Curator\Data\portraitAnimalsGoats_ca.paa"] call zen_custom_modules_fnc_register;
