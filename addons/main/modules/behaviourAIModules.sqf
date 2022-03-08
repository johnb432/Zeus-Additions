/*
 * Author: johnb43
 * Creates modules that can change dismount, turn out and mine detecting behaviour on AI.
 */

["Zeus Additions - AI", "Change AI Dismount Behaviour", {
    params ["", "_object"];

    _object = vehicle _object;

    if !(alive _object && {(fullCrew [_object, "driver", true]) isNotEqualTo []}) exitWith {
        ["Select an undestroyed vehicle!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Change AI dismounting behaviour", [
        ["TOOLBOX:ENABLED", ["Passenger dismount in combat", "Allow passengers to dismount while in combat."], false],
        ["TOOLBOX:ENABLED", ["Crew dismount in combat", "Allow crews to dismount while in combat."], false],
        ["TOOLBOX:ENABLED", ["Crew stay in immobile vehicles", "Allow crews to stay in immobile vehicles. THIS DOES NOT WORK IF ACE VEHICLE DAMAGE IS LOADED."], false]
    ],
    {
        params ["_results", "_object"];
        _results params ["_dismountPassengers", "_dismountCrew", "_stayCrew"];

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
                params ["_unit", "_stayCrew", "_behaviour"];

                _unit enableAIFeature ["AUTOCOMBAT", _stayCrew];
                _unit enableAIFeature ["FSM", _stayCrew];
                _unit setBehaviour _behaviour;
                _unit setCombatBehaviour _behaviour;
            }, [_x, _stayCrew, _behaviour]], _x] call CBA_fnc_targetEvent;
        } forEach ((crew _object) select {alive _x && {!isPlayer _x}});

        ["Changed dismount behaviour on vehicle"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;

["Zeus Additions - AI", "[WIP] Change AI Mine Detecting Behaviour", {
    params ["", "_unit"];

    ["[WIP] Change AI Mine Detecting Behaviour (broken?)", [
        ["SIDES", ["AI selected", "Select AI from the list to change mine detection capabilities."], []],
        ["TOOLBOX:YESNO", ["Include Group", "Includes the entire group of the AI on which the module was placed."], false],
        ["TOOLBOX:YESNO", ["Allow AI to detect mines", "You can either disable or reenable mine detection."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_sides", "_doGroup", "_allowMinedetection"];

        if (_sides isEqualTo [] && {isNull _unit}) exitWith {
            ["Select a side!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _units = [];

        private _string = if (isNull _unit) then {
            {
                _units append units _x;
            } forEach _sides;

            "Changed mine detecting behaviour on units";
        } else {
            if (_doGroup) exitWith {
                _units = units _unit;

                "Changed mine detecting behaviour on group";
            };

            _units pushBack _unit;

            "Changed mine detecting behaviour on unit";
        };

        _units = _units select {alive _x && {!isPlayer _x}};

        if (_units isEqualTo []) exitWith {
            ["No AI units were found!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _function = ["disableAI", "enableAI"] select _allowMinedetection;

        {
            [_x, "MINEDETECTION"] remoteExecCall [_function, _x];
        } forEach _units;

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_EXPLOSION] call zen_custom_modules_fnc_register;

["Zeus Additions - AI", "[WIP] Allow AI to Turn Out", {
    params ["", "_object"];

    _object = vehicle _object;

    if !(alive _object && {(fullCrew [_object, "driver", true]) isNotEqualTo []}) exitWith {
        ["Select an undestroyed vehicle!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    if (((crew _object) select {alive _x && {!isPlayer _x}}) isEqualTo []) exitWith {
        ["Select a vehicle with AI crew!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Allow AI to Turn Out", [
        ["TOOLBOX:YESNO", ["Allow AI to Turn Out", "Makes the AI able to turn out or not."], true]
    ],
    {
        params ["_results", "_object"];
        _results params ["_allowTurnOut"];

        private _behaviour = ["COMBAT", "SAFE"] select _allowTurnOut;

        {
            // Execute where AI is local
            ["zen_common_execute", [{
                params ["_unit", "_allowTurnOut", "_behaviour"];

                _unit enableAIFeature ["AUTOCOMBAT", _allowTurnOut];
                _unit setBehaviour _behaviour;
                _unit setCombatBehaviour _behaviour;
            }, [_x, _allowTurnOut, _behaviour]], _x] call CBA_fnc_targetEvent;
        } forEach ((crew _object) select {alive _x && {!isPlayer _x}});

        ["Changed turning out ability on AI crew members"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
