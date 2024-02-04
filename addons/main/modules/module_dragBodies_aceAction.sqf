/*
 * Author: johnb43
 * Init for drag bodies action.
 * Cobbled together out of ACE3 code.
 */

INFO_1("Running %1",__FILE__);

private _dragBodyAction = [QGVAR(dragDeadBody), LLSTRING_ACE(dragging,drag), "z\ace\addons\dragging\UI\icons\person_drag.paa", {
    // Claim, so that no one else can interact with corpse
    [_player, _target] call ace_common_fnc_claim;

    private _pos = getPosASL _target;

    // Create a clone of the object
    private _clone = createVehicle [typeOf _target, ASLToAGL _pos, [], 0, "CAN_COLLIDE"];

    // Claim the clone
    [_player, _clone] call ace_common_fnc_claim;

    // Move unit -10 m below terrain in order to hide it and remove its inventory access
    _pos set [2, -10];

    // Corpse is desynced, but it doesn't matter here
    _target setPosATL _pos;

    // Hide unit (as a safety precaution)
    private _isObjectHidden = isObjectHidden _target;

    if (!_isObjectHidden) then {
        ["zen_common_hideObjectGlobal", [_target, true]] call CBA_fnc_serverEvent;
    };

    private _simulationEnabled = simulationEnabled _target;

    if (_simulationEnabled) then {
        ["zen_common_enableSimulationGlobal", [_target, false]] call CBA_fnc_serverEvent;
    };

    private _isInRemainsCollector = isInRemainsCollector _target;

    // Make sure corpse isn't deleted by engine's garbage collector
    if (_isInRemainsCollector) then {
        removeFromRemainsCollector [_target];
    };

    private _isInClibCollector = _target getVariable ["CLib_noClean", false];

    // Make sure corpse isn't deleted by CLib's garbage collector
    if (_isInClibCollector) then {
        _target setVariable ["CLib_noClean", true, true];
    };

    // Make sure clone has the same wound textures as the corpse
    private _targetDamage = damage _target;

    if (_targetDamage != 0) then {
        _clone setDamage (_targetDamage min 0.99); // Don't kill the clone
    };

    // Damage relevant hitpoints, but don't kill unit
    {
        _clone setHitPointDamage [_x, (_target getHitPointDamage _x) min 0.99];
    } forEach ["HitHead", "HitBody", "HitHands", "HitLegs"];

    // Disable all damage
    _clone allowDamage false;
    _clone setVariable [QGVAR(corpse), [_target, [_isInRemainsCollector, _isInClibCollector], _isObjectHidden, _simulationEnabled], true];

    [{
        params ["_clone", "_target"];

        // Remove clone from zeus interface
        [[_clone], false] call zen_common_fnc_updateEditableObjects;

        // Clone loadout (sometimes default loadouts are randomised, so overwrite those)
        [_clone, _target call CBA_fnc_getLoadout] call CBA_fnc_setLoadout;

        // Set facial expression
        [["zen_common_execute", [{
            params ["_clone", "_face"];

            _clone setFace _face;
            _clone setMimic "unconscious";
        }, [_clone, face _target]]] call CBA_fnc_globalEventJIP, _clone] call CBA_fnc_removeGlobalEventJIP;

        // Release claim on corpse
        [objNull, _target] call ace_common_fnc_claim;
    }, [_clone, _target], 0.25] call CBA_fnc_waitAndExecute;

    private _objectCurators = objectCurators _target;

    // Save which curators had this object as editable
    _target setVariable [QGVAR(objectCurators), _objectCurators, true];

    if (_objectCurators isNotEqualTo []) then {
        [[_target], false, _objectCurators] call zen_common_fnc_updateEditableObjects;
    };

    // Set direction and position of clone ot match target
    _clone setDir (((_target modelToWorldVisual (_target selectionPosition "head")) vectorFromTo (_target modelToWorldVisual (_target selectionPosition "Spine3"))) call CBA_fnc_vectDir);
    _clone setPosATL ((getPosATL _target) vectorAdd [0, 0, 0.2]);

    // Start dragging
    [_player, _clone] call ace_dragging_fnc_startDrag;
} call FUNC(sanitiseFunction), {
    !alive _target && {isNull objectParent _target} && {[_player, _target, []] call ace_common_fnc_canInteractWith} && {_target getVariable [QGVAR(canDragBody), false]};
}] call ace_interact_menu_fnc_createAction;

// Add globally and JIP; Run only once
["zen_common_execute", [{
    if (!hasInterface) exitWith {};

    ["CAManBase", 0, ["ACE_MainActions"], _this, true] call ace_interact_menu_fnc_addActionToClass;
} call FUNC(sanitiseFunction), _dragBodyAction], QGVAR(aceActionsJIP)] call CBA_fnc_globalEventJIP;
