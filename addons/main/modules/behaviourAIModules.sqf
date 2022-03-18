/*
 * Author: johnb43
 * Creates modules that can change dismount, turn out and mine detecting behaviour on AI.
 */

["Zeus Additions - AI", "Change AI Crew Behaviour", {
    params ["", "_object"];

    _object = vehicle _object;

    if !(alive _object && {(fullCrew [_object, "driver", true]) isNotEqualTo []}) exitWith {
        ["Select an undestroyed vehicle!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Change AI Crew Behaviour", [
        ["TOOLBOX:ENABLED", ["Passenger dismount in combat", "Allow passengers to dismount while in combat."], canUnloadInCombat _object],
        ["TOOLBOX:ENABLED", ["Crew dismount in combat", "Allow crews to dismount while in combat."], false],
        ["TOOLBOX:ENABLED", ["Crew stay in immobile vehicles", "Allow crews to stay in immobile vehicles. THIS DOES NOT WORK IF ACE VEHICLE DAMAGE IS LOADED."], isAllowedCrewInImmobile _object],
        ["TOOLBOX:YESNO", ["Allow AI to Turn Out", "Makes the AI able to turn out or not."], true]
    ],
    {
        params ["_results", "_object"];
        _results params ["_dismountPassengers", "_dismountCrew", "_stayCrew", "_allowTurnOut"];

        // Execute where vehicle is local
        ["zen_common_execute", [{
            params ["_object", "_dismountPassengers", "_dismountCrew", "_stayCrew"];

            _object setUnloadInCombat [_dismountPassengers, _dismountCrew];
            _object allowCrewInImmobile _stayCrew;
        }, [_object, _dismountPassengers, _dismountCrew, _stayCrew]], _object] call CBA_fnc_targetEvent;

        private _behaviour = ["COMBAT", "SAFE"] select _stayCrew;

        _stayCrew = !_stayCrew;

        // ACE forces AI crew to dismount if critical hit; can't be fixed until ACE adds something
        {
            // Execute where AI is local
            ["zen_common_execute", [{
                params ["_unit", "_stayCrew", "_allowTurnOut", "_behaviour"];

                _unit enableAIFeature ["AUTOCOMBAT", _stayCrew || _allowTurnOut];
                _unit enableAIFeature ["FSM", _stayCrew];
                _unit setBehaviour _behaviour;
                _unit setCombatBehaviour _behaviour;
            }, [_x, _stayCrew, _allowTurnOut, _behaviour]], _x] call CBA_fnc_targetEvent;
        } forEach ((crew _object) select {alive _x && {!isPlayer _x}});

        ["Changed crew behaviour on vehicle"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
