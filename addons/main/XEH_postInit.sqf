#include "script_component.hpp"

if (!hasInterface) exitWith {};

private _cfgPatches = configFile >> "CfgPatches";

// Optionals
GVAR(ACEDraggingLoaded) = isClass (_cfgPatches >> "ace_dragging");
GVAR(ACEClipboardLoaded) = isClass (configFile >> "ACE_Extensions" >> "ace_clipboard");

// If for some reason this postInit loads before the ZEN one, make sure there is something
if (isNil "zen_common_aceMedical") then {
    zen_common_aceMedical = isClass (_cfgPatches >> "ace_medical");
};

if (isNil "zen_common_aceMedicalTreatment") then {
    zen_common_aceMedicalTreatment = isClass (_cfgPatches >> "ace_medical_treatment");
};

// Add counter and JIP functions only if player is curator
["zen_curatorDisplayLoaded", {
    [_thisType, _thisId] call CBA_fnc_removeEventHandler;

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
}] call CBA_fnc_addEventHandlerArgs;

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
#include "modules\setCaptive.sqf"
#include "modules\stormScript.sqf"
#include "modules\toggleConsciousnessForced.sqf"
#include "modules\trackUnitDeath.sqf"
#include "modules\unitParadrop.sqf"
#include "modules\unitParadropAction.sqf"

// Optionals
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
    #include "modules\openMedicalMenu.sqf"

    // Check if ACE Medical Treatment is loaded
    if (zen_common_aceMedicalTreatment) then {
        #include "modules\createResupplyMedical.sqf"
    };
} else {
    if (GVAR(enableACEMedicalHint)) then {
        _notificationArray pushBack "Multiple ACE medical related functions aren't available because ACE medical isn't loaded.";
    };
};

// Check if ACE Cargo is loaded
if (isClass (_cfgPatches >> "ace_cargo")) then {
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
