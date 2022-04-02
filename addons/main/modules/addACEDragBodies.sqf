/*
 * Author: johnb43
 * Spawns a module that allows Zeus to make dead bodies draggable.
 * Cobbled together out of ACE3 code
 */

if (isNil QGVAR(draggingKilledEH)) then {
    GVAR(draggingKilledEH) = true;
    publicVariable QGVAR(draggingKilledEH);

    ["zen_common_execute", [{
        // Need to check for weapon holders when the unit dies, otherwise they get deleted
        addMissionEventHandler ["EntityKilled", {
            params ["_unit"];

            if !(_unit isKindOf "CAManBase") exitWith {};

            if (!isNil QGVAR(enableDragging)) then {
                _unit setVariable [QGVAR(canDragBody), true, true];
            };

            if (isPlayer _unit) exitWith {};

            // Find the weaponholder that goes with the unit
            [{
                params ["_unit", "_weaponsItems"];

                // Find all weapon holders nearby
                private _weaponHolders = nearestObjects [getPos _unit, ["WeaponHolderSimulated"], 5];

                if (_weaponHolders isEqualTo []) exitWith {};

                private _weaponHoldersFiltered = [];
                private _weaponHolder = objNull;

                // Find weapon holders with weapons from unit
                {
                    _weaponHolder = _x;

                    {
                        if (_x in _weaponsItems) then {
                            _weaponHoldersFiltered pushBack _weaponHolder;
                        };
                    } forEach (weaponsItems _x);
                } forEach _weaponHolders;

                _unit setVariable [QGVAR(weaponHolders), _weaponHoldersFiltered, true];
            }, [_unit, weaponsItems _unit], 0.5] call CBA_fnc_waitAndExecute;
        }];
    }, []]] call CBA_fnc_serverEvent;

    ["zen_common_execute", [{
        // When unit has finished dragging, this event is triggered
        ["ace_common_fixCollision", {
            params ["_bodyBag"];

            private _data = _bodyBag getVariable [QGVAR(bodyData), []];

            // If unit is being dragged via body drag, kill them when released
            if (_data isEqualTo []) exitWith {};

            private _body = ([_data, [0, 0, 0]] call zen_common_fnc_deserializeObjects) param [0, objNull];

            if (isNull _body) exitWith {};

            _body setVectorDirAndUp [vectorDir _bodyBag, vectorUp _bodyBag];
            _body setPosASL getPosASL _bodyBag;

            _body switchMove "AinjPpneMrunSnonWnonDb_grab";

            // Set old medical state
            if (zen_common_aceMedical) then {
                [_body, _bodyBag getVariable [QGVAR(bodyState), []]] call ace_medical_fnc_deserializeState;
                _body call ace_medical_status_fnc_setDead;
            } else {
                _body setHitPointDamage ["HitHead", 1, true];
            };

            // Add dragging to new body if it was possible for old body
            if (!isNil QGVAR(enableDragging) || _bodyBag getVariable [QGVAR(canDragBody), false]) then {
                _body setVariable [QGVAR(canDragBody), true, true];
            };

            [{
                params ["_bodyBag", "_body", "_names"];

                // Delete body bag
                deleteVehicle _bodyBag;

                // Rename new body to old name
                _body setVariable ["ACE_Name", _names select 0, true];
                _body setVariable ["ACE_NameRaw", _names select 1, true];
            }, [_bodyBag, _body, _bodyBag getVariable [QGVAR(bodyName), ["Unknown", "UnknownRaw"]]]] call CBA_fnc_execNextFrame;
        }] call CBA_fnc_addEventHandler;
    }, []]] call CBA_fnc_globalEventJIP;

    // zen_common_fnc_serializeObjects does not work with dead objects
    private _functionString = str zen_common_fnc_serializeObjects;
    _functionString = (_functionString call CBA_fnc_leftTrim) call CBA_fnc_rightTrim;
    _functionString = _functionString select [1, count _functionString - 2];

    private _index = -1;

    // Go through string and remove headers
    while {true} do {
        // remove #line blabla
        if ((_functionString select [0, 5]) isEqualTo "#line") then {
            _index = _functionString find ["#", 1];

            if (_index isNotEqualTo -1) then {
                _functionString = _functionString select [_index];
            } else {
                // Arrived at last #line
                _index = _functionString find """";

                if (_index isNotEqualTo -1) then {
                    _index = _functionString find ["""", _index + 1];

                    if (_index isNotEqualTo -1) then {
                        // Remove all whitespaces on right and left
                        _functionString = ((_functionString select [_index + 1]) call CBA_fnc_leftTrim) call CBA_fnc_rightTrim;
                    };
                };
            };
        } else {
            break;
        };
    };

    // Remove condition for dead units from function
    _functionString = [_functionString, "alive _x && {vehicle _x == _x}", "isNull objectParent _x"] call CBA_fnc_replace;

    // zeus_additions_main_fnc_serializeObjects; Used by this module and zeus corpse dragging
    DFUNC(serializeObjects) = if (_functionString isNotEqualTo "") then {
        compileFinal _functionString;
    } else {
        zen_common_fnc_serializeObjects;
    };
};

