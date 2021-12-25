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

// Get ammunition list
private _temp = [GVAR(LATBLU),GVAR(LATRED),GVAR(MATBLU),GVAR(MATRED),GVAR(HATBLU),GVAR(HATRED),GVAR(AABLU),GVAR(AARED)];

GVAR(magsTotal) = [GVAR(LATBLU_mags),GVAR(LATRED_mags),GVAR(MATBLU_mags),GVAR(MATRED_mags),GVAR(HATBLU),GVAR(HATRED_mags),GVAR(AABLU_mags),GVAR(AARED_mags)] apply {
    if (!isNil QUOTE(_x)) then {
        if (_x isEqualType "") then {
            parseSimpleArray _x;
        } else {
            if (_x isEqualType []) then {
                _x;
            };
        };
    } else {
        _temp select _forEachIndex;
    };
};

GVAR(ACEDraggingLoaded) = isClass (configFile >> "CfgPatches" >> "ace_dragging");
GVAR(ACEMedicalLoaded) = isClass (configFile >> "CfgPatches" >> "ace_medical");

// Add modules
call FUNC(addACEDragAndCarry);
call FUNC(behaviourAIModules);
call FUNC(changeChannelVisibility);
call FUNC(changeGrassRender);
call FUNC(changeRadioRange);
call FUNC(changeRHSAPS);
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
call FUNC(trackUnitDeath);
call FUNC(unitParadrop);
call FUNC(unitParadropAction);
call FUNC(unloadACECargo);

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

    hint "[Zeus Additions]: No Curator Object was found.";
}] call CBA_fnc_waitUntilAndExecute;

// Hint what is missing if wanted
private _coreCUPLHint = GVAR(enableSnowScriptHint) && {!isClass (configFile >> "CfgPatches" >> "CUP_Worlds")};
private _TFARHint = GVAR(enableTFARHint) && {!isClass (configFile >> "CfgPatches" >> "tfar_core")} && {!isClass (configFile >> "CfgPatches" >> "task_force_radio")};
private _RHSHint =  GVAR(enableRHSHint) && {!isClass (configFile >> "CfgPatches" >> "rhs_main_loadorder")};
private _ACECargoHint = GVAR(enableACECargoHint) && {!isClass (configFile >> "CfgPatches" >> "ace_cargo")};
private _ACEDragHint = GVAR(enableACEDragHint) && {!GVAR(ACEDraggingLoaded)};
private _ACEMedicalHint = GVAR(enableACEMedicalHint) && {!GVAR(ACEMedicalLoaded)};

if (_coreCUPLHint || {_TFARHint} || {_RHSHint} || {_ACECargoHint} || _ACEDragHint) then {
    systemChat "[Zeus Additions]:";

    if (_coreCUPLHint) then {
        systemChat "The snow script module isn't available because CUP Core isn't loaded.";
    };

    if (_TFARHint) then {
        systemChat "The radio range module isn't available because TFAR isn't loaded.";
    };

    if (_RHSHint) then {
        systemChat "The RHS APS module isn't available because RHS AFRF isn't loaded.";
    };

    if (_ACECargoHint) then {
        systemChat "The ACE unload cargo module isn't available because ACE cargo isn't loaded.";
    };

    if (_ACEDragHint) then {
        systemChat "The ACE drag and carry module isn't available because ACE dragging isn't loaded.";
    };

    if (_ACEMedicalHint) then {
        systemChat "Multiple ACE medical related functions aren't available because ACE medical isn't loaded.";
    };
};
