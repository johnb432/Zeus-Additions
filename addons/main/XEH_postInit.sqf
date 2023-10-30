#include "script_component.hpp"

// Macros don't like commas in strings
INFO_ZA(FORMAT_2(QUOTE(PostInit: didJIP: ARR_2(%1,Functions) sent: %2),didJIP,!isNil QGVAR(functionsSent)));

// Execute init for everyone and JIP if init hasn't been run yet
if (!isServer && {isNil QGVAR(functionsSent)}) then {
    SEND_MP(init);
    remoteExecCall [QFUNC(init), 0, QGVAR(initJIPId)];
};

if (!hasInterface) exitWith {};

// Add mission counter only if player is curator; However, check every time the zeus interface is opened
["zen_curatorDisplayLoaded", {
    // Wait until CBA settings have been initialised
    [FUNC(objectsCounterMissionEH), []] call zen_common_fnc_runAfterSettingsInit;
}] call CBA_fnc_addEventHandler;

// Add drag bodies and JIP functions only if player is curator
["zen_curatorDisplayLoaded", {
    [_thisType, _thisId] call CBA_fnc_removeEventHandler;

    // Add the JIP & building destruction functionality; If CBA settings haven't been initialised yet, just let CBA settings handle reason changing
    if (GETMVAR("CBA_settings_ready",false)) then {
        private _uid = getPlayerUID player;

        [QGVAR(JIP), _uid, GVAR(enableJIP), QFUNC(handleJIP)] call FUNC(changeReason);
        [QGVAR(buildingDestruction), _uid, GVAR(enableBuildingDestructionHandling), QFUNC(handleBuildingDestruction)] call FUNC(changeReason);
    };

    // Add Drag Bodies module
    if (zen_common_aceMedical && {!isNil "ace_medical_treatment"} && {!isNil "ace_dragging"}) then {
        #include "modules\module_dragBodies.sqf"
    };
}] call CBA_fnc_addEventHandlerArgs;

// Add modules
#include "modules\module_behaviourCrew.sqf"
#include "modules\module_captive.sqf"
#include "modules\module_carBomb.sqf"
#include "modules\module_channelVisibility.sqf"
#include "modules\module_configureDoors.sqf"
#include "modules\module_createResupply.sqf"
#include "modules\module_deleteObjectForced.sqf"
#include "modules\module_deleteZeus.sqf"
#include "modules\module_dogAttack.sqf"
#include "modules\module_dustStorm.sqf"
#include "modules\module_gearScript.sqf"
#include "modules\module_grassRender.sqf"
#include "modules\module_mapMarkers.sqf"
#include "modules\module_missionEndModifier.sqf"
#include "modules\module_missionObjectCounter.sqf"
#include "modules\module_pauseTime.sqf"
#include "modules\module_removeGrenades.sqf"
#include "modules\module_suicideBomber.sqf"
#include "modules\module_switchUnit.sqf"
#include "modules\module_toggleConsciousnessForced.sqf"
#include "modules\module_trackUnitDeath.sqf"
#include "modules\module_unitParadrop.sqf"
#include "modules\module_unitParadropAction.sqf"
#include "modules\module_vehicleExplosionPrevention.sqf"

// Optionals
private _cfgPatches = configFile >> "CfgPatches";
GVAR(ACEClipboardLoaded) = isClass (configFile >> "ACE_Extensions" >> "ace_clipboard");

// Check if ACE Cargo is loaded
if (!isNil "ace_cargo") then {
    #include "modules\module_unloadACECargo.sqf"
};

// Check if ACE Dragging is loaded
if (!isNil "ace_dragging") then {
    #include "modules\module_dragAndCarry.sqf"

    if (zen_common_aceMedical && {!isNil "ace_medical_treatment"}) then {
        #include "modules\functionality_dragBodies.sqf"
    };
};

// Check if ACE Medical is loaded
if (zen_common_aceMedical) then {
    #include "modules\module_createInjuries.sqf"

    // If KAT is not loaded, load medical menu module
    if (isNil "kat_zeus") then {
        #include "modules\module_medicalMenu.sqf"
    };

    // Check if ACE Medical Treatment is loaded
    if (!isNil "ace_medical_treatment") then {
        #include "modules\module_createResupplyMedical.sqf"
    };
};

// Check if TFAR is loaded
if (isClass (_cfgPatches >> "tfar_core") || {isClass (_cfgPatches >> "task_force_radio")}) then {
    #include "modules\module_tfarRadioRange.sqf"
};

// Check if RHS AFRF is loaded
if (isClass (_cfgPatches >> "rhs_main_loadorder")) then {
    #include "modules\module_rhsAps.sqf"
};
// Optionals finished

// Hint what is missing once CBA settings have been loaded
["CBA_settingsInitialized", {
    private _cfgPatches = configFile >> "CfgPatches";
    private _notificationArray = ["[Zeus Additions]:"];

    // Check if ACE Cargo is loaded
    if (isNil "ace_cargo") then {
        private _string = LLSTRING(aceCargoMissing);
        INFO_ZA(_string);

        if (GVAR(enableACECargoHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Check if ACE Dragging is loaded
    if (isNil "ace_dragging") then {
        private _string = LLSTRING(aceDraggingMissing);
        INFO_ZA(_string);

        if (GVAR(enableACEDragHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Check if ACE Medical is loaded
    if (!zen_common_aceMedical) then {
        private _string = LLSTRING(aceMedicalMissing);
        INFO_ZA(_string);

        if (GVAR(enableACEMedicalHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Check if TFAR is loaded
    if (!isClass (_cfgPatches >> "tfar_core") && {!isClass (_cfgPatches >> "task_force_radio")}) then {
        private _string = LLSTRING(tfarMissing);
        INFO_ZA(_string);

        if (GVAR(enableTFARHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Check if RHS AFRF is loaded
    if (!isClass (_cfgPatches >> "rhs_main_loadorder")) then {
        private _string = LLSTRING(rhsMissing);
        INFO_ZA(_string);

        if (GVAR(enableRHSHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Hint what is missing if wanted
    if ((count _notificationArray) == 1) exitWith {};

    {
        systemChat _x;
    } forEach _notificationArray;
}] call CBA_fnc_addEventHandler;
