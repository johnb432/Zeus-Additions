#include "script_component.hpp"

/*
 * Author: Fred, with modifications made by johnb43
 * Creates a module that spawns a dog.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_dogAttack;
 *
 * Public: No
 */

["Zeus Additions - AI", "Spawn Attack Dog", {
    params ["_pos"];

    ["Spawn Attack Dog", [
        ["SIDES", ["Spawn as", "Only the first selected side will be taken into account."], []],
        ["SIDES", ["Attack", "Allows the dog to attack the given sides. If none are selected, it will attack no one and will be peaceful."], []],
        ["SLIDER", ["Search Radius", "The dogs will search within given radius for targets."], [0, 1000, 100, 0]],
        ["SLIDER", ["Dog Damage", "How much damage the dog deals."], [0, 50, 3, 2]],
        ["TOOLBOX:YESNO", ["Spawn lightning", "Spawns a lightning bolt where the module is placed."], false],
        ["TOOLBOX:YESNO", ["Spawn sound", "Adds the lightning bolt sound. This causes damage though, as it's like the Zeus bolt."], false],
        ["TOOLBOX:YESNO", ["Turn on pathing", "Turns on animal AI behaviour and pathing. Only applies if dog is peaceful."], false],
        ["EDIT", ["Name", "Sets the dog's name. If left blank, a random name will be chosen."], ""]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_sides", "_attackSides", "_radius", "_damage", "_spawnLightning", "_spawnBolt", "_animalBehaviour", "_name"];
        _pos params ["_posX", "_posY"];

        if (_sides isEqualTo []) exitWith {
            ["You must select a side!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _lightning = objNull;

        // Make lightning bolt
        if (_spawnLightning) then {
            _lightning = createVehicle [selectRandom ["Lightning1_F", "Lightning2_F"], [_posX, _posY, 0], [], 0, "CAN_COLLIDE"];

            [{
                deleteVehicle _this;
            }, _lightning, 1] call CBA_fnc_waitAndExecute;
        };

        // Make sound for lightning bolt
        if (_spawnBolt) then {
            (createvehicle ["LightningBolt", [_posX, _posY, 0], [], 0, "CAN_COLLIDE"]) setDamage 1;
        };

        [{
            // Wait until lightning bolt has been deleted
            isNull (_this select 0);
         }, {
            params ["", "_side", "_attackSides", "_radius", "_damage", "_posX", "_posY", "_animalBehaviour", "_name"];

            // Create dog
            private _group = createGroup _side;
            private _dog = _group createUnit ["Fin_random_F", [_posX, _posY, 0.3], [], 0, "CAN_COLLIDE"];
            [_group] joinSilent _dog;

            ["zen_common_addObjects", [[_dog]]] call CBA_fnc_serverEvent;

            _dog setName ([selectRandom ["Fluffy", "Doggo", "Cuddles", "Santa's Little Helper", "Biter", "Foxer", "Boxy", "Death", "SirKillsALot"], _name] select (_name isNotEqualTo ""));

            // If no side to be attacked are provided, dog is peaceful
            if (_attackSides isEqualTo []) exitWith {
                // If dog is peaceful, dog can be allowed to have own AI
                if (!_animalBehaviour) then {
                    _dog setVariable ["BIS_fnc_animalBehaviour_disable", false, true];
                };
            };

            // Turn off AI in dog
            _dog setVariable ["BIS_fnc_animalBehaviour_disable", false, true];

            // Make the dog move to trigger the EH below
            _dog playMoveNow "Dog_Run";

            private _EHid = _dog addEventHandler ["AnimDone", {
                params ["_unit", "_anim"];

                private _nearestEnemy = _unit getVariable [QGVAR(dogNearestEnemy), objNull];

                if (isNull _nearestEnemy) exitWith {};

                // This allows a smooth moving towards the target
                _unit setVectorDir ((getPos _nearestEnemy) vectorDiff (getPos _unit));

                private _distance = _unit distance _nearestEnemy;

                if (_distance > 10) exitWith {
                    _unit playMoveNow "Dog_Sprint";
                };

                _unit playMoveNow (["Dog_Walk", "Dog_Run"] select (_distance > 5));
            }];

            [{
                params ["_args", "_handleID"];
                _args params ["_dog", "_attackSides", "_radius", "_damage", "_EHid"];

                // If dog died, stop looking for targets
                if (!alive _dog) exitWith {
                    _dog removeEventHandler ["AnimDone", _EHid];
                    _handleID call CBA_fnc_removePerFrameHandler;
                };

                // Look for the closest enemy: Exclude invalid classes
                private _dogNearestEnemy = (((getPos _dog) nearEntities ["CAManBase", _radius]) select {!(side _x in [sideLogic, sideAmbientLife, sideEmpty]) && {side _x in _attackSides}}) select 0;
                _dog setVariable [QGVAR(dogNearestEnemy), _dogNearestEnemy];

                if (!isNull _dogNearestEnemy && {(_dog distance _dogNearestEnemy) < 5}) then {
                    // Prevents the dog from barking too much
                    if (random 1 < 0.4) then {
                        playSound3D ["A3\Sounds_F\ambient\animals\dog3.wss", _dog, false, getPosASL _dog, 5, 0.75, 100];
                    };

                    ["zen_common_execute", [ace_medical_fnc_addDamageToUnit, [_dogNearestEnemy, _damage, selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "stab"]], _dogNearestEnemy] call CBA_fnc_targetEvent;
                };
            }, 2.5, [_dog, _attackSides, _radius, _damage, _EHid]] call CBA_fnc_addPerFrameHandler;
        }, [_lightning, (_sides select 0), _attackSides, _radius, _damage, _posX, _posY, _animalBehaviour, _name]] call CBA_fnc_waitUntilAndExecute;
    },
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}, ICON_DOG] call zen_custom_modules_fnc_register;
