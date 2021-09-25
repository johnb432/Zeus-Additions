#include "script_component.hpp"

if (!hasInterface) exitWith {};

// Take the FK blacklist if enabled and present
if (GVAR(blacklistFKEnable) && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
    GVAR(blacklist) = [];

    {
        GVAR(blacklist) append ((format ["FKF/CfgArsenalBlacklist/%1", _x]) call Clib_fnc_getSetting);
    } forEach ("FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings);
} else {
    GVAR(blacklist) = parseSimpleArray GVAR(blacklistSettings);
};

GVAR(magsTotal) = [];
private _temp = [GVAR(545x39),GVAR(762x39),GVAR(762x54R),GVAR(oddBLU),GVAR(Stanag556),GVAR(Misc556),GVAR(Belt556),GVAR(QBZ58KH65),GVAR(MX65),GVAR(All762),GVAR(Belt762),GVAR(12G),GVAR(PistolBLU),GVAR(PistolRED),GVAR(UGLBLU),GVAR(UGLRED),GVAR(MATBLU),GVAR(MATRED),GVAR(HATRED),GVAR(HATBLUAMMO),GVAR(AABLU),GVAR(AARED)];

{
    GVAR(magsTotal) pushBack ([_temp select _forEachIndex, parseSimpleArray _x] select (isNil QUOTE(_x)));
} forEach [
    GVAR(545x39_mags),
    GVAR(762x39_mags),
    GVAR(762x54R_mags),
    GVAR(oddBLU_mags),
    GVAR(Stanag556_mags),
    GVAR(Misc556_mags),
    GVAR(Belt556_mags),
    GVAR(QBZ58KH65_mags),
    GVAR(MX65_mags),
    GVAR(All762_mags),
    GVAR(Belt762_mags),
    GVAR(12G_mags),
    GVAR(PistolBLU_mags),
    GVAR(PistolRED_mags),
    GVAR(UGLBLU_mags),
    GVAR(UGLRED_mags),
    GVAR(MATBLU_mags),
    GVAR(MATRED_mags),
    GVAR(HATRED_mags),
    GVAR(HATBLUAMMO_mags),
    GVAR(AABLU_mags),
    GVAR(AARED_mags)
];

GVAR(weaponsTotal) = [];

_temp = [GVAR(LATBLU),GVAR(LATRED),GVAR(HATBLU)];

{
    GVAR(weaponsTotal) pushBack ([_temp select _forEachIndex, parseSimpleArray _x] select (isNil QUOTE(_x)));
} forEach [GVAR(BLUFORLAT),GVAR(REDFORLAT),GVAR(BLUFORHAT)];

GVAR(weaponsTotal) pushBack ["UK3CB_BAF_Javelin_CLU"];

call FUNC(addACEDragAndCarry);
call FUNC(behaviourAIModules);
call FUNC(changeChannelVisibility);
call FUNC(changeGrassRender);
call FUNC(changeRadioRange);
call FUNC(configureDoors);
call FUNC(createInjuries);
call FUNC(createResupply);
call FUNC(deathStare);
call FUNC(deleteObjectForced);
call FUNC(dogAttack);
call FUNC(exitUnconsciousUnit);
call FUNC(gearScript);
call FUNC(missionEndModifier);
call FUNC(objectsCounterMission);
call FUNC(openMedicalMenu);
call FUNC(pauseTime);
call FUNC(placeMapMarker);
call FUNC(preventExplodingVehicle);
call FUNC(remoteControl);
call FUNC(removeGrenades);
call FUNC(snowScript);
call FUNC(toggleConsciousnessForced);
call FUNC(unitParadrop);

[{
    // Wait for curator object
    !isNull (getAssignedCuratorLogic player);
}, {
    // Add the JIP function
    call FUNC(handleJIP);

    // Add mission object counter
    call FUNC(objectsCounterMissionEH);
}, [], 30, {
    // Hint only if setting is enabled
    if (!GVAR(enableNoCuratorHint)) exitWith {};

    ["[Zeus Additions]: No Curator Object was found.", false, 10, 1] call ace_common_fnc_displayText;
}] call CBA_fnc_waitUntilAndExecute;

// Hint what is missing
private _coreCUPLHint = GVAR(enableSnowScriptHint) && {!isClass (configFile >> "CfgPatches" >> "CUP_Worlds")};
private _TFARHint = GVAR(enableTFARHint) && {!isClass (configFile >> "CfgPatches" >> "tfar_core")};

if (_coreCUPLHint || {_TFARHint}) then {
    systemChat "[Zeus Additions]:";

    if (_coreCUPLHint) then {
        systemChat "The snow script isn't available because CUP Core isn't loaded.";
    };

    if (_TFARHint) then {
        systemChat "The radio range script isn't available because TFAR isn't loaded.";
    };
};
