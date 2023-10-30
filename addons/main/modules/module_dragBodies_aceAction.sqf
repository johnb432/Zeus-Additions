/*
 * Author: johnb43
 * Init for drag bodies action.
 * Cobbled together out of ACE3 code.
 */

INFO_ZA(FORMAT_1("Running %1",__FILE__));

private _dragBodyAction = [QGVAR(dragDeadBody), LLSTRING_ACE(dragging,drag), "z\ace\addons\dragging\UI\icons\person_drag.paa", {
    // Claim, so that no one else can interact with corpse
    [_player, _target] call ace_common_fnc_claim;

    // Make unit local to server, to avoid desync
    ["zen_common_execute", [{
        params ["_target"];

        // Join another group if alredy in a group
        if ((count units _target) > 1) then {
            [_target] joinSilent grpNull;
        };

        // If ownership was transferred successfully, quit
        if ((group _target) setGroupOwner 2) exitWith {};

        // Just change locality if alone
        _target setOwner 2;
    }, _target]] call CBA_fnc_serverEvent;

    // Hide unit
    private _isObjectHidden = isObjectHidden _target;

    if (!_isObjectHidden) then {
        [_target, true] remoteExecCall ["hideObjectGlobal", 2];
    };

    private _isInRemainsCollector = isInRemainsCollector _target;

    // Make sure corpse isn't deleted by engine's garbage collector
    if (_isInRemainsCollector) then {
        removeFromRemainsCollector [_target];
    };

    // Place into body bag
    private _position = (getPosASL _target) vectorAdd [0, 0, 0.2];
    private _direction = ((_target modelToWorldVisual (_target selectionPosition "head")) vectorFromTo (_target modelToWorldVisual (_target selectionPosition "Spine3"))) call CBA_fnc_vectDir;

    // Create a clone of the object
    private _clone = createVehicle [typeOf _target, getPosATL _target];

    // Disable all damage
    _clone allowDamage false;
    _clone setVariable [QGVAR(corpse), [_target, _isInRemainsCollector, _isObjectHidden], true];

    _clone setDir _direction;
    _clone setPosASL _position;

    // Start dragging
    [_player, _clone] call ace_dragging_fnc_startDrag;

    // Remove clone from zeus interface
    [{
        params ["_clone", "_target"];

        [[_clone, _target], false] call zen_common_fnc_updateEditableObjects;

        // Set facial expression
        [["zen_common_execute", [{
            params ["_clone", "_face"];

            _clone setFace _face;
            _clone setMimic "unconscious";
        }, [_clone, face _target]]] call CBA_fnc_globalEventJIP, _clone] call CBA_fnc_removeGlobalEventJIP;

        // Clone loadout
        [_clone, _target call CBA_fnc_getLoadout] call CBA_fnc_setLoadout;
    }, [_clone, _target], 0.25] call CBA_fnc_waitAndExecute;
} call FUNC(sanitiseFunction), {
    !alive _target && {isNull objectParent _target} && {[_player, _target, []] call ace_common_fnc_canInteractWith} && {_target getVariable [QGVAR(canDragBody), false]};
}] call ace_interact_menu_fnc_createAction;

// Add globally and JIP; Run only once
["zen_common_execute", [{
    if (!hasInterface) exitWith {};

    ["CAManBase", 0, ["ACE_MainActions"], _this, true] call ace_interact_menu_fnc_addActionToClass;
} call FUNC(sanitiseFunction), _dragBodyAction], QGVAR(aceActionsJIP)] call CBA_fnc_globalEventJIP;
