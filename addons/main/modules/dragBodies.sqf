/*
 * Author: johnb43
 * Adds the ability to drag corpses whilst in Zeus and using the map.
 */

// Whenever player opens zeus interface, check if curator has changed; If change, reassign eventhandler
["zen_curatorDisplayLoaded", {
    private _curator = getAssignedCuratorLogic player;

    if (isNull _curator || {!isNil {_curator getVariable QGVAR(curatorEhID)}}) exitWith {};

    _curator setVariable [QGVAR(curatorEhID),
        _curator addEventHandler ["CuratorObjectEdited", {
            params ["", "_entity"];

            if (alive _entity || {!(_entity isKindOf "CAManBase")}) exitWith {};

            private _data = [[_entity], nil, false] call FUNC(serializeObjects);

            if (_data isEqualTo [[], []]) exitWith {};

            [_entity, true] remoteExecCall ["hideObjectGlobal", 2];

            // Dead units in grpNull don't have any of those set
            _data set [1, [[civilian, "WEDGE", "CARELESS", "BLUE", "LIMITED", [], 1]]];
            _data select 0 select 0 set [5, "PRIVATE"];

            // Add deleted EH
            _entity addEventHandler ["Deleted", {
                params ["_entity"];

                // AI bodies will be deleted immediately, player bodies are deleted when they are respawned or disconnect
                {
                    // Set cause for weapon holders
                    _x setVariable [QGVAR(deletedBecauseDragging), true];
                } forEach ((_entity getVariable [QGVAR(weaponHolders), []]) select {!isNull _x});
            }];

            {
                // Add deleted EH
                _x addEventHandler ["Deleted", {
                    params ["_weaponHolder"];

                    // If deleted normally, don't bother
                    if !(_weaponHolder getVariable [QGVAR(deletedBecauseDragging), false]) exitWith {};

                    // Check if there are any weapons still present
                    private _weaponItems = weaponsItems _weaponHolder;

                    if (_weaponItems isEqualTo []) exitWith {};

                    [{
                        // Wait until the weaponholder has been deleted
                        isNull (_this select 0)
                    }, {
                        params ["", "_posATL", "_vectorDir", "_vectorUp", "_weaponItems"];

                        // Create a new weapon holder & put it in the same position as the old
                        private _newWeaponHolder = createVehicle ["WeaponHolderSimulated", [0, 0, 0], [], 0, "CAN_COLLIDE"];
                        _newWeaponHolder setPosATL _posATL;

                        // Remove from JIP if object is deleted
                        [["zen_common_setVectorDirAndUp", [_newWeaponHolder, [_vectorDir, _vectorUp]]] call CBA_fnc_globalEventJIP, _newWeaponHolder] call CBA_fnc_removeGlobalEventJIP;

                        // Readd weapons
                        {
                            _newWeaponHolder addWeaponWithAttachmentsCargoGlobal [_x, 1];
                        } forEach _weaponItems;
                    }, [_weaponHolder, (getPosATL _weaponHolder) vectorAdd [0, 0, 0.05], vectorDir _weaponHolder, vectorUp _weaponHolder, _weaponItems]] call CBA_fnc_waitUntilAndExecute;
                }];
            } forEach ((_entity getVariable [QGVAR(weaponHolders), []]) select {!isNull _x});

            private _body = ([_data, [0, 0, 0]] call zen_common_fnc_deserializeObjects) param [0, objNull];

            if (isNull _body) exitWith {};

            _body setDir (((_entity modelToWorldVisual (_entity selectionPosition "head")) vectorFromTo (_entity modelToWorldVisual (_entity selectionPosition "Spine3"))) call CBA_fnc_vectDir);
            _body setPosASL ((getPosASL _entity) vectorAdd [0, 0, 0.05]);

            _body switchMove "AinjPpneMrunSnonWnonDb_grab";

            // Remove from JIP if object is deleted
            [["zen_common_setName", [_body, name _entity]] call CBA_fnc_globalEventJIP, _body] call CBA_fnc_removeGlobalEventJIP;

            // Set old medical state
            if (zen_common_aceMedical) then {
                [_body, _entity call ace_medical_fnc_serializeState] call ace_medical_fnc_deserializeState;
                _body call ace_medical_status_fnc_setDead;
            } else {
                _body setHitPointDamage ["HitHead", 1, true];
            };

            // Add dragging to new body if it was possible for old body
            if (!isNil QGVAR(enableDragging) || {_entity getVariable [QGVAR(canDragBody), false]}) then {
                _body setVariable [QGVAR(canDragBody), true, true];
            };

            private _dogTagTaken = _entity getVariable "ace_dogtags_dogtagTaken";

            // Mark dog tags as taken
            if (!isNil "_dogTagTaken" && {!isNull _dogTagTaken}) then {
                _body setVariable ["ace_dogtags_dogtagTaken", _body, true];
            };

            // Rename new body to old name
            _body setVariable ["ACE_Name", _entity call ace_common_fnc_getName, true];
            _body setVariable ["ACE_NameRaw", [_entity, false, true] call ace_common_fnc_getName, true];

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
            }, _entity] call CBA_fnc_execNextFrame;
        }]
    ];
}] call CBA_fnc_addEventHandler;
