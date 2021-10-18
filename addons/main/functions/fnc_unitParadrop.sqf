#include "script_component.hpp"

/*
 * Author: johnb43
 * Spawns a module that allows units to paradrop.
 * With some help from https://github.com/zen-mod/ZEN/blob/master/addons/modules/functions/fnc_moduleCreateMinefield.sqf
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_unitParadrop;
 *
 * Public: No
 */

["Zeus Additions - Utility", "Paradrop Units", {
    params ["_pos"];

    ["Paradrop Units (Read tooltips! Use this in map screen to get best results)", [
        ["OWNERS", ["Players selected", "Select sides/groups/players."], [[], [], [], 0], true],
        ["TOOLBOX:YESNO", ["Include Context Menu Selection", "Paradrops units (AI or players) selected by the Zeus using the ZEN context menu."], false, true],
        ["TOOLBOX:YESNO", ["Include Vehicles", "Takes vehicles with players and paradrops them both together, crew staying inside. Applies to players only."], false],
        ["TOOLBOX:YESNO", ["Include Players in Vehicles", "Takes players only out of their vehicles and paradrops the players only."], false],
        ["SLIDER", ["Paradrop Altitude", "Determines how far up units are paradropped over terrain level."], [150, 5000, 1000, 0]],
        ["SLIDER", ["Unit Density", "Determines how far apart units are paradropped from each other."], [10, 100, 40, 0]],
        ["TOOLBOX:YESNO", ["Give Units Parachutes", "Stores their backpacks and gives them parachutes automatically. Upon landing units get their backpacks back."], true]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_selected", "_includeContextMenu", "_includeVehicles", "_includePlayersInVehicles", "_height", "_density", "_giveUnitsParachutes"];
        _selected params ["_sides", "_groups", "_players"];

        // Check for selected units
        if (!_includeContextMenu && {_sides isEqualTo []} && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            ["Select a side/group/unit!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        // Set height on position
        _pos set [2, _height];

        private _unitList = [];
        private _vehicleList = [];
        private _objectList = [];
        private _vehicle = objNull;

        // Find all players from the list
        {
            if (_includePlayersInVehicles || {isNull objectParent _x}) then {
                _unitList pushBack _x;
            };

            if (!_includeVehicles) then {
                continue;
            };

            _vehicle = objectParent _x;

            if (_vehicle isKindOf "LandVehicle" || {_vehicle isKindOf "Ship"}) then {
                _vehicleList pushBackUnique _vehicle;
            };
        } forEach ((call CBA_fnc_players) select {side _x in _sides || {group _x in _groups} || {_x in _players}});

        // Add context menu selection of entities
        if (_includeContextMenu) then {
            if (!isNil QGVAR(selectedParadropUnits)) then {
                _unitList append GVAR(selectedParadropUnits);
            };

            if (!isNil QGVAR(selectedParadropVehicles)) then {
                _vehicleList append GVAR(selectedParadropVehicles);
            };

            if (!isNil QGVAR(selectedParadropMisc)) then {
                _objectList append GVAR(selectedParadropMisc);
            };

            // Reset choice for the next time
            GVAR(selectedParadropUnits) = nil;
            GVAR(selectedParadropVehicles) = nil;
            GVAR(selectedParadropMisc) = nil;
        };

        // Try to make a square of parachuting units
        private _unitCount = count _unitList;
        private _vicCount = count _vehicleList;
        private _objectCount = count _objectList;
        private _vicObjCount = _vicCount + _objectCount;
        private _allCount = _unitCount + _vicCount + _objectCount;

        _vehicleList append _objectList;

        private _sqrt = sqrt _allCount;
        private _width = round _sqrt;
        private _height = ceil _sqrt;

        if (_width * _height < _allCount) then {
            _width = _width + 1;
        };

        // Starting position
        private _topLeft = _pos vectorAdd [-_width / 2, -_height / 2, 0];
        private _indexUnits = 0;
        private _indexVics = 0;
        private _unit;

        // Iterate through each spot in the rectangle
        for "_i" from 0 to (_width - 1) * _density step _density do {
            for "_j" from 0 to (_height - 1) * _density step _density do {
                if (_allCount isEqualTo (_indexUnits + _indexVics)) exitWith {};

                // Spawn infantry
                if (_indexUnits isNotEqualTo _unitCount) then {
                   _unit = _unitList select _indexUnits;

                   // If unit is already paradropping, don't TP
                   if (_unit getVariable [QGVAR(isParadropping), false]) then {
                       continue;
                   };

                   _unit setVariable [QGVAR(isParadropping), true, true];

                   // If AI, don't need to transition screen or inform about paradrop
                   if (isPlayer _unit) then {
                       [["You are being paradropped...", "BLACK OUT", 2, true]] remoteExecCall ["cutText", _unit];
                       ["zen_common_hint", ["The parachute will automatically deploy if you haven't deployed it before reaching 150m above ground level. Your backpack will be returned upon landing."], _unit] call CBA_fnc_targetEvent;
                   };

                   // Teleport and add parachute
                   ["zen_common_execute", [
                       CBA_fnc_waitAndExecute, [
                           {
                               params ["_unit", "_topLeft", "_i", "_j", "_giveUnitsParachutes"];

                               _unit setPosATL (_topLeft vectorAdd [_i, _j, 0]);

                               // Spawn parachute
                               if (_giveUnitsParachutes) then {
                                   _unit addBackpack "B_Parachute";
                               };

                               // Don't do effect if unit is AI
                               if (!isPlayer _unit) exitWith {};

                               [["", "BLACK IN", 2, true]] remoteExecCall ["cutText", _unit];
                           }, [_unit, _topLeft, _i, _j, _giveUnitsParachutes], 3
                       ]
                   ], _unit] call CBA_fnc_targetEvent;

                   // If automatic parachute distribution is disabled, don't continue
                   if (!_giveUnitsParachutes) then {
                       continue;
                   };

                   // Store old backpack information, then delete backpack
                   _unit setVariable [QGVAR(backpackUnit), backpack _unit, true];
                   _unit setVariable [QGVAR(backpackContents), backpackItems _unit, true];
                   removeBackpackGlobal _unit;

                   [{
                       ["zen_common_execute", [
                           CBA_fnc_waitUntilAndExecute, [
                               {
                                   // If the unit is on the ground or in water
                                   isTouchingGround _this || {(eyePos _this) select 2 < 1};
                               }, {
                                   // Unit is no longer paradropping
                                   _this setVariable [QGVAR(isParadropping), false, true];

                                   // Remove parachute and give old backpack back
                                   removeBackpackGlobal _this;
                                   private _backpack = _this getVariable QGVAR(backpackUnit);

                                   if (isNil "_backpack") exitWith {};

                                   _this addBackpack _backpack;
                                   _this setVariable [QGVAR(backpackUnit), nil, true];

                                   // Return old content
                                   private _contents = _this getVariable [QGVAR(backpackContents), []];

                                   if (_contents isEqualTo []) exitWith {};

                                   {
                                       _this addItemToBackpack _x;
                                   } forEach _contents;

                                   _this setVariable [QGVAR(backpackContents), nil, true];
                               }, _this
                           ]
                       ], _this] call CBA_fnc_targetEvent;

                       ["zen_common_execute", [
                           CBA_fnc_waitUntilAndExecute, [
                               {
                                   // If the units is <100m AGL, deploy parachute to prevent them splatting on the ground
                                   (eyePos _this) select 2 < 100 || {!alive _this};
                               }, {
                                   // If parachute is already open or unit is unconscious or dead, don't do action
                                   if ((((objectParent _this) call BIS_fnc_objectType) select 1) isEqualTo "Parachute" || {_this getVariable ["ACE_isUnconscious", false]} || {!alive _this}) exitWith {};

                                   _this action ["OpenParachute", _this];
                               }, _this
                           ]
                       ], _this] call CBA_fnc_targetEvent;
                   }, _unit, 3.5] call CBA_fnc_waitAndExecute;

                   _indexUnits = _indexUnits + 1;
                } else {
                    // Spawn vehicles
                    if (_indexVics isNotEqualTo _vicObjCount) then {
                        _vehicle = _vehicleList select _indexVics;
                        _vehicle setPosATL (_topLeft vectorAdd [_i, _j, 0]);

                        private _bbr = boundingBoxReal _vehicle;

                        // Attach parachute to the middle (in height)
                        _vehicle attachTo [createVehicle ["i_parachute_02_f", getPos _vehicle, [], 0, "CAN_COLLIDE"], [0, 0, ((_bbr select 1 select 2) - (_bbr select 0 select 2)) / 2]];

                        _indexVics = _indexVics + 1;
                    };
                };
            };
        };

        ["Paradropped %1 units, %2 vehicles & %3 objects", _unitCount, _vicCount, _objectCount] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _pos] call zen_dialog_fnc_create;
}, ICON_PARADROP] call zen_custom_modules_fnc_register;
