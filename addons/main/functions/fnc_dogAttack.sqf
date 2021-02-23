#include "script_component.hpp"

/*
 * Author: Fred, with modifications made by johnb43
 * Creates a modules that spawns a dog.
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

["Zeus Additions", "[WIP] Spawn Attack Dog", {
    params ["_pos"];

    ["Side Selector", [
        ["SIDES", ["Spawn as", "Only the first selected side will be taken into account."], [east]],
        ["SIDES", ["Attack", "Allows the dog to attack the given sides."], [west]],
        ["SLIDER", ["Search Radius", "The dogs will search within given radius for targets."], [0, 1000, 100, 0]],
        ["SLIDER", ["Dog Damage", "How much damage the dog deals."], [0, 5, 1, 2]],
        ["SLIDER", ["Update Interval", "Determines how quickly the script runs."], [0.1, 10, 3, 1]],
        ["CHECKBOX", ["Spawn lightning", "Spawns a lightning bolt where the module is placed."], true]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_sides", "_attackSides", "_radius", "_damage", "_interval", "_spawnLightning"];

        if (_sides isEqualTo []) exitWith {
            ["You must select a side!"] call zen_common_fnc_showMessage;
        };

        private _grp = createGroup (_sides select 0);
        private _dog = _grp createUnit ["Fin_random_F", [_pos select 0, _pos select 1, 0.3], [], 0, "CAN_COLLIDE"];

        [_grp] joinSilent _dog;


        if (_spawnLightning) then {
            private _lightning = createVehicle ["Lightning1_F", [_pos select 0, _pos select 1, 0], [], 0, "CAN_COLLIDE"];
            //[_dog, ["dog_spawn_in", 50]] remoteExec ["say3D", -2, true]; //Find Zeus lightning bolt sounds
            [{deleteVehicle _this}, _lightning, 1] call CBA_fnc_waitAndExecute;
        };

        _dog setVariable ["BIS_fnc_animalBehaviour_disable", false];

        {
            [_x, [[_dog], true]] remoteExec ["addCuratorEditableObjects", _x, true];
        } forEach allCurators;

        _dog playMoveNow "Dog_Run";
        _dog setName selectRandom ["Fluffy","Susian","Cuddles","Santa's Little Helper","Biter","Foxer","Boxy","Death","TopKek","Rabit","Cuddles","SirKillsALot","Dogga","Digga"];

        GVAR(animFinished) = true;

        private _EHid = _dog addEventHandler ["AnimDone", {
        	   params ["_unit", "_anim"];

            if (GVAR(distanceEnemy) > 10) then {
                _unit playMoveNow "Dog_Sprint";
            };

            if (GVAR(distanceEnemy) > 6 && {GVAR(distanceEnemy) < 10}) then {
                _unit playMoveNow "Dog_Run";
            };

            if (GVAR(distanceEnemy) > 3 && {GVAR(distanceEnemy) < 6}) then {
                _unit playMoveNow "Dog_Walk";
            };

            _unit setDir (_unit getDir GVAR(dogNearestEnemy));
            _unit move (getPos GVAR(dogNearestEnemy));

            GVAR(animFinished) = true;
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
            GVAR(dogNearestEnemy) = _dogNearestEnemy;

            if (!isNull _dogNearestEnemy) then {
                //_dog setDir (_dog getDir _dogNearestEnemy);

                GVAR(distanceEnemy) = _dog distance _dogNearestEnemy;

                if (GVAR(distanceEnemy) < 3) then {
                    _dog setPos ((getPos _dogNearestEnemy) set [1, ((_enemyPos select 1) + 1)]);
                    _dog playMove "Dog_Sit";

                    playSound3D ["A3\Sounds_F\ambient\animals\dog3.wss", _dog, false, getPosASL _dog, 15, 0.5, 100];

                    [_dogNearestEnemy, _damage, selectRandom ["LeftArm", "RightArm", "LeftLeg", "RightLeg"], "stab"] remoteExec ["ace_medical_fnc_addDamageToUnit", _dogNearestEnemy, true];
                };

                /*
                if (_distance > 20) then {
                    _dog playMove "Dog_Sprint";
                };

                if (_distance > 10 && {_distance < 20}) then {
                    _dog playMove "Dog_Run";
                };

                if (_distance > 3 && {_distance < 10}) then {
                    _dog playMove "Dog_Walk";
                };
                */
                /*
                if (GVAR(animFinished)) then {
                    _dog move (getPos _dogNearestEnemy);
                    GVAR(animFinished) = false;
                };*/
            };
        }, _interval, [_dog, _attackSides, _radius, _damage, _EHid]] call CBA_fnc_addPerFrameHandler;
    },
    {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
