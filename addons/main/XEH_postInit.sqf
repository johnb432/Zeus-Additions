#include "script_component.hpp"

if (!hasInterface) exitWith {};

// Optionals
GVAR(ACEClipboardLoaded) = isClass (configFile >> "ACE_Extensions" >> "ace_clipboard");

// If for some reason this postInit loads before the ZEN one, make sure there is something
if (isNil "zen_common_aceMedical") then {
    zen_common_aceMedical = !isNil "ace_medical";
};

// Add mission counter only if player is curator; However, check every time the zeus interface is opened
["zen_curatorDisplayLoaded", {
    call FUNC(objectsCounterMissionEH);
}] call CBA_fnc_addEventHandler;

// Add drag bodies and JIP functions only if player is curator
["zen_curatorDisplayLoaded", {
    [_thisType, _thisId] call CBA_fnc_removeEventHandler;

    // Add the JIP functionality
    call FUNC(handleJIP);

    // Add Drag Bodies module
    if (zen_common_aceMedical && {!isNil "ace_medical_treatment"} && {!isNil "ace_dragging"}) then {
        #include "modules\addACEDragBodies.sqf"
    };
}] call CBA_fnc_addEventHandlerArgs;

// Add modules
#include "modules\behaviourAIModules.sqf"
#include "modules\carBomb.sqf"
#include "modules\changeChannelVisibility.sqf"
#include "modules\changeGrassRender.sqf"
#include "modules\configureDoors.sqf"
#include "modules\createResupply.sqf"
#include "modules\deleteObjectForced.sqf"
#include "modules\dogAttack.sqf"
#include "modules\gearScript.sqf"
#include "modules\missionEndModifier.sqf"
#include "modules\objectsCounterMission.sqf"
#include "modules\pauseTime.sqf"
#include "modules\placeMapMarker.sqf"
#include "modules\preventExplodingVehicle.sqf"
#include "modules\remoteControl.sqf"
#include "modules\removeGrenades.sqf"
#include "modules\setCaptive.sqf"
#include "modules\stormScript.sqf"
#include "modules\suicideBomber.sqf"
#include "modules\toggleConsciousnessForced.sqf"
#include "modules\trackUnitDeath.sqf"
#include "modules\unitParadrop.sqf"
#include "modules\unitParadropAction.sqf"

// Optionals
private _cfgPatches = configFile >> "CfgPatches";
private _notificationArray = ["[Zeus Additions]:"];

// Check if ACE Dragging is loaded
if (!isNil "ace_dragging") then {
    #include "modules\addACEDragAndCarry.sqf"

    if (zen_common_aceMedical && {!isNil "ace_medical_treatment"}) then {
        #include "modules\dragBodies.sqf"
    };
} else {
    if (GVAR(enableACEDragHint)) then {
        _notificationArray pushBack "The ACE drag and carry modules aren't available because ACE dragging isn't loaded.";
    };
};

// Check if TFAR is loaded
if (isClass (_cfgPatches >> "tfar_core") || {isClass (_cfgPatches >> "task_force_radio")}) then {
    #include "modules\changeRadioRange.sqf"
} else {
    if (GVAR(enableTFARHint)) then {
        _notificationArray pushBack "The radio range module isn't available because TFAR isn't loaded.";
    };
};

// Check if RHS AFRF is loaded
if (isClass (_cfgPatches >> "rhs_main_loadorder")) then {
    #include "modules\changeRHSAPS.sqf"
} else {
    if (GVAR(enableRHSHint)) then {
        _notificationArray pushBack "The RHS APS module isn't available because RHS AFRF isn't loaded.";
    };
};

// Check if ACE Medical is loaded
if (zen_common_aceMedical) then {
    #include "modules\createInjuries.sqf"

    // If KAT is loaded, don't load module
    if (isNil "kat_zeus") then {
        #include "modules\openMedicalMenu.sqf"
    };

    // Check if ACE Medical Treatment is loaded
    if (!isNil "ace_medical_treatment") then {
        #include "modules\createResupplyMedical.sqf"
    };
} else {
    if (GVAR(enableACEMedicalHint)) then {
        _notificationArray pushBack "Multiple ACE medical related functions aren't available because ACE medical isn't loaded.";
    };
};

// Check if ACE Cargo is loaded
if (!isNil "ace_cargo") then {
    #include "modules\unloadACECargo.sqf"
} else {
    if (GVAR(enableACECargoHint)) then {
        _notificationArray pushBack "The ACE unload cargo module isn't available because ACE cargo isn't loaded.";
    };
};
// Optionals finished

// Hint what is missing if wanted
if ((count _notificationArray) == 1) exitWith {};

{
    systemChat _x;
} forEach _notificationArray;
