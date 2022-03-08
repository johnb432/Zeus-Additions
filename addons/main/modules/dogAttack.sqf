/*
 * Author: Fred, with modifications made by johnb43
 * Creates a module that spawns a dog.
 */

["Zeus Additions - AI", "Spawn Attack Dog", {
    params ["_pos"];

    // Position has to be AGL/ATL, ZEN gives ASL
    _pos set [2, 0];

    ["Spawn Attack Dog", [
        ["SIDES", ["Spawn as", "Only the first selected side will be taken into account."], []],
        ["SIDES", ["Attack", "Allows the dog to attack the given sides. If none are selected, it will attack no one and will be peaceful."], []],
        ["SLIDER", ["Search Radius", "The dogs will search within given radius for targets."], [0, 1000, 100, 0]],
        [["SLIDER:PERCENT", ["Dog Damage", "How much damage the dog deals."], [0, 1, 0.1]], ["SLIDER", ["Dog Damage", "How much damage the dog deals."], [0, 50, 3, 2]]] select zen_common_aceMedical,
        ["TOOLBOX:YESNO", ["Spawn lightning", "Spawns a lightning bolt where the module is placed."], false],
        ["TOOLBOX:YESNO", ["Spawn sound", "Adds the lightning bolt sound. This causes damage though, as it's like the Zeus bolt."], false],
        ["TOOLBOX:YESNO", ["Turn off pathing", "Turns off animal AI behaviour and pathing. Only applies if dog is peaceful."], false],
        ["EDIT", ["Name", "Sets the dog's name. If left blank, a random name will be chosen."], ""]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_sides", "_attackSides", "_radius", "_damage", "_spawnLightning", "_spawnBolt", "_animalBehaviour", "_name"];

        if (_sides isEqualTo []) exitWith {
            ["You must select a side!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _lightning = objNull;

        // Make lightning bolt
        if (_spawnLightning) then {
            _lightning = createVehicle [selectRandom ["Lightning1_F", "Lightning2_F"], _pos, [], 0, "CAN_COLLIDE"];

            [{
                deleteVehicle _this;
            }, _lightning, 1] call CBA_fnc_waitAndExecute;
        };

        // Make sound for lightning bolt
        if (_spawnBolt) then {
            (createvehicle ["LightningBolt", _pos, [], 0, "CAN_COLLIDE"]) setDamage 1;
        };

        [{
            // Wait until lightning bolt has been deleted
            isNull (_this select 0);
         }, {
            params ["", "_side", "_attackSides", "_radius", "_damage", "_pos", "_animalBehaviour", "_name"];

            // Create dog
            private _group = createGroup _side;
            private _dog = _group createUnit ["Fin_random_F", _pos, [], 0, "CAN_COLLIDE"];

            ["zen_common_addObjects", [[_dog]]] call CBA_fnc_serverEvent;

            _dog setName ([selectRandom ["Fluffy", "Doggo", "Cuddles", "Santa's Little Helper", "Biter", "Foxer", "Boxy", "Death", "SirKillsALot"], _name] select (_name isNotEqualTo ""));

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

            ["zen_common_addObjects", [[_helperUnit]]] call CBA_fnc_serverEvent;

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

            // Set up time trackers
            _helperUnit setVariable [QGVAR(timeDog), time - 2.5];
            _helperUnit setVariable [QGVAR(timeBark), time - 2.5];
            _helperUnit setVariable [QGVAR(currentPosWP), [0, 0, 0]];

            [{
                params ["_args", "_pfhID"];
                _args params ["_dog", "_helperUnit", "_attackSides", "_radius", "_damage"];

                // If dog has died, stop looking for targets
                if (!alive _dog) exitWith {
                    deleteVehicle _helperUnit;

                    _pfhID call CBA_fnc_removePerFrameHandler;
                };

                // Set various animations for various speeds
                if (speed _helperUnit isEqualTo 0) then {
                    _dog playMoveNow "Dog_Sit";
                } else {
                    if (speed _helperUnit > 14) exitWith {
                        if (speed _helperUnit > 22) exitWith {
                            _dog playMoveNow "Dog_Sprint";
                        };

                        _dog playMoveNow "Dog_Run";
                    };

                    _dog playMoveNow "Dog_Walk";
                };

                private _dogNearestEnemy = _helperUnit getVariable QGVAR(dogNearestEnemy);
                private _time = time;
                private _group = group _helperUnit;
                private _currentWaypoint = [_group, currentWaypoint _group];
                private _posWaypoint = waypointPosition _currentWaypoint;

                // Get waypoint as soon as possible, as waypoint sometimes delete themselves very quickly
                if (waypointType _currentWaypoint in ["DESTROY", "SAD"]  && {(_helperUnit getVariable QGVAR(currentPosWP)) isNotEqualTo _posWaypoint}) then {
                    _dogNearestEnemy = ((_posWaypoint nearEntities ["CAManBase", 5]) select {(side _x in _attackSides) && {_x isNotEqualTo _helperUnit} && {alive _x} && {!(_x getVariable ["ACE_isUnconscious", false])} && {(lifeState _x) isNotEqualTo "INCAPACITATED"} && {isNil {_x getVariable QGVAR(dogNearestEnemy)}}}) select 0;
                    _helperUnit setVariable [QGVAR(dogNearestEnemy), _dogNearestEnemy];
                    _helperUnit setVariable [QGVAR(currentPosWP), _posWaypoint];
                };

                // Prevents unnecessary orders and commands
                if (_time >= (_helperUnit getVariable [QGVAR(timeDog), -1]) + 2.5) then {
                    _helperUnit setVariable [QGVAR(timeDog), _time];

                    // If no valid target, find one
                    if (isNil "_dogNearestEnemy" || {!alive _dogNearestEnemy} || {_dogNearestEnemy getVariable ["ACE_isUnconscious", false]} || {(lifeState _dogNearestEnemy) isEqualTo "INCAPACITATED"}) then {
                        // Look for the closest enemy: Exclude invalid classes, helper units (both "internal" and "external"), dead or unconscious units
                        _dogNearestEnemy = (((getPosATL _helperUnit) nearEntities ["CAManBase", _radius]) select {(side _x in _attackSides) && {_x isNotEqualTo _helperUnit} && {alive _x} && {!(_x getVariable ["ACE_isUnconscious", false])} && {(lifeState _x) isNotEqualTo "INCAPACITATED"} && {isNil {_x getVariable QGVAR(dogNearestEnemy)}}}) select 0;
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
                                private _hitPoint = selectRandom ["hitarms", "hithands", "hitlegs"];
                                [_dogNearestEnemy, [_hitPoint, _damage + (_dogNearestEnemy getHitPointDamage _hitPoint), true, _dog]] remoteExecCall ["setHitPointDamage", _dogNearestEnemy];
                            };
                        };

                        // Prevents excessive barking
                        if (_time >= ((_helperUnit getVariable [QGVAR(timeBark), -1]) + 3) && {random 1 < 0.4}) then {
                            playSound3D ["A3\Sounds_F\ambient\animals\dog3.wss", _dog, false, getPosASL _dog, 5, 0.75, 100];
                            _helperUnit setVariable [QGVAR(timeBark), _time];
                        };
                    };
                };
            }, 0.25, [_dog, _helperUnit, _attackSides, _radius, _damage]] call CBA_fnc_addPerFrameHandler;
        }, [_lightning, _sides select 0, _attackSides, _radius, _damage, _pos, _animalBehaviour, _name]] call CBA_fnc_waitUntilAndExecute;
    },
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}, ICON_DOG] call zen_custom_modules_fnc_register;
