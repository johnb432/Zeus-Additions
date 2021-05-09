#include "script_component.hpp"

// Takes the FK blacklist if enabled and present
if (GVAR(blacklistFKEnable) && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
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

private _temp2 = [GVAR(LATBLU),GVAR(LATRED),GVAR(HATBLU)];

{
    GVAR(magsTotal) pushBack ([_temp select _forEachIndex, parseSimpleArray _x] select (isNil QUOTE(_x)));
} forEach [GVAR(BLUFORLAT),GVAR(REDFORLAT),GVAR(BLUFORHAT)];

GVAR(weaponsTotal) pushBack ["UK3CB_BAF_Javelin_CLU"];

call FUNC(ammoResupply);
call FUNC(behaviourAIModules);
call FUNC(createInjuries);
call FUNC(deathStare);
call FUNC(disableChannels);
call FUNC(dogAttack);
call FUNC(exitUnconsciousUnit);
call FUNC(forceDelete);
call FUNC(forceWakeUp);
call FUNC(gearScriptModules);
call FUNC(grassRender);
call FUNC(lockDoors);
call FUNC(makeInvincible);
call FUNC(medicalResupply);
call FUNC(moduleMedicalMenu);
call FUNC(pauseTime);
call FUNC(preventBlowUpVehicle);
call FUNC(radioDistance);
//call FUNC(snowScript);
call FUNC(unitParadrop);
