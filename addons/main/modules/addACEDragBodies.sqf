/*
 * Author: johnb43
 * Spawns a module that allows Zeus to make dead bodies draggable.
 * Cobbled together out of ACE3 code.
 */

if (isNil QGVAR(draggingKilledEH)) then {
    GVAR(draggingKilledEH) = true;
    publicVariable QGVAR(draggingKilledEH);

    ["zen_common_execute", [{
        // Need to check for weapon holders when an entity is created, otherwise they get deleted
        addMissionEventHandler ["EntityCreated", {
            params ["_weaponHolder"];

            if (typeOf _weaponHolder != "WeaponHolderSimulated") exitWith {};

            // 'getCorpse' does not work immediately upon death for weapon holders
            [{
                private _unit = getCorpse _this;

                if (isNull _unit || {isNull _this}) exitWith {};

                // Get previously saved weapon holders
                private _savedWeaponHolders = _unit getVariable [QGVAR(weaponHolders), []];

                _savedWeaponHolders pushBackUnique _this;

                _unit setVariable [QGVAR(weaponHolders), _savedWeaponHolders, true];
            }, _weaponHolder, 0.2] call CBA_fnc_waitAndExecute;
        }];

        // When a unit is killed, enable interaction
        addMissionEventHandler ["EntityKilled", {
            params ["_unit"];

            if (isNil QGVAR(enableDragging) || {!(_unit isKindOf "CAManBase")} || {_unit isKindOf "VirtualCurator_F"}) exitWith {};

            _unit setVariable [QGVAR(canDragBody), true, true];
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

            // Remove from JIP if object is deleted
            [["zen_common_setVectorDirAndUp", [_body, [vectorDir _bodyBag, vectorUp _bodyBag]]] call CBA_fnc_globalEventJIP, _body] call CBA_fnc_removeGlobalEventJIP;
            _body setPosASL getPosASL _bodyBag;

            _body switchMove "AinjPpneMrunSnonWnonDb_grab";

            // Remove from JIP if object is deleted
            [["zen_common_setName", [_body, _bodyBag getVariable [QGVAR(name), "Unknown"]]] call CBA_fnc_globalEventJIP, _body] call CBA_fnc_removeGlobalEventJIP;

            // Set old medical state
            if (zen_common_aceMedical) then {
                [_body, _bodyBag getVariable [QGVAR(bodyState), []]] call ace_medical_fnc_deserializeState;
                _body call ace_medical_status_fnc_setDead;
            } else {
                _body setHitPointDamage ["HitHead", 1, true];
            };

            // Add dragging to new body if it was possible for old body
            if (!isNil QGVAR(enableDragging) || {_bodyBag getVariable [QGVAR(canDragBody), false]}) then {
                _body setVariable [QGVAR(canDragBody), true, true];
            };

            private _dogTagTaken = _bodyBag getVariable "ace_dogtags_dogtagTaken";

            // Mark dog tags as taken
            if (!isNil "_dogTagTaken" && {!isNull _dogTagTaken}) then {
                _body setVariable ["ace_dogtags_dogtagTaken", _body, true];
            };

            // Rename new body to old name
            _body setVariable ["ACE_Name", _bodyBag getVariable ["ACE_Name", "Unknown"], true];
            _body setVariable ["ACE_NameRaw", _bodyBag getVariable ["ACE_NameRaw", "UnknownRaw"], true];

            [{
                // Delete body bag
                deleteVehicle _this;
            }, _bodyBag] call CBA_fnc_execNextFrame;
        }] call CBA_fnc_addEventHandler;
    }, []]] call CBA_fnc_globalEventJIP;
};

// Sanizises a function
private _sanitiseFunction = {
    params ["_functionString"];

    _functionString = _functionString select [1, count _functionString - 2];

    private _index = -1;

    // Go through string and remove headers
    while {true} do {
        // Remove #line blabla
        if ((_functionString select [0, 5]) == "#line") then {
            _index = _functionString find ["#", 1];

            if (_index != -1) then {
                _functionString = _functionString select [_index];
            } else {
                // Arrived at last #line
                _index = _functionString find """";

                if (_index != -1) then {
                    _index = _functionString find ["""", _index + 1];

                    if (_index != -1) then {
                        // Remove all whitespaces on right and left
                        _functionString = trim (_functionString select [_index + 1]);
                    };
                };
            };
        } else {
            break;
        };
    };

    _functionString
};

