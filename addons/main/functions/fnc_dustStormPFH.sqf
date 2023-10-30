#include "..\script_component.hpp"
/*
 * Author: JW, AZCoder, johnb43
 * Makes dust clouds. Particle effects from here (tweaked by johnb43):
 * https://forums.bohemia.net/forums/topic/215391-light-snowfall-script/?do=findComment&comment=3276526
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_dustStormPFH;
 *
 * Public: No
 */

[{
    // Wait until the player is fully loaded
    !isNull (findDisplay IDD_MISSION)
}, {
    [{
        private _player = player;

        // If game is not in focus or if player is dead, don't spawn in particles until game is focussed and player is alive again
        if (isGamePaused || {!isGameFocused} || {!alive _player}) exitWith {};

        private _stormIntensity = _player getVariable [QGVAR(stormIntensity), 0];

        // Stop PFH if intensity is set to nil
        if (_stormIntensity == 0) exitWith {
            (_this select 1) call CBA_fnc_removePerFrameHandler;
        };

        // If inside, don't do script
        if (round insideBuilding _player == 1) exitWith {};

        private _vehicle = vehicle _player;
        private _pos = getPosATL _vehicle;
        private _inc = 0;
        (velocity _vehicle) params ["_xVel", "_yVel"];

        while {_inc < _stormIntensity} do {
            drop [
                ["\A3\data_f\cl_basic", 1, 0, 1], // shapeName
                "", // animationName
                "Billboard", // type
                1, // timerPeriod
                3, // lifeTime
                _pos vectorAdd [50 - (random 100) + _xVel, 50 - (random 100) + _yVel, 0], // position
                [0, 0, 0], // moveVelocity
                3, // rotationVelocity
                10, // weight
                8, // volume
                1, // rubbing
                [10, 10, 20], // size
                [[0.65, 0.5, 0.5, 0], [0.65, 0.6, 0.5, 0.3], [1, 0.95, 0.8, 0]], // color
                [0.08], // animationPhase
                0, // randomDirectionPeriod
                0, // randomDirectionIntensity
                "", // onTimer
                "", // beforeDestroy
                "" // object
                // [angle, onSurface, bounceOnSurface, emissiveColor, vectorDir]
            ];

            _inc = _inc + 50;
        };
    }, 0.1] call CBA_fnc_addPerFrameHandler;
}, []] call CBA_fnc_waitUntilAndExecute;
