#include "script_component.hpp"

/*
 * Author: JW, AZCoder, modified by johnb43
 * PFH for snow script
 * https://forums.bohemia.net/forums/topic/215391-light-snowfall-script/?tab=comments#comment-3276526
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * allPlayers call zeus_additions_main_fnc_snowScriptEvent;
 *
 * Public: No
 */

params ["_targets"];

//systemChat format ["%1", _targets];

["zen_common_execute", [CBA_fnc_addPerFrameHandler,
    [{
        params ["_args", "_handleid"];
        _args params ["_playerPos", "_line", "_pos", "_d", "_a"];

        private _intensity = player getVariable [QGVAR(intensitySnow), nil];

        if (!(player getVariable [QGVAR(enableSnowScript), false]) || isNil "_intensity") exitWith {
            [_handleid] call CBA_fnc_removePerFrameHandler;
        };

        while {_a < _intensity} do {
            // See if there is a roof over the player's head
            _playerPos = getPosWorld player;
            _line = lineIntersectsSurfaces [_playerPos, _playerPos vectorAdd [0, 0, 50], player, objNull, true, 1, "GEOM", "NONE"];

            // If not inside
            if !(count _line > 0 && {(_line select 0 select 3) isKindOf "House"}) then {
                _pos = getPosATL (objectParent player);

                /*
                if (isNil "_fog") then {
                    if (_intensity > 4000) then {
                        _fog = "#particlesource" createVehicleLocal _pos;
                        _fog setParticleParams [
                            ["\Ca\Data\ParticleEffects\Universal\universal.p3d" , 16, 12, 13, 0], "", "Billboard", 1, 10,
                            [0, 0, -6], [0, 0, 0], 1, 1.275, 1, 0,
                            [7,6], [[1, 1, 1, 0], [1, 1, 1, 0.04], [1, 1, 1, 0]], [1000], 1, 0, "", "", player
                        ];
                        _fog setParticleRandom [3, [55, 55, 0.2], [0, 0, -0.1], 2, 0.45, [0, 0, 0, 0.1], 0, 0];
                        _fog setParticleCircle [0.001, [0, 0, -0.12]];
                        _fog setDropInterval 0.001;
                    };
                } else {
                    _fog setPos _pos;
                };
                */

                for "_i" from 2 to 12 step 2 do {
                    _dpos = [((_pos select 0) + (_d - (random (2*_d))) + ((velocity objectParent player select 0)*1)),((_pos select 1) + (_d - (random (2*_d))) + ((velocity objectParent player select 0)*1)),((_pos select 2) + _i)];
                    drop ["\ca\data\cl_water", "", "Billboard", 1, 7, _dpos, [0,0,-1], 1, 0.0000001, 0.000, 0.7, [0.07], [[1,1,1,0], [1,1,1,1], [1,1,1,1], [1,1,1,1]], [0,0], 0.2, 1.2, "", "", ""];
                    _a = _a + 1;
                };
            };
        };
    }, 0.1, [nil, nil, position (objectParent player), 15, 0]]
], _targets] call CBA_fnc_targetEvent;
