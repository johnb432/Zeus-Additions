/*
 * Author: johnb43
 * Creates modules that can change dismount and turn out behaviour on AI.
 */

[LSTRING(moduleCategoryAI), LSTRING(aiBehaviourModuleName), {
    params ["", "_object"];

    if (isNull _object) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    if (!alive _object) exitWith {
        [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
    };

    if ((fullCrew [_object, "driver", true]) isEqualTo []) exitWith {
        [LSTRING_ZEN(modules,onlyVehicles)] call zen_common_fnc_showMessage;
    };

    private _getUnloadInCombat = getUnloadInCombat _object;

    [LSTRING(aiBehaviourModuleName), [
        ["TOOLBOX:ENABLED", [LSTRING(enablePassengerDismount), LSTRING(enablePassengerDismountDesc)], _getUnloadInCombat select 0, true],
        ["TOOLBOX:ENABLED", [LSTRING(enableCrewDismount), LSTRING(enableCrewDismountDesc)], _getUnloadInCombat select 1, true],
        ["TOOLBOX:ENABLED", [LSTRING(enableCrewStayImmobile), LSTRING(enableCrewStayImmobileDesc)], isAllowedCrewInImmobile _object, true],
        ["TOOLBOX:YESNO", [LSTRING(enableAiTurnOut), LSTRING(enableAiTurnOutDesc)], _object isNil QGVAR(turnOutJIP), true]
    ], {
        params ["_results", "_object"];
        _results params ["_dismountPassengers", "_dismountCrew", "_stayCrew", "_allowTurnOut"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

        if (isNil QFUNC(addBehaviourEh)) then {
            #include "module_behaviourCrew_init.inc.sqf"
        };

        // Prevent/allow crew from dismounting when ACE vehicle damage is enabled
        _object setVariable ["ace_vehicle_damage_allowCrewInImmobile", _stayCrew, true];

        ["zen_common_execute", [{
            (_this select 0) allowCrewInImmobile (_this select 1);
        }, [_object, _stayCrew]], _object] call CBA_fnc_targetEvent;

        [[QGVAR(setUnloadInCombat), [_object, _dismountPassengers, _dismountCrew], QGVAR(setUnload_) + hashValue _object] call FUNC(globalEventJIP), _object] call FUNC(removeGlobalEventJIP);

        if (!_allowTurnOut) then {
            if !(_object isNil QGVAR(turnOutJIP)) exitWith {};

            private _jipID = [QGVAR(executeFunction), [QFUNC(addBehaviourEh), _object]] call FUNC(globalEventJIP);
            [_jipID, _object] call FUNC(removeGlobalEventJIP);

            _object setVariable [QGVAR(turnOutJIP), _jipID, true];

            // Whenever a crew member mounts/dismounts, make them stay turned in
            [QGVAR(executeFunction), [QFUNC(addGetInOutEh), _object]] call CBA_fnc_serverEvent;
        } else {
            _object call FUNC(removeAiCrewBehaviour);
        };

        private _behaviour = ["COMBAT", "AWARE"] select _allowTurnOut;
        _stayCrew = !_stayCrew;

        // ACE Vehicle Damage forces AI crew to dismount if critical hit; Can't be fixed until ACE adds something
        {
            [QGVAR(executeFunction), [QFUNC(setBehaviourVehicleCrew), [_object, _x, _stayCrew, _allowTurnOut, _behaviour]], _x] call CBA_fnc_targetEvent;
        } forEach ((crew _object) select {alive _x && {!isPlayer _x}});

        _object setVariable [QGVAR(turnOutBehaviour), [_stayCrew, _allowTurnOut, _behaviour], true];

        [LSTRING(changedAiBehaviourMessage)] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;

[LSTRING(moduleCategoryAI), LSTRING(aiDriverModuleName), {
    params ["", "_object"];

    if (isNull _object) exitWith {
        [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
    };

    if (!alive _object) exitWith {
        [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
    };

    if (fullCrew [_object, "driver", true] isEqualTo []) exitWith {
        [LSTRING_ZEN(modules,onlyVehicles)] call zen_common_fnc_showMessage;
    };

    private _driver = driver _object;

    if (!isNull _driver && {!(_driver getVariable [QGVAR(aiDriver), false])}) exitWith {
        [LSTRING(driverAlreadyPresentMessage)] call zen_common_fnc_showMessage;
    };

    // Players must be in vehicle for this
    [LSTRING(aiDriverModuleName), [
        ["TOOLBOX:ENABLED", [LSTRING(aiDriverModuleName), LSTRING(enableAiDriverDesc)], _driver getVariable [QGVAR(aiDriver), false], true],
        ["TOOLBOX:YESNO", [LSTRING(enableInvulnerability), LSTRING(enableInvulnerabilityDesc)], false]
    ], {
        params ["_results", "_object"];
        _results params ["_addAiDriver", "_invulnerable"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _object) exitWith {
            [LSTRING_ZEN(modules,noObjectSelected)] call zen_common_fnc_showMessage;
        };

        if (!alive _object) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

        private _driver = driver _object;

        if (!isNull _driver && {!(_driver getVariable [QGVAR(aiDriver), false])}) exitWith {
            [LSTRING(driverAlreadyPresentMessage)] call zen_common_fnc_showMessage;
        };

        if (_addAiDriver && {(crew _object) findIf {isPlayer _x} == -1}) exitWith {
            [LSTRING(requirePlayersMessage)] call zen_common_fnc_showMessage;
        };

        private _commander = effectiveCommander _object;

        if (_addAiDriver && {!isPlayer _commander}) exitWith {
            [LSTRING(requirePlayerCommanderMessage)] call zen_common_fnc_showMessage;
        };

        if (isNil QFUNC(addBehaviourEh)) then {
            #include "module_behaviourCrew_init.inc.sqf"
        };

        if (_addAiDriver) then {
            // Driver is already AI
            if (_driver getVariable [QGVAR(aiDriver), false]) exitWith {
                [LSTRING(aiDriverAlreadyPresentMessage)] call zen_common_fnc_showMessage;
            };

            ["zen_common_execute", [{
                params ["_commander", "_object", "_invulnerable"];

                private _unitType = switch (side group _commander) do {
                    case west: {"B_Survivor_F"};
                    case east: {"O_Survivor_F"};
                    case independent: {"I_Survivor_F"};
                    default {"C_man_1"};
                };

                private _driver = createAgent [_unitType, ASLToAGL getPosASL _commander, [], 0, "CAN_COLLIDE"];

                _driver setVariable [QGVAR(aiDriver), true, true];

                // Give unit basic gear
                removeAllWeapons _driver;
                removeGoggles _driver;

                _driver forceAddUniform uniform _commander;
                _driver addVest vest _commander;
                _driver addHeadgear headgear _commander;

                // Move unit into vehicle
                _driver assignAsDriver _object;
                _driver moveInDriver _object;

                doStop _driver;

                _driver allowDamage !_invulnerable;

                // Prevent crew from dismounting when ACE vehicle damage is enabled
                _object setVariable ["ace_vehicle_damage_allowCrewInImmobile", true, true];

                [_object, _driver, false, false, "COMBAT"] call FUNC(setBehaviourVehicleCrew);

                ["zen_common_execute", [{
                    (_this select 0) setOwner owner (_this select 1);
                }, [_object, _commander]]] call CBA_fnc_serverEvent;

                ["zen_common_execute", [{
                    (_this select 0) setEffectiveCommander (_this select 1);
                }, [_object, _commander]]] call CBA_fnc_globalEvent;

                // Lock the driver's position as soon as the driver has mounted
                [{
                    (_this select 1) in (_this select 0)
                }, {
                    ["zen_common_execute", [{
                        _this lockDriver true;
                    }, _this select 0], _this select 0] call CBA_fnc_targetEvent;
                }, [_object, _driver], 5] call CBA_fnc_waitUntilAndExecute;

                // Monitor the driver
                [QGVAR(executeFunction), [QFUNC(addAiDriverEh), [_object, _driver]]] call CBA_fnc_serverEvent;
            } call FUNC(sanitiseFunction), [_commander, _object, _invulnerable]], _commander] call CBA_fnc_targetEvent;

            [LSTRING(addedAiDriverMessage)] call zen_common_fnc_showMessage;

            // Prevent unit from turning out
            if (!isNil {_object getVariable QGVAR(turnOutJIP)}) exitWith {};

            private _jipID = [QGVAR(executeFunction), [QFUNC(addBehaviourEh), _object]] call FUNC(globalEventJIP);
            [_jipID, _object] call FUNC(removeGlobalEventJIP);

            _object setVariable [QGVAR(turnOutJIP), _jipID, true];

            // Whenever a crew member mounts/dismounts, make them stay turned in
            [QGVAR(executeFunction), [QFUNC(addGetInOutEh), _object]] call CBA_fnc_serverEvent;
        } else {
            // Driver is already not AI
            if !(_driver getVariable [QGVAR(aiDriver), false]) exitWith {
                [LSTRING(aiDriverAlreadyRemovedMessage)] call zen_common_fnc_showMessage;
            };

            // Allow crew to dismount when ACE vehicle damage is enabled
            _object setVariable ["ace_vehicle_damage_allowCrewInImmobile", nil, true];

            // Remove the driver
            [QGVAR(executeFunction), [QFUNC(removeAiDriverEh), [_object, _driver]]] call CBA_fnc_serverEvent;

            [LSTRING(removedAiDriverMessage)] call zen_common_fnc_showMessage;
        };
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