if (isNil QFUNC(serializeObjects)) then {
    // 'zen_common_fnc_serializeObjects' does not work with dead objects
    private _functionString = (trim str zen_common_fnc_serializeObjects) call _sanitiseFunction;

    // Remove condition for dead units from function
    _functionString = [_functionString, "alive _x && {vehicle _x == _x}", "isNull objectParent _x"] call CBA_fnc_replace;

    // 'zeus_additions_main_fnc_serializeObjects'; Used by this module and zeus corpse dragging
    DFUNC(serializeObjects) = if (_functionString != "") then {
        compileFinal _functionString
    } else {
        zen_common_fnc_serializeObjects
    };
};

if (isNil QFUNC(deserializeInventory)) then {
    // 'zen_common_fnc_deserializeInventory' clears the inventory first, which makes objects of type 'WeaponHolderSimulated' delete immediately
    private _functionString = (trim str zen_common_fnc_deserializeInventory) call _sanitiseFunction;

    // Remove clearing of object on highest level
    _functionString = [_functionString, toString [10] + "clearItemCargoGlobal _object;" + toString [10], ""] call CBA_fnc_replace;
    _functionString = [_functionString, "clearWeaponCargoGlobal _object;" + toString [10], ""] call CBA_fnc_replace;
    _functionString = [_functionString, "clearMagazineCargoGlobal _object;" + toString [10], ""] call CBA_fnc_replace;
    _functionString = [_functionString, "clearBackpackCargoGlobal _object;" + toString [10] + toString [10], ""] call CBA_fnc_replace;

    // 'zeus_additions_main_fnc_serializeInventory'; Used by this module and zeus corpse dragging
    DFUNC(deserializeInventory) = if (_functionString != "") then {
        compileFinal _functionString
    } else {
        zen_common_fnc_serializeInventory
    };
};

