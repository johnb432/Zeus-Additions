GVAR(aiFeatureList) = [
    "AUTOTARGET",
    "MOVE",
    "TARGET",
    "TEAMSWITCH",
    "WEAPONAIM",
    "ANIM",
    "FSM",
    "AIMINGERROR",
    "SUPPRESSION",
    "CHECKVISIBLE",
    "AUTOCOMBAT",
    "COVER",
    "PATH",
    "MINEDETECTION",
    "LIGHTS",
    "NVG",
    "RADIOPROTOCOL",
    "FIREWEAPON"
];

[
    LSTRING(moduleCategoryUtility),
    QGVAR(deepCopy),
    [LSTRING(deepCopy), LSTRING(deepCopyDesc)],
    {
        if (isNull curatorCamera) exitWith {};

        private _curatorSelectedObjects = curatorSelected select 0;

        if (_curatorSelectedObjects isEqualTo []) exitWith {};

        private _objects = [];
        private _unitInfo = [];
        private _crewInfo = [];
        private _centerASL = [0, 0, 0];

        private _objectCount = {
            private _isMan = _x isKindOf "CAManBase";

            // Exclude crew, if they are selected (ZEN function will handle them)
            if (_isMan && {!isNull objectParent _x}) then {
                false
            } else {
                _objects pushBack _x;
                _centerASL = _centerASL vectorAdd getPosASL _x;

                if (_isMan) then {
                    private _unit = _x;

                    _unitInfo pushBack (GVAR(aiFeatureList) apply {_unit checkAIFeature _x});
                } else {
                    if (_x isKindOf "AllVehicles" && {!(_x isKindOf "Animal")}) then {
                        _crewInfo pushBack ((fullCrew _x) apply {
                            private _unit = _x select 0;

                            _x deleteAt [0, 5];

                            [_x, GVAR(aiFeatureList) apply {_unit checkAIFeature _x}]
                        });
                    };
                };

                true
            }
        } count _curatorSelectedObjects;

        _centerASL = _centerASL vectorMultiply (1 / (_objectCount max 1));

        // Serialise all objects together, to keep group information
        GVAR(copiedObjects) = [
            [_objects, ASLToAGL _centerASL] call zen_common_fnc_serializeObjects,
            _objects apply {(getPosASL _x) vectorDiff _centerASL},
            _unitInfo,
            _crewInfo
        ];

        playSound ["RscDisplayCurator_error01", true];

        true
    },
    {},
    [DIK_C, [false, true, true]]
] call CBA_fnc_addKeybind;

[
    LSTRING(moduleCategoryUtility),
    QGVAR(deepPaste),
    [LSTRING(deepPaste), LSTRING(deepPasteDesc)],
    {
        if (isNull curatorCamera || {isNil QGVAR(copiedObjects)}) exitWith {};

        GVAR(copiedObjects) params ["_serialisedData", "_offsets", "_unitInfo", "_crewInfo"];

        private _posASL = AGLToASL (screenToWorld getMousePosition);
        private _intersections = lineIntersectsSurfaces [AGLToASL (positionCameraToWorld [0, 0, 0]), _posASL, objNull, objNull, true, 1, "FIRE", "GEOM", false];

        if (_intersections isNotEqualTo []) then {
            _posASL = (_intersections select 0) select 0;
            _posASL = _posASL vectorAdd [0, 0, 0.05];
        };

        private _objects = [_serialisedData, [0, 0, 0]] call zen_common_fnc_deserializeObjects;
        private _offsetIndex = 0;
        private _unitInfoIndex = 0;
        private _crewInfoIndex = 0;

        {
            private _isMan = _x isKindOf "CAManBase";

            // Don't handle crew here
            if (_isMan && {!isNull objectParent _x}) then {
                continue;
            };

            if (_isMan) then {
                private _unit = _x;

                {
                    _unit enableAIFeature [GVAR(aiFeatureList) select _forEachIndex, _x];
                } forEach (_unitInfo select _unitInfoIndex);

                _unitInfoIndex = _unitInfoIndex + 1;

                private _pos = _posASL vectorAdd (_offsets select _offsetIndex);
                _offsetIndex = _offsetIndex + 1;

                _unit setPosASL ((lineIntersectsSurfaces [_pos, _pos vectorAdd [0, 0, -5000], objNull, objNull, true, 1, "FIRE", "GEOM", false]) select 0 select 0);
            } else {
                if (_x isKindOf "AllVehicles" && {!(_x isKindOf "CAManBase")} && {!(_x isKindOf "Animal")}) then {
                    {
                        private _data = _x;

                        (_data deleteAt [0, 5]) params ["_unit"];

                        // Find matching unit in new vehicle
                        private _index = (_crewInfo select _crewInfoIndex) findIf {(_x select 0) isEqualTo _data};

                        if (_index == -1) then {
                            ERROR_2("Unit couldn't be found - %1 - %2",_data,_crewInfo select _crewInfoIndex);

                            continue;
                        };

                        {
                            _unit enableAIFeature [GVAR(aiFeatureList) select _forEachIndex, _x];
                        } forEach (((_crewInfo select _crewInfoIndex) select _index) select 1);
                    } forEach (fullCrew _x);

                    _crewInfoIndex = _crewInfoIndex + 1;
                };

                _x setPosASL (_posASL vectorAdd (_offsets select _offsetIndex));
                _offsetIndex = _offsetIndex + 1;
            };
        } forEach _objects;

        playSound ["RscDisplayCurator_error01", true];

        true
    },
    {},
    [DIK_V, [false, true, true]]
] call CBA_fnc_addKeybind;
