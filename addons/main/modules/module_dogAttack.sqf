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
        [["SLIDER:PERCENT", ["str_a3_normaldamage1", LSTRING(dogAttackDamageDesc)], [0, 1, 0.1]], ["SLIDER", ["str_a3_normaldamage1", LSTRING(dogAttackDamageDesc)], [0, 50, 3, 2]]] select zen_common_aceMedical,
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
            _lightning = createVehicle [format ["Lightning%1_F", floor (random 2) + 1], _pos, [], 0, "CAN_COLLIDE"];

            [{
                deleteVehicle _this;
            }, _lightning, 1] call CBA_fnc_waitAndExecute;
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

            [["zen_common_setName", [_dog, _name]] call CBA_fnc_globalEventJIP, _dog] call CBA_fnc_removeGlobalEventJIP;

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

            // Make helper invisible and invincible
            [_helperUnit, true] remoteExecCall ["hideObjectGlobal", 2];
            _helperUnit allowDamage false;

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
                    default {"Dog_Sit"};
                });

                private _dogNearestEnemy = _helperUnit getVariable [QGVAR(dogNearestEnemy), objNull];
                private _time = time;
                private _group = group _helperUnit;
                private _currentWaypoint = [_group, currentWaypoint _group];
                private _posWaypoint = waypointPosition _currentWaypoint;

                // Get waypoint as soon as possible, as waypoint sometimes delete themselves very quickly
                if (waypointType _currentWaypoint in ["DESTROY", "SAD"]  && {(_helperUnit getVariable QGVAR(currentPosWP)) isNotEqualTo _posWaypoint}) then {
                    _dogNearestEnemy = ((_posWaypoint nearEntities ["CAManBase", 5]) select {
                        alive _x &&
                        {(side _x) in _attackSides} &&
                        {_x != _helperUnit} &&
                        {(lifeState _x) != "INCAPACITATED"} &&
                        {!(_x getVariable [QGVAR(isHelperUnit), false])} &&
                        {!(_x isKindOf "VirtualCurator_F")}
                    }) param [0, objNull];

                    _helperUnit setVariable [QGVAR(dogNearestEnemy), _dogNearestEnemy];
                    _helperUnit setVariable [QGVAR(currentPosWP), _posWaypoint];
                };

                // Prevents unnecessary orders and commands
                if (_time >= (_helperUnit getVariable [QGVAR(timeDog), -1]) + 2.5) then {
                    _helperUnit setVariable [QGVAR(timeDog), _time];

                    // If no valid target, find one
                    if (!alive _dogNearestEnemy || {(lifeState _dogNearestEnemy) == "INCAPACITATED"}) then {
                        // Look for the closest enemy: Exclude invalid classes, helper units, dead or unconscious units
                        _dogNearestEnemy = (((getPosATL _helperUnit) nearEntities ["CAManBase", _radius]) select {
                            alive _x &&
                            {(side _x) in _attackSides} &&
                            {_x != _helperUnit} &&
                            {(lifeState _x) != "INCAPACITATED"} &&
                            {!(_x getVariable [QGVAR(isHelperUnit), false])} &&
                            {!(_x isKindOf "VirtualCurator_F")}
                        }) param [0, objNull];

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
                            if (zen_common_aceMedical) then {
                                [_dogNearestEnemy, _damage, selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "stab", _dog, [], false] remoteExecCall ["ace_medical_fnc_addDamageToUnit", _dogNearestEnemy];
                            } else {
                                private _hitPoint = selectRandom ["HitArms", "HitHands", "HitLegs"];
                                [_dogNearestEnemy, [_hitPoint, (_dogNearestEnemy getHitPointDamage _hitPoint) + _damage, true, _dog, _dog]] remoteExecCall ["setHitPointDamage", _dogNearestEnemy];
                            };
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