["Zeus Additions - Utility", "Add ACE Drag Body Option", {
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
        private _bodies = (if (_all == 1) then {
            allDeadMen
        } else {
            [[], [_object]] select (!isNull _object && {!alive _object})
        }) select {isNull objectParent _x && {_x isKindOf "CAManBase"} && {!(_x isKindOf "VirtualCurator_F")}};

        if (!_includePlayers) then {
            _bodies = _bodies select {!isPlayer _x};
        };

        if (_bodies isEqualTo [] && {_allFuture == 0}) exitWith {
            ["No dead bodies were found"] call zen_common_fnc_showMessage;
        };

        // Compile action only if it's going to be used
        if (isNil QGVAR(dragBodyActions) && {_dragging || {_allFuture != 0}}) then {
            GVAR(dragBodyActions) = true;
            publicVariable QGVAR(dragBodyActions);
            publicVariable QFUNC(serializeObjects);
            publicVariable QFUNC(serializeInventory);

            private _dragBodyAction =
                ["ace_dragging_dragDeadBody", localize "STR_ACE_Dragging_Drag", "z\ace\addons\dragging\UI\icons\person_drag.paa", {
                    // Get data from current object
                    private _data = [[_target], nil, false] call FUNC(serializeObjects);

                    if (_data isEqualTo [[], []]) exitWith {};

                    [_player, _target, true] call ace_common_fnc_claim;
                    [_target, true] remoteExecCall ["hideObjectGlobal", 2];

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

                    _bodyBag setVariable ["ACE_Name", _target call ace_common_fnc_getName, true];
                    _bodyBag setVariable ["ACE_NameRaw", [_target, false, true] call ace_common_fnc_getName, true];
                    _bodyBag setVariable ["ace_dogtags_dogtagTaken", _target getVariable "ace_dogtags_dogtagTaken", true];
                    _bodyBag setVariable [QGVAR(name), name _target, true];

                    if (zen_common_aceMedical) then {
                        _bodyBag setVariable [QGVAR(bodyState), _target call ace_medical_fnc_serializeState, true];
                    };

                    // Start dragging
                    [_player, _bodyBag] call ace_dragging_fnc_startDrag;

                    // Add deleted EH
                    _target addEventHandler ["Deleted", {
                        params ["_target"];

                        // AI bodies will be deleted immediately, player bodies are deleted when they are respawned or disconnect
                        {
                            // Set cause for weapon holders
                            _x setVariable [QGVAR(deletedBecauseDragging), true];
                        } forEach ((_target getVariable [QGVAR(weaponHolders), []]) select {!isNull _x});
                    }];

                    {
                        // Add deleted EH
                        _x addEventHandler ["Deleted", {
                            params ["_weaponHolder"];

                            // If deleted normally, don't bother
                            if !(_weaponHolder getVariable [QGVAR(deletedBecauseDragging), false]) exitWith {};

                            private _data = _weaponHolder call zen_common_fnc_serializeInventory;

                            // Check if there is anything still present
                            if (_data isEqualTo [[[],[]],[],[],[[],[]],[]]) exitWith {};

                            [{
                                // Wait until the weaponholder has been deleted
                                isNull (_this select 0)
                            }, {
                                params ["", "_posATL", "_vectorDirAndUp", "_data"];

                                // Create a new weapon holder & put it in the same position as the old
                                private _newWeaponHolder = createVehicle ["WeaponHolderSimulated", [0, 0, 0], [], 0, "CAN_COLLIDE"];
                                _newWeaponHolder setPosATL _posATL;

                                // Remove from JIP if object is deleted
                                [["zen_common_setVectorDirAndUp", [_newWeaponHolder, _vectorDirAndUp]] call CBA_fnc_globalEventJIP, _newWeaponHolder] call CBA_fnc_removeGlobalEventJIP;

                                // Readd all of the old items
                                [_newWeaponHolder, _data] call FUNC(deserializeInventory);
                            }, [_weaponHolder, (getPosATL _weaponHolder) vectorAdd [0, 0, 0.05], [vectorDir _weaponHolder, vectorUp _weaponHolder], _data]] call CBA_fnc_waitUntilAndExecute;
                        }];
                    } forEach ((_target getVariable [QGVAR(weaponHolders), []]) select {!isNull _x});

                    // Make sure EH have been assigned
                    [{
                        [{
                            // Delete/hide the old body
                            if (isPlayer _this) then {
                                hideBody _this;
                            } else {
                                deleteVehicle _this;
                            };
                        }, _this] call CBA_fnc_execNextFrame;
                    }, _target] call CBA_fnc_execNextFrame;
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
                "No dead bodies without ACE Drag Body were found"
            };

            {
                _x setVariable [QGVAR(canDragBody), true, true];
            } forEach _bodies;

            format ["Added ACE Drag Body to %1", ["body", "all bodies"] select (count _bodies != 1)]
        } else {
            // Remove action
            _bodies = _bodies select {_x getVariable [QGVAR(canDragBody), false]};

            if (_bodies isEqualTo []) exitWith {
                "No dead bodies with ACE Drag Body were found!"
            };

            {
                _x setVariable [QGVAR(canDragBody), false, true];
            } forEach _bodies;

            format ["Removed ACE Drag Body from %1", ["body", "all bodies"] select (count _bodies != 1)]
        };

        // Add missionEH
        if (_allFuture == 1) then {
            _string = if (!isNil QGVAR(enableDragging)) then {
                "ACE Drag Body was already added to all future bodies"
            } else {
                GVAR(enableDragging) = true;
                publicVariable QGVAR(enableDragging);

                "Added ACE Drag Body to all future bodies"
            };
        };

        // Remove missionEH
        if (_allFuture == 2) then {
            _string = if (isNil QGVAR(enableDragging)) then {
                "ACE Drag Body was already removed from all future bodies"
            } else {
                GVAR(enableDragging) = nil;
                publicVariable QGVAR(enableDragging);

                "Removed ACE Drag Body from all future bodies"
            };
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _object] call zen_dialog_fnc_create;
}, ICON_PERSON] call zen_custom_modules_fnc_register;
