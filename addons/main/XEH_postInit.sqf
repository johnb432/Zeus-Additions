#include "script_component.hpp"

private _blackList = [];

GVAR(isClibPresent) = isClass (configFile >> "CfgPatches" >> "CLib");

// Wait for FKFramework to update
/*
if (GVAR(isClibPresent) && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
    {
        _blackList append ((format ["FKF/CfgArsenalBlacklist/%1", _x]) call Clib_fnc_getSetting);
    } forEach ("FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings);
} else {*/
    _blackList = parseSimpleArray GVAR(blacklistSettings);
//};

GVAR(blacklist) = _blackList;

GVAR(magsTotal) = [];
private _temp = [GVAR(545x39),GVAR(762x39),GVAR(762x54R),GVAR(oddBLU),GVAR(Stanag556),GVAR(Misc556),GVAR(Belt556),GVAR(QBZ58KH65),GVAR(MX65),GVAR(All762),GVAR(Belt762),GVAR(12G),GVAR(PistolBLU),GVAR(PistolRED),GVAR(UGLBLU),GVAR(UGLRED),GVAR(MATBLU),GVAR(MATRED),GVAR(HATRED),GVAR(HATBLUAMMO),GVAR(AABLU),GVAR(AARED)];

{
    if (!isNil QUOTE(_x)) then {
        GVAR(magsTotal) pushBack (parseSimpleArray _x);
    } else {
        GVAR(magsTotal) pushBack (_temp select _forEachIndex);
    };
} forEach [GVAR(545x39Mags),GVAR(762x39Mags),GVAR(762x54RMags),GVAR(oddBluforMags),GVAR(556x45StanagMags),GVAR(556x45MiscMags),GVAR(556x45Belts),GVAR(58x4265x39Mags),GVAR(65x39Mags),GVAR(762x51Mags),GVAR(762x51Belts),GVAR(12Gauge),GVAR(BLUFORPistol),GVAR(REDFORPistol),GVAR(BLUFORUGL),GVAR(REDFORUGL),GVAR(BLUFORMAT),GVAR(REDFORMAT),GVAR(BLUFORHATAMMO),GVAR(REDFORHAT),GVAR(BLUFORAA),GVAR(REDFORAA)];

GVAR(weaponsTotal) = [];

private _temp2 = [GVAR(LATBLU),GVAR(LATRED),GVAR(HATBLU)];

{
    if (!isNil QUOTE(_x)) then {
        GVAR(weaponsTotal) pushBack (parseSimpleArray _x);
    } else {
        GVAR(weaponsTotal) pushBack (_temp2 select _forEachIndex);
    };
} forEach [GVAR(BLUFORLAT),GVAR(REDFORLAT),GVAR(BLUFORHAT)];

GVAR(weaponsTotal) pushBack ["UK3CB_BAF_Javelin_CLU"];

call FUNC(ammoResupply);
call FUNC(createInjuries);
call FUNC(dogAttack);
call FUNC(forceWakeUp);
call FUNC(gearScriptModules);
call FUNC(grassRender);
call FUNC(medicalResupply);
call FUNC(radioDistance);