["Zeus Additions - Utility", "[WIP] Add ACE Drag Body Option", {
    params ["", "_object"];

    ["Add ACE Drag Body Option", [
        ["TOOLBOX:ENABLED", ["Dragging", "Enables the dragging of a dead body."], false],
        ["TOOLBOX", ["Selection", "Changes ACE body dragging on selected corpse only or all dead units."], [0, 1, 2, ["Object only", "All Dead Units"]]],
        ["TOOLBOX:YESNO", ["Include Player corpses", "If selected, player corpses will also be able to be dragged."], false],
        ["TOOLBOX", ["Apply to all future dead units", "Enables the dragging of all future dead bodies, including players (regardless of the setting above)."], [0, 1, 3, ["Unchanged", "Enabled", "Disabled"]], true]
    ],
    {
        params ["_results", "_object"];
        _results params ["_dragging", "_all", "_includePlayers", "_allFuture"];

        // Select bodies not in vehicles, dead, not null and men
        private _bodies = ([[[], [_object]] select (!isNull _object && {!alive _object}), allDeadMen] select _all) select {isNull objectParent _x && {_x isKindOf "CAManBase"}};

        if (!_includePlayers) then {
            _bodies = _bodies select {!isPlayer _x};
        };

        if (_bodies isEqualTo [] && {_allFuture isEqualTo 0}) exitWith {
             ["No dead bodies were found!"] call zen_common_fnc_showMessage;
             playSound "FD_Start_F";
        };

        // Compile action only if it's going to be used
        if (isNil QGVAR(dragBodyActions) && {_dragging || _allFuture isNotEqualTo 0}) then {
            GVAR(dragBodyActions) = true;
            publicVariable QGVAR(dragBodyActions);
            publicVariable QFUNC(serializeObjects);

            private _dragBodyAction =
                ["ace_dragging_dragDeadBody", localize "STR_ACE_Dragging_Drag", "z\ace\addons\dragging\UI\icons\person_drag.paa", {
                    private _data = [[_target], nil, false] call FUNC(serializeObjects);

                    if (_data isEqualTo [[], []]) exitWith {};

                    [_player, _target, true] call ace_common_fnc_claim;
                    [_target, true] remoteExec ["hideObjectGlobal", 2];

                    // Dead units in grpNull don't have any of those set
                    _data set [1, [[civilian, "WEDGE", "CARELESS", "BLUE", "LIMITED", [], 1]]];
                    _data select 0 select 0 set [5, "PRIVATE"];

                    // Place into body bag
                    private _position = (getPosASL _target) vectorAdd [0, 0, 0.2];
                    private _direction = ((_target modelToWorldVisual (_target selectionPosition "head")) vectorFromTo (_target modelToWorldVisual (_target selectionPosition "Spine3"))) call CBA_fnc_vectDir;

                    // Create the body bag object, set its position to prevent it from flipping
                    private _bodyBag = createVehicle ["ACE_bodyBagObject", [0, 0, 0], [], 0, "NONE"];
                    _bodyBag setDir _direction;
                    _bodyBag setPosASL _position;

                    [_player, _bodyBag, true] call ace_common_fnc_claim;

                    _bodyBag setVariable [QGVAR(canDragBody), true, true];
                    _bodyBag setVariable [QGVAR(bodyData), _data, true];
                    _bodyBag setVariable [QGVAR(bodyName), [_target call ace_common_fnc_getName, [_target, false, true] call ace_common_fnc_getName], true];

                    if (zen_common_aceMedical) then {
                        _bodyBag setVariable [QGVAR(bodyState), _target call ace_medical_fnc_serializeState, true];
                    };

                    [{
                    	params ["_player", "_target", "_bodyBag"];

                    	[_player, _bodyBag] call ace_dragging_fnc_startDrag;

                        {
                            // Set cause for weapon holders
                            _x setVariable [QGVAR(deletedBecauseDragging), true];

                            // Add deleted EH
                            _x addEventHandler ["Deleted", {
                                params ["_weaponHolder"];

                                // If deleted normally, don't bother
                                if !(_weaponHolder getVariable [QGVAR(deletedBecauseDragging), false]) exitWith {};

                                // Check if there are any weapon still present
                                private _weaponItems = weaponsItems _weaponHolder;

                                if (_weaponItems isEqualTo []) exitWith {};

                                // Create a new weapon holder & put it in the same position as the old
                                private _newWeaponHolder = createVehicle ["WeaponHolderSimulated", (getPosATL _weaponHolder) vectorAdd [0, 0, 0.2], [], 0, "CAN_COLLIDE"];
                                _newWeaponHolder setVectorDirAndUp [vectorDir _weaponHolder, vectorUp _weaponHolder];

                                // Readd weapons
                                {
                                    _newWeaponHolder addWeaponWithAttachmentsCargoGlobal [_x, 1];
                                } forEach _weaponItems;
                            }];
                        } forEach ((_target getVariable [QGVAR(weaponHolders), []]) select {!isNull _x});

                    	// Make sure EH have been assigned
                    	[{
                            // Server will handle hiding and deleting the body
                            ["ace_placedInBodyBag", _this] call CBA_fnc_globalEvent;
                    	}, [_target, _bodyBag]] call CBA_fnc_execNextFrame;
                    }, [_player, _target, _bodyBag]] call CBA_fnc_execNextFrame;
                }, {
                    !alive _target && {isNull objectParent _target} && {[_player, _target, []] call ace_common_fnc_canInteractWith} && {_target getVariable [QGVAR(canDragBody), false]};
                }] call ace_interact_menu_fnc_createAction;

            // Add globally and JIP; Run only once
            ["zen_common_execute", [{
                if (!hasInterface) exitWith {};

                ["CAManBase", 0, ["ACE_MainActions"], _this, true] call ace_interact_menu_fnc_addActionToClass;
            }, _dragBodyAction]] call CBA_fnc_globalEventJIP;
        };

        private _string = if (_dragging) then {
             // Add action
            _bodies = _bodies select {!(_x getVariable [QGVAR(canDragBody), false])};

            if (_bodies isEqualTo []) exitWith {
                "No dead bodies without ACE Drag Body were found!";
            };

            {
                _x setVariable [QGVAR(canDragBody), true, true];
            } forEach _bodies;

            format ["Added ACE Drag Body to %1", ["body", "all bodies"] select (count _bodies isNotEqualTo 1)];
        } else {
            // Remove action
            _bodies = _bodies select {_x getVariable [QGVAR(canDragBody), false]};

            if (_bodies isEqualTo []) exitWith {
                "No dead bodies with ACE Drag Body were found!";
            };

            {
                _x setVariable [QGVAR(canDragBody), false, true];
            } forEach _bodies;

            format ["Removed ACE Drag Body from %1", ["body", "all bodies"] select (count _bodies isNotEqualTo 1)];
        };

        // Add missionEH
        if (_allFuture isEqualTo 1) then {
            if (!isNil QGVAR(enableDragging)) exitWith {
                playSound "FD_Start_F";
                _string = "ACE Drag Body was already added to all future bodies!";
            };

            GVAR(enableDragging) = true;
            publicVariable QGVAR(enableDragging);

            _string = "Added ACE Drag Body to all future bodies";
        };

        // Remove missionEH
        if (_allFuture isEqualTo 2) then {
            if (isNil QGVAR(enableDragging)) exitWith {
                playSound "FD_Start_F";
                _string = "ACE Drag Body was already removed from all future bodies!";
            };

            GVAR(enableDragging) = nil;
            publicVariable QGVAR(enableDragging);

            _string = "Removed ACE Drag Body from all future bodies";
        };

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_OBJECT] call zen_custom_modules_fnc_register;
