/*
 * Author: johnb43
 * Adds the ability to drag corpses whilst in Zeus and using the map.
 */

(getAssignedCuratorLogic player) addEventHandler ["CuratorObjectEdited", {
    params ["", "_entity"];

    if (alive _entity || {!(_entity isKindOf "CAManBase")}) exitWith {};

    private _data = [[_entity], nil, false] call FUNC(serializeObjects);

    if (_data isEqualTo [[], []]) exitWith {};

    [_entity, true] remoteExec ["hideObjectGlobal", 2];

    // Dead units in grpNull don't have any of those set
    _data set [1, [[civilian, "WEDGE", "CARELESS", "BLUE", "LIMITED", [], 1]]];
    _data select 0 select 0 set [5, "PRIVATE"];

    // Get old info
    private _position = (getPosASL _entity) vectorAdd [0, 0, 0.2];
    private _direction = ((_entity modelToWorldVisual (_entity selectionPosition "head")) vectorFromTo (_entity modelToWorldVisual (_entity selectionPosition "Spine3"))) call CBA_fnc_vectDir;
    private _names = [_entity call ace_common_fnc_getName, [_entity, false, true] call ace_common_fnc_getName];
    private _medicalState = if (zen_common_aceMedical) then {
         _entity call ace_medical_fnc_serializeState;
    } else {
        nil;
    };

    [{
        params ["_entity", "_data", "_medicalState", "_names", "_position", "_direction"];

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
        } forEach ((_entity getVariable [QGVAR(weaponHolders), []]) select {!isNull _x});


        private _body = ([_data, [0, 0, 0]] call zen_common_fnc_deserializeObjects) param [0, objNull];

        if (isNull _body) exitWith {};

        _body setDir _direction;
        _body setPosASL _position;

        _body switchMove "AinjPpneMrunSnonWnonDb_grab";

        // Set old medical state
        if (zen_common_aceMedical && {!isNil "_medicalState"}) then {
            [_body, _medicalState] call ace_medical_fnc_deserializeState;
            _body call ace_medical_status_fnc_setDead;
        } else {
            _body setHitPointDamage ["HitHead", 1, true];
        };

        // Add dragging to new body if it was possible for old body
        if (!isNil QGVAR(enableDragging) || _entity getVariable [QGVAR(canDragBody), false]) then {
            _body setVariable [QGVAR(canDragBody), true, true];
        };

        [{
            params ["_body", "_names"];

            // Rename new body to old name
            _body setVariable ["ACE_Name", _names select 0, true];
            _body setVariable ["ACE_NameRaw", _names select 1, true];
        }, [_body, _names]] call CBA_fnc_execNextFrame;

        // Make sure EH have been assigned
        [{
            if (isPlayer _this) then {
                _this call ace_medical_treatment_fnc_removeBody;
            } else {
                deleteVehicle _this;
            };
        }, _entity] call CBA_fnc_execNextFrame;
    }, [_entity, _data, _medicalState, _names, _position, _direction]] call CBA_fnc_execNextFrame;
}];
