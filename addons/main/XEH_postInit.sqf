#include "script_component.hpp"

if (!hasInterface) exitWith {};

// Optionals
GVAR(ACEDraggingLoaded) = isClass (configFile >> "CfgPatches" >> "ace_dragging");
GVAR(ACEClipboardLoaded) = isClass (configFile >> "ACE_Extensions" >> "ace_clipboard");

// If for some reason this postInit loads before the ZEN one, make sure there is something
if (isNil "zen_common_aceMedical") then {
    zen_common_aceMedical = isClass (configFile >> "CfgPatches" >> "ace_medical");
};

if (isNil "zen_common_aceMedicalTreatment") then {
    zen_common_aceMedicalTreatment = isClass (configFile >> "CfgPatches" >> "ace_medical_treatment");
};

// Add counter and JIP functions only if player is curator
GVAR(registeredID) = ["zen_curatorDisplayLoaded", {
    ["zen_curatorDisplayLoaded", GVAR(registeredID)] call CBA_fnc_removeEventHandler;
    GVAR(registeredID) = nil;

    // Add the JIP functionality
    call FUNC(handleJIP);

    // Add mission object counter
    if (GVAR(enableMissionCounter)) then {
        call FUNC(objectsCounterMissionEH);
    };

    // Add Drag Bodies module
    if (zen_common_aceMedical && {zen_common_aceMedicalTreatment} && {GVAR(ACEDraggingLoaded)}) then {
        #include "modules\addACEDragBodies.sqf"
        #include "modules\dragBodies.sqf"
    };
}] call CBA_fnc_addEventHandler;

// Add modules
#include "modules\behaviourAIModules.sqf"
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
#include "modules\toggleConsciousnessForced.sqf"
#include "modules\trackUnitDeath.sqf"
#include "modules\unitParadrop.sqf"
#include "modules\unitParadropAction.sqf"

private _notificationArray = ["[Zeus Additions]:"];

// Check if ACE Dragging is loaded
if (GVAR(ACEDraggingLoaded)) then {
    #include "modules\addACEDragAndCarry.sqf"
} else {
    if (GVAR(enableACEDragHint)) then {
        _notificationArray pushBack "The ACE drag and carry modules aren't available because ACE dragging isn't loaded.";
    };
};

// Check if TFAR is loaded
if (isClass (configFile >> "CfgPatches" >> "tfar_core") || {isClass (configFile >> "CfgPatches" >> "task_force_radio")}) then {
    #include "modules\changeRadioRange.sqf"
} else {
    if (GVAR(enableTFARHint)) then {
        _notificationArray pushBack "The radio range module isn't available because TFAR isn't loaded.";
    };
};

// Check if RHS AFRF is loaded
if (isClass (configFile >> "CfgPatches" >> "rhs_main_loadorder")) then {
    #include "modules\changeRHSAPS.sqf"
} else {
    if (GVAR(enableRHSHint)) then {
        _notificationArray pushBack "The RHS APS module isn't available because RHS AFRF isn't loaded.";
    };
};

// Check if ACE Medical is loaded
if (zen_common_aceMedical) then {
    #include "modules\createInjuries.sqf"
    #include "modules\openMedicalMenu.sqf"

    // Check if ACE Interaction is loaded
    if (isClass (configFile >> "CfgPatches" >> "ace_interact_menu")) then {
        #include "modules\deathStare.sqf"
    };

    // Check if ACE Medical Treatment is loaded
    if (zen_common_aceMedicalTreatment) then {
        #include "modules\createResupplyMedical.sqf"
    };
} else {
    if (GVAR(enableACEMedicalHint)) then {
        _notificationArray pushBack "Multiple ACE medical related functions aren't available because ACE medical isn't loaded.";
    };
};

// Check if CUP is loaded
if (isClass (configFile >> "CfgPatches" >> "CUP_Worlds")) then {
    #include "modules\stormScript.sqf"
} else {
    if (GVAR(enableSnowScriptHint)) then {
        _notificationArray pushBack "The storm script module isn't available because CUP Core isn't loaded.";
    };
};

// Check if ACE Cargo is loaded
if (isClass (configFile >> "CfgPatches" >> "ace_cargo")) then {
    #include "modules\unloadACECargo.sqf"
} else {
    if (GVAR(enableACECargoHint)) then {
        _notificationArray pushBack "The ACE unload cargo module isn't available because ACE cargo isn't loaded.";
    };
};
// Optionals finished

// Hint what is missing if wanted
if ((count _notificationArray) isEqualTo 1) exitWith {};

{
    systemChat _x;
} forEach _notificationArray;
