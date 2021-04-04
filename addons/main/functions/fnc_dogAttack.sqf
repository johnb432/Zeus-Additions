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

if (!hasInterface) exitWith {};

["Zeus Additions - AI", "Spawn Attack Dog", {
    params ["_pos"];

    ["Side Selector", [
        ["SIDES", ["Spawn as", "Only the first selected side will be taken into account."], [east]],
        ["SIDES", ["Attack", "Allows the dog to attack the given sides."], [west]],
        ["SLIDER", ["Search Radius", "The dogs will search within given radius for targets."], [0, 1000, 100, 0]],
        ["SLIDER", ["Dog Damage", "How much damage the dog deals."], [0, 20, 3, 2]],
        ["CHECKBOX", ["Spawn lightning", "Spawns a lightning bolt where the module is placed."], false],
        ["CHECKBOX", ["Spawn sound", "Adds the lightning bolt sound. This causes damage though, as it's like the Zeus bolt."], false]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_sides", "_attackSides", "_radius", "_damage", "_spawnLightning", "_spawnBolt"];
        _pos params ["_posX", "_posY"];

        if (_sides isEqualTo []) exitWith {
            ["You must select a side!"] call zen_common_fnc_showMessage;
        };

        private _lightning = objNull;

        if (_spawnLightning) then {
            _lightning = createVehicle [selectRandom ["Lightning1_F", "Lightning2_F"], [_posX, _posY, 0], [], 0, "CAN_COLLIDE"];

            [{
                deleteVehicle _this;
            }, _lightning, 1] call CBA_fnc_waitAndExecute;
        };

        if (_spawnBolt) then {
            (createvehicle ["LightningBolt", [_posX, _posY, 0], [], 0, "CAN_COLLIDE"]) setDamage 1;
        };

        [{
            isNull (_this select 0)
         }, {
            params ["_lightning", "_side", "_attackSides", "_radius", "_damage", "_posX", "_posY"];

            private _grp = createGroup _side;
            private _dog = _grp createUnit ["Fin_random_F", [_posX, _posY, 0.3], [], 0, "CAN_COLLIDE"];
            [_grp] joinSilent _dog;
            _dog setVariable ["BIS_fnc_animalBehaviour_disable", false];

            ["zen_common_addObjects", [[_dog]]] call CBA_fnc_serverEvent;

            _dog playMoveNow "Dog_Run";
            _dog setName selectRandom ["Fluffy","Susian","Cuddles","Santa's Little Helper","Biter","Foxer","Boxy","Death","TopKek","Rabit","SirKillsALot","Dogga"];

            private _EHid = _dog addEventHandler ["AnimDone", {
            	   params ["_unit", "_anim"];

                private _nearestEnemy = _unit getVariable [QGVAR(dogNearestEnemy), _dogNearestEnemy];

                if (isNil "_nearestEnemy") exitWith {};

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

                if (!alive _dog) exitWith {
                    _dog removeEventHandler ["AnimDone", _EHid];
                    [_handleID] call CBA_fnc_removePerFrameHandler;
                };

                // Look for the closest enemy: Exclude invalid classes
                private _dogNearestEnemy = (((getPos _dog) nearEntities ["Man", _radius]) select {!(side _x in [sideLogic, sideAmbientLife, sideEmpty]) && {side _x in _attackSides}}) select 0;
                _dog setVariable [QGVAR(dogNearestEnemy), _dogNearestEnemy];

                if (!isNull _dogNearestEnemy && {(_dog distance _dogNearestEnemy) < 5}) then {
                    playSound3D ["A3\Sounds_F\ambient\animals\dog3.wss", _dog, false, getPosASL _dog, 5, 0.75, 100];

                    ["zen_common_execute", [ace_medical_fnc_addDamageToUnit, [_dogNearestEnemy, _damage, selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "stab"]], _dogNearestEnemy] call CBA_fnc_targetEvent;
                };
            }, 2.5, [_dog, _attackSides, _radius, _damage, _EHid]] call CBA_fnc_addPerFrameHandler;
        }, [_lightning, (_sides select 0), _attackSides, _radius, _damage, _posX, _posY]] call CBA_fnc_waitUntilAndExecute;
    },
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
